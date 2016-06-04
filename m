From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/9] net: dsa: Add support for parsing the old binding
Date: Fri,  3 Jun 2016 17:05:24 -0700
Message-ID: <1464998733-10405-5-git-send-email-f.fainelli@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33583 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbcFDAFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:05:50 -0400
Received: by mail-pa0-f67.google.com with SMTP id di3so6951315pab.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:05:50 -0700 (PDT)
In-Reply-To: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend dsa2.c to support parsing for the old binding, which mostly means
looking for more or less the same properties in different places.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 142 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 126 insertions(+), 16 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index b5640d8ffbae..23273fd984a8 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -408,21 +408,11 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 	dst->applied = false;
 }
 
-static int dsa_cpu_parse(struct device_node *port, u32 index,
-			 struct dsa_switch_tree *dst,
-			 struct dsa_switch *ds)
+static int _dsa_cpu_parse(struct dsa_switch_tree *dst,
+			   struct dsa_switch *ds,
+			   struct net_device *ethernet_dev,
+			   u32 index)
 {
-	struct net_device *ethernet_dev;
-	struct device_node *ethernet;
-
-	ethernet = of_parse_phandle(port, "ethernet", 0);
-	if (!ethernet)
-		return -EINVAL;
-
-	ethernet_dev = of_find_net_device_by_node(ethernet);
-	if (!ethernet_dev)
-		return -EPROBE_DEFER;
-
 	if (!ds->master_netdev)
 		ds->master_netdev = ethernet_dev;
 
@@ -445,6 +435,24 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
 	return 0;
 }
 
+static int dsa_cpu_parse(struct device_node *port, u32 index,
+			 struct dsa_switch_tree *dst,
+			 struct dsa_switch *ds)
+{
+	struct net_device *ethernet_dev;
+	struct device_node *ethernet;
+
+	ethernet = of_parse_phandle(port, "ethernet", 0);
+	if (!ethernet)
+		return -EINVAL;
+
+	ethernet_dev = of_find_net_device_by_node(ethernet);
+	if (!ethernet_dev)
+		return -EPROBE_DEFER;
+
+	return _dsa_cpu_parse(dst, ds, ethernet_dev, index);
+}
+
 static int dsa_ds_parse(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 {
 	struct device_node *port;
@@ -552,6 +560,108 @@ static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 	return ports;
 }
 
+static int _dsa_register_switch_legacy(struct dsa_switch *ds, struct device_node *np)
+{
+	const char *compat = of_get_property(np, "compatible", NULL);
+	struct device_node *dn, *ethernet;
+	struct net_device *ethernet_dev;
+	struct dsa_switch_tree *dst;
+	u32 tree = 0, index;
+	int err;
+
+	/* Tree is implied by how many devices are present in the DT with the
+	 * supported compatible strings from net/dsa/dsa.c
+	 */
+	for_each_compatible_node(dn, NULL, compat) {
+		if (dn != np)
+			tree++;
+	}
+
+	/* index is present in the "reg" property, second cell */
+	err = of_property_read_u32_index(np->child, "reg", 1, &index);
+	if (err)
+		return err;
+
+	if (index >= DSA_MAX_SWITCHES)
+		return -EINVAL;
+
+	err = dsa_parse_ports_dn(np->child, ds);
+	if (err)
+		return err;
+
+	dst = dsa_get_dst(tree);
+	if (!dst) {
+		dst = dsa_add_dst(tree);
+		if (!dst)
+			return -ENOMEM;
+	}
+
+	if (dst->ds[index]) {
+		err = -EBUSY;
+		goto out;
+	}
+
+	ds->dst = dst;
+	ds->index = index;
+	dsa_dst_add_ds(dst, ds, index);
+
+	err = dsa_dst_complete(dst);
+	if (err < 0)
+		goto out;
+
+	if (err == 1) {
+		/* Not all switches registered yet */
+		err = 0;
+		goto out;
+	}
+
+	if (dst->applied) {
+		pr_info("DSA: Disjoint trees?\n");
+		err = -EINVAL;
+		goto out_del_dst;
+	}
+
+	ethernet = of_parse_phandle(np, "dsa,ethernet", 0);
+	if (!ethernet) {
+		err = -EINVAL;
+		goto out_del_dst;
+	}
+
+	ethernet_dev = of_find_net_device_by_node(ethernet);
+	if (!ethernet_dev) {
+		err = -EPROBE_DEFER;
+		goto out_del_dst;
+	}
+
+	err = _dsa_cpu_parse(dst, ds, ethernet_dev, index);
+	if (err)
+		goto out_del_dst;
+
+	if (!dst->master_netdev) {
+		pr_warn("Tree has no master device\n");
+		goto out_del_dst;
+	}
+
+	pr_info("DSA: tree %d parsed\n", dst->tree);
+
+	err = dsa_dst_apply(dst);
+	if (err) {
+		dsa_dst_unapply(dst);
+		goto out_del_dst;
+	}
+
+	dsa_put_dst(dst);
+
+	return 0;
+
+out_del_dst:
+	dsa_dst_del_ds(dst, ds, ds->index);
+out:
+	dsa_put_dst(dst);
+
+	return err;
+}
+
 static int __dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
 {
 	struct device_node *ports = dsa_get_ports(ds, np);
@@ -626,8 +736,8 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
 {
 	struct device_node *ports = dsa_get_ports(ds, np);
 
-	if (IS_ERR(ports))
-		return PTR_ERR(ports);
+	if (IS_ERR(ports) && PTR_ERR(ports) == -EINVAL)
+		return _dsa_register_switch_legacy(ds, np);
 
 	return __dsa_register_switch(ds, np);
 }
-- 
2.7.4
