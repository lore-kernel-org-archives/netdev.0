From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH net-next] net: dsa: Introduce dsa_is_port_initialized
Date: Tue, 24 Feb 2015 23:02:02 -0800
Message-ID: <1424847723-31140-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:35883 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbbBYHCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 02:02:21 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YQVzA-003am6-Ic
	for netdev@vger.kernel.org; Wed, 25 Feb 2015 07:02:20 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid race conditions when using the ds->ports[] array,
we need to check if the accessed port has been initialized.
Introduce and use helper function dsa_is_port_initialized
for that purpose and use it where needed.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Applies to net-next on top of Florian's patches adding HW bridging support
to dsa.

 include/net/dsa.h | 5 +++++
 net/dsa/dsa.c     | 4 ++--
 net/dsa/slave.c   | 5 +----
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 92be3479..c542c13 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -165,6 +165,11 @@ static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
 	return !!(ds->index == ds->dst->cpu_switch && p == ds->dst->cpu_port);
 }
 
+static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
+{
+	return ds->phys_port_mask & (1 << p) && ds->ports[p];
+}
+
 static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 {
 	struct dsa_switch_tree *dst = ds->dst;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 9c208f0..a1d1f07 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -374,7 +374,7 @@ static int dsa_switch_suspend(struct dsa_switch *ds)
 
 	/* Suspend slave network devices */
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
-		if (!(ds->phys_port_mask & (1 << i)))
+		if (!dsa_is_port_initialized(ds, i))
 			continue;
 
 		ret = dsa_slave_suspend(ds->ports[i]);
@@ -400,7 +400,7 @@ static int dsa_switch_resume(struct dsa_switch *ds)
 
 	/* Resume slave network devices */
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
-		if (!(ds->phys_port_mask & (1 << i)))
+		if (!dsa_is_port_initialized(ds, i))
 			continue;
 
 		ret = dsa_slave_resume(ds->ports[i]);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index b5a4d89..a47305c 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -222,10 +222,7 @@ static u32 dsa_slave_br_port_mask(struct dsa_switch *ds,
 	u32 mask = 0;
 
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
-		if (!((1 << port) & ds->phys_port_mask))
-			continue;
-
-		if (!ds->ports[port])
+		if (!dsa_is_port_initialized(ds, port))
 			continue;
 
 		p = netdev_priv(ds->ports[port]);
-- 
2.1.0
