From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando@oss.ntt.co.jp>
Subject: [PATCH 1/2] IGMP snooping: set mrouters_only flag for IPv4 traffic
 properly
Date: Tue, 14 Jun 2011 10:04:43 +0900
Message-ID: <1308013483.3896.9.camel@nexus.oss.ntt.co.jp>
References: <1307933995.2704.11.camel@nausicaa>
	 <1308013301.3896.6.camel@nexus.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Hayato Kakuta <kakuta.hayato@oss.ntt.co.jp>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:54757 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab1FNBEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 21:04:45 -0400
In-Reply-To: <1308013301.3896.6.camel@nexus.oss.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upon reception of a IGMP/IGMPv2 membership report the kernel sets the
mrouters_only flag in a skb that may be a clone of the original skb, which
means that sometimes the bridge loses track of membership report packets (cb
buffers are tied to a specific skb and not shared) and it ends up forwading
join requests to the bridge interface.

This can cause unexpected membership timeouts and intermitent/permanent loss
of connectivity as described in RFC 4541 [2.1.1. IGMP Forwarding Rules]:

    A snooping switch should forward IGMP Membership Reports only to
    those ports where multicast routers are attached.
    [...]
    Sending membership reports to other hosts can result, for IGMPv1
    and IGMPv2, in unintentionally preventing a host from joining a
    specific multicast group.


Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Tested-by: Hayato Kakuta <kakuta.hayato@oss.ntt.co.jp>
---

diff -urNp linux-3.0-rc2-orig/net/bridge/br_multicast.c linux-3.0-rc2/net/bridge/br_multicast.c
--- linux-3.0-rc2-orig/net/bridge/br_multicast.c	2011-06-09 13:34:04.164261031 +0900
+++ linux-3.0-rc2/net/bridge/br_multicast.c	2011-06-09 20:04:23.473930447 +0900
@@ -1424,7 +1424,7 @@ static int br_multicast_ipv4_rcv(struct
 	switch (ih->type) {
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
-		BR_INPUT_SKB_CB(skb2)->mrouters_only = 1;
+		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
 		err = br_ip4_multicast_add_group(br, port, ih->group);
 		break;
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:


