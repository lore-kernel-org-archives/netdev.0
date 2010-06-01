From: Christoph Lameter <cl@linux-foundation.org>
Subject: [PATCH] IP: Increment INADDRERRORS if routing for a packet is not
 successful
Date: Tue, 1 Jun 2010 16:13:39 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1006011609280.9438@router.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi157.sbcis.sbc.com ([207.115.36.171]:50318 "EHLO
	nlpi157.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044Ab0FAVNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:13:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Something like this would have been very helpful during recent debugging
of multicast issues. Silent discards are bad.


If the kernel perceives that something is wrong with an incoming packet then the
IP stack currently silently discards packets. This makes it difficult to diagnose
problems with the network configurations (such as a misbehaving kernel
subsystem discarding multicast packets because the reverse path filter
does not like multicast subscriptions on the second NIC with rp_filter=1).

It is also necessary to know how many inbound packets are discarded to
assess networking issues in general with a NIC.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/ipv4/route.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6/net/ipv4/route.c
===================================================================
--- linux-2.6.orig/net/ipv4/route.c	2010-06-01 11:46:10.000000000 -0500
+++ linux-2.6/net/ipv4/route.c	2010-06-01 11:52:55.000000000 -0500
@@ -2981,6 +2981,9 @@ static int inet_rtm_getroute(struct sk_b
 		rt = skb_rtable(skb);
 		if (err == 0 && rt->u.dst.error)
 			err = -rt->u.dst.error;
+		if (err)
+			IP_INC_STATS_BH(dev_net(skb->dev),
+					IPSTATS_MIB_INADDRERRORS);
 	} else {
 		struct flowi fl = {
 			.nl_u = {


