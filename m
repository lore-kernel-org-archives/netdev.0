From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] ethtool: Provide a default implementation of
 ethtool_ops::get_drvinfo
Date: Thu, 05 Aug 2010 20:20:08 +0100
Message-ID: <1281036008.2095.6.camel@achroite.uk.solarflarecom.com>
References: <201008051302.06045.rusty@rustcorp.com.au>
	 <1280980041.13192.628.camel@localhost>
	 <20100804.215424.200345652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org, mst@redhat.com,
	izumi.taku@jp.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:22745 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759048Ab0HETUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 15:20:12 -0400
In-Reply-To: <20100804.215424.200345652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver name and bus address for a net_device can normally be found
through the driver model now.  Instead of requiring drivers to provide
this information redundantly through the ethtool_ops::get_drvinfo
operation, use the driver model to do so if the driver does not define
the operation.  Since ETHTOOL_GDRVINFO no longer requires the driver
to implement any operations, do not require net_device::ethtool_ops to
be set either.

Remove implementations of get_drvinfo and ethtool_ops that provide
only this information.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
On Wed, 2010-08-04 at 21:54 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Thu, 05 Aug 2010 04:47:21 +0100
> 
> > On Thu, 2010-08-05 at 13:02 +0930, Rusty Russell wrote:
> >> I often use "ethtool -i" command to check what driver controls the
> >> ehternet device.  But because current virtio_net driver doesn't
> >> support "ethtool -i", it becomes the following:
> >> 
> >>         # ethtool -i eth3
> >>         Cannot get driver information: Operation not supported
> >> 
> >> This patch simply adds the "ethtool -i" support. The following is the
> >> result when using the virtio_net driver with my patch applied to.
> >> 
> >>         # ethtool -i eth3
> >>         driver: virtio_net
> >>         version: N/A
> >>         firmware-version: N/A
> >>         bus-info: virtio0
> >> 
> >> Personally, "-i" is one of the most frequently-used option, and most
> >> network drivers support "ethtool -i", so I think virtio_net also
> >> should do.
> > [...]
> > 
> > This information is already available generically through sysfs:
> >     basename $(readlink /sys/class/net/eth3/device)
> >     basename $(readlink /sys/class/net/eth3/device/driver)
> > 
> > Given that, we should either recommend that people use that method
> > instead, or we should add an equivalent default implementation of the
> > get_drvinfo operation.
> 
> We've had ethtool for nearly a decade, it's a standard facility and
> it's only wise to have all drivers implement as much of the API as
> possible.
> 
> As such I've applied Rusty's patch and I will apply any patch which
> makes a driver more fully provide support for all ethtool facilities.

Here's a patch that should do that for a whole bunch of drivers at once. :-)

This is compile-tested on i386, and I tested that it DTRT if I then
remove the ethtool_ops from sfc.  There are a few PowerPC-specific
drivers affected that I have not even compile-tested.

I didn't see the previous patch in your public tree, so I applied it
locally before making this patch.

Ben.

 drivers/firewire/net.c           |   13 -------------
 drivers/ieee1394/eth1394.c       |   16 ----------------
 drivers/net/bmac.c               |    7 -------
 drivers/net/fec_mpc52xx.c        |    6 ------
 drivers/net/pasemi_mac_ethtool.c |   16 ----------------
 drivers/net/pcmcia/3c574_cs.c    |   13 -------------
 drivers/net/pcmcia/axnet_cs.c    |   13 -------------
 drivers/net/pcmcia/ibmtr_cs.c    |   13 -------------
 drivers/net/pcmcia/pcnet_cs.c    |   16 ----------------
 drivers/net/sc92031.c            |   11 -----------
 drivers/net/tulip/xircom_cb.c    |   15 ---------------
 drivers/net/usb/hso.c            |    9 ---------
 drivers/net/usb/kaweth.c         |    9 ---------
 drivers/net/virtio_net.c         |   14 --------------
 drivers/net/wireless/ray_cs.c    |   16 ----------------
 drivers/net/wireless/wl3501_cs.c |   18 ------------------
 net/core/ethtool.c               |   33 +++++++++++++++++++++++----------
 17 files changed, 23 insertions(+), 215 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 7142eee..277efb3 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -8,7 +8,6 @@
 
 #include <linux/bug.h>
 #include <linux/device.h>
