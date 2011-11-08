From: Brian Haley <brian.haley@hp.com>
Subject: Re: Query on usage of multicast as source IPv6 address
Date: Mon, 07 Nov 2011 21:11:24 -0500
Message-ID: <4EB88FCC.9000509@hp.com>
References: <20111107204550.GB2980@kumar.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kumar Sanghvi <divinekumar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:41014 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163Ab1KHCL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 21:11:27 -0500
In-Reply-To: <20111107204550.GB2980@kumar.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2011 03:45 PM, Kumar Sanghvi wrote:
> Hi,
> 
> I am trying to understand IPv6 behavior in Linux.
> And I have a doubt related to use of multicast address
> as source address.
> 
> RFC 4291 in Section 2.7 states that:
> "Multicast addresses must not be used as source addresses
>  in IPv6 packets or appear in any Routing header."
> 
> However, what should be the behavior if a host receives a
> packet (probably from a malicious host with pktgen abilities)
> having a multicast address in source address field:
> 1) Should the receiving host discard the packet?

I believe other *nixes silently drop it, can you try this patch?

-Brian

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 027c7ff..a46c64e 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -111,6 +111,14 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev,
struct packet_type *pt
 	    ipv6_addr_loopback(&hdr->daddr))
 		goto err;

+	/*
+	 * RFC4291 2.7
+	 * Multicast addresses must not be used as source addresses in IPv6
+	 * packets or appear in any Routing header.
+	 */
+	if (ipv6_addr_is_multicast(&hdr->saddr))
+		goto err;
+
 	skb->transport_header = skb->network_header + sizeof(*hdr);
 	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
