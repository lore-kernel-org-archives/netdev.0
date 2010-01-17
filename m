From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] ipv4: support for request type gratuitous ARP
Date: Sun, 17 Jan 2010 15:45:45 +0200 (EET)
Message-ID: <Pine.LNX.4.58.1001171310420.2769@u.domain.uli>
References: <20100110.132105.179935794.davem@davemloft.net>
 <1263680334-1770-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Laurent Chavey <chavey@google.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:47397 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752258Ab0AQNnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jan 2010 08:43:06 -0500
In-Reply-To: <1263680334-1770-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 17 Jan 2010, Octavian Purdila wrote:

> Even though we currently support response type gratuitous ARP
> [response type, source mac, dest mac, source IP, source IP] we do not
> support the request type [request type, source mac, ff:ff:ff:ff:ff:ff,
> source IP, source IP].
> 
> RFC2002 says:
> 
>      In either case, for a gratuitous ARP, the ARP packet MUST be
>      transmitted as a local broadcast packet on the local link.  As
>      specified in [16], any node receiving any ARP packet (Request or
>      Reply) MUST update its local ARP cache with the Sender Protocol
>      and Hardware Addresses in the ARP packet, if the receiving node
>      has an entry for that IP address already in its ARP cache.  This
>      requirement in the ARP protocol applies even for ARP Request
>      packets, and for ARP Reply packets that do not match any ARP
>      Request transmitted by the receiving node [16].
> 
> This patch adds support for request type gratuitous ARP, but due to
> security reasons the ARP table is updated only if the per device
> ARP_ACCEPT option is enabled.

	May be I'm missing something but the description and
the changed code do not match. You claim this patch now supports
dest mac ff:ff:ff:ff:ff:ff while without the patch the
'skb->pkt_type != PACKET_HOST' check usually updates the
existing entry with state NUD_STALE (neigh_update). What
exactly is not handled correctly?

	I think, the existing entry should be updated
properly even without the patch, when sip=tip. May be
there is unwanted ARP reply? It is not clear from this email. Can
you give example why we need to override ip_route_input? What is
the case that there is existing entry for sip that we want
to update but for some reason we do not like ip_route_input
result and entry is not updated? I don't think, ip_route_input
will do something different when sip=tip=unicast address.
This is not much different from the case when tip is IP
from the same subnet as sip. There are only 2 'goto out' but
both places update the entry depending on some policy.

	Also, you call neigh_event_ns which creates new entry while
RFC talks about updating existing entry: "if the receiving node
has an entry for that IP address already in its ARP cache".
We don't want to create new entry. After neigh_event_ns you
jump again to update (2nd unneeded update).

	As for arp_accept, it only allows creating new ARP
entries on received reply, but when disabled it does not
prevent updates for existing entries.

	For me, I see only one problem in kernel, may be
you should name this change "ARP PROXY: Ignore
gratuitous ARP requests" and you just need to add one line:

        if (arp->ar_op == htons(ARPOP_REQUEST) &&
+	    sip != tip &&
            ip_route_input(skb, tip, sip, 0, dev) == 0) {

	Because ARP PROXY works with tip, it does not need
to work just for sip. Still, existing sip will be updated
but no reply will be sent which is more possible when
the request is a broadcast. As result, for gratuitous ARP
requests and replies what we will do is just an update without
using routing or creating unneeded proxy entries.

> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---
>  net/ipv4/arp.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index c95cd93..588fed8 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -811,8 +811,13 @@ static int arp_process(struct sk_buff *skb)
>  		goto out;
>  	}
>  
> -	if (arp->ar_op == htons(ARPOP_REQUEST) &&
> -	    ip_route_input(skb, tip, sip, 0, dev) == 0) {
> +	if (arp->ar_op == htons(ARPOP_REQUEST)) {
> +		/* gratuitous ARP */
> +		if (tip == sip && IPV4_DEVCONF_ALL(dev_net(dev), ARP_ACCEPT)) {
> +			n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
> +			goto update;
> +		} else if (ip_route_input(skb, tip, sip, 0, dev) != 0)
> +			goto update_lookup;
>  
>  		rt = skb_rtable(skb);
>  		addr_type = rt->rt_type;
> @@ -853,6 +858,7 @@ static int arp_process(struct sk_buff *skb)
>  		}
>  	}
>  
> +update_lookup:
>  	/* Update our ARP tables */
>  
>  	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
> @@ -868,6 +874,7 @@ static int arp_process(struct sk_buff *skb)
>  			n = __neigh_lookup(&arp_tbl, &sip, dev, 1);
>  	}
>  
> +update:
>  	if (n) {
>  		int state = NUD_REACHABLE;
>  		int override;
> 

Regards

--
Julian Anastasov <ja@ssi.bg>
