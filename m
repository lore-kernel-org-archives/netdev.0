From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] hamradio: baycom: use new parport device model
Date: Sun, 17 Sep 2017 12:46:20 +0100
Message-ID: <1505648780-4385-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org,
        Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
        Thomas Sailer <t.sailer@alumni.ethz.ch>
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify baycom driver to use the new parallel port device model.

Signed-off-by: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
---

Not tested on real hardware, only tested on qemu and verified that the
device is binding to the driver properly in epp_open but then unbinding
as the device was not found.

 drivers/net/hamradio/baycom_epp.c | 50 +++++++++++++++++++++++++++++++++++----
 1 file changed, 46 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 1503f10..1e62d00 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -840,6 +840,7 @@ static int epp_open(struct net_device *dev)
 	unsigned char tmp[128];
 	unsigned char stat;
 	unsigned long tstart;
+	struct pardev_cb par_cb;
 	
         if (!pp) {
                 printk(KERN_ERR "%s: parport at 0x%lx unknown\n", bc_drvname, dev->base_addr);
@@ -859,8 +860,21 @@ static int epp_open(struct net_device *dev)
                 return -EIO;
 	}
 	memset(&bc->modem, 0, sizeof(bc->modem));
-        bc->pdev = parport_register_device(pp, dev->name, NULL, epp_wakeup, 
-					   NULL, PARPORT_DEV_EXCL, dev);
+	memset(&par_cb, 0, sizeof(par_cb));
+	par_cb.wakeup = epp_wakeup;
+	par_cb.private = (void *)dev;
+	par_cb.flags = PARPORT_DEV_EXCL;
+	for (i = 0; i < NR_PORTS; i++)
+		if (baycom_device[i] == dev)
+			break;
+
+	if (i == NR_PORTS) {
+		pr_err("%s: no device found\n", bc_drvname);
+		parport_put_port(pp);
+		return -ENODEV;
+	}
+
+	bc->pdev = parport_register_dev_model(pp, dev->name, &par_cb, i);
 	parport_put_port(pp);
         if (!bc->pdev) {
                 printk(KERN_ERR "%s: cannot register parport at 0x%lx\n", bc_drvname, pp->base);
@@ -1185,6 +1199,23 @@ MODULE_LICENSE("GPL");
 
 /* --------------------------------------------------------------------- */
 
+static int baycom_epp_par_probe(struct pardevice *par_dev)
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
+static struct parport_driver baycom_epp_par_driver = {
+	.name = "bce",
+	.probe = baycom_epp_par_probe,
+	.devmodel = true,
+};
+
 static void __init baycom_epp_dev_setup(struct net_device *dev)
 {
 	struct baycom_state *bc = netdev_priv(dev);
@@ -1204,10 +1235,15 @@ static void __init baycom_epp_dev_setup(struct net_device *dev)
 
 static int __init init_baycomepp(void)
 {
-	int i, found = 0;
+	int i, found = 0, ret;
 	char set_hw = 1;
 
 	printk(bc_drvinfo);
+
+	ret = parport_register_driver(&baycom_epp_par_driver);
+	if (ret)
+		return ret;
+
 	/*
 	 * register net devices
 	 */
@@ -1241,7 +1277,12 @@ static int __init init_baycomepp(void)
 		found++;
 	}
 
-	return found ? 0 : -ENXIO;
+	if (found == 0) {
+		parport_unregister_driver(&baycom_epp_par_driver);
+		return -ENXIO;
+	}
+
+	return 0;
 }
 
 static void __exit cleanup_baycomepp(void)
@@ -1260,6 +1301,7 @@ static void __exit cleanup_baycomepp(void)
 				printk(paranoia_str, "cleanup_module");
 		}
 	}
+	parport_unregister_driver(&baycom_epp_par_driver);
 }
 
 module_init(init_baycomepp);
-- 
2.7.4

