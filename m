From: sfeldma@gmail.com
Subject: [PATCH net-next] rocker: hook ndo_neigh_destroy to cleanup neigh refs in driver
Date: Wed, 12 Aug 2015 18:45:25 -0700
Message-ID: <1439430325-49311-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35586 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbbHMBmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 21:42:36 -0400
Received: by pacgr6 with SMTP id gr6so26112350pac.2
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 18:42:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Rocker driver tracks arp_tbl neighs to resolve IPv4 route nexthops.  The
driver uses NETEVENT_NEIGH_UPDATE for neigh adds and updates, but there is
no event when the neigh is removed from the device (such as when the device
goes admin down).  This patches hooks ndo_neigh_destroy so the driver can
know when a neigh is removed from the device.  In response, the driver will
purge the neigh entry from its internal tbl.

I didn't find an in-tree users of ndo_neigh_destroy, so I'm not sure if
this ndo is vestigial or if there are out-of-tree users.  In any case, it
does what I need here.  An alternative design would be to generate
NETEVENT_NEIGH_UPDATE event when neigh is being destroyed, setting state to
NUD_NONE so driver knows neigh entry is dead.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 Documentation/networking/switchdev.txt |    3 ++-
 drivers/net/ethernet/rocker/rocker.c   |   11 +++++++++++
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index 9825f32..476df04 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -367,4 +367,5 @@ driver's rocker_port_ipv4_resolve() for an example.
 
 The driver can monitor for updates to arp_tbl using the netevent notifier
 NETEVENT_NEIGH_UPDATE.  The device can be programmed with resolved nexthops
-for the routes as arp_tbl updates.
+for the routes as arp_tbl updates.  The driver implements ndo_neigh_destroy
+to know when arp_tbl neighbor entries are purged from the port.
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index af05075..619b2e2 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4264,6 +4264,16 @@ static int rocker_port_change_proto_down(struct net_device *dev,
 	return 0;
 }
 
+static void rocker_port_neigh_destroy(struct neighbour *n)
+{
+	struct rocker_port *rocker_port = netdev_priv(n->dev);
+	int flags = ROCKER_OP_FLAG_REMOVE | ROCKER_OP_FLAG_NOWAIT;
+	__be32 ip_addr = *(__be32 *)n->primary_key;
+
+	rocker_port_ipv4_neigh(rocker_port, SWITCHDEV_TRANS_NONE,
+			       flags, ip_addr, n->ha);
+}
+
 static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_open			= rocker_port_open,
 	.ndo_stop			= rocker_port_stop,
@@ -4278,6 +4288,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_dump			= switchdev_port_fdb_dump,
 	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
 	.ndo_change_proto_down		= rocker_port_change_proto_down,
+	.ndo_neigh_destroy		= rocker_port_neigh_destroy,
 };
 
 /********************
-- 
1.7.10.4
