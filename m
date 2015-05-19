From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 4/4] rocker: make rocker_port_internal_vlan_id_{get,put}() non-transactional
Date: Tue, 19 May 2015 15:24:17 +0900
Message-ID: <1432016657-24231-5-git-send-email-simon.horman@netronome.com>
References: <1432016657-24231-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34210 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbbESGYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 02:24:42 -0400
Received: by pabru16 with SMTP id ru16so9898332pab.1
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 23:24:41 -0700 (PDT)
In-Reply-To: <1432016657-24231-1-git-send-email-simon.horman@netronome.com>
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
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 3f728bcd0f90..2302f4a8c924 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3854,7 +3854,6 @@ rocker_internal_vlan_tbl_find(struct rocker *rocker, int ifindex)
 }
 
 static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
-					       enum switchdev_trans trans,
 					       int ifindex)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -3863,7 +3862,7 @@ static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
 	unsigned long lock_flags;
 	int i;
 
-	entry = rocker_port_kzalloc(rocker_port, trans, sizeof(*entry));
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
 	if (!entry)
 		return 0;
 
@@ -3873,7 +3872,7 @@ static __be16 rocker_port_internal_vlan_id_get(struct rocker_port *rocker_port,
 
 	found = rocker_internal_vlan_tbl_find(rocker, ifindex);
 	if (found) {
-		rocker_port_kfree(rocker_port, trans, entry);
+		kfree(entry);
 		goto found;
 	}
 
@@ -3897,7 +3896,6 @@ found:
 }
 
 static void rocker_port_internal_vlan_id_put(struct rocker_port *rocker_port,
-					     enum switchdev_trans trans,
 					     int ifindex)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -3919,7 +3917,7 @@ static void rocker_port_internal_vlan_id_put(struct rocker_port *rocker_port,
 		bit = ntohs(found->vlan_id) - ROCKER_INTERNAL_VLAN_ID_BASE;
 		clear_bit(bit, rocker->internal_vlan_bitmap);
 		hash_del(&found->entry);
-		rocker_port_kfree(rocker_port, trans, found);
+		kfree(found);
 	}
 
 not_found:
@@ -4905,9 +4903,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port_set_learning(rocker_port, SWITCHDEV_TRANS_NONE);
 
 	rocker_port->internal_vlan_id =
-		rocker_port_internal_vlan_id_get(rocker_port,
-						 SWITCHDEV_TRANS_NONE,
-						 dev->ifindex);
+		rocker_port_internal_vlan_id_get(rocker_port, dev->ifindex);
 	err = rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE, 0);
 	if (err) {
 		dev_err(&pdev->dev, "install ig port table failed\n");
@@ -5155,7 +5151,7 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 {
 	int err;
 
-	rocker_port_internal_vlan_id_put(rocker_port, SWITCHDEV_TRANS_NONE,
+	rocker_port_internal_vlan_id_put(rocker_port,
 					 rocker_port->dev->ifindex);
 
 	rocker_port->bridge_dev = bridge;
@@ -5166,9 +5162,7 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 	if (err)
 		return err;
 	rocker_port->internal_vlan_id =
-		rocker_port_internal_vlan_id_get(rocker_port,
-						 SWITCHDEV_TRANS_NONE,
-						 bridge->ifindex);
+		rocker_port_internal_vlan_id_get(rocker_port, bridge->ifindex);
 	return rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE, 0, 0);
 }
 
@@ -5176,7 +5170,7 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 {
 	int err;
 
-	rocker_port_internal_vlan_id_put(rocker_port, SWITCHDEV_TRANS_NONE,
+	rocker_port_internal_vlan_id_put(rocker_port,
 					 rocker_port->bridge_dev->ifindex);
 
 	rocker_port->bridge_dev = NULL;
@@ -5188,7 +5182,6 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 		return err;
 	rocker_port->internal_vlan_id =
 		rocker_port_internal_vlan_id_get(rocker_port,
-						 SWITCHDEV_TRANS_NONE,
 						 rocker_port->dev->ifindex);
 	err = rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE, 0, 0);
 	if (err)
-- 
2.1.4
