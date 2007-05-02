From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: Natsemi DP83815 driver spaming
Date: Wed, 2 May 2007 22:41:29 +0100
Message-ID: <20070502214128.GA4814@sirena.org.uk>
References: <46379A7E.3000109@interia.pl> <20070501212750.GC31630@sirena.org.uk> <b3ece790705011543gdca3a9ei905d3499b6c18dc8@mail.gmail.com> <46382798.2090709@interia.pl> <b3ece790705012303x1e5a2d03xddf6c14aec5a99d8@mail.gmail.com> <463830E1.8080107@interia.pl> <b3ece790705012351g5c0ff8a6g9f2f350ff86f3319@mail.gmail.com> <20070502082211.GD31630@sirena.org.uk> <b3ece790705020744p2e73bb5fo2c0acad947a5de15@mail.gmail.com> <4638EF0B.9050701@interia.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IJpNTDwzlM2Ie8A6"
Cc: Tim Hockin <thockin@hockin.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?utf-8?B?UmFmYcWC?= Bilski <rafalbilski@interia.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1767076AbXEBVl4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4638EF0B.9050701@interia.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 02, 2007 at 10:05:31PM +0200, Rafa=C5=82 Bilski wrote:

> What about module option?

That would work, though you crossed in the post with me writing a patch
adding a sysfs file; I merged the two for overkill (below).  I also have
a patch which changes the log message for the workaround so that it is
displayed by default in order to make this easier to diagnose.

diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 109e802..b9f3ab3 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -81,6 +81,8 @@ static const int multicast_filter_limit =3D 100;
    Setting to > 1518 effectively disables this feature. */
 static int rx_copybreak;
=20
+static int dspcfg_workaround =3D 1;
+
 /* Used to pass the media type, etc.
    Both 'options[]' and 'full_duplex[]' should exist for driver
    interoperability.
@@ -139,12 +141,14 @@ MODULE_LICENSE("GPL");
 module_param(mtu, int, 0);
 module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
+module_param(dspcfg_workaround, int, 1);
 module_param_array(options, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
 MODULE_PARM_DESC(mtu, "DP8381x MTU (all boards)");
 MODULE_PARM_DESC(debug, "DP8381x default debug level");
 MODULE_PARM_DESC(rx_copybreak,
 	"DP8381x copy breakpoint for copy-only-tiny-frames");
+MODULE_PARM_DESC(dspcfg_workaround, "DP8381x: control DspCfg workaround");
 MODULE_PARM_DESC(options,
 	"DP8381x: Bits 0-3: media type, bit 17: full duplex");
 MODULE_PARM_DESC(full_duplex, "DP8381x full duplex setting(s) (1)");
@@ -590,6 +594,7 @@ struct netdev_private {
 	u32 srr;
 	/* expected DSPCFG value */
 	u16 dspcfg;
+	int dspcfg_workaround;
 	/* parms saved in ethtool format */
 	u16	speed;		/* The forced speed, 10Mb, 100Mb, gigabit */
 	u8	duplex;		/* Duplex, half or full */
@@ -656,6 +661,56 @@ static int netdev_get_regs(struct net_device *dev, u8 =
*buf);
 static int netdev_get_eeprom(struct net_device *dev, u8 *buf);
 static const struct ethtool_ops ethtool_ops;
