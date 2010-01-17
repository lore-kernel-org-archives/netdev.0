From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] ipv4: support for request type gratuitous ARP
Date: Sun, 17 Jan 2010 22:43:54 +0200 (EET)
Message-ID: <Pine.LNX.4.58.1001172213550.10728@u.domain.uli>
References: <20100110.132105.179935794.davem@davemloft.net>
 <1263680334-1770-1-git-send-email-opurdila@ixiacom.com>
 <Pine.LNX.4.58.1001171310420.2769@u.domain.uli> <201001172055.52953.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Laurent Chavey <chavey@google.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:50188 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754637Ab0AQUlM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jan 2010 15:41:12 -0500
In-Reply-To: <201001172055.52953.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 17 Jan 2010, Octavian Purdila wrote:

> On Sunday 17 January 2010 15:45:45 you wrote:
> 
> > 	May be I'm missing something but the description and
> > the changed code do not match. You claim this patch now supports
> > dest mac ff:ff:ff:ff:ff:ff while without the patch the
> > 'skb->pkt_type != PACKET_HOST' check usually updates the
> > existing entry with state NUD_STALE (neigh_update). What

> Hi Julian,
> 
> Thanks for looking at this patch ! You are indeed correct, we don't need to do anything special when we want to update an existing ARP entry.
> 
> But I also want to be able to create a new ARP entry not only update an existing one (and we can do that with Linux today, but only with response type grat arp).
> 
> How about this new version?

	Looks correct to me. You will save some CPU cycles
if the 'arp->ar_op == htons(ARPOP_REQUEST)' check is not added.
May be you also need to change arp_accept in 
Documentation/networking/ip-sysctl.txt to show that we do not 
differentiate Gratuitous ARP requests from replies.

> [PATCH] ipv4: allow warming up the ARP cache with request type gratuitous ARP
> 
> If the per device ARP_ACCEPT option is enabled, currently we only allow
> creating new ARP cache entries for response type gratuitous ARP.
> 
> Allowing gratuitous ARP to create new ARP entries (not only to update
> existing ones) is useful when we want to avoid unnecessary delays for
> the first packet of a stream.
> 
> This patch allows request type gratuitous ARP to create new ARP cache
> entries as well. This is useful when we want to warm-up the ARP cache
> entries for a large number of hosts on the same LAN.
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---
>  net/ipv4/arp.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 0787092..1940b4d 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -907,7 +907,8 @@ static int arp_process(struct sk_buff *skb)
>  		   devices (strip is candidate)
>  		 */
>  		if (n == NULL &&
> -		    arp->ar_op == htons(ARPOP_REPLY) &&
> +		    (arp->ar_op == htons(ARPOP_REPLY) ||
> +		     (arp->ar_op == htons(ARPOP_REQUEST) && tip == sip)) &&
>  		    inet_addr_type(net, sip) == RTN_UNICAST)
>  			n = __neigh_lookup(&arp_tbl, &sip, dev, 1);
>  	}

Regards

--
Julian Anastasov <ja@ssi.bg>
