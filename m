From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH] bridge: Cannot communicate with brX when its MAC address
 is changed
Date: Wed, 30 Nov 2011 17:31:18 +0900
Message-ID: <4ED5E9D6.3070404@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:33159 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756076Ab1K3Ib1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 03:31:27 -0500
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D01583EE0BD
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 17:31:25 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B63A145DE56
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 17:31:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A02B545DE55
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 17:31:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DF901DB8051
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 17:31:25 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 451681DB8048
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 17:31:25 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the MAC address of a bridge interface is changed, it cannot communicate
with others. Because Whether or not a packet should be transferred to bridge
interface depends on whether or not dst of a packet is in fdb and is_local=y.
If we change MAC address of a bridge interface, it isn't in fdb.

This patch adds an condition that dst of a packet matches MAC address of
a bridge interface to the conventional condition.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 net/bridge/br_input.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 5a31731..4e5c862 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -94,7 +94,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
 			skb2 = skb;
 
 		br->dev->stats.multicast++;
-	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
+	} else if ((dst = __br_fdb_get(br, dest) && dst->is_local) ||
+		   !compare_ether_addr(p->br->dev->dev_addr, dest)) {
 		skb2 = skb;
 		/* Do not forward the packet since it's local. */
 		skb = NULL;
