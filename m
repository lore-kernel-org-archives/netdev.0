From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] arp: always override existing neigh entries with
 gratuitous ARP
Date: Thu, 18 May 2017 02:25:23 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705180123060.2283@ja.home.ssi.bg>
References: <cover.1495056542.git.ihrachys@redhat.com> <8d14e8bd5c4d988f073eb14307bbb8491896414c.1495056542.git.ihrachys@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ihar Hrachyshka <ihrachys@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34166 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752375AbdEQXZj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 19:25:39 -0400
In-Reply-To: <8d14e8bd5c4d988f073eb14307bbb8491896414c.1495056542.git.ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 17 May 2017, Ihar Hrachyshka wrote:

> Currently, when arp_accept is 1, we always override existing neigh
> entries with incoming gratuitous ARP replies. Otherwise, we override
> them only if new replies satisfy _locktime_ conditional (packets arrive
> not earlier than _locktime_ seconds since the last update to the neigh
> entry).
> 
> The idea behind locktime is to pick the very first (=> close) reply
> received in a unicast burst when ARP proxies are used. This helps to
> avoid ARP thrashing where Linux would switch back and forth from one
> proxy to another.
> 
> This logic has nothing to do with gratuitous ARP replies that are
> generally not aligned in time when multiple IP address carriers send
> them into network.
> 
> This patch enforces overriding of existing neigh entries by all incoming
> gratuitous ARP packets, irrespective of their time of arrival. This will
> make the kernel honour all incoming gratuitous ARP packets.
> 
> Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>
> ---
>  net/ipv4/arp.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 3f06201..97ea9d8 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -858,16 +858,16 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
>  
>  	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
>  
> -	if (IN_DEV_ARP_ACCEPT(in_dev)) {
> -		unsigned int addr_type = inet_addr_type_dev_table(net, dev, sip);
> -
> -		/* Unsolicited ARP is not accepted by default.

	Above line is not related to GARP. I think, it should
stay at its old place, see below. Also, in first patch, line
should be:

	/* GARP _replies_ also require target hwaddr to be
	 * the same as source.
	 */

> -		   It is possible, that this option should be enabled for some
> -		   devices (strip is candidate)
> -		 */
> +	if (n || IN_DEV_ARP_ACCEPT(in_dev)) {
> +		addr_type = inet_addr_type_dev_table(net, dev, sip);
>  		is_garp = arp_is_garp(dev, addr_type, arp->ar_op,
>  				      sip, tip, sha, tha);

	There was something I didn't liked in the old code:
inet_addr_type_dev_table() can be slow and we should call it
only when needed. With some rearranging we can fix it, for
example:

1. arp_is_garp(net,..., int *addr_type) should use:

	bool is_garp = tip == sip;

	...
	if (is_garp) {
		*addr_type = inet_addr_type_dev_table(net, dev, sip);
		if (*addr_type != RTN_UNICAST)
			is_garp = false;
	}
	return is_garp;

> +	}
>  
> +	if (IN_DEV_ARP_ACCEPT(in_dev)) {
> +		/* It is possible, that this option should be enabled for some
> +		 * devices (strip is candidate)
> +		 */
>  		if (!n &&
>  		    ((arp->ar_op == htons(ARPOP_REPLY)  &&
>  				addr_type == RTN_UNICAST) || is_garp))
> 

2. fill addr_type and do is_garp check first:

	if (n || IN_DEV_ARP_ACCEPT(in_dev)) {
		addr_type = -1;
                is_garp = arp_is_garp(net, dev, addr_type, arp->ar_op,
                                      sip, tip, sha, tha, &addr_type);
	}


	/* Unsolicited ARP is not accepted by default.
	 * It is possible, that this option should be enabled for some
	 * devices (strip is candidate)
	 */
	if (!n && IN_DEV_ARP_ACCEPT(in_dev) &&
	    (is_garp ||
	     (arp->ar_op == htons(ARPOP_REPLY) &&
	      (addr_type == RTN_UNICAST ||
	       (addr_type < 0 &&
	        inet_addr_type_dev_table(net, dev, sip) == RTN_UNICAST)))))
		n = __neigh_lookup(&arp_tbl, &sip, dev, 1);

	As result, we will avoid the unneeded
inet_addr_type_dev_table() call for ARP requests (non-GARP)
which are too common to see. May be there is another way
to make this code more nice...

Regards
