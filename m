From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 3/7] net: dsa: use temporary dsa_device_ops variable
Date: Fri, 29 Sep 2017 17:19:17 -0400
Message-ID: <20170929211921.5571-4-vivien.didelot@savoirfairelinux.com>
References: <20170929211921.5571-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40258 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752255AbdI2VXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 17:23:30 -0400
In-Reply-To: <20170929211921.5571-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When resolving the DSA tagging protocol used by a CPU switch, use a
temporary "tag_ops" variable to store the dsa_device_ops instead of
using directly dst->tag_ops. This will make the future patches moving
this pointer around easier to read.

There is no functional changes.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c   | 8 +++++---
 net/dsa/legacy.c | 8 +++++---
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index dcccaebde708..6a10c5c1639f 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -485,6 +485,7 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 			 struct dsa_switch_tree *dst,
 			 struct dsa_switch *ds)
 {
+	const struct dsa_device_ops *tag_ops;
 	enum dsa_tag_protocol tag_protocol;
 	struct net_device *ethernet_dev;
 	struct device_node *ethernet;
@@ -514,13 +515,14 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	ds->cpu_port_mask |= BIT(index);
 
 	tag_protocol = ds->ops->get_tag_protocol(ds);
-	dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
-	if (IS_ERR(dst->tag_ops)) {
+	tag_ops = dsa_resolve_tag_protocol(tag_protocol);
+	if (IS_ERR(tag_ops)) {
 		dev_warn(ds->dev, "No tagger for this switch\n");
 		ds->cpu_port_mask &= ~BIT(index);
-		return PTR_ERR(dst->tag_ops);
+		return PTR_ERR(tag_ops);
 	}
 
+	dst->tag_ops = tag_ops;
 	dst->rcv = dst->tag_ops->rcv;
 
 	return 0;
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index ae505d8e4417..8e849013f69d 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -144,13 +144,15 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 	 * switch.
 	 */
 	if (dst->cpu_dp->ds == ds) {
+		const struct dsa_device_ops *tag_ops;
 		enum dsa_tag_protocol tag_protocol;
 
 		tag_protocol = ops->get_tag_protocol(ds);
-		dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
-		if (IS_ERR(dst->tag_ops))
-			return PTR_ERR(dst->tag_ops);
+		tag_ops = dsa_resolve_tag_protocol(tag_protocol);
+		if (IS_ERR(tag_ops))
+			return PTR_ERR(tag_ops);
 
+		dst->tag_ops = tag_ops;
 		dst->rcv = dst->tag_ops->rcv;
 	}
 
-- 
2.14.1
