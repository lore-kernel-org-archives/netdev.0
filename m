From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: dsa: loop: Implement ethtool statistics
Date: Thu, 15 Jun 2017 10:15:53 -0700
Message-ID: <20170615171553.16482-3-f.fainelli@gmail.com>
References: <20170615171553.16482-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34420 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdFORQG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 13:16:06 -0400
Received: by mail-wr0-f193.google.com with SMTP id y25so2140802wrd.1
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 10:16:06 -0700 (PDT)
In-Reply-To: <20170615171553.16482-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a DSA driver implements ethtool statistics, we also override the
master network device's ethtool statistics with the CPU port's
statistics and this has proven to be a possible source of bugs in the
past. Enhance the dsa_loop.c driver to provide statistics under the
forme of ok/error reads and writes from the per-port PHY read/writes.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/dsa_loop.c | 79 ++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 77 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index fb888593c2e9..fdd8f3872102 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -14,6 +14,7 @@
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 #include <linux/export.h>
+#include <linux/ethtool.h>
 #include <linux/workqueue.h>
 #include <linux/module.h>
 #include <linux/if_bridge.h>
@@ -26,6 +27,30 @@ struct dsa_loop_vlan {
 	u16 untagged;
 };
 
+struct dsa_loop_mib_entry {
+	char name[ETH_GSTRING_LEN];
+	unsigned long val;
+};
+
+enum dsa_loop_mib_counters {
+	DSA_LOOP_PHY_READ_OK,
+	DSA_LOOP_PHY_READ_ERR,
+	DSA_LOOP_PHY_WRITE_OK,
+	DSA_LOOP_PHY_WRITE_ERR,
+	__DSA_LOOP_CNT_MAX,
+};
+
+static struct dsa_loop_mib_entry dsa_loop_mibs[] = {
+	[DSA_LOOP_PHY_READ_OK]	= { "phy_read_ok", },
+	[DSA_LOOP_PHY_READ_ERR]	= { "phy_read_err", },
+	[DSA_LOOP_PHY_WRITE_OK] = { "phy_write_ok", },
+	[DSA_LOOP_PHY_WRITE_ERR] = { "phy_write_err", },
+};
+
+struct dsa_loop_port {
+	struct dsa_loop_mib_entry mib[__DSA_LOOP_CNT_MAX];
+};
+
 #define DSA_LOOP_VLANS	5
 
 struct dsa_loop_priv {
@@ -33,6 +58,7 @@ struct dsa_loop_priv {
 	unsigned int	port_base;
 	struct dsa_loop_vlan vlans[DSA_LOOP_VLANS];
 	struct net_device *netdev;
+	struct dsa_loop_port ports[DSA_MAX_PORTS];
 	u16 pvid;
 };
 
@@ -47,11 +73,43 @@ static enum dsa_tag_protocol dsa_loop_get_protocol(struct dsa_switch *ds)
 
 static int dsa_loop_setup(struct dsa_switch *ds)
 {
+	struct dsa_loop_priv *ps = ds->priv;
+	unsigned int i;
+
+	for (i = 0; i < ds->num_ports; i++)
+		memcpy(ps->ports[i].mib, dsa_loop_mibs,
+		       sizeof(dsa_loop_mibs));
+
 	dev_dbg(ds->dev, "%s\n", __func__);
 
 	return 0;
 }
 
+static int dsa_loop_get_sset_count(struct dsa_switch *ds)
+{
+	return __DSA_LOOP_CNT_MAX;
+}
+
+static void dsa_loop_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
+{
+	struct dsa_loop_priv *ps = ds->priv;
+	unsigned int i;
+
+	for (i = 0; i < __DSA_LOOP_CNT_MAX; i++)
+		memcpy(data + i * ETH_GSTRING_LEN,
+		       ps->ports[port].mib[i].name, ETH_GSTRING_LEN);
+}
+
+static void dsa_loop_get_ethtool_stats(struct dsa_switch *ds, int port,
+				       uint64_t *data)
+{
+	struct dsa_loop_priv *ps = ds->priv;
+	unsigned int i;
+
+	for (i = 0; i < __DSA_LOOP_CNT_MAX; i++)
+		data[i] = ps->ports[port].mib[i].val;
+}
+
 static int dsa_loop_set_addr(struct dsa_switch *ds, u8 *addr)
 {
 	dev_dbg(ds->dev, "%s\n", __func__);
@@ -63,10 +121,17 @@ static int dsa_loop_phy_read(struct dsa_switch *ds, int port, int regnum)
 {
 	struct dsa_loop_priv *ps = ds->priv;
 	struct mii_bus *bus = ps->bus;
+	int ret;
 
 	dev_dbg(ds->dev, "%s\n", __func__);
 
-	return mdiobus_read_nested(bus, ps->port_base + port, regnum);
+	ret = mdiobus_read_nested(bus, ps->port_base + port, regnum);
+	if (ret < 0)
+		ps->ports[port].mib[DSA_LOOP_PHY_READ_ERR].val++;
+	else
+		ps->ports[port].mib[DSA_LOOP_PHY_READ_OK].val++;
+
+	return ret;
 }
 
 static int dsa_loop_phy_write(struct dsa_switch *ds, int port,
@@ -74,10 +139,17 @@ static int dsa_loop_phy_write(struct dsa_switch *ds, int port,
 {
 	struct dsa_loop_priv *ps = ds->priv;
 	struct mii_bus *bus = ps->bus;
+	int ret;
 
 	dev_dbg(ds->dev, "%s\n", __func__);
 
-	return mdiobus_write_nested(bus, ps->port_base + port, regnum, value);
+	ret = mdiobus_write_nested(bus, ps->port_base + port, regnum, value);
+	if (ret < 0)
+		ps->ports[port].mib[DSA_LOOP_PHY_WRITE_ERR].val++;
+	else
+		ps->ports[port].mib[DSA_LOOP_PHY_WRITE_OK].val++;
+
+	return ret;
 }
 
 static int dsa_loop_port_bridge_join(struct dsa_switch *ds, int port,
@@ -225,6 +297,9 @@ static int dsa_loop_port_vlan_dump(struct dsa_switch *ds, int port,
 static struct dsa_switch_ops dsa_loop_driver = {
 	.get_tag_protocol	= dsa_loop_get_protocol,
 	.setup			= dsa_loop_setup,
+	.get_strings		= dsa_loop_get_strings,
+	.get_ethtool_stats	= dsa_loop_get_ethtool_stats,
+	.get_sset_count		= dsa_loop_get_sset_count,
 	.set_addr		= dsa_loop_set_addr,
 	.phy_read		= dsa_loop_phy_read,
 	.phy_write		= dsa_loop_phy_write,
-- 
2.9.3
