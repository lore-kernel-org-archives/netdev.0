From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v3 net-next 4/4] rocker: make rocker_port_internal_vlan_id_{get,put}() non-transactional
Date: Wed, 20 May 2015 14:48:22 +0900
Message-ID: <1432100902-10187-5-git-send-email-simon.horman@netronome.com>
References: <1432100902-10187-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35758 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbbETFsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 01:48:45 -0400
Received: by pdea3 with SMTP id a3so55680342pde.2
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 22:48:44 -0700 (PDT)
In-Reply-To: <1432100902-10187-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The motivation for this is that rocker_port_internal_vlan_id_{get,put} appear
to only partially implement the transaction model: memory allocation
and freeing is transactional, but hash and bitmap manipulation is not.

The latter could be fixed, however, as it is not currently exercised
due to trans always being SWITCHDEV_TRANS_NONE it seems cleaner
to make rocker_port_internal_vlan_id_get non-transactional.

Found by inspection.
I do not believe that this change should have any run-time effect.

Fixes: c4f20321d968 ("rocker: support prepare-commit transaction model")
Acked-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
v3
* No change

v2
* Added Scott Feldman's ack
---
 drivers/net/ethernet/rocker/rocker.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index fde3186074bb..573179f9f63e 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3852,7 +3852,6 @@ rocker_internal_vlan_tbl_find(struct rocker *rocker, int ifindex)
 }
 
 static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
-					       enum switchdev_trans trans,
 					       int ifindex)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -3861,7 +3860,7 @@ static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
 	unsigned long lock_flags;
 	int i;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return 0;
 
@@ -3871,7 +3870,7 @@ static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
 
 	found = rocker_internal_vlan_tbl_find(rocker, ifindex);
 	if (found) {
-		rocker_port_kfree(rocker_port, trans, entry);
+		kfree(entry);
 		goto found;
 	}
 
@@ -3895,7 +3894,6 @@ found:
 }
 
 static void rocker_port_internal_vlan_id_put(struct rocker_port *rocker_port,
-					     enum switchdev_trans trans,
 					     int ifindex)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -3917,7 +3915,7 @@ static void rocker_port_internal_vlan_id_put(struct rocker_port *rocker_port,
 		bit = ntohs(found->vlan_id) - ROCKER_INTERNAL_VLAN_ID_BASE;
 		clear_bit(bit, rocker->internal_vlan_bitmap);
 		hash_del(&found->entry);
-		rocker_port_kfree(rocker_port, trans, found);
+		kfree(found);
 	}
 
 not_found:
@@ -4903,9 +4901,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port_set_learning(rocker_port, SWITCHDEV_TRANS_NONE);
 
 	rocker_port->internal_vlan_id =
-		rocker_port_internal_vlan_id_get(rocker_port,
-						 SWITCHDEV_TRANS_NONE,
-						 dev->ifindex);
+		rocker_port_internal_vlan_id_get(rocker_port, dev->ifindex);
 	err = rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE, 0);
 	if (err) {
 		dev_err(&pdev->dev, "install ig port table failed\n");
@@ -5153,7 +5149,7 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 {
 	int err;
 
-	rocker_port_internal_vlan_id_put(rocker_port, SWITCHDEV_TRANS_NONE,
+	rocker_port_internal_vlan_id_put(rocker_port,
 					 rocker_port->dev->ifindex);
 
 	rocker_port->bridge_dev = bridge;
@@ -5164,9 +5160,7 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 	if (err)
 		return err;
 	rocker_port->internal_vlan_id =
-		rocker_port_internal_vlan_id_get(rocker_port,
-						 SWITCHDEV_TRANS_NONE,
-						 bridge->ifindex);
+		rocker_port_internal_vlan_id_get(rocker_port, bridge->ifindex);
 	return rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE, 0, 0);
 }
 
@@ -5174,7 +5168,7 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 {
 	int err;
 
-	rocker_port_internal_vlan_id_put(rocker_port, SWITCHDEV_TRANS_NONE,
+	rocker_port_internal_vlan_id_put(rocker_port,
 					 rocker_port->bridge_dev->ifindex);
 
 	rocker_port->bridge_dev = NULL;
@@ -5186,7 +5180,6 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 		return err;
 	rocker_port->internal_vlan_id =
 		rocker_port_internal_vlan_id_get(rocker_port,
-						 SWITCHDEV_TRANS_NONE,
 						 rocker_port->dev->ifindex);
 	err = rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE, 0, 0);
 	if (err)
-- 
2.1.4
