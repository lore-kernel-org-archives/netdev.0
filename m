From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [net-next PATCH v3] ipv4: allow warming up the ARP cache with
 request type gratuitous ARP
Date: Tue, 19 Jan 2010 10:09:13 +1030
Message-ID: <20100119100913.65177497@opy.nosense.org>
References: <201001190058.44495.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Julian Anastasov <ja@ssi.bg>,
	Laurent Chavey <chavey@google.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.adam.net.au ([202.136.110.249]:43536 "EHLO
	smtp3.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353Ab0ARXje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 18:39:34 -0500
In-Reply-To: <201001190058.44495.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Octavian,

On Tue, 19 Jan 2010 00:58:44 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> If the per device ARP_ACCEPT option is enable, currently we only allow
> creating new ARP cache entries for response type gratuitous ARP.
> 
> Allowing gratuitous ARP to create new ARP entries (not only to update
> existing ones) is useful when we want to avoid unnecessary delays for
> the first packet of a stream.
> 
> This patch allows request type gratuitous ARP to create new ARP cache
> entries as well. This is useful when we want to populate the ARP cache
> entries for a large number of hosts on the same LAN.
> 

I don't think this complies with the ARP RFC (RFC826). Walking through
the validation steps, Gratuitous ARP seems to only pass if there is an
existing entry in the table, otherwise they'd fail, as the target
address in the GA packet doesn't match that of the receiving host.

I can guess your motivation for this, however I wonder if going outside
the spec for relatively rare testing cases (in comparison to all the ARP
usage on all IP LANs) is wise. While ARP is vulnerable to DoS attacks, I
think allowing GAs to generate new ARP entries would increase its
vulnerability. There may also be some other unexpected consequences
that haven't been identified.

Possibly for your test environments, maybe static ARP entries might
be a feasible alternative that's still compliant with RFC826?

Regards,
Mark.


> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---
>  Documentation/networking/ip-sysctl.txt |   15 ++++++++++++---
>  net/ipv4/arp.c                         |    3 ++-
>  2 files changed, 14 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index c532884..2dc7a1d 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -852,9 +852,18 @@ arp_notify - BOOLEAN
>  	    or hardware address changes.
>  
>  arp_accept - BOOLEAN
> -	Define behavior when gratuitous arp replies are received:
> -	0 - drop gratuitous arp frames
> -	1 - accept gratuitous arp frames
> +	Define behavior for gratuitous ARP frames who's IP is not
> +	already present in the ARP table:
> +	0 - don't create new entries in the ARP table
> +	1 - create new entries in the ARP table
> +
> +	Both replies and requests type gratuitous arp will trigger the
> +	ARP table to be updated, if this setting is on.
> +
> +	If the ARP table already contains the IP address of the
> +	gratuitous arp frame, the arp table will be updated regardless
> +	if this setting is on or off.
> +
>  
>  app_solicit - INTEGER
>  	The maximum number of probes to send to the user space ARP daemon
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
> -- 
> 1.5.6.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
