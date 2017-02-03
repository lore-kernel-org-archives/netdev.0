From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/6] net: dsa: move netdevice notifier registration
Date: Fri,  3 Feb 2017 13:20:16 -0500
Message-ID: <20170203182021.14246-2-vivien.didelot@savoirfairelinux.com>
References: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the netdevice notifier block register code in slave.c and provide
helpers for dsa.c to register and unregister it.

At the same time, check for errors since (un)register_netdevice_notifier
may fail.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa.c      | 10 ++++------
 net/dsa/dsa_priv.h |  4 ++--
 net/dsa/slave.c    | 22 ++++++++++++++++++++--
 3 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 619e57a44d1d..beb79ccf0f59 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -903,10 +903,6 @@ static struct packet_type dsa_pack_type __read_mostly = {
 	.func	= dsa_switch_rcv,
 };
 
-static struct notifier_block dsa_netdevice_nb __read_mostly = {
-	.notifier_call	= dsa_slave_netdevice_event,
-};
-
 #ifdef CONFIG_PM_SLEEP
 static int dsa_suspend(struct device *d)
 {
@@ -964,7 +960,9 @@ static int __init dsa_init_module(void)
 {
 	int rc;
 
-	register_netdevice_notifier(&dsa_netdevice_nb);
+	rc = dsa_slave_register_notifier();
+	if (rc)
+		return rc;
 
 	rc = platform_driver_register(&dsa_driver);
 	if (rc)
@@ -978,7 +976,7 @@ module_init(dsa_init_module);
 
 static void __exit dsa_cleanup_module(void)
 {
-	unregister_netdevice_notifier(&dsa_netdevice_nb);
+	dsa_slave_unregister_notifier();
 	dev_remove_pack(&dsa_pack_type);
 	platform_driver_unregister(&dsa_driver);
 }
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index a5509b765fc0..591a40aea9ca 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -63,8 +63,8 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 void dsa_slave_destroy(struct net_device *slave_dev);
 int dsa_slave_suspend(struct net_device *slave_dev);
 int dsa_slave_resume(struct net_device *slave_dev);
-int dsa_slave_netdevice_event(struct notifier_block *unused,
-			      unsigned long event, void *ptr);
+int dsa_slave_register_notifier(void);
+void dsa_slave_unregister_notifier(void);
 
 /* tag_dsa.c */
 extern const struct dsa_device_ops dsa_netdev_ops;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 09fc3e9462c1..949644c1dac2 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1524,8 +1524,8 @@ static int dsa_slave_port_event(struct net_device *dev, unsigned long event,
 	return NOTIFY_DONE;
 }
 
-int dsa_slave_netdevice_event(struct notifier_block *unused,
-			      unsigned long event, void *ptr)
+static int dsa_slave_netdevice_event(struct notifier_block *nb,
+				     unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
@@ -1534,3 +1534,21 @@ int dsa_slave_netdevice_event(struct notifier_block *unused,
 
 	return NOTIFY_DONE;
 }
+
+static struct notifier_block dsa_slave_nb __read_mostly = {
+	.notifier_call	= dsa_slave_netdevice_event,
+};
+
+int dsa_slave_register_notifier(void)
+{
+	return register_netdevice_notifier(&dsa_slave_nb);
+}
+
+void dsa_slave_unregister_notifier(void)
+{
+	int err;
+
+	err = unregister_netdevice_notifier(&dsa_slave_nb);
+	if (err)
+		pr_err("DSA: failed to unregister slave notifier (%d)\n", err);
+}
-- 
2.11.0
