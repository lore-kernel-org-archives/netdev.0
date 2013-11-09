From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2 net-next] openvswitch: Use skb_zerocopy() for upcall
Date: Sat, 9 Nov 2013 22:02:29 +0000
Message-ID: <1384034549.3802.41.camel@bwh-desktop.uk.level5networks.com>
References: <cover.1383901577.git.tgraf@suug.ch>
	 <63f4476190ef4044f7c09b225b4e93cd929bf0be.1383901577.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <jesse@nicira.com>, <davem@davemloft.net>, <dev@openvswitch.org>,
	<netdev@vger.kernel.org>, <eric.dumazet@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41838 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758015Ab3KIWCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 17:02:33 -0500
In-Reply-To: <63f4476190ef4044f7c09b225b4e93cd929bf0be.1383901577.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 10:15 +0100, Thomas Graf wrote:
> Use of skb_zerocopy() avoids the expensive call to memcpy() when
> copying the packet data into the Netlink skb. Completes checksum
> through skb_checksum_help() if needed.
> 
> Netlink messaged must be properly padded and aligned to meet
> sanity checks of the user space counterpart.
> 
> Cost of memcpy is significantly reduced from:
> +   7.48%       vhost-8471  [k] memcpy
> +   5.57%     ovs-vswitchd  [k] memcpy
> +   2.81%       vhost-8471  [k] csum_partial_copy_generic
> 
> to:
> +   5.72%     ovs-vswitchd  [k] memcpy
> +   3.32%       vhost-5153  [k] memcpy
> +   0.68%       vhost-5153  [k] skb_zerocopy
> 
> (megaflows disabled)
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  net/openvswitch/datapath.c | 52 +++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 45 insertions(+), 7 deletions(-)
> 
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 1408adc..3f170e3 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
[...]
> @@ -441,13 +449,43 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
>  			  nla_len(upcall_info->userdata),
>  			  nla_data(upcall_info->userdata));
>  
> -	nla = __nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, skb->len);
> +	/* Only reserve room for attribute header, packet data is added
> +	 * in skb_zerocopy() */
> +	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0)))
> +		goto out;
> +	nla->nla_len = nla_attr_size(skb->len);
>  
> -	skb_copy_and_csum_dev(skb, nla_data(nla));
> +	skb_zerocopy(user_skb, skb, skb->len, hlen);
>  
> -	genlmsg_end(user_skb, upcall);
> -	err = genlmsg_unicast(net, user_skb, upcall_info->portid);
> +	/* OVS user space expects the size of the message to be aligned to
> +	 * NLA_ALIGNTO. Aligning nlmsg_len is not enough, the actual bytes
> +	 * read must match nlmsg_len.
> +	 */
> +	plen = NLA_ALIGN(user_skb->len) - user_skb->len;
> +	if (plen > 0) {
> +		int nr_frags = skb_shinfo(user_skb)->nr_frags;
> +
> +		if (nr_frags) {
> +			skb_frag_t *frag;
> +
> +			frag = &skb_shinfo(user_skb)->frags[nr_frags -1];
> +			skb_frag_size_add(frag, plen);

It looks like this is effectively padding with whatever happens to
follow the original packet content.  This could result in a small
information leak.  If the fragment has non-zero offset and already
extends to the end of a page, this could result in a segfault as the
next page may be unmapped.

Perhaps you could add the padding as an extra fragment pointing to a
preallocated zero page.  If the skb already has the maximum number of
fragments, you would have to copy the last fragment in order to add
padding.

> +			BUG_ON(frag->size > PAGE_SIZE);
[...]

I'm not sure that's a reasonable assumption either.  We certainly allow
fragments to be larger than PAGE_SIZE in the transmit path.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
