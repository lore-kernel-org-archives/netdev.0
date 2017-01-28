From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/4] net: dsa: b53: Add support for port mirroring
Date: Fri, 27 Jan 2017 17:25:27 -0800
Message-ID: <20170128012528.30524-4-f.fainelli@gmail.com>
References: <20170128012528.30524-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33691 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751230AbdA1B31 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 20:29:27 -0500
Received: by mail-pf0-f194.google.com with SMTP id e4so19456285pfg.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 17:29:27 -0800 (PST)
In-Reply-To: <20170128012528.30524-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for configuring port mirroring through the cls_matchall
classifier. We do a full ingress or egress capture towards the capture
port. Future improvements could include leveraging the divider to allow
less frames to be captured, as well as matching specific MAC DA/SA.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 67 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/b53/b53_priv.h   |  4 +++
 2 files changed, 71 insertions(+)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index bb210b12ad1b..052ff4c22667 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1453,6 +1453,71 @@ static enum dsa_tag_protocol b53_get_tag_protocol(struct dsa_switch *ds)
 	return DSA_TAG_PROTO_NONE;
 }
 
+int b53_mirror_add(struct dsa_switch *ds, int port,
+		   struct dsa_mall_mirror_tc_entry *mirror, bool ingress)
+{
+	struct b53_device *dev = ds->priv;
+	u16 reg, loc;
+
+	if (ingress)
+		loc = B53_IG_MIR_CTL;
+	else
+		loc = B53_EG_MIR_CTL;
+
+	b53_read16(dev, B53_MGMT_PAGE, loc, &reg);
+	reg &= ~MIRROR_MASK;
+	reg |= BIT(port);
+	b53_write16(dev, B53_MGMT_PAGE, loc, reg);
+
+	b53_read16(dev, B53_MGMT_PAGE, B53_MIR_CAP_CTL, &reg);
+	reg &= ~CAP_PORT_MASK;
+	reg |= mirror->to_local_port;
+	reg |= MIRROR_EN;
+	b53_write16(dev, B53_MGMT_PAGE, B53_MIR_CAP_CTL, reg);
+
+	return 0;
+}
+EXPORT_SYMBOL(b53_mirror_add);
+
+void b53_mirror_del(struct dsa_switch *ds, int port,
+		    struct dsa_mall_mirror_tc_entry *mirror)
+{
+	struct b53_device *dev = ds->priv;
+	bool loc_disable = false, other_loc_disable = false;
+	u16 reg, loc;
+
+	if (mirror->ingress)
+		loc = B53_IG_MIR_CTL;
+	else
+		loc = B53_EG_MIR_CTL;
+
+	/* Update the desired ingress/egress register */
+	b53_read16(dev, B53_MGMT_PAGE, loc, &reg);
+	reg &= ~BIT(port);
+	if (!(reg & MIRROR_MASK))
+		loc_disable = true;
+	b53_write16(dev, B53_MGMT_PAGE, loc, reg);
+
+	/* Now look at the other one to know if we can disable mirroring
+	 * entirely
+	 */
+	if (mirror->ingress)
+		b53_read16(dev, B53_MGMT_PAGE, B53_EG_MIR_CTL, &reg);
+	else
+		b53_read16(dev, B53_MGMT_PAGE, B53_IG_MIR_CTL, &reg);
+	if (!(reg & MIRROR_MASK))
+		other_loc_disable = true;
+
+	b53_read16(dev, B53_MGMT_PAGE, B53_MIR_CAP_CTL, &reg);
+	/* Both no longer have ports, let's disable mirroring */
+	if (loc_disable && other_loc_disable) {
+		reg &= ~MIRROR_EN;
+		reg &= ~mirror->to_local_port;
+	}
+	b53_write16(dev, B53_MGMT_PAGE, B53_MIR_CAP_CTL, reg);
+}
+EXPORT_SYMBOL(b53_mirror_del);
+
 static const struct dsa_switch_ops b53_switch_ops = {
 	.get_tag_protocol	= b53_get_tag_protocol,
 	.setup			= b53_setup,
@@ -1477,6 +1542,8 @@ static const struct dsa_switch_ops b53_switch_ops = {
 	.port_fdb_dump		= b53_fdb_dump,
 	.port_fdb_add		= b53_fdb_add,
 	.port_fdb_del		= b53_fdb_del,
+	.port_mirror_add	= b53_mirror_add,
+	.port_mirror_del	= b53_mirror_del,
 };
 
 struct b53_chip_data {
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index a8031b382c55..28ffe255276f 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -408,5 +408,9 @@ int b53_fdb_del(struct dsa_switch *ds, int port,
 int b53_fdb_dump(struct dsa_switch *ds, int port,
 		 struct switchdev_obj_port_fdb *fdb,
 		 int (*cb)(struct switchdev_obj *obj));
+int b53_mirror_add(struct dsa_switch *ds, int port,
+		   struct dsa_mall_mirror_tc_entry *mirror, bool ingress);
+void b53_mirror_del(struct dsa_switch *ds, int port,
+		    struct dsa_mall_mirror_tc_entry *mirror);
 
 #endif
-- 
2.9.3
