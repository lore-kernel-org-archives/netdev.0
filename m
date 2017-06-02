From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Move dsa_switch_{suspend,resume} out of legacy.c
Date: Thu,  1 Jun 2017 19:53:04 -0700
Message-ID: <20170602025304.14298-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dsa_switch_suspend() and dsa_switch_resume() are functions that belong in
net/dsa/dsa.c and are not part of the legacy platform support code.

Fixes: a6a71f19fe5e ("net: dsa: isolate legacy code")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c    | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/legacy.c | 47 -----------------------------------------------
 2 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 26130ae438da..90038d45a547 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -223,6 +223,53 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 	return 0;
 }
 
+#ifdef CONFIG_PM_SLEEP
+int dsa_switch_suspend(struct dsa_switch *ds)
+{
+	int i, ret = 0;
+
+	/* Suspend slave network devices */
+	for (i = 0; i < ds->num_ports; i++) {
+		if (!dsa_is_port_initialized(ds, i))
+			continue;
+
+		ret = dsa_slave_suspend(ds->ports[i].netdev);
+		if (ret)
+			return ret;
+	}
+
+	if (ds->ops->suspend)
+		ret = ds->ops->suspend(ds);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(dsa_switch_suspend);
+
+int dsa_switch_resume(struct dsa_switch *ds)
+{
+	int i, ret = 0;
+
+	if (ds->ops->resume)
+		ret = ds->ops->resume(ds);
+
+	if (ret)
+		return ret;
+
+	/* Resume slave network devices */
+	for (i = 0; i < ds->num_ports; i++) {
+		if (!dsa_is_port_initialized(ds, i))
+			continue;
+
+		ret = dsa_slave_resume(ds->ports[i].netdev);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dsa_switch_resume);
+#endif
+
 static struct packet_type dsa_pack_type __read_mostly = {
 	.type	= cpu_to_be16(ETH_P_XDSA),
 	.func	= dsa_switch_rcv,
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index ad345c8b0b06..7281098df04e 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -289,53 +289,6 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 	dsa_switch_unregister_notifier(ds);
 }
 
-#ifdef CONFIG_PM_SLEEP
-int dsa_switch_suspend(struct dsa_switch *ds)
-{
-	int i, ret = 0;
-
-	/* Suspend slave network devices */
-	for (i = 0; i < ds->num_ports; i++) {
-		if (!dsa_is_port_initialized(ds, i))
-			continue;
-
-		ret = dsa_slave_suspend(ds->ports[i].netdev);
-		if (ret)
-			return ret;
-	}
-
-	if (ds->ops->suspend)
-		ret = ds->ops->suspend(ds);
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(dsa_switch_suspend);
-
-int dsa_switch_resume(struct dsa_switch *ds)
-{
-	int i, ret = 0;
-
-	if (ds->ops->resume)
-		ret = ds->ops->resume(ds);
-
-	if (ret)
-		return ret;
-
-	/* Resume slave network devices */
-	for (i = 0; i < ds->num_ports; i++) {
-		if (!dsa_is_port_initialized(ds, i))
-			continue;
-
-		ret = dsa_slave_resume(ds->ports[i].netdev);
-		if (ret)
-			return ret;
-	}
-
-	return 0;
-}
-EXPORT_SYMBOL_GPL(dsa_switch_resume);
-#endif
-
 /* platform driver init and cleanup *****************************************/
 static int dev_is_class(struct device *dev, void *class)
 {
-- 
2.11.0
