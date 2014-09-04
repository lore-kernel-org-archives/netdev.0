From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net] core: Untag packets after rx_handler has run.
Date: Thu,  4 Sep 2014 14:40:43 -0400
Message-ID: <1409856043-21840-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Zumbiehl <florz@florz.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Matthew Rosato <mjrosato@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:40616 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754702AbaIDSky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 14:40:54 -0400
Received: by mail-qg0-f52.google.com with SMTP id z60so10302803qgd.25
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 11:40:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we attempt to remove the vlan informaion from the packet
before passing it to the rx_handler.  In most situations this works
just fine since the rx_handlers are usually installed for the
lower device and thus vlan device isn't found.  However, macvtap
device is a bit different as it installs an rx_handler on top
of a macvlan device.  As a result, if someone was define a vlan
device on top of a macvap (for the purposes of enabling a VM
to use vlans with macvtap), then the current code will result
in passing an untagged packet to the macvtap rx_handler and the
VM will not receive tagged traffic.

This patch moves the untaggin code to after the rx_handler for
the current device has been called.  This still works for the
existing rx_handlers (like bonding/teaming/bridging/etc) and
also makes vlans on top of macvtap work as before.

Fixes: 6acf54f1cf (macvtap: Add support of packet capture on macvtap device)
Reported-by: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/core/dev.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ab9a165..54691d1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3642,17 +3642,6 @@ ncls:
 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
 		goto drop;
 
-	if (vlan_tx_tag_present(skb)) {
-		if (pt_prev) {
-			ret = deliver_skb(skb, pt_prev, orig_dev);
-			pt_prev = NULL;
-		}
-		if (vlan_do_receive(&skb))
-			goto another_round;
-		else if (unlikely(!skb))
-			goto unlock;
-	}
-
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
 		if (pt_prev) {
@@ -3674,6 +3663,17 @@ ncls:
 		}
 	}
 
+	if (vlan_tx_tag_present(skb)) {
+		if (pt_prev) {
+			ret = deliver_skb(skb, pt_prev, orig_dev);
+			pt_prev = NULL;
+		}
+		if (vlan_do_receive(&skb))
+			goto another_round;
+		else if (unlikely(!skb))
+			goto unlock;
+	}
+
 	if (unlikely(vlan_tx_tag_present(skb))) {
 		if (vlan_tx_tag_get_id(skb))
 			skb->pkt_type = PACKET_OTHERHOST;
-- 
1.9.3