-#include <linux/ethtool.h>
 #include <linux/firewire.h>
 #include <linux/firewire-constants.h>
 #include <linux/highmem.h>
@@ -1359,17 +1358,6 @@ static int fwnet_change_mtu(struct net_device *net, int new_mtu)
 	return 0;
 }
 
-static void fwnet_get_drvinfo(struct net_device *net,
-			      struct ethtool_drvinfo *info)
-{
-	strcpy(info->driver, KBUILD_MODNAME);
-	strcpy(info->bus_info, "ieee1394");
-}
-
-static const struct ethtool_ops fwnet_ethtool_ops = {
-	.get_drvinfo = fwnet_get_drvinfo,
-};
-
 static const struct net_device_ops fwnet_netdev_ops = {
 	.ndo_open       = fwnet_open,
 	.ndo_stop	= fwnet_stop,
@@ -1388,7 +1376,6 @@ static void fwnet_init_dev(struct net_device *net)
 	net->hard_header_len	= FWNET_HLEN;
 	net->type		= ARPHRD_IEEE1394;
 	net->tx_queue_len	= 10;
-	SET_ETHTOOL_OPS(net, &fwnet_ethtool_ops);
 }
 
 /* caller must hold fwnet_device_mutex */
diff --git a/drivers/ieee1394/eth1394.c b/drivers/ieee1394/eth1394.c
index a4e9dcb..62ab09e 100644
--- a/drivers/ieee1394/eth1394.c
+++ b/drivers/ieee1394/eth1394.c
@@ -58,7 +58,6 @@
 #include <linux/tcp.h>
 #include <linux/skbuff.h>
 #include <linux/bitops.h>
-#include <linux/ethtool.h>
 #include <asm/uaccess.h>
 #include <asm/delay.h>
 #include <asm/unaligned.h>
@@ -173,8 +172,6 @@ static netdev_tx_t ether1394_tx(struct sk_buff *skb,
 				struct net_device *dev);
 static void ether1394_iso(struct hpsb_iso *iso);
 
-static const struct ethtool_ops ethtool_ops;
-
 static int ether1394_write(struct hpsb_host *host, int srcid, int destid,
 			   quadlet_t *data, u64 addr, size_t len, u16 flags);
 static void ether1394_add_host(struct hpsb_host *host);
@@ -525,8 +522,6 @@ static void ether1394_init_dev(struct net_device *dev)
 	dev->header_ops		= &ether1394_header_ops;
 	dev->netdev_ops		= &ether1394_netdev_ops;
 
-	SET_ETHTOOL_OPS(dev, &ethtool_ops);
-
 	dev->watchdog_timeo	= ETHER1394_TIMEOUT;
 	dev->flags		= IFF_BROADCAST | IFF_MULTICAST;
 	dev->features		= NETIF_F_HIGHDMA;
@@ -1698,17 +1693,6 @@ fail:
 	return NETDEV_TX_OK;
 }
 
-static void ether1394_get_drvinfo(struct net_device *dev,
-				  struct ethtool_drvinfo *info)
-{
-	strcpy(info->driver, driver_name);
-	strcpy(info->bus_info, "ieee1394"); /* FIXME provide more detail? */
-}
-
-static const struct ethtool_ops ethtool_ops = {
-	.get_drvinfo = ether1394_get_drvinfo
-};
-
 static int __init ether1394_init_module(void)
 {
 	int err;
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 959add2..9322699 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -1233,15 +1233,8 @@ static void bmac_reset_and_enable(struct net_device *dev)
 	}
 	spin_unlock_irqrestore(&bp->lock, flags);
 }
