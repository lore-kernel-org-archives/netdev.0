From: Brian Haley <brian.haley@hp.com>
Subject: Re: IPv6 duplicate address detection erroneously marking address
 as duplicate when a host receives its own multicast packets?
Date: Wed, 21 Apr 2010 21:27:49 -0400
Message-ID: <4BCFA615.8060205@hp.com>
References: <1271880831.6685.6.camel@spathi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sam Cannell <sam.cannell@catalyst.net.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:19128 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014Ab0DVB2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 21:28:03 -0400
In-Reply-To: <1271880831.6685.6.camel@spathi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sam Cannell wrote:
> I've been having some trouble with ip6 duplicate address detection in a
> Linux VM (under XVM on OpenSolaris).  It seems that the ethernet bridge
> in XVM sends a host's own multicast packets back to it, which the
> duplicate address detection code in linux decide that another host on
> the network is using the same address.
<snip>
>
> I'd happily put this down to a failing in XVM, however the stateless
> autoconfiguration RFC (4862) states that the stack shouldn't decide an
> address is duplicate based on receipt of a neighbor solicitation message
> that it sent itself:
<snip>
> 
> Assuming my understanding of the RFC is correct, this suggests to me
> that duplicate address detection in Linux is being a little too hasty to
> mark the address as invalid.  Thoughts?

Well, my initial reaction is XVM is doing the wrong thing looping-back
multicast packets.  You can try the following (untested) patch, I can
only confirm it compiles.

-Brian


Add a check for looped-back DAD packets on Ethernet interfaces.

Signed-off-by: Brian Haley <brian.haley@hp.com>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index da0a4d2..33a7212 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -57,6 +57,7 @@
 #include <linux/net.h>
 #include <linux/in6.h>
 #include <linux/route.h>
+#include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/rcupdate.h>
 #include <linux/slab.h>
@@ -800,6 +801,16 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 					}
 				}
 
+				if (dev->type == ARPHRD_ETHER) {
+					struct ethhdr *eth = eth_hdr(skb);
+					if (!compare_ether_addr_64bits(
+								dev->dev_addr,
+								eth->h_source)){
+						/* looped-back to us */
+						goto out;
+					}
+				}
+
 				/*
 				 * We are colliding with another node
 				 * who is doing DAD
