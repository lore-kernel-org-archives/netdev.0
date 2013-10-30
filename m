From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 5/5] net: sctp: fix and consolidate SCTP checksumming
 code
Date: Wed, 30 Oct 2013 10:29:23 -0400
Message-ID: <527117C3.2080306@gmail.com>
References: <1383130252-1515-1-git-send-email-dborkman@redhat.com> <1383130252-1515-6-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:32990 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566Ab3J3O30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 10:29:26 -0400
In-Reply-To: <1383130252-1515-6-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2013 06:50 AM, Daniel Borkmann wrote:
> This fixes an outstanding bug found through IPVS, where SCTP packets
> with skb->data_len > 0 (non-linearized) and empty frag_list, but data
> accumulated in frags[] member, are forwarded with incorrect checksum
> letting SCTP initial handshake fail on some systems. Linearizing each
> SCTP skb in IPVS to prevent that would not be a good solution as
> this leads to an additional and unnecessary performance penalty on
> the load-balancer itself for no good reason (as we actually only want
> to update the checksum, and can do that in a different/better way
> presented here).
>
> The actual problem is elsewhere, namely, that SCTP's checksumming
> in sctp_compute_cksum() does not take frags[] into account like
> skb_checksum() does. So while we are fixing this up, we better reuse
> the existing code that we have anyway in __skb_checksum() and use it
> for walking through the data doing checksumming. This will not only
> fix this issue, but also consolidates some SCTP code with core
> sk_buff code, bringing it closer together and removing respectively
> avoiding reimplementation of skb_checksum() for no good reason.
>
> As crc32c() can use hardware implementation within the crypto layer,
> we leave that intact (it wraps around / falls back to e.g. slice-by-8
> algorithm in __crc32c_le() otherwise); plus use the __crc32c_le_combine()
> combinator for crc32c blocks.
>
> Also, we remove all other SCTP checksumming code, so that we only
> have to use sctp_compute_cksum() from now on; for doing that, we need
> to transform SCTP checkumming in output path slightly, and can leave
> the rest intact.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>


Daniel

Here is a follow-on idea that might help even more.
What if we put a pointer to skb_checksum_ops() in the skb
somewhere (I was thinking of skb_shinfo).  Then
skb_checksum can simply use the data from there.  This would
allow us to get rid of all the special cases in SCTP that do
checksumming.  We can just set it to partial, set up the right
fields and let HW or SW always do the right thing.

-vlad

> ---
>   include/net/sctp/checksum.h | 56 +++++++++++++++------------------------------
>   net/sctp/output.c           |  9 +-------
>   2 files changed, 20 insertions(+), 45 deletions(-)
>
> diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
> index 259924d..6bd44fe 100644
> --- a/include/net/sctp/checksum.h
> +++ b/include/net/sctp/checksum.h
> @@ -42,56 +42,38 @@
>   #include <linux/types.h>
>   #include <net/sctp/sctp.h>
>   #include <linux/crc32c.h>
> +#include <linux/crc32.h>
>
> -static inline __u32 sctp_crc32c(__u32 crc, u8 *buffer, u16 length)
> +static inline __wsum sctp_csum_update(const void *buff, int len, __wsum sum)
>   {
> -	return crc32c(crc, buffer, length);
> -}
> -
> -static inline __u32 sctp_start_cksum(__u8 *buffer, __u16 length)
> -{
> -	__u32 crc = ~(__u32)0;
> -	__u8  zero[sizeof(__u32)] = {0};
> -
> -	/* Optimize this routine to be SCTP specific, knowing how
> -	 * to skip the checksum field of the SCTP header.
> +	/* This uses the crypto implementation of crc32c, which is either
> +	 * implemented w/ hardware support or resolves to __crc32c_le().
>   	 */
> -
> -	/* Calculate CRC up to the checksum. */
> -	crc = sctp_crc32c(crc, buffer, sizeof(struct sctphdr) - sizeof(__u32));
> -
> -	/* Skip checksum field of the header. */
> -	crc = sctp_crc32c(crc, zero, sizeof(__u32));
> -
> -	/* Calculate the rest of the CRC. */
> -	crc = sctp_crc32c(crc, &buffer[sizeof(struct sctphdr)],
> -			    length - sizeof(struct sctphdr));
> -	return crc;
> -}
> -
> -static inline __u32 sctp_update_cksum(__u8 *buffer, __u16 length, __u32 crc32)
> -{
> -	return sctp_crc32c(crc32, buffer, length);
> +	return crc32c(sum, buff, len);
>   }
>
> -static inline __le32 sctp_end_cksum(__u32 crc32)
> +static inline __wsum sctp_csum_combine(__wsum csum, __wsum csum2,
> +				       int offset, int len)
>   {
> -	return cpu_to_le32(~crc32);
> +	return __crc32c_le_combine(csum, csum2, len);
>   }
>
> -/* Calculate the CRC32C checksum of an SCTP packet.  */
>   static inline __le32 sctp_compute_cksum(const struct sk_buff *skb,
>   					unsigned int offset)
>   {
> -	const struct sk_buff *iter;
> +	struct sctphdr *sh = sctp_hdr(skb);
> +        __le32 ret, old = sh->checksum;
> +	const struct skb_checksum_ops ops = {
> +		.update  = sctp_csum_update,
> +		.combine = sctp_csum_combine,
> +	};
>
> -	__u32 crc32 = sctp_start_cksum(skb->data + offset,
> -				       skb_headlen(skb) - offset);
> -	skb_walk_frags(skb, iter)
> -		crc32 = sctp_update_cksum((__u8 *) iter->data,
> -					  skb_headlen(iter), crc32);
> +	sh->checksum = 0;
> +	ret = cpu_to_le32(~__skb_checksum(skb, offset, skb->len - offset,
> +					  ~(__u32)0, &ops));
> +	sh->checksum = old;
>
> -	return sctp_end_cksum(crc32);
> +	return ret;
>   }
>
>   #endif /* __sctp_checksum_h__ */
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 3191373..e650978 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -390,7 +390,6 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>   	__u8 has_data = 0;
>   	struct dst_entry *dst = tp->dst;
>   	unsigned char *auth = NULL;	/* pointer to auth in skb data */
> -	__u32 cksum_buf_len = sizeof(struct sctphdr);
>
>   	pr_debug("%s: packet:%p\n", __func__, packet);
>
> @@ -493,7 +492,6 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>   		if (chunk == packet->auth)
>   			auth = skb_tail_pointer(nskb);
>
> -		cksum_buf_len += chunk->skb->len;
>   		memcpy(skb_put(nskb, chunk->skb->len),
>   			       chunk->skb->data, chunk->skb->len);
>
> @@ -538,12 +536,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>   	if (!sctp_checksum_disable) {
>   		if (!(dst->dev->features & NETIF_F_SCTP_CSUM) ||
>   		    (dst_xfrm(dst) != NULL) || packet->ipfragok) {
> -			__u32 crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
> -
> -			/* 3) Put the resultant value into the checksum field in the
> -			 *    common header, and leave the rest of the bits unchanged.
> -			 */
> -			sh->checksum = sctp_end_cksum(crc32);
> +			sh->checksum = sctp_compute_cksum(nskb, 0);
>   		} else {
>   			/* no need to seed pseudo checksum for SCTP */
>   			nskb->ip_summed = CHECKSUM_PARTIAL;
>
