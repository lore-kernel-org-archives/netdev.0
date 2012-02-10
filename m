From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] net: Don't proxy arp respond if iif == rt->dst.dev if private VLAN is disabled
Date: Fri, 10 Feb 2012 15:07:11 +0100
Message-ID: <1328882831-15300-1-git-send-email-tgraf@suug.ch>
Cc: Jesper Dangaard Brouer <hawk@comx.dk>, Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752986Ab2BJOHa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 09:07:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 653241 (net: RFC3069, private VLAN proxy arp support) changed
the behavior of arp proxy to send arp replies back out on the interface
the request came in even if the private VLAN feature is disabled.

Previously we checked rt->dst.dev != skb->dev for in scenarios, when
proxy arp is enabled on for the netdevice and also when individual proxy
neighbour entries have been added.

This patch adds the check back for the pneigh_lookup() scenario.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/arp.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 59402be..63e4989 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -863,7 +863,8 @@ static int arp_process(struct sk_buff *skb)
 			if (addr_type == RTN_UNICAST  &&
 			    (arp_fwd_proxy(in_dev, dev, rt) ||
 			     arp_fwd_pvlan(in_dev, dev, rt, sip, tip) ||
-			     pneigh_lookup(&arp_tbl, net, &tip, dev, 0))) {
+			     (rt->dst.dev != dev &&
+			      pneigh_lookup(&arp_tbl, net, &tip, dev, 0)))) {
 				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 				if (n)
 					neigh_release(n);
-- 
1.7.7.6
