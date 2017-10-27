From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/7] net: dsa: get master device at port parsing time
Date: Fri, 27 Oct 2017 15:55:17 -0400
Message-ID: <20171027195519.5931-6-vivien.didelot@savoirfairelinux.com>
References: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:47344 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932450AbdJ0Tze (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 15:55:34 -0400
In-Reply-To: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fetching the master device can be done directly when a port is parsed
from device tree or pdata, instead of waiting until dsa_dst_parse.

Now that -EPROBE_DEFER is returned before we add the switch to the tree,
there is no need to check for this error after dsa_dst_parse.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c | 44 ++++++++++++++++++--------------------------
 1 file changed, 18 insertions(+), 26 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 5b9dea81d617..be43e06caf7e 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -470,27 +470,9 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 {
 	const struct dsa_device_ops *tag_ops;
 	enum dsa_tag_protocol tag_protocol;
-	struct net_device *ethernet_dev;
-	struct device_node *ethernet;
 
-	if (port->dn) {
-		ethernet = of_parse_phandle(port->dn, "ethernet", 0);
-		if (!ethernet)
-			return -EINVAL;
-		ethernet_dev = of_find_net_device_by_node(ethernet);
-		if (!ethernet_dev)
-			return -EPROBE_DEFER;
-	} else {
-		ethernet_dev = dsa_dev_to_net_device(ds->cd->netdev[index]);
-		if (!ethernet_dev)
-			return -EPROBE_DEFER;
-		dev_put(ethernet_dev);
-	}
-
-	if (!dst->cpu_dp) {
+	if (!dst->cpu_dp)
 		dst->cpu_dp = port;
-		dst->cpu_dp->master = ethernet_dev;
-	}
 
 	tag_protocol = ds->ops->get_tag_protocol(ds);
 	tag_ops = dsa_resolve_tag_protocol(tag_protocol);
@@ -584,7 +566,14 @@ static int dsa_port_parse_of(struct dsa_port *dp, struct device_node *dn)
 	struct device_node *link = of_parse_phandle(dn, "link", 0);
 
 	if (ethernet) {
+		struct net_device *master;
+
+		master = of_find_net_device_by_node(ethernet);
+		if (!master)
+			return -EPROBE_DEFER;
+
 		dp->type = DSA_PORT_TYPE_CPU;
+		dp->master = master;
 	} else if (link) {
 		dp->type = DSA_PORT_TYPE_DSA;
 	} else {
@@ -631,7 +620,16 @@ static int dsa_port_parse(struct dsa_port *dp, const char *name,
 			  struct device *dev)
 {
 	if (!strcmp(name, "cpu")) {
+		struct net_device *master;
+
+		master = dsa_dev_to_net_device(dev);
+		if (!master)
+			return -EPROBE_DEFER;
+
+		dev_put(master);
+
 		dp->type = DSA_PORT_TYPE_CPU;
+		dp->master = master;
 	} else if (!strcmp(name, "dsa")) {
 		dp->type = DSA_PORT_TYPE_DSA;
 	} else {
@@ -773,14 +771,8 @@ static int _dsa_register_switch(struct dsa_switch *ds)
 	}
 
 	err = dsa_dst_parse(dst);
-	if (err) {
-		if (err == -EPROBE_DEFER) {
-			dsa_dst_del_ds(dst, ds, ds->index);
-			return err;
-		}
-
+	if (err)
 		goto out_del_dst;
-	}
 
 	err = dsa_dst_apply(dst);
 	if (err) {
-- 
2.14.3
