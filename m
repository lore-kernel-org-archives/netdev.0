From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-14
Date: Tue, 26 Aug 2008 22:19:15 +0800
Message-ID: <48B410E3.3040903@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57804 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757039AbYHZOVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:41 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index c3d119f..e10b616 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -340,14 +340,14 @@ out:
 static int mcs7830_mdio_read(struct net_device *netdev, int phy_id,
 			     int location)
 {
-	struct usbnet *dev = netdev->priv;
+	struct usbnet *dev = netdev_priv(netdev);
 	return mcs7830_read_phy(dev, location);
 }
 
 static void mcs7830_mdio_write(struct net_device *netdev, int phy_id,
 				int location, int val)
 {
-	struct usbnet *dev = netdev->priv;
+	struct usbnet *dev = netdev_priv(netdev);
 	mcs7830_write_phy(dev, location, val);
 }
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0196a0d..cc155f3 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -125,7 +125,8 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 		unsigned int i;
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-			give_a_page(dev->priv, skb_shinfo(skb)->frags[i].page);
+			give_a_page(netdev_priv(dev),
+				    skb_shinfo(skb)->frags[i].page);
 		skb->data_len = 0;
 		skb_shinfo(skb)->nr_frags = 0;
 	}
diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index b142427..c79f0ac 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -74,7 +74,7 @@ static int dlci_header(struct sk_buff *skb, struct net_device *dev,
 	unsigned int		hlen;
 	char			*dest;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	hdr.control = FRAD_I_UI;
 	switch(type)
@@ -110,7 +110,7 @@ static void dlci_receive(struct sk_buff *skb, struct net_device *dev)
 	struct frhdr		*hdr;
 	int					process, header;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 	if (!pskb_may_pull(skb, sizeof(*hdr))) {
 		printk(KERN_NOTICE "%s: invalid data no header\n",
 		       dev->name);
@@ -197,7 +197,7 @@ static int dlci_transmit(struct sk_buff *skb, struct net_device *dev)
 	if (!skb || !dev)
 		return(0);
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 	
@@ -235,9 +235,9 @@ static int dlci_config(struct net_device *dev, struct dlci_conf __user *conf, in
 	struct frad_local	*flp;
 	int			err;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
-	flp = dlp->slave->priv;
+	flp = netdev_priv(dlp->slave);
 
 	if (!get)
 	{
@@ -269,7 +269,7 @@ static int dlci_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	if (!capable(CAP_NET_ADMIN))
 		return(-EPERM);
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	switch(cmd)
 	{
@@ -298,7 +298,7 @@ static int dlci_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct dlci_local *dlp;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	return((*dlp->slave->change_mtu)(dlp->slave, new_mtu));
 }
@@ -309,7 +309,7 @@ static int dlci_open(struct net_device *dev)
 	struct frad_local	*flp;
 	int			err;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	if (!*(short *)(dev->dev_addr))
 		return(-EINVAL);
@@ -317,7 +317,7 @@ static int dlci_open(struct net_device *dev)
 	if (!netif_running(dlp->slave))
 		return(-ENOTCONN);
 
-	flp = dlp->slave->priv;
+	flp = netdev_priv(dlp->slave);
 	err = (*flp->activate)(dlp->slave, dev);
 	if (err)
 		return(err);
@@ -335,9 +335,9 @@ static int dlci_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
-	flp = dlp->slave->priv;
+	flp = netdev_priv(dlp->slave);
 	err = (*flp->deactivate)(dlp->slave, dev);
 
 	return 0;
@@ -347,7 +347,7 @@ static struct net_device_stats *dlci_get_stats(struct net_device *dev)
 {
 	struct dlci_local *dlp;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	return(&dlp->stats);
 }
@@ -365,7 +365,7 @@ static int dlci_add(struct dlci_add *dlci)
 	if (!slave)
 		return -ENODEV;
 
-	if (slave->type != ARPHRD_FRAD || slave->priv == NULL)
+	if (slave->type != ARPHRD_FRAD || netdev_priv(slave) == NULL)
 		goto err1;
 
 	/* create device name */
@@ -391,11 +391,11 @@ static int dlci_add(struct dlci_add *dlci)
 
 	*(short *)(master->dev_addr) = dlci->dlci;
 
-	dlp = (struct dlci_local *) master->priv;
+	dlp = netdev_priv(master);
 	dlp->slave = slave;
 	dlp->master = master;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 	err = (*flp->assoc)(slave, master);
 	if (err < 0)
 		goto err2;
@@ -435,9 +435,9 @@ static int dlci_del(struct dlci_add *dlci)
 		return(-EBUSY);
 	}
 
-	dlp = master->priv;
+	dlp = netdev_priv(master);
 	slave = dlp->slave;
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	rtnl_lock();
 	err = (*flp->deassoc)(slave, master);
@@ -491,7 +491,7 @@ static const struct header_ops dlci_header_ops = {
 
 static void dlci_setup(struct net_device *dev)
 {
-	struct dlci_local *dlp = dev->priv;
+	struct dlci_local *dlp = netdev_priv(dev);
 
 	dev->flags		= 0;
 	dev->open		= dlci_open;
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 73e2f27..6a07ba9 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -185,7 +185,7 @@ static void sdla_stop(struct net_device *dev)
 {
 	struct frad_local *flp;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	switch(flp->type)
 	{
 		case SDLA_S502A:
@@ -212,7 +212,7 @@ static void sdla_start(struct net_device *dev)
 {
 	struct frad_local *flp;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	switch(flp->type)
 	{
 		case SDLA_S502A:
@@ -432,7 +432,7 @@ static int sdla_cmd(struct net_device *dev, int cmd, short dlci, short flags,
 	int                      ret, waiting, len;
 	long                     window;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	window = flp->type == SDLA_S508 ? SDLA_508_CMD_BUF : SDLA_502_CMD_BUF;
 	cmd_buf = (struct sdla_cmd *)(dev->mem_start + (window & SDLA_ADDR_MASK));
 	ret = 0;
@@ -509,7 +509,7 @@ static int sdla_activate(struct net_device *slave, struct net_device *master)
 	struct frad_local *flp;
 	int i;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->master[i] == master)
@@ -531,7 +531,7 @@ static int sdla_deactivate(struct net_device *slave, struct net_device *master)
 	struct frad_local *flp;
 	int               i;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->master[i] == master)
@@ -556,7 +556,7 @@ static int sdla_assoc(struct net_device *slave, struct net_device *master)
 	if (master->type != ARPHRD_DLCI)
 		return(-EINVAL);
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 	{
@@ -589,7 +589,7 @@ static int sdla_deassoc(struct net_device *slave, struct net_device *master)
 	struct frad_local *flp;
 	int               i;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->master[i] == master)
@@ -619,7 +619,7 @@ static int sdla_dlci_conf(struct net_device *slave, struct net_device *master, i
 	int               i;
 	short             len, ret;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->master[i] == master)
@@ -628,7 +628,7 @@ static int sdla_dlci_conf(struct net_device *slave, struct net_device *master, i
 	if (i == CONFIG_DLCI_MAX)
 		return(-ENODEV);
 
-	dlp = master->priv;
+	dlp = netdev_priv(master);
 
 	ret = SDLA_RET_OK;
 	len = sizeof(struct dlci_conf);
@@ -659,7 +659,7 @@ static int sdla_transmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long     flags;
 	struct buf_entry  *pbuf;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	ret = 0;
 	accept = 1;
 
@@ -755,7 +755,7 @@ static void sdla_receive(struct net_device *dev)
 	int               i=0, received, success, addr, buf_base, buf_top;
 	short             dlci, len, len2, split;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	success = 1;
 	received = addr = buf_top = buf_base = 0;
 	len = dlci = 0;
@@ -860,7 +860,7 @@ static void sdla_receive(struct net_device *dev)
 	if (success)
 	{
 		flp->stats.rx_packets++;
-		dlp = master->priv;
+		dlp = netdev_priv(master);
 		(*dlp->receive)(skb, master);
 	}
 
@@ -925,7 +925,7 @@ static void sdla_poll(unsigned long device)
 	struct frad_local *flp;
 
 	dev = (struct net_device *) device;
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (sdla_byte(dev, SDLA_502_RCV_BUF))
 		sdla_receive(dev);
@@ -941,7 +941,7 @@ static int sdla_close(struct net_device *dev)
 	int               len, i;
 	short             dlcis[CONFIG_DLCI_MAX];
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	len = 0;
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
@@ -1002,7 +1002,7 @@ static int sdla_open(struct net_device *dev)
 	int               len, i;
 	char              byte;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (!flp->initialized)
 		return(-EPERM);
@@ -1079,7 +1079,7 @@ static int sdla_open(struct net_device *dev)
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->dlci[i])
 		{
-			dlp = flp->master[i]->priv;
+			dlp = netdev_priv(flp->master[i]);
 			if (dlp->configured)
 				sdla_cmd(dev, SDLA_SET_DLCI_CONFIGURATION, abs(flp->dlci[i]), 0, &dlp->config, sizeof(struct dlci_conf), NULL, NULL);
 		}
@@ -1099,7 +1099,7 @@ static int sdla_config(struct net_device *dev, struct frad_conf __user *conf, in
 	if (dev->type == 0xFFFF)
 		return(-EUNATCH);
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (!get)
 	{
@@ -1230,7 +1230,7 @@ static int sdla_reconfig(struct net_device *dev)
 	struct conf_data  data;
 	int               i, len;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	len = 0;
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
@@ -1255,7 +1255,7 @@ static int sdla_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	if(!capable(CAP_NET_ADMIN))
 		return -EPERM;
 		
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (!flp->initialized)
 		return(-EINVAL);
@@ -1321,7 +1321,7 @@ static int sdla_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct frad_local *flp;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (netif_running(dev))
 		return(-EBUSY);
@@ -1338,7 +1338,7 @@ static int sdla_set_config(struct net_device *dev, struct ifmap *map)
 	unsigned base;
 	int err = -EINVAL;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (flp->initialized)
 		return(-EINVAL);
@@ -1593,14 +1593,14 @@ fail:
 static struct net_device_stats *sdla_stats(struct net_device *dev)
 {
 	struct frad_local *flp;
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	return(&flp->stats);
 }
 
 static void setup_sdla(struct net_device *dev)
 {
-	struct frad_local *flp = dev->priv;
+	struct frad_local *flp = netdev_priv(dev);
 
 	netdev_boot_setup_check(dev);
 
@@ -1651,7 +1651,7 @@ static int __init init_sdla(void)
 
 static void __exit exit_sdla(void)
 {
-	struct frad_local *flp = sdla->priv;
+	struct frad_local *flp = netdev_priv(sdla);
 
 	unregister_netdev(sdla);
 	if (flp->initialized) {


