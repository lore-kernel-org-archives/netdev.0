From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 4/5] be2net: allow offloading with the same port for IPv4 and IPv6
Date: Thu, 17 Sep 2015 16:11:13 +0200
Message-ID: <1b2a27cefac4b736f098624b8c411aee6ccef9f2.1442498316.git.jbenc@redhat.com>
References: <cover.1442498316.git.jbenc@redhat.com>
Cc: Sathya Perla <sathya.perla@avagotech.com>,
	Ajit Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37273 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751839AbbIQOL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 10:11:28 -0400
In-Reply-To: <cover.1442498316.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The callback for adding vxlan port can be called with the same port for both
IPv4 and IPv6. Do not disable the offloading if this occurs.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  1 +
 drivers/net/ethernet/emulex/benet/be_main.c | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 0a27805cbbbd..821540913343 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -582,6 +582,7 @@ struct be_adapter {
 	u16 pvid;
 	__be16 vxlan_port;
 	int vxlan_port_count;
+	int vxlan_port_aliases;
 	struct phy_info phy;
 	u8 wol_cap;
 	bool wol_en;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 12687bf52b95..7bf51a1a0a77 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5176,6 +5176,11 @@ static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 	if (lancer_chip(adapter) || BEx_chip(adapter) || be_is_mc(adapter))
 		return;
 
+	if (adapter->vxlan_port == port && adapter->vxlan_port_count) {
+		adapter->vxlan_port_aliases++;
+		return;
+	}
+
 	if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS) {
 		dev_info(dev,
 			 "Only one UDP port supported for VxLAN offloads\n");
@@ -5226,6 +5231,11 @@ static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 	if (adapter->vxlan_port != port)
 		goto done;
 
+	if (adapter->vxlan_port_aliases) {
+		adapter->vxlan_port_aliases--;
+		return;
+	}
+
 	be_disable_vxlan_offloads(adapter);
 
 	dev_info(&adapter->pdev->dev,
-- 
1.8.3.1
