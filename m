From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v2 1/1] drivers: net: cpsw: add support to dump ALE table via ethtool register dump
Date: Tue, 22 Jul 2014 23:25:07 +0530
Message-ID: <1406051707-9984-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:45520 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267AbaGVRzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 13:55:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to view addresses added by the driver and learnt by the
hardware from ALE table via ethtool register dump interface.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
Changes from initial version
* Fixed one build warning

Below is the sample output of ale table dump via ethtool interface.

root@am437x-evm:~# ./ethtool -d eth0
cpsw hw version 1.15 (0)
0   : type: vlan , vid = 1 untag_force = 0x3, reg_mcast = 0x3, unreg_mcast = 0x0, member_list = 0x3
1   : type: mcast, vid = 1, addr = ff:ff:ff:ff:ff:ff, mcast_state = f, no super, port_mask = 0x3
2   : type: ucast, vid = 1, addr = 20:cd:39:2b:c7:be, ucast_type = persistant, port_num = 0x0
3   : type: vlan , vid = 0 untag_force = 0x7, reg_mcast = 0x0, unreg_mcast = 0x0, member_list = 0x7
4   : type: mcast, vid = 1, addr = 01:00:5e:00:00:01, mcast_state = f, no super, port_mask = 0x3
6   : type: ucast, vid = 1, addr = 00:00:0c:07:ac:08, ucast_type = touched   , port_num = 0x1
12  : type: ucast, vid = 1, addr = 5c:f9:dd:76:28:8d, ucast_type = touched   , port_num = 0x1
14  : type: ucast, vid = 1, addr = d4:ae:52:c2:c4:5b, ucast_type = untouched , port_num = 0x1
15  : type: ucast, vid = 0, addr = 20:cd:39:2b:c7:be, ucast_type = touched   , port_num = 0x0
16  : type: ucast, vid = 1, addr = c0:8c:60:bb:a5:49, ucast_type = touched   , port_num = 0x1
17  : type: ucast, vid = 1, addr = 00:0f:8f:13:b2:8f, ucast_type = touched   , port_num = 0x1
19  : type: ucast, vid = 1, addr = bc:30:5b:d3:13:80, ucast_type = touched   , port_num = 0x1
26  : type: ucast, vid = 1, addr = 00:1a:a0:ae:c2:ee, ucast_type = untouched , port_num = 0x1
27  : type: ucast, vid = 1, addr = b8:ac:6f:8f:50:a3, ucast_type = touched   , port_num = 0x1
28  : type: ucast, vid = 1, addr = 00:08:a1:97:79:57, ucast_type = untouched , port_num = 0x1
32  : type: ucast, vid = 1, addr = f0:f7:55:7c:0e:49, ucast_type = touched   , port_num = 0x1
37  : type: ucast, vid = 1, addr = b8:ca:3a:b6:b0:20, ucast_type = untouched , port_num = 0x1
39  : type: ucast, vid = 1, addr = b8:ac:6f:8b:82:2c, ucast_type = untouched , port_num = 0x1
40  : type: ucast, vid = 1, addr = b8:ac:6f:90:7a:ab, ucast_type = untouched , port_num = 0x1
41  : type: ucast, vid = 1, addr = d4:be:d9:99:c8:3d, ucast_type = untouched , port_num = 0x1
42  : type: ucast, vid = 1, addr = 5c:26:0a:6e:d1:27, ucast_type = touched   , port_num = 0x1
49  : type: ucast, vid = 1, addr = d4:be:d9:9a:68:1d, ucast_type = touched   , port_num = 0x1
53  : type: ucast, vid = 1, addr = 00:1d:09:33:e4:ce, ucast_type = untouched , port_num = 0x1
54  : type: ucast, vid = 1, addr = 00:26:b9:8c:4e:90, ucast_type = untouched , port_num = 0x1
---

 drivers/net/ethernet/ti/cpsw.c     | 24 +++++++++++++++++++++++-
 drivers/net/ethernet/ti/cpsw_ale.c | 12 ++++++++++--
 drivers/net/ethernet/ti/cpsw_ale.h |  4 ++++
 3 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 62d49e9..c9e86b1 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1751,14 +1751,34 @@ static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_vlan_rx_kill_vid	= cpsw_ndo_vlan_rx_kill_vid,
 };
 
