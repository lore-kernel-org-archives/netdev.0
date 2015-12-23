From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 06/28] net: dsa: Have the switch driver allocate there own private memory
Date: Wed, 23 Dec 2015 13:56:20 +0100
Message-ID: <1450875402-20740-7-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48691 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757091AbbLWM5c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:57:32 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now the switch devices have a dev pointer, make use if it for allocating
the drivers private data structures using a devm_kzalloc().

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/bcm_sf2.c   |  7 +++++--
 drivers/net/dsa/mv88e6123.c |  6 +++---
 drivers/net/dsa/mv88e6131.c |  6 +++---
 drivers/net/dsa/mv88e6171.c |  6 +++---
 drivers/net/dsa/mv88e6352.c |  6 +++---
 drivers/net/dsa/mv88e6xxx.c | 13 ++++++++++---
 drivers/net/dsa/mv88e6xxx.h |  5 ++++-
 include/net/dsa.h           |  8 +++++++-
 8 files changed, 38 insertions(+), 19 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 6925b3c13895..23326c2a01b8 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -929,7 +929,7 @@ static void bcm_sf2_identify_ports(struct bcm_sf2_priv *priv,
 static int bcm_sf2_sw_setup(struct dsa_switch *ds, struct device *dev)
 {
 	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct bcm_sf2_priv *priv;
 	struct device_node *dn;
 	void __iomem **base;
 	unsigned int port;
@@ -937,6 +937,10 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds, struct device *dev)
 	u32 reg, rev;
 	int ret;
 
+	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
 	spin_lock_init(&priv->indir_lock);
 	mutex_init(&priv->stats_mutex);
 
@@ -1365,7 +1369,6 @@ static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
 
 static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_BRCM,
-	.priv_size		= sizeof(struct bcm_sf2_priv),
 	.probe			= bcm_sf2_sw_probe,
 	.setup			= bcm_sf2_sw_setup,
 	.set_addr		= bcm_sf2_sw_set_addr,
diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index fab428bb7545..9d39f108793b 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -70,13 +70,14 @@ static int mv88e6123_setup_global(struct dsa_switch *ds)
 
 static int mv88e6123_setup(struct dsa_switch *ds, struct device *dev)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_priv_state *ps;
 	int ret;
 
-	ret = mv88e6xxx_setup_common(ds);
+	ret = mv88e6xxx_setup_common(ds, dev);
 	if (ret < 0)
 		return ret;
 
+	ps = ds_to_priv(ds);
 	switch (ps->id) {
 	case PORT_SWITCH_ID_6123:
 		ps->num_ports = 3;
@@ -102,7 +103,6 @@ static int mv88e6123_setup(struct dsa_switch *ds, struct device *dev)
 
 struct dsa_switch_driver mv88e6123_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
-	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6123_probe,
 	.setup			= mv88e6123_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index d82cf3d38455..3103b4953af4 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -88,13 +88,14 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 
 static int mv88e6131_setup(struct dsa_switch *ds, struct device *dev)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_priv_state *ps;
 	int ret;
 
-	ret = mv88e6xxx_setup_common(ds);
+	ret = mv88e6xxx_setup_common(ds, dev);
 	if (ret < 0)
 		return ret;
 
+	ps = ds_to_priv(ds);
 	mv88e6xxx_ppu_state_init(ds);
 
 	switch (ps->id) {
@@ -159,7 +160,6 @@ mv88e6131_phy_write(struct dsa_switch *ds,
 
 struct dsa_switch_driver mv88e6131_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_DSA,
-	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6131_probe,
 	.setup			= mv88e6131_setup,
 	.set_addr		= mv88e6xxx_set_addr_direct,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 9635f14ec1fb..29a77366afc6 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -66,13 +66,14 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 
 static int mv88e6171_setup(struct dsa_switch *ds, struct device *dev)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_priv_state *ps;
 	int ret;
 
-	ret = mv88e6xxx_setup_common(ds);
+	ret = mv88e6xxx_setup_common(ds, dev);
 	if (ret < 0)
 		return ret;
 
+	ps = ds_to_priv(ds);
 	ps->num_ports = 7;
 
 	ret = mv88e6xxx_switch_reset(ds, true);
@@ -88,7 +89,6 @@ static int mv88e6171_setup(struct dsa_switch *ds, struct device *dev)
 
 struct dsa_switch_driver mv88e6171_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
-	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6171_probe,
 	.setup			= mv88e6171_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index c2c4153e3423..eb57a379b9cc 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -77,13 +77,14 @@ static int mv88e6352_setup_global(struct dsa_switch *ds)
 
 static int mv88e6352_setup(struct dsa_switch *ds, struct device *dev)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_priv_state *ps;
 	int ret;
 
-	ret = mv88e6xxx_setup_common(ds);
+	ret = mv88e6xxx_setup_common(ds, dev);
 	if (ret < 0)
 		return ret;
 
+	ps = ds_to_priv(ds);
 	ps->num_ports = 7;
 
 	mutex_init(&ps->eeprom_mutex);
@@ -301,7 +302,6 @@ static int mv88e6352_set_eeprom(struct dsa_switch *ds,
 
 struct dsa_switch_driver mv88e6352_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
-	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6352_probe,
 	.setup			= mv88e6352_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 529273676d36..772adc7f9397 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -281,7 +281,7 @@ static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
 
 	ps = container_of(ugly, struct mv88e6xxx_priv_state, ppu_work);
 	if (mutex_trylock(&ps->ppu_mutex)) {
-		struct dsa_switch *ds = ((struct dsa_switch *)ps) - 1;
+		struct dsa_switch *ds = ps->ds;
 
 		if (mv88e6xxx_ppu_enable(ds) == 0)
 			ps->ppu_disabled = 0;
@@ -2187,9 +2187,16 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 	return 0;
 }
 
-int mv88e6xxx_setup_common(struct dsa_switch *ds)
+int mv88e6xxx_setup_common(struct dsa_switch *ds, struct device *dev)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_priv_state *ps;
+
+	ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
+	if (!ps)
+		return -ENOMEM;
+
+	ds->priv = ps;
+	ps->ds = ds;
 
 	mutex_init(&ps->smi_mutex);
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 9e5c56800b7b..72f7dbbce0e2 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -379,6 +379,9 @@ struct mv88e6xxx_vtu_stu_entry {
 };
 
 struct mv88e6xxx_priv_state {
+	/* The dsa_switch this private structure is related to */
+	struct dsa_switch *ds;
+
 	/* When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
 	 * mode, this mutex is effectively useless.)
@@ -431,7 +434,7 @@ char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
 			    const struct mv88e6xxx_switch_id *table,
 			    unsigned int num);
 int mv88e6xxx_setup_ports(struct dsa_switch *ds);
-int mv88e6xxx_setup_common(struct dsa_switch *ds);
+int mv88e6xxx_setup_common(struct dsa_switch *ds, struct device *dev);
 int mv88e6xxx_setup_global(struct dsa_switch *ds);
 int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg);
 int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val);
diff --git a/include/net/dsa.h b/include/net/dsa.h
index f5b4f1bcfdf3..05067b030962 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -130,6 +130,12 @@ struct dsa_switch {
 	int			index;
 
 	/*
+	 * Give the switch driver somewhere to hang its private data
+	 * structure.
+	 */
+	void *priv;
+
+	/*
 	 * Tagging protocol understood by this switch
 	 */
 	enum dsa_tag_protocol	tag_protocol;
@@ -340,7 +346,7 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
 
 static inline void *ds_to_priv(struct dsa_switch *ds)
 {
-	return (void *)(ds + 1);
+	return ds->priv;
 }
 
 static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
-- 
2.6.3
