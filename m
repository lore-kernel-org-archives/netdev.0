From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v2 14/18] calipso: Allow the lsm to label the skbuff directly.
Date: Sun, 07 Feb 2016 14:56:15 -0500
Message-ID: <3481418.JCgvbfSAcg@sifl>
References: <1452246774-13241-15-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Huw Davies <huw@codeweavers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754805AbcBGT4R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Feb 2016 14:56:17 -0500
In-Reply-To: <1452246774-13241-15-git-send-email-huw@codeweavers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, January 08, 2016 09:52:50 AM Huw Davies wrote:
> In some cases, the lsm needs to add the label to the skbuff directly.
> A NF_INET_LOCAL_OUT IPv6 hook is added to selinux to match the IPv4
> behaviour.  This allows selinux to label the skbuffs that it requires.
> 
> Signed-off-by: Huw Davies <huw@codeweavers.com>

...

> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 5f9c252..71b5045 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -920,7 +920,7 @@ enum {
>  int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset, int
> target, unsigned short *fragoff, int *fragflg);
> 
> -int ipv6_find_tlv(struct sk_buff *skb, int offset, int type);
> +int ipv6_find_tlv(const struct sk_buff *skb, int offset, int type);

It probably does make sense to constify the skb argument, but you should do 
that in a separate patch.

>  struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
>  				const struct ipv6_txoptions *opt,
> diff --git a/include/net/netlabel.h b/include/net/netlabel.h
> index a2408c3..0697ba2 100644
> --- a/include/net/netlabel.h
> +++ b/include/net/netlabel.h
> @@ -231,6 +231,10 @@ struct netlbl_lsm_secattr {
>   * @sock_delattr: remove the socket's attr
>   * @req_setattr: set the req socket's attr
>   * @req_delattr: remove the req socket's attr
> + * @optptr: find option in packet

How about "skbuff_optptr" instead?

> + * @getattr: retrieve attr from memory block

How about "opt_getattr"?

> + * @skbuff_setattr: set the skbuff's attr
> + * @skbuff_delattr: remove the skbuff's attr

...

> +/**
> + * calipso_skbuff_setattr - Set the CALIPSO option on a packet
> + * @skb: the packet
> + * @doi_def: the CALIPSO DOI to use
> + * @secattr: the security attributes
> + *
> + * Description:
> + * Set the CALIPSO option on the given packet based on the security
> attributes. + * Returns a pointer to the IP header on success and NULL on
> failure. + *
> + */
> +static int calipso_skbuff_setattr(struct sk_buff *skb,
> +				  const struct calipso_doi *doi_def,
> +				  const struct netlbl_lsm_secattr *secattr)
> +{
> +	int ret_val;
> +	struct ipv6hdr *ip6_hdr;
> +	struct ipv6_opt_hdr *hop;
> +	unsigned char buf[CALIPSO_MAX_BUFFER];
> +	int len_delta;
> +	unsigned int start, end, next_opt, pad;
> +
> +	ip6_hdr = ipv6_hdr(skb);
> +	if (ip6_hdr->nexthdr == NEXTHDR_HOP) {
> +		hop = (struct ipv6_opt_hdr *)(ip6_hdr + 1);
> +		ret_val = calipso_opt_find(hop, &start, &end);
> +		if (ret_val && ret_val != -ENOENT)
> +			return ret_val;
> +		if (end != ipv6_optlen(hop))
> +			next_opt = end;
> +		else
> +			next_opt = 0;
> +		len_delta = -(int)end;
> +	} else {
> +		start = 0;
> +		next_opt = 0;
> +		len_delta = 0;
> +	}
> +
> +	memset(buf, 0, sizeof(buf));
> +	ret_val = calipso_genopt(buf, start & 3, sizeof(buf), doi_def, secattr);
> +	if (ret_val < 0)
> +		return ret_val;
> +
> +	end = start + ret_val;
> +
> +	if (WARN_ON_ONCE(end & 3))
> +		return -EINVAL;

See my earlier comments about the use of WARN_ON_ONCE().

> +	pad = ((end & 7) + (next_opt & 7)) & 7;
> +	len_delta += end + pad;
> +
> +	if (WARN_ON_ONCE(len_delta & 7))
> +		return -EINVAL;

Same.

> +	ret_val = skb_cow(skb, skb_headroom(skb) + len_delta);
> +	if (ret_val < 0)
> +		return ret_val;
> +
> +	if (len_delta) {
> +		if (len_delta > 0)
> +			skb_push(skb, len_delta);
> +		else
> +			skb_pull(skb, -len_delta);
> +		memmove((char *)ip6_hdr - len_delta, ip6_hdr,
> +			sizeof(*ip6_hdr) + start);
> +		skb_reset_network_header(skb);
> +		ip6_hdr = ipv6_hdr(skb);
> +	}

-- 
paul moore
security @ redhat
