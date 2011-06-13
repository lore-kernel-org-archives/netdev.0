From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Subject: [PATCH 2/2] IGMP snooping: set mrouters_only flag for IPv6 traffic
 properly
Date: Mon, 13 Jun 2011 12:21:44 +0900
Message-ID: <1307935304.3550.8.camel@nausicaa>
References: <1307933995.2704.11.camel@nausicaa>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:42604 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891Ab1FMDVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 23:21:46 -0400
In-Reply-To: <1307933995.2704.11.camel@nausicaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upon reception of a MGM report packet the kernel sets the mrouters_only flag
in a skb that is a clone of the original skb, which means that the bridge
loses track of MGM packets (cb buffers are tied to a specifici skb and not
shared) and it ends up forwading join requests to the bridge interface.

This can cause unexpected membership timeouts and intermitent/permanent loss
of connectivity as described in RFC 4541 [2.1.1. IGMP Forwarding Rules]:

    A snooping switch should forward IGMP Membership Reports only to
    those ports where multicast routers are attached.
    [...]
    Sending membership reports to other hosts can result, for IGMPv1
    and IGMPv2, in unintentionally preventing a host from joining a
    specific multicast group.


Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
---

diff -urNp linux-3.0-rc2-orig/net/bridge/br_multicast.c linux-3.0-rc2/net/bridge/br_multicast.c
--- linux-3.0-rc2-orig/net/bridge/br_multicast.c	2011-06-13 12:10:27.805554187 +0900
+++ linux-3.0-rc2/net/bridge/br_multicast.c	2011-06-13 12:12:27.591626915 +0900
@@ -1543,7 +1543,7 @@ static int br_multicast_ipv6_rcv(struct
 			goto out;
 		}
 		mld = (struct mld_msg *)skb_transport_header(skb2);
-		BR_INPUT_SKB_CB(skb2)->mrouters_only = 1;
+		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
 		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca);
 		break;
 	    }