-static void bmac_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
-{
-	struct bmac_data *bp = netdev_priv(dev);
-	strcpy(info->driver, "bmac");
-	strcpy(info->bus_info, dev_name(&bp->mdev->ofdev.dev));
-}
 
 static const struct ethtool_ops bmac_ethtool_ops = {
-	.get_drvinfo		= bmac_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 };
 
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index d1a5b17..f04fa98 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -771,11 +771,6 @@ static void mpc52xx_fec_reset(struct net_device *dev)
 

 /* ethtool interface */
-static void mpc52xx_fec_get_drvinfo(struct net_device *dev,
-		struct ethtool_drvinfo *info)
-{
-	strcpy(info->driver, DRIVER_NAME);
-}
 
 static int mpc52xx_fec_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
@@ -810,7 +805,6 @@ static void mpc52xx_fec_set_msglevel(struct net_device *dev, u32 level)
 }
 
 static const struct ethtool_ops mpc52xx_fec_ethtool_ops = {
-	.get_drvinfo = mpc52xx_fec_get_drvinfo,
 	.get_settings = mpc52xx_fec_get_settings,
 	.set_settings = mpc52xx_fec_set_settings,
 	.get_link = ethtool_op_get_link,
diff --git a/drivers/net/pasemi_mac_ethtool.c b/drivers/net/pasemi_mac_ethtool.c
index fefa79e..4825959 100644
--- a/drivers/net/pasemi_mac_ethtool.c
+++ b/drivers/net/pasemi_mac_ethtool.c
@@ -90,21 +90,6 @@ pasemi_mac_ethtool_set_settings(struct net_device *netdev,
 	return phy_ethtool_sset(phydev, cmd);
 }
 
-static void
-pasemi_mac_ethtool_get_drvinfo(struct net_device *netdev,
-			       struct ethtool_drvinfo *drvinfo)
-{
-	struct pasemi_mac *mac;
-	mac = netdev_priv(netdev);
-
-	/* clear and fill out info */
-	memset(drvinfo, 0, sizeof(struct ethtool_drvinfo));
-	strncpy(drvinfo->driver, "pasemi_mac", 12);
-	strcpy(drvinfo->version, "N/A");
-	strcpy(drvinfo->fw_version, "N/A");
-	strncpy(drvinfo->bus_info, pci_name(mac->pdev), 32);
-}
-
 static u32
 pasemi_mac_ethtool_get_msglevel(struct net_device *netdev)
 {
@@ -164,7 +149,6 @@ static void pasemi_mac_get_strings(struct net_device *netdev, u32 stringset,
 const struct ethtool_ops pasemi_mac_ethtool_ops = {
 	.get_settings		= pasemi_mac_ethtool_get_settings,
 	.set_settings		= pasemi_mac_ethtool_set_settings,
-	.get_drvinfo		= pasemi_mac_ethtool_get_drvinfo,
 	.get_msglevel		= pasemi_mac_ethtool_get_msglevel,
 	.set_msglevel		= pasemi_mac_ethtool_set_msglevel,
 	.get_link		= ethtool_op_get_link,
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 10ee106..3a3fa26 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -83,7 +83,6 @@ earlier 3Com products.
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
 #include <linux/ioport.h>
-#include <linux/ethtool.h>
 #include <linux/bitops.h>
 #include <linux/mii.h>
 
@@ -239,7 +238,6 @@ static int el3_rx(struct net_device *dev, int worklimit);
 static int el3_close(struct net_device *dev);
 static void el3_tx_timeout(struct net_device *dev);
 static int el3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-static const struct ethtool_ops netdev_ethtool_ops;
 static void set_rx_mode(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 
@@ -286,7 +284,6 @@ static int tc574_probe(struct pcmcia_device *link)
 	link->conf.ConfigIndex = 1;
 
 	dev->netdev_ops = &el3_netdev_ops;
-	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	return tc574_config(link);
@@ -1065,16 +1062,6 @@ static int el3_rx(struct net_device *dev, int worklimit)
 	return worklimit;
 }
 
-static void netdev_get_drvinfo(struct net_device *dev,
-			       struct ethtool_drvinfo *info)
-{
-	strcpy(info->driver, "3c574_cs");
-}
-
-static const struct ethtool_ops netdev_ethtool_ops = {
-	.get_drvinfo		= netdev_get_drvinfo,
-};
-
 /* Provide ioctl() calls to examine the MII xcvr state. */
 static int el3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 33525bf..3003745 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -32,7 +32,6 @@
 #include <linux/timer.h>
 #include <linux/delay.h>
 #include <linux/spinlock.h>
-#include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/crc32.h>
@@ -87,7 +86,6 @@ static netdev_tx_t axnet_start_xmit(struct sk_buff *skb,
 static struct net_device_stats *get_stats(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 static void axnet_tx_timeout(struct net_device *dev);
-static const struct ethtool_ops netdev_ethtool_ops;
 static irqreturn_t ei_irq_wrapper(int irq, void *dev_id);
 static void ei_watchdog(u_long arg);
 static void axnet_reset_8390(struct net_device *dev);
@@ -172,7 +170,6 @@ static int axnet_probe(struct pcmcia_device *link)
 
     dev->netdev_ops = &axnet_netdev_ops;
 
-    SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
     dev->watchdog_timeo = TX_TIMEOUT;
 
     return axnet_config(link);
@@ -658,16 +655,6 @@ reschedule:
     add_timer(&info->watchdog);
 }
 
-static void netdev_get_drvinfo(struct net_device *dev,
-			       struct ethtool_drvinfo *info)
-{
-	strcpy(info->driver, "axnet_cs");
-}
-
-static const struct ethtool_ops netdev_ethtool_ops = {
-	.get_drvinfo		= netdev_get_drvinfo,
-};
-
 /*====================================================================*/
 
 static int axnet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 67ee985..c02ae65 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -52,7 +52,6 @@
 #include <linux/string.h>
 #include <linux/timer.h>
 #include <linux/module.h>
-#include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <linux/trdevice.h>
 #include <linux/ibmtr.h>
@@ -108,16 +107,6 @@ typedef struct ibmtr_dev_t {
     struct tok_info	*ti;
 } ibmtr_dev_t;
 
-static void netdev_get_drvinfo(struct net_device *dev,
-			       struct ethtool_drvinfo *info)
-{
-	strcpy(info->driver, "ibmtr_cs");
-}
-
-static const struct ethtool_ops netdev_ethtool_ops = {
-	.get_drvinfo		= netdev_get_drvinfo,
-};
-
 static irqreturn_t ibmtr_interrupt(int irq, void *dev_id) {
 	ibmtr_dev_t *info = dev_id;
 	struct net_device *dev = info->dev;
@@ -161,8 +150,6 @@ static int __devinit ibmtr_attach(struct pcmcia_device *link)
 
     info->dev = dev;
 
-    SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
-
     return ibmtr_config(link);
 } /* ibmtr_attach */
 
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index bfdef72..17c7c66 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -35,7 +35,6 @@
 #include <linux/string.h>
 #include <linux/timer.h>
 #include <linux/delay.h>
-#include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <linux/log2.h>
 #include <linux/etherdevice.h>
@@ -101,7 +100,6 @@ static void pcnet_release(struct pcmcia_device *link);
 static int pcnet_open(struct net_device *dev);
 static int pcnet_close(struct net_device *dev);
 static int ei_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-static const struct ethtool_ops netdev_ethtool_ops;
 static irqreturn_t ei_irq_wrapper(int irq, void *dev_id);
 static void ei_watchdog(u_long arg);
 static void pcnet_reset_8390(struct net_device *dev);
@@ -632,8 +630,6 @@ static int pcnet_config(struct pcmcia_device *link)
     ei_status.word16 = 1;
     ei_status.reset_8390 = &pcnet_reset_8390;
 
-    SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
-
     if (info->flags & (IS_DL10019|IS_DL10022))
 	mii_phy_probe(dev);
 
@@ -1147,18 +1143,6 @@ reschedule:
 
 /*====================================================================*/
 
-static void netdev_get_drvinfo(struct net_device *dev,
-			       struct ethtool_drvinfo *info)
-{
-	strcpy(info->driver, "pcnet_cs");
-}
-
-static const struct ethtool_ops netdev_ethtool_ops = {
-	.get_drvinfo		= netdev_get_drvinfo,
-};
-
-/*====================================================================*/
-
 
 static int ei_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 8c4067a..31b92f5 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1251,16 +1251,6 @@ static int sc92031_ethtool_set_settings(struct net_device *dev,
 	return 0;
 }
 
-static void sc92031_ethtool_get_drvinfo(struct net_device *dev,
-		struct ethtool_drvinfo *drvinfo)
-{
-	struct sc92031_priv *priv = netdev_priv(dev);
-	struct pci_dev *pdev = priv->pdev;
-
-	strcpy(drvinfo->driver, SC92031_NAME);
-	strcpy(drvinfo->bus_info, pci_name(pdev));
-}
-
 static void sc92031_ethtool_get_wol(struct net_device *dev,
 		struct ethtool_wolinfo *wolinfo)
 {
@@ -1382,7 +1372,6 @@ static void sc92031_ethtool_get_ethtool_stats(struct net_device *dev,
 static const struct ethtool_ops sc92031_ethtool_ops = {
 	.get_settings		= sc92031_ethtool_get_settings,
 	.set_settings		= sc92031_ethtool_set_settings,
-	.get_drvinfo		= sc92031_ethtool_get_drvinfo,
 	.get_wol		= sc92031_ethtool_get_wol,
 	.set_wol		= sc92031_ethtool_set_wol,
 	.nway_reset		= sc92031_ethtool_nway_reset,
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index a439e93..5a73752 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -29,7 +29,6 @@
 #include <linux/skbuff.h>
 #include <linux/delay.h>
 #include <linux/init.h>
-#include <linux/ethtool.h>
 #include <linux/bitops.h>
 
 #include <asm/uaccess.h>
@@ -181,19 +180,6 @@ static void print_binary(unsigned int number)
 }
 #endif
 
-static void netdev_get_drvinfo(struct net_device *dev,
-			       struct ethtool_drvinfo *info)
-{
-	struct xircom_private *private = netdev_priv(dev);
-
-	strcpy(info->driver, "xircom_cb");
-	strcpy(info->bus_info, pci_name(private->pdev));
-}
-
-static const struct ethtool_ops netdev_ethtool_ops = {
-	.get_drvinfo		= netdev_get_drvinfo,
-};
-
 static const struct net_device_ops netdev_ops = {
 	.ndo_open		= xircom_open,
 	.ndo_stop		= xircom_close,
@@ -279,7 +265,6 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	setup_descriptors(private);
 
 	dev->netdev_ops = &netdev_ops;
-	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	pci_set_drvdata(pdev, dev);
 
 	if (register_netdev(dev)) {
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 6efca66..4f123f8 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -843,16 +843,7 @@ static netdev_tx_t hso_net_start_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-static void hso_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
-{
-	struct hso_net *odev = netdev_priv(net);
-
-	strncpy(info->driver, driver_name, ETHTOOL_BUSINFO_LEN);
-	usb_make_path(odev->parent->usb, info->bus_info, sizeof info->bus_info);
-}
-
 static const struct ethtool_ops ops = {
-	.get_drvinfo = hso_get_drvinfo,
 	.get_link = ethtool_op_get_link
 };
 
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 2b7b39c..5e98643 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -759,14 +759,6 @@ static int kaweth_close(struct net_device *net)
 	return 0;
 }
 
-static void kaweth_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
-{
-	struct kaweth_device *kaweth = netdev_priv(dev);
-
-	strlcpy(info->driver, driver_name, sizeof(info->driver));
-	usb_make_path(kaweth->dev, info->bus_info, sizeof (info->bus_info));
-}
-
 static u32 kaweth_get_link(struct net_device *dev)
 {
 	struct kaweth_device *kaweth = netdev_priv(dev);
@@ -775,7 +767,6 @@ static u32 kaweth_get_link(struct net_device *dev)
 }
 
 static const struct ethtool_ops ops = {
-	.get_drvinfo	= kaweth_get_drvinfo,
 	.get_link	= kaweth_get_link
 };
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4598e9d..bb6b67f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -705,19 +705,6 @@ static int virtnet_close(struct net_device *dev)
 	return 0;
 }
 
-static void virtnet_get_drvinfo(struct net_device *dev,
-				struct ethtool_drvinfo *drvinfo)
-{
-	struct virtnet_info *vi = netdev_priv(dev);
-	struct virtio_device *vdev = vi->vdev;
-
-	strncpy(drvinfo->driver, KBUILD_MODNAME, ARRAY_SIZE(drvinfo->driver));
-	strncpy(drvinfo->version, "N/A", ARRAY_SIZE(drvinfo->version));
-	strncpy(drvinfo->fw_version, "N/A", ARRAY_SIZE(drvinfo->fw_version));
-	strncpy(drvinfo->bus_info, dev_name(&vdev->dev),
-		ARRAY_SIZE(drvinfo->bus_info));
-}
-
 static int virtnet_set_tx_csum(struct net_device *dev, u32 data)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -830,7 +817,6 @@ static void virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
 }
 
 static const struct ethtool_ops virtnet_ethtool_ops = {
-	.get_drvinfo = virtnet_get_drvinfo,
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.set_tso = ethtool_op_set_tso,
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 9c38fc3..0234800 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -43,7 +43,6 @@
 #include <linux/if_arp.h>
 #include <linux/ioport.h>
 #include <linux/skbuff.h>
-#include <linux/ethtool.h>
 #include <linux/ieee80211.h>
 
 #include <pcmcia/cs_types.h>
@@ -81,8 +80,6 @@ static int ray_dev_config(struct net_device *dev, struct ifmap *map);
 static struct net_device_stats *ray_get_stats(struct net_device *dev);
 static int ray_dev_init(struct net_device *dev);
 
-static const struct ethtool_ops netdev_ethtool_ops;
-
 static int ray_open(struct net_device *dev);
 static netdev_tx_t ray_dev_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev);
@@ -335,7 +332,6 @@ static int ray_probe(struct pcmcia_device *p_dev)
 
 	/* Raylink entries in the device structure */
 	dev->netdev_ops = &ray_netdev_ops;
-	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->wireless_handlers = &ray_handler_def;
 #ifdef WIRELESS_SPY
 	local->wireless_data.spy_data = &local->spy_data;
@@ -1079,18 +1075,6 @@ AP to AP	1	1	dest AP		src AP		dest	source
 	}
 } /* end encapsulate_frame */
 
-/*===========================================================================*/
-
-static void netdev_get_drvinfo(struct net_device *dev,
-			       struct ethtool_drvinfo *info)
-{
-	strcpy(info->driver, "ray_cs");
-}
-
-static const struct ethtool_ops netdev_ethtool_ops = {
-	.get_drvinfo = netdev_get_drvinfo,
-};
-
 /*====================================================================*/
 
 /*------------------------------------------------------------------*/
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 376c6b9..fda932e 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -29,7 +29,6 @@
 
 #include <linux/delay.h>
 #include <linux/types.h>
-#include <linux/ethtool.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/in.h>
@@ -89,13 +88,6 @@
 static int wl3501_config(struct pcmcia_device *link);
 static void wl3501_release(struct pcmcia_device *link);
 
-/*
- * The dev_info variable is the "key" that is used to match up this
- * device driver with appropriate cards, through the card configuration
- * database.
- */
-static dev_info_t wl3501_dev_info = "wl3501_cs";
-
 static const struct {
 	int reg_domain;
 	int min, max, deflt;
@@ -1419,15 +1411,6 @@ static struct iw_statistics *wl3501_get_wireless_stats(struct net_device *dev)
 	return wstats;
 }
 
-static void wl3501_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
-{
-	strlcpy(info->driver, wl3501_dev_info, sizeof(info->driver));
-}
-
-static const struct ethtool_ops ops = {
-	.get_drvinfo = wl3501_get_drvinfo
-};
-
 /**
  * wl3501_detach - deletes a driver "instance"
  * @link - FILL_IN
@@ -1914,7 +1897,6 @@ static int wl3501_probe(struct pcmcia_device *p_dev)
 	this->p_dev = p_dev;
 	dev->wireless_data	= &this->wireless_data;
 	dev->wireless_handlers	= &wl3501_handler_def;
-	SET_ETHTOOL_OPS(dev, &ops);
 	netif_stop_queue(dev);
 	p_dev->priv = dev;
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 7a85367..d2c4da5 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -205,18 +205,24 @@ static noinline_for_stack int ethtool_get_drvinfo(struct net_device *dev,
 	struct ethtool_drvinfo info;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 
-	if (!ops->get_drvinfo)
-		return -EOPNOTSUPP;
-
 	memset(&info, 0, sizeof(info));
 	info.cmd = ETHTOOL_GDRVINFO;
-	ops->get_drvinfo(dev, &info);
+	if (ops && ops->get_drvinfo) {
+		ops->get_drvinfo(dev, &info);
+	} else if (dev->dev.parent && dev->dev.parent->driver) {
+		strlcpy(info.bus_info, dev_name(dev->dev.parent),
+			sizeof(info.bus_info));
+		strlcpy(info.driver, dev->dev.parent->driver->name,
+			sizeof(info.driver));
+	} else {
+		return -EOPNOTSUPP;
+	}
 
 	/*
 	 * this method of obtaining string set info is deprecated;
 	 * Use ETHTOOL_GSSET_INFO instead.
 	 */
-	if (ops->get_sset_count) {
+	if (ops && ops->get_sset_count) {
 		int rc;
 
 		rc = ops->get_sset_count(dev, ETH_SS_TEST);
@@ -229,9 +235,9 @@ static noinline_for_stack int ethtool_get_drvinfo(struct net_device *dev,
 		if (rc >= 0)
 			info.n_priv_flags = rc;
 	}
-	if (ops->get_regs_len)
+	if (ops && ops->get_regs_len)
 		info.regdump_len = ops->get_regs_len(dev);
-	if (ops->get_eeprom_len)
+	if (ops && ops->get_eeprom_len)
 		info.eedump_len = ops->get_eeprom_len(dev);
 
 	if (copy_to_user(useraddr, &info, sizeof(info)))
@@ -1402,12 +1408,19 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	if (!dev || !netif_device_present(dev))
 		return -ENODEV;
 
-	if (!dev->ethtool_ops)
-		return -EOPNOTSUPP;
-
 	if (copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
 		return -EFAULT;
 
+	if (!dev->ethtool_ops) {
+		/* ETHTOOL_GDRVINFO does not require any driver support.
+		 * It is also unprivileged and does not change anything,
+		 * so we can take a shortcut to it. */
+		if (ethcmd == ETHTOOL_GDRVINFO)
+			return ethtool_get_drvinfo(dev, useraddr);
+		else
+			return -EOPNOTSUPP;
+	}
+
 	/* Allow some commands to be done by anyone */
 	switch (ethcmd) {
 	case ETHTOOL_GDRVINFO:
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

