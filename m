From: sfeldma@gmail.com
Subject: [PATCH net-next 3/5] rocker: install untagged VLAN (vid=0) support for each port
Date: Mon,  1 Jun 2015 11:39:04 -0700
Message-ID: <1433183947-13095-4-git-send-email-sfeldma@gmail.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33356 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbbFASh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 14:37:29 -0400
Received: by pdbqa5 with SMTP id qa5so113846328pdb.0
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 11:37:28 -0700 (PDT)
In-Reply-To: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

On port probe, install by default untagged VLAN support.  This is
equivalent to running the command:

	bridge vlan add vid 0 dev DEV self

A user could, if they wanted, manaully removing untagged support from the
port by running the command:

	bridge vlan del vid 0 dev DEV self

But installing it by default on port initialization gives the normal
expected behavior.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 76e2281..bd56273 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3157,6 +3157,8 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 
 	for (i = 0; i < rocker->port_count; i++) {
 		p = rocker->ports[i];
+		if (!p)
+			continue;
 		if (!rocker_port_is_bridged(p))
 			continue;
 		if (test_bit(ntohs(vlan_id), p->vlan_bitmap)) {
@@ -3216,7 +3218,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 
 	for (i = 0; i < rocker->port_count; i++) {
 		p = rocker->ports[i];
-		if (test_bit(ntohs(vlan_id), p->vlan_bitmap))
+		if (p && test_bit(ntohs(vlan_id), p->vlan_bitmap))
 			ref++;
 	}
 
@@ -4882,6 +4884,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	const struct pci_dev *pdev = rocker->pdev;
 	struct rocker_port *rocker_port;
 	struct net_device *dev;
+	u16 untagged_vid = 0;
 	int err;
 
 	dev = alloc_etherdev(sizeof(struct rocker_port));
@@ -4917,16 +4920,27 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 
 	rocker_port_set_learning(rocker_port, SWITCHDEV_TRANS_NONE);
 
-	rocker_port->internal_vlan_id =
-		rocker_port_internal_vlan_id_get(rocker_port, dev->ifindex);
 	err = rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE, 0);
 	if (err) {
 		dev_err(&pdev->dev, "install ig port table failed\n");
 		goto err_port_ig_tbl;
 	}
 
+	rocker_port->internal_vlan_id =
+		rocker_port_internal_vlan_id_get(rocker_port, dev->ifindex);
+
+	err = rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
+				   untagged_vid, 0);
+	if (err) {
+		netdev_err(rocker_port->dev, "install untagged VLAN failed\n");
+		goto err_untagged_vlan;
+	}
+
 	return 0;
 
+err_untagged_vlan:
+	rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE,
+			   ROCKER_OP_FLAG_REMOVE);
 err_port_ig_tbl:
 	unregister_netdev(dev);
 err_register_netdev:
-- 
1.7.10.4
