From: sfeldma@gmail.com
Subject: [PATCH net-next 4/5] rocker: move MAC learn event back to 'no wait' processing
Date: Fri, 12 Jun 2015 21:35:49 -0700
Message-ID: <1434170150-63838-5-git-send-email-sfeldma@gmail.com>
References: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	makita.toshiaki@lab.ntt.co.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:33096 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbbFMEeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 00:34:07 -0400
Received: by igbpi8 with SMTP id pi8so23456257igb.0
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 21:34:06 -0700 (PDT)
In-Reply-To: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   40 +++-------------------------------
 1 file changed, 3 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 6c15c2e..8430cb3 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -1459,36 +1459,14 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 			   const unsigned char *addr,
 			   __be16 vlan_id, int flags);
 
-struct rocker_mac_vlan_seen_work {
-	struct work_struct work;
-	struct rocker_port *rocker_port;
-	int flags;
-	unsigned char addr[ETH_ALEN];
-	__be16 vlan_id;
-};
-
-static void rocker_event_mac_vlan_seen_work(struct work_struct *work)
-{
-	const struct rocker_mac_vlan_seen_work *sw =
-		container_of(work, struct rocker_mac_vlan_seen_work, work);
-
-	rtnl_lock();
-	rocker_port_fdb(sw->rocker_port, SWITCHDEV_TRANS_NONE,
-			sw->addr, sw->vlan_id, sw->flags);
-	rtnl_unlock();
-
-	kfree(work);
-}
-
 static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 				      const struct rocker_tlv *info)
 {
-	struct rocker_mac_vlan_seen_work *sw;
 	const struct rocker_tlv *attrs[ROCKER_TLV_EVENT_MAC_VLAN_MAX + 1];
 	unsigned int port_number;
 	struct rocker_port *rocker_port;
 	const unsigned char *addr;
-	int flags = ROCKER_OP_FLAG_LEARNED;
+	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_LEARNED;
 	__be16 vlan_id;
 
 	rocker_tlv_parse_nested(attrs, ROCKER_TLV_EVENT_MAC_VLAN_MAX, info);
@@ -1510,20 +1488,8 @@ static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 	    rocker_port->stp_state != BR_STATE_FORWARDING)
 		return 0;
 
-	sw = kmalloc(sizeof(*sw), GFP_ATOMIC);
-	if (!sw)
-		return -ENOMEM;
-
-	INIT_WORK(&sw->work, rocker_event_mac_vlan_seen_work);
-
-	sw->rocker_port = rocker_port;
-	sw->flags = flags;
-	ether_addr_copy(sw->addr, addr);
-	sw->vlan_id = vlan_id;
-
-	schedule_work(&sw->work);
-
-	return 0;
+	return rocker_port_fdb(rocker_port, SWITCHDEV_TRANS_NONE,
+			       addr, vlan_id, flags);
 }
 
 static int rocker_event_process(const struct rocker *rocker,
-- 
1.7.10.4
