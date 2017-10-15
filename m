From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] hamradio: baycom_par: use new parport device model
Date: Sun, 15 Oct 2017 22:00:52 +0100
Message-ID: <1508101252-14268-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org,
        Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
        Thomas Sailer <t.sailer@alumni.ethz.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify baycom driver to use the new parallel port device model.

Signed-off-by: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
---

Not tested on real hardware, only tested on kvm with 32 bit guest and
verified that the device is binding to the driver properly in par96_open
but then unbinding as the device was not found.

 drivers/net/hamradio/baycom_par.c | 48 +++++++++++++++++++++++++++++++++++----
 1 file changed, 44 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hamradio/baycom_par.c b/drivers/net/hamradio/baycom_par.c
index e178383..1f7ceaf 100644
--- a/drivers/net/hamradio/baycom_par.c
+++ b/drivers/net/hamradio/baycom_par.c
@@ -311,7 +311,9 @@ static void par96_wakeup(void *handle)
 static int par96_open(struct net_device *dev)
 {
 	struct baycom_state *bc = netdev_priv(dev);
+	struct pardev_cb par_cb;
 	struct parport *pp;
+	int i;
 
 	if (!dev || !bc)
 		return -ENXIO;
@@ -332,8 +334,21 @@ static int par96_open(struct net_device *dev)
 	}
 	memset(&bc->modem, 0, sizeof(bc->modem));
 	bc->hdrv.par.bitrate = 9600;
-	bc->pdev = parport_register_device(pp, dev->name, NULL, par96_wakeup, 
-				 par96_interrupt, PARPORT_DEV_EXCL, dev);
+	memset(&par_cb, 0, sizeof(par_cb));
+	par_cb.wakeup = par96_wakeup;
+	par_cb.irq_func = par96_interrupt;
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
+	bc->pdev = parport_register_dev_model(pp, dev->name, &par_cb, i);
 	parport_put_port(pp);
 	if (!bc->pdev) {
 		printk(KERN_ERR "baycom_par: cannot register parport at 0x%lx\n", dev->base_addr);
@@ -490,12 +505,34 @@ static int baycom_ioctl(struct net_device *dev, struct ifreq *ifr,
 
 /* --------------------------------------------------------------------- */
 
+static int baycom_par_probe(struct pardevice *par_dev)
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
+static struct parport_driver baycom_par_driver = {
+	.name = "bcp",
+	.probe = baycom_par_probe,
+	.devmodel = true,
+};
+
 static int __init init_baycompar(void)
 {
-	int i, found = 0;
+	int i, found = 0, ret;
 	char set_hw = 1;
 
 	printk(bc_drvinfo);
+
+	ret = parport_register_driver(&baycom_par_driver);
+	if (ret)
+		return ret;
+
 	/*
 	 * register net devices
 	 */
@@ -524,8 +561,10 @@ static int __init init_baycompar(void)
 		baycom_device[i] = dev;
 	}
 
-	if (!found)
+	if (!found) {
+		parport_unregister_driver(&baycom_par_driver);
 		return -ENXIO;
+	}
 	return 0;
 }
 
@@ -539,6 +578,7 @@ static void __exit cleanup_baycompar(void)
 		if (dev)
 			hdlcdrv_unregister(dev);
 	}
+	parport_unregister_driver(&baycom_par_driver);
 }
 
 module_init(init_baycompar);
-- 
1.9.1
