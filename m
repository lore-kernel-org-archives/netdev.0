From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 1/4] net: dsa: Allow the DSA driver to indicate the tag protocol
Date: Mon, 22 Aug 2016 16:01:01 +0200
Message-ID: <1471874464-16142-2-git-send-email-andrew@lunn.ch>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Cc: Jamie Lentin <jm@lentin.co.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40573 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754794AbcHVOMX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 10:12:23 -0400
In-Reply-To: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA drivers may drive different families of switches which need
different tag protocol. Rather than hard code the tag protocol in the
driver structure, have a callback for the DSA core to call.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/b53/b53_common.c | 7 ++++++-
 drivers/net/dsa/bcm_sf2.c        | 7 ++++++-
 drivers/net/dsa/mv88e6060.c      | 7 ++++++-
 drivers/net/dsa/mv88e6xxx/chip.c | 7 ++++++-
 include/net/dsa.h                | 5 +++--
 net/dsa/dsa.c                    | 5 ++++-
 net/dsa/dsa2.c                   | 4 +++-
 7 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 38ee10de7884..65ecb51f99e5 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1373,8 +1373,13 @@ static void b53_br_set_stp_state(struct dsa_switch *ds, int port,
 	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), reg);
 }
 
+static enum dsa_tag_protocol b53_get_tag_protocol(struct dsa_switch *ds)
+{
+	return DSA_TAG_PROTO_NONE;
+}
+
 static struct dsa_switch_driver b53_switch_ops = {
-	.tag_protocol		= DSA_TAG_PROTO_NONE,
+	.get_tag_protocol	= b53_get_tag_protocol,
 	.setup			= b53_setup,
 	.set_addr		= b53_set_addr,
 	.get_strings		= b53_get_strings,
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 8e6fe13dbec3..b47a74b37a42 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -136,6 +136,11 @@ static int bcm_sf2_sw_get_sset_count(struct dsa_switch *ds)
 	return BCM_SF2_STATS_SIZE;
 }
 
+static enum dsa_tag_protocol bcm_sf2_sw_get_tag_protocol(struct dsa_switch *ds)
+{
+	return DSA_TAG_PROTO_BRCM;
+}
+
 static void bcm_sf2_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
@@ -1577,8 +1582,8 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 }
 
 static struct dsa_switch_driver bcm_sf2_switch_driver = {
-	.tag_protocol		= DSA_TAG_PROTO_BRCM,
 	.setup			= bcm_sf2_sw_setup,
+	.get_tag_protocol	= bcm_sf2_sw_get_tag_protocol,
 	.set_addr		= bcm_sf2_sw_set_addr,
 	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
 	.get_strings		= bcm_sf2_sw_get_strings,
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index e36b40886bd8..1fdfbf3a50bc 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -69,6 +69,11 @@ static const char *mv88e6060_get_name(struct mii_bus *bus, int sw_addr)
 	return NULL;
 }
 
+static enum dsa_tag_protocol mv88e6060_get_tag_protocol(struct dsa_switch *ds)
+{
+	return DSA_TAG_PROTO_TRAILER;
+}
+
 static const char *mv88e6060_drv_probe(struct device *dsa_dev,
 				       struct device *host_dev, int sw_addr,
 				       void **_priv)
@@ -248,7 +253,7 @@ mv88e6060_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 }
 
 static struct dsa_switch_driver mv88e6060_switch_driver = {
-	.tag_protocol	= DSA_TAG_PROTO_TRAILER,
+	.get_tag_protocol = mv88e6060_get_tag_protocol,
 	.probe		= mv88e6060_drv_probe,
 	.setup		= mv88e6060_setup,
 	.set_addr	= mv88e6060_set_addr,
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 014b52bd72f1..63cad6c00bc7 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3924,6 +3924,11 @@ static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
+static enum dsa_tag_protocol mv88e6xxx_get_tag_protocol(struct dsa_switch *ds)
+{
+	return DSA_TAG_PROTO_EDSA;
+}
+
 static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 				       struct device *host_dev, int sw_addr,
 				       void **priv)
@@ -3967,8 +3972,8 @@ free:
 }
 
 static struct dsa_switch_driver mv88e6xxx_switch_driver = {
-	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.probe			= mv88e6xxx_drv_probe,
+	.get_tag_protocol	= mv88e6xxx_get_tag_protocol,
 	.setup			= mv88e6xxx_setup,
 	.set_addr		= mv88e6xxx_set_addr,
 	.adjust_link		= mv88e6xxx_adjust_link,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index d00c392bc9f8..8ca2684c5358 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -239,14 +239,15 @@ struct switchdev_obj_port_vlan;
 struct dsa_switch_driver {
 	struct list_head	list;
 
-	enum dsa_tag_protocol	tag_protocol;
-
 	/*
 	 * Probing and setup.
 	 */
 	const char	*(*probe)(struct device *dsa_dev,
 				  struct device *host_dev, int sw_addr,
 				  void **priv);
+
+	enum dsa_tag_protocol (*get_tag_protocol)(struct dsa_switch *ds);
+
 	int	(*setup)(struct dsa_switch *ds);
 	int	(*set_addr)(struct dsa_switch *ds, u8 *addr);
 	u32	(*get_phy_flags)(struct dsa_switch *ds, int port);
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 8bda74e595a5..8d3a28d4e99d 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -354,7 +354,10 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	 * switch.
 	 */
 	if (dst->cpu_switch == index) {
-		dst->tag_ops = dsa_resolve_tag_protocol(drv->tag_protocol);
+		enum dsa_tag_protocol tag_protocol;
+
+		tag_protocol = drv->get_tag_protocol(ds);
+		dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
 		if (IS_ERR(dst->tag_ops)) {
 			ret = PTR_ERR(dst->tag_ops);
 			goto out;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index f30bad9678f0..2e343221464c 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -443,6 +443,7 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
 			 struct dsa_switch_tree *dst,
 			 struct dsa_switch *ds)
 {
+	enum dsa_tag_protocol tag_protocol;
 	struct net_device *ethernet_dev;
 	struct device_node *ethernet;
 
@@ -465,7 +466,8 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
 		dst->cpu_port = index;
 	}
 
-	dst->tag_ops = dsa_resolve_tag_protocol(ds->drv->tag_protocol);
+	tag_protocol = ds->drv->get_tag_protocol(ds);
+	dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
 	if (IS_ERR(dst->tag_ops)) {
 		dev_warn(ds->dev, "No tagger for this switch\n");
 		return PTR_ERR(dst->tag_ops);
-- 
2.8.1