+static int cpsw_get_regs_len(struct net_device *ndev)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+
+	return priv->data.ale_entries * ALE_ENTRY_WORDS * sizeof(u32);
+}
+
+static void cpsw_get_regs(struct net_device *ndev,
+			  struct ethtool_regs *regs, void *p)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	u32 *reg = p;
+
+	/* update CPSW IP version */
+	regs->version = priv->version;
+
+	cpsw_ale_dump(priv->ale, reg);
+}
+
 static void cpsw_get_drvinfo(struct net_device *ndev,
 			     struct ethtool_drvinfo *info)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 
-	strlcpy(info->driver, "TI CPSW Driver v1.0", sizeof(info->driver));
+	strlcpy(info->driver, "cpsw", sizeof(info->driver));
 	strlcpy(info->version, "1.0", sizeof(info->version));
 	strlcpy(info->bus_info, priv->pdev->name, sizeof(info->bus_info));
+	info->regdump_len = cpsw_get_regs_len(ndev);
 }
 
 static u32 cpsw_get_msglevel(struct net_device *ndev)
@@ -1866,6 +1886,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_ethtool_stats	= cpsw_get_ethtool_stats,
 	.get_wol	= cpsw_get_wol,
 	.set_wol	= cpsw_set_wol,
+	.get_regs_len	= cpsw_get_regs_len,
+	.get_regs	= cpsw_get_regs,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index 7f89306..0579b22 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -25,8 +25,6 @@
 #include "cpsw_ale.h"
 
 #define BITMASK(bits)		(BIT(bits) - 1)
-#define ALE_ENTRY_BITS		68
-#define ALE_ENTRY_WORDS	DIV_ROUND_UP(ALE_ENTRY_BITS, 32)
 
 #define ALE_VERSION_MAJOR(rev)	((rev >> 8) & 0xff)
 #define ALE_VERSION_MINOR(rev)	(rev & 0xff)
@@ -763,3 +761,13 @@ int cpsw_ale_destroy(struct cpsw_ale *ale)
 	kfree(ale);
 	return 0;
 }
+
+void cpsw_ale_dump(struct cpsw_ale *ale, u32 *data)
+{
+	int i;
+
+	for (i = 0; i < ale->params.ale_entries; i++) {
+		cpsw_ale_read(ale, i, data);
+		data += ALE_ENTRY_WORDS;
+	}
+}
diff --git a/drivers/net/ethernet/ti/cpsw_ale.h b/drivers/net/ethernet/ti/cpsw_ale.h
index de409c3..31cf43c 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.h
+++ b/drivers/net/ethernet/ti/cpsw_ale.h
@@ -80,6 +80,9 @@ enum cpsw_ale_port_state {
 #define ALE_MCAST_FWD_LEARN		2
 #define ALE_MCAST_FWD_2			3
 
+#define ALE_ENTRY_BITS		68
+#define ALE_ENTRY_WORDS	DIV_ROUND_UP(ALE_ENTRY_BITS, 32)
+
 struct cpsw_ale *cpsw_ale_create(struct cpsw_ale_params *params);
 int cpsw_ale_destroy(struct cpsw_ale *ale);
 
@@ -104,5 +107,6 @@ int cpsw_ale_del_vlan(struct cpsw_ale *ale, u16 vid, int port);
 int cpsw_ale_control_get(struct cpsw_ale *ale, int port, int control);
 int cpsw_ale_control_set(struct cpsw_ale *ale, int port,
 			 int control, int value);
+void cpsw_ale_dump(struct cpsw_ale *ale, u32 *data);
 
 #endif
-- 
2.0.0.390.gcb682f8
