From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next v3 05/13] net: dsa: Move FDB add/del implementation inside DSA
Date: Sun,  6 Aug 2017 16:15:43 +0300
Message-ID: <1502025351-41261-6-git-send-email-arkadis@mellanox.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com, Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44787 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751338AbdHFNMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 09:12:18 -0400
In-Reply-To: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently DSA uses switchdev's implementation of FDB add/del ndos. This
patch moves the implementation inside DSA in order to support the legacy
way for static FDB configuration.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
---
 net/dsa/dsa_priv.h |  7 +++++++
 net/dsa/legacy.c   | 22 ++++++++++++++++++++++
 net/dsa/slave.c    | 14 ++------------
 3 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 5af25e7..dab10d5 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -112,6 +112,13 @@ bool dsa_schedule_work(struct work_struct *work);
 /* legacy.c */
 int dsa_legacy_register(void);
 void dsa_legacy_unregister(void);
+int dsa_legacy_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+		       struct net_device *dev,
+		       const unsigned char *addr, u16 vid,
+		       u16 flags);
+int dsa_legacy_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
+		       struct net_device *dev,
+		       const unsigned char *addr, u16 vid);
 
 /* port.c */
 int dsa_port_set_state(struct dsa_port *dp, u8 state,
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 1d7a328..578001f 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -741,6 +741,28 @@ static int dsa_resume(struct device *d)
 }
 #endif
 
+/* legacy way, bypassing the bridge *****************************************/
+int dsa_legacy_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+		       struct net_device *dev,
+		       const unsigned char *addr, u16 vid,
+		       u16 flags)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
+
+	return dsa_port_fdb_add(dp, addr, vid);
+}
+
+int dsa_legacy_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
+		       struct net_device *dev,
+		       const unsigned char *addr, u16 vid)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
+
+	return dsa_port_fdb_del(dp, addr, vid);
+}
+
 static SIMPLE_DEV_PM_OPS(dsa_pm_ops, dsa_suspend, dsa_resume);
 
 static const struct of_device_id dsa_of_match_table[] = {
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index a2fbbc7..2cf1c94 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -250,12 +250,6 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
 	 */
 
 	switch (obj->id) {
-	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		if (switchdev_trans_ph_prepare(trans))
-			return 0;
-		err = dsa_port_fdb_add(dp, SWITCHDEV_OBJ_PORT_FDB(obj)->addr,
-				       SWITCHDEV_OBJ_PORT_FDB(obj)->vid);
-		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_port_mdb_add(dp, SWITCHDEV_OBJ_PORT_MDB(obj), trans);
 		break;
@@ -279,10 +273,6 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
 	int err;
 
 	switch (obj->id) {
-	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = dsa_port_fdb_del(dp, SWITCHDEV_OBJ_PORT_FDB(obj)->addr,
-				       SWITCHDEV_OBJ_PORT_FDB(obj)->vid);
-		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = dsa_port_mdb_del(dp, SWITCHDEV_OBJ_PORT_MDB(obj));
 		break;
@@ -955,8 +945,8 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
-	.ndo_fdb_add		= switchdev_port_fdb_add,
-	.ndo_fdb_del		= switchdev_port_fdb_del,
+	.ndo_fdb_add		= dsa_legacy_fdb_add,
+	.ndo_fdb_del		= dsa_legacy_fdb_del,
 	.ndo_fdb_dump		= switchdev_port_fdb_dump,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 	.ndo_get_iflink		= dsa_slave_get_iflink,
-- 
2.4.11
