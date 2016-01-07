From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] net: plip: use new parport device model
Date: Thu,  7 Jan 2016 15:42:37 +0530
Message-ID: <1452161557-6840-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify plip driver to use the new parallel port device model.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/plip/plip.c | 36 ++++++++++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 8 deletions(-)

diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
index 040b897..9c4b41a 100644
--- a/drivers/net/plip/plip.c
+++ b/drivers/net/plip/plip.c
@@ -1249,6 +1249,7 @@ static void plip_attach (struct parport *port)
 	struct net_device *dev;
 	struct net_local *nl;
 	char name[IFNAMSIZ];
+	struct pardev_cb plip_cb;
 
 	if ((parport[0] == -1 && (!timid || !port->devices)) ||
 	    plip_searchfor(parport, port->number)) {
@@ -1273,9 +1274,15 @@ static void plip_attach (struct parport *port)
 
 		nl = netdev_priv(dev);
 		nl->dev = dev;
-		nl->pardev = parport_register_device(port, dev->name, plip_preempt,
-						 plip_wakeup, plip_interrupt,
-						 0, dev);
+
+		memset(&plip_cb, 0, sizeof(plip_cb));
+		plip_cb.private = dev;
+		plip_cb.preempt = plip_preempt;
+		plip_cb.wakeup = plip_wakeup;
+		plip_cb.irq_func = plip_interrupt;
+
+		nl->pardev = parport_register_dev_model(port, dev->name,
+							&plip_cb, unit);
 
 		if (!nl->pardev) {
 			printk(KERN_ERR "%s: parport_register failed\n", name);
@@ -1315,10 +1322,23 @@ static void plip_detach (struct parport *port)
 	/* Nothing to do */
 }
 
+static int plip_probe(struct pardevice *par_dev)
+{
+	struct device_driver *drv = par_dev->dev.driver;
+	int len = strlen(drv->name);
+
+	if (strncmp(par_dev->name, drv->name, len))
+		return -ENODEV;
+
+	return 0;
+}
+
 static struct parport_driver plip_driver = {
-	.name	= "plip",
-	.attach = plip_attach,
-	.detach = plip_detach
+	.name		= "plip",
+	.probe		= plip_probe,
+	.match_port	= plip_attach,
+	.detach		= plip_detach,
+	.devmodel	= true,
 };
 
 static void __exit plip_cleanup_module (void)
@@ -1326,8 +1346,6 @@ static void __exit plip_cleanup_module (void)
 	struct net_device *dev;
 	int i;
 
-	parport_unregister_driver (&plip_driver);
-
 	for (i=0; i < PLIP_MAX; i++) {
 		if ((dev = dev_plip[i])) {
 			struct net_local *nl = netdev_priv(dev);
@@ -1339,6 +1357,8 @@ static void __exit plip_cleanup_module (void)
 			dev_plip[i] = NULL;
 		}
 	}
+
+	parport_unregister_driver(&plip_driver);
 }
 
 #ifndef MODULE
-- 
1.9.1