=20
+#define NATSEMI_ATTR(_name) \
+static ssize_t natsemi_show_##_name(struct device *dev, \
+         struct device_attribute *attr, char *buf); \
+	 static ssize_t natsemi_set_##_name(struct device *dev, \
+		struct device_attribute *attr, \
+	        const char *buf, size_t count); \
+	 static DEVICE_ATTR(_name, 0644, natsemi_show_##_name, natsemi_set_##_nam=
e)
+
+#define NATSEMI_CREATE_FILE(_dev, _name) \
+         device_create_file(&_dev->dev, &dev_attr_##_name)
+#define NATSEMI_REMOVE_FILE(_dev, _name) \
+         device_create_file(&_dev->dev, &dev_attr_##_name)
+
+NATSEMI_ATTR(dspcfg_workaround);
+
+static ssize_t natsemi_show_dspcfg_workaround(struct device *dev,
+				  	      struct device_attribute *attr,=20
+					      char *buf)
+{
+	struct netdev_private *np =3D netdev_priv(to_net_dev(dev));
+
+	return sprintf(buf, "%s\n", np->dspcfg_workaround ? "on" : "off");
+}
+
+static ssize_t natsemi_set_dspcfg_workaround(struct device *dev,
+					     struct device_attribute *attr,
+					     const char *buf, size_t count)
+{
+	struct netdev_private *np =3D netdev_priv(to_net_dev(dev));
+	int new_setting;
+	u32 flags;
+
+        /* Find out the new setting */
+        if (!strncmp("on", buf, count - 1) || !strncmp("1", buf, count - 1=
))
+                new_setting =3D 1;
+        else if (!strncmp("off", buf, count - 1)
+                 || !strncmp("0", buf, count - 1))
+		new_setting =3D 0;
+	else
+                 return count;=20
+
+	spin_lock_irqsave(&np->lock, flags);
+
+	np->dspcfg_workaround =3D new_setting;
+
+	spin_unlock_irqrestore(&np->lock, flags);
+
+	return count;
+}
+
 static inline void __iomem *ns_ioaddr(struct net_device *dev)
 {
 	return (void __iomem *) dev->base_addr;
@@ -820,6 +875,7 @@ static int __devinit natsemi_probe1 (struct pci_dev *pd=
ev,
 		np->ignore_phy =3D 1;
 	else
 		np->ignore_phy =3D 0;
+	np->dspcfg_workaround =3D dspcfg_workaround;
=20
 	/* Initial port:
 	 * - If configured to ignore the PHY set up for external.
@@ -899,6 +955,9 @@ static int __devinit natsemi_probe1 (struct pci_dev *pd=
ev,
 	if (i)
 		goto err_register_netdev;
=20
+	if (!NATSEMI_CREATE_FILE(pdev, dspcfg_workaround))
+		goto err_create_file;
+
 	if (netif_msg_drv(np)) {
 		printk(KERN_INFO "natsemi %s: %s at %#08lx (%s), ",
 			dev->name, natsemi_pci_info[chip_idx].name, iostart,
@@ -915,6 +974,9 @@ static int __devinit natsemi_probe1 (struct pci_dev *pd=
ev,
 	}
 	return 0;
=20
+ err_create_file:
+ 	unregister_netdev(dev);
+
  err_register_netdev:
 	iounmap(ioaddr);
=20
@@ -1727,7 +1789,8 @@ static void init_registers(struct net_device *dev)
  *    It seems that a reference set for this chip went out with incorrect =
info,
  *    and there exist boards that aren't quite right.  An unexpected volta=
ge
  *    drop can cause the PHY to get itself in a weird state (basically res=
et).
- *    NOTE: this only seems to affect revC chips.
+ *    NOTE: this only seems to affect revC chips.  The user can disable
+ *    this check via dspcfg_workaround sysfs option.
  * 3) check of death of the RX path due to OOM
  */
 static void netdev_timer(unsigned long data)
@@ -1753,7 +1816,7 @@ static void netdev_timer(unsigned long data)
 		writew(1, ioaddr+PGSEL);
 		dspcfg =3D readw(ioaddr+DSPCFG);
 		writew(0, ioaddr+PGSEL);
-		if (dspcfg !=3D np->dspcfg) {
+		if (np->dspcfg_workaround && dspcfg !=3D np->dspcfg) {
 			if (!netif_queue_stopped(dev)) {
 				spin_unlock_irq(&np->lock);
 				if (netif_msg_hw(np))
@@ -3157,6 +3220,7 @@ static void __devexit natsemi_remove1 (struct pci_dev=
 *pdev)
 	struct net_device *dev =3D pci_get_drvdata(pdev);
 	void __iomem * ioaddr =3D ns_ioaddr(dev);
=20
+	NATSEMI_REMOVE_FILE(pdev, dspcfg_workaround);
 	unregister_netdev (dev);
 	pci_release_regions (pdev);
 	iounmap(ioaddr);

--=20
"You grabbed my hand and we fell into it, like a daydream - or a fever."

--IJpNTDwzlM2Ie8A6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iQCVAwUBRjkFgw2erOLNe+68AQITagP+PgPIu2ZNHjLmrzT6MLrMxqJ0eGxLFwXO
TAf87lPeEI85L96dxDN0UqOwOVf//VlSFxnsN6v/9SYDIDJcU6qJm2yBPAaoSkhI
/khY9WG7jIxlZVFSi7D7UK9DpI+EJYiNq8/v2uIIf4vC+pKdRxuQ3k0j7UB3dUg/
FWrZJyCU2/U=
=qOvG
-----END PGP SIGNATURE-----

--IJpNTDwzlM2Ie8A6--
