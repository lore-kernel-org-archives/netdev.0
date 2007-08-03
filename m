From: Yoann Padioleau <padator@wanadoo.fr>
Subject: [PATCH 12/13] dev->priv to netdev_priv(dev), for drivers/net/wan
Date: Fri, 3 Aug 2007 19:37:09 +0200 (MEST)
Message-ID: <200708031737.TAA00878@ifs.emn.fr>
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Replacing accesses to dev->priv to netdev_priv(dev). The replacment
is safe when netdev_priv is used to access a private structure that is
right next to the net_device structure in memory. Cf
http://groups.google.com/group/comp.os.linux.development.system/browse_thread/thread/de19321bcd94dbb8/0d74a4adcd6177bd
This is the case when the net_device structure was allocated with
a call to alloc_netdev or one of its derivative.

Here is an excerpt of the semantic patch that performs the transformation

@ rule1 @
type T;
struct net_device *dev;
@@

 dev = 
(
        alloc_netdev
|         
        alloc_etherdev
|
        alloc_trdev
)
   (sizeof(T), ...)

@ rule1bis @
struct net_device *dev;
expression E;
@@
 dev->priv = E

@ rule2 depends on rule1 && !rule1bis  @
struct net_device *dev;
type rule1.T;
@@

- (T*) dev->priv
+ netdev_priv(dev)

Signed-off-by: Yoann Padioleau <padator@wanadoo.fr>
Cc: jeff@garzik.org
Cc: netdev@vger.kernel.org
Cc: akpm@linux-foundation.org
---

 drivers/net/wan/dlci.c         |   30 +++++++++++++-------------
 drivers/net/wan/lmc/lmc_main.c |   26 +++++++++++------------
 drivers/net/wan/sdla.c         |   46 ++++++++++++++++++++---------------------
 drivers/net/wan/sealevel.c     |   12 +++++-----
 drivers/net/wan/x25_asy.c      |   28 ++++++++++++------------
 5 files changed, 71 insertions(+), 71 deletions(-)

diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 66be20c..d988161 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -74,7 +74,7 @@ static int dlci_header(struct sk_buff *s
 	unsigned int		hlen;
 	char			*dest;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	hdr.control = FRAD_I_UI;
 	switch(type)
@@ -110,7 +110,7 @@ static void dlci_receive(struct sk_buff 
 	struct frhdr		*hdr;
 	int					process, header;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 	if (!pskb_may_pull(skb, sizeof(*hdr))) {
 		printk(KERN_NOTICE "%s: invalid data no header\n",
 		       dev->name);
@@ -197,7 +197,7 @@ static int dlci_transmit(struct sk_buff 
 	if (!skb || !dev)
 		return(0);
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 	
@@ -235,7 +235,7 @@ static int dlci_config(struct net_device
 	struct frad_local	*flp;
 	int			err;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	flp = dlp->slave->priv;
 
@@ -269,7 +269,7 @@ static int dlci_dev_ioctl(struct net_dev
 	if (!capable(CAP_NET_ADMIN))
 		return(-EPERM);
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	switch(cmd)
 	{
@@ -298,7 +298,7 @@ static int dlci_change_mtu(struct net_de
 {
 	struct dlci_local *dlp;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	return((*dlp->slave->change_mtu)(dlp->slave, new_mtu));
 }
@@ -309,7 +309,7 @@ static int dlci_open(struct net_device *
 	struct frad_local	*flp;
 	int			err;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	if (!*(short *)(dev->dev_addr))
 		return(-EINVAL);
@@ -335,7 +335,7 @@ static int dlci_close(struct net_device 
 
 	netif_stop_queue(dev);
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	flp = dlp->slave->priv;
 	err = (*flp->deactivate)(dlp->slave, dev);
@@ -347,7 +347,7 @@ static struct net_device_stats *dlci_get
 {
 	struct dlci_local *dlp;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	return(&dlp->stats);
 }
@@ -365,7 +365,7 @@ static int dlci_add(struct dlci_add *dlc
 	if (!slave)
 		return -ENODEV;
 
-	if (slave->type != ARPHRD_FRAD || slave->priv == NULL)
+	if (slave->type != ARPHRD_FRAD || netdev_priv(slave) == NULL)
 		goto err1;
 
 	/* create device name */
@@ -391,11 +391,11 @@ static int dlci_add(struct dlci_add *dlc
 
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
@@ -435,9 +435,9 @@ static int dlci_del(struct dlci_add *dlc
 		return(-EBUSY);
 	}
 
-	dlp = master->priv;
+	dlp = netdev_priv(master);
 	slave = dlp->slave;
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	rtnl_lock();
 	err = (*flp->deassoc)(slave, master);
@@ -487,7 +487,7 @@ static int dlci_ioctl(unsigned int cmd, 
 
 static void dlci_setup(struct net_device *dev)
 {
-	struct dlci_local *dlp = dev->priv;
+	struct dlci_local *dlp = netdev_priv(dev);
 
 	dev->flags		= 0;
 	dev->open		= dlci_open;
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index ae132c1..9aa04a6 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -126,7 +126,7 @@ int lmc_ioctl (struct net_device *dev, s
 
     ret = -EOPNOTSUPP;
 
-    sc = dev->priv;
+    sc = netdev_priv(dev);
 
     lmc_trace(dev, "lmc_ioctl in");
 
@@ -634,7 +634,7 @@ static void lmc_watchdog (unsigned long 
     u_int32_t ticks;
     unsigned long flags;
 
-    sc = dev->priv;
+    sc = netdev_priv(dev);
 
     lmc_trace(dev, "lmc_watchdog in");
 
@@ -872,7 +872,7 @@ #endif
         lmc_first_load = 1;
     }
     
-    sc = dev->priv;
+    sc = netdev_priv(dev);
     sc->lmc_device = dev;
     sc->name = dev->name;
 
@@ -1018,7 +1018,7 @@ static void __devexit lmc_remove_one (st
     struct net_device *dev = pci_get_drvdata(pdev);
     
     if (dev) {
-	    lmc_softc_t *sc = dev->priv;
+	    lmc_softc_t *sc = netdev_priv(dev);
 	    
 	    printk("%s: removing...\n", dev->name);
 	    lmc_proto_detach(sc);
@@ -1035,7 +1035,7 @@ static void __devexit lmc_remove_one (st
  */
 static int lmc_open (struct net_device *dev) /*fold00*/
 {
-    lmc_softc_t *sc = dev->priv;
+    lmc_softc_t *sc = netdev_priv(dev);
 
     lmc_trace(dev, "lmc_open in");
 
@@ -1153,7 +1153,7 @@ static int lmc_open (struct net_device *
 static void lmc_running_reset (struct net_device *dev) /*fold00*/
 {
 
-    lmc_softc_t *sc = (lmc_softc_t *) dev->priv;
+    lmc_softc_t *sc = netdev_priv(dev);
 
     lmc_trace(dev, "lmc_runnig_reset in");
 
@@ -1194,7 +1194,7 @@ static int lmc_close (struct net_device 
 
     lmc_trace(dev, "lmc_close in");
     
-    sc = dev->priv;
+    sc = netdev_priv(dev);
     sc->lmc_ok = 0;
     sc->lmc_media->set_link_status (sc, 0);
     del_timer (&sc->timer);
@@ -1210,7 +1210,7 @@ static int lmc_close (struct net_device 
 /* When the interface goes down, this is called */
 static int lmc_ifdown (struct net_device *dev) /*fold00*/
 {
-    lmc_softc_t *sc = dev->priv;
+    lmc_softc_t *sc = netdev_priv(dev);
     u32 csr6;
     int i;
 
@@ -1287,7 +1287,7 @@ static irqreturn_t lmc_interrupt (int ir
 
     lmc_trace(dev, "lmc_interrupt in");
 
-    sc = dev->priv;
+    sc = netdev_priv(dev);
     
     spin_lock(&sc->lmc_lock);
 
@@ -1473,7 +1473,7 @@ static int lmc_start_xmit (struct sk_buf
 
     lmc_trace(dev, "lmc_start_xmit in");
 
-    sc = dev->priv;
+    sc = netdev_priv(dev);
 
     spin_lock_irqsave(&sc->lmc_lock, flags);
 
@@ -1570,7 +1570,7 @@ static int lmc_rx (struct net_device *de
 
     lmc_trace(dev, "lmc_rx in");
 
-    sc = dev->priv;
+    sc = netdev_priv(dev);
 
     lmc_led_on(sc, LMC_DS3_LED3);
 
@@ -1764,7 +1764,7 @@ skip_out_of_mem:
 
 static struct net_device_stats *lmc_get_stats (struct net_device *dev) /*fold00*/
 {
-    lmc_softc_t *sc = dev->priv;
+    lmc_softc_t *sc = netdev_priv(dev);
     unsigned long flags;
 
     lmc_trace(dev, "lmc_get_stats in");
@@ -2145,7 +2145,7 @@ static void lmc_driver_timeout(struct ne
 
     lmc_trace(dev, "lmc_driver_timeout in");
 
-    sc = dev->priv;
+    sc = netdev_priv(dev);
 
     spin_lock_irqsave(&sc->lmc_lock, flags);
 
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 792e588..a2f1849 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -185,7 +185,7 @@ static void sdla_stop(struct net_device 
 {
 	struct frad_local *flp;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	switch(flp->type)
 	{
 		case SDLA_S502A:
@@ -212,7 +212,7 @@ static void sdla_start(struct net_device
 {
 	struct frad_local *flp;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	switch(flp->type)
 	{
 		case SDLA_S502A:
@@ -432,7 +432,7 @@ static int sdla_cmd(struct net_device *d
 	int                      ret, waiting, len;
 	long                     window;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	window = flp->type == SDLA_S508 ? SDLA_508_CMD_BUF : SDLA_502_CMD_BUF;
 	cmd_buf = (struct sdla_cmd *)(dev->mem_start + (window & SDLA_ADDR_MASK));
 	ret = 0;
@@ -509,7 +509,7 @@ static int sdla_activate(struct net_devi
 	struct frad_local *flp;
 	int i;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->master[i] == master)
@@ -531,7 +531,7 @@ static int sdla_deactivate(struct net_de
 	struct frad_local *flp;
 	int               i;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->master[i] == master)
@@ -556,7 +556,7 @@ static int sdla_assoc(struct net_device 
 	if (master->type != ARPHRD_DLCI)
 		return(-EINVAL);
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 	{
@@ -589,7 +589,7 @@ static int sdla_deassoc(struct net_devic
 	struct frad_local *flp;
 	int               i;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->master[i] == master)
@@ -619,7 +619,7 @@ static int sdla_dlci_conf(struct net_dev
 	int               i;
 	short             len, ret;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->master[i] == master)
@@ -628,7 +628,7 @@ static int sdla_dlci_conf(struct net_dev
 	if (i == CONFIG_DLCI_MAX)
 		return(-ENODEV);
 
-	dlp = master->priv;
+	dlp = netdev_priv(master);
 
 	ret = SDLA_RET_OK;
 	len = sizeof(struct dlci_conf);
@@ -659,7 +659,7 @@ static int sdla_transmit(struct sk_buff 
 	unsigned long     flags;
 	struct buf_entry  *pbuf;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	ret = 0;
 	accept = 1;
 
@@ -755,7 +755,7 @@ static void sdla_receive(struct net_devi
 	int               i=0, received, success, addr, buf_base, buf_top;
 	short             dlci, len, len2, split;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	success = 1;
 	received = addr = buf_top = buf_base = 0;
 	len = dlci = 0;
@@ -860,7 +860,7 @@ static void sdla_receive(struct net_devi
 	if (success)
 	{
 		flp->stats.rx_packets++;
-		dlp = master->priv;
+		dlp = netdev_priv(master);
 		(*dlp->receive)(skb, master);
 	}
 
@@ -924,7 +924,7 @@ static void sdla_poll(unsigned long devi
 	struct frad_local *flp;
 
 	dev = (struct net_device *) device;
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (sdla_byte(dev, SDLA_502_RCV_BUF))
 		sdla_receive(dev);
@@ -940,7 +940,7 @@ static int sdla_close(struct net_device 
 	int               len, i;
 	short             dlcis[CONFIG_DLCI_MAX];
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	len = 0;
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
@@ -1001,7 +1001,7 @@ static int sdla_open(struct net_device *
 	int               len, i;
 	char              byte;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (!flp->initialized)
 		return(-EPERM);
@@ -1098,7 +1098,7 @@ static int sdla_config(struct net_device
 	if (dev->type == 0xFFFF)
 		return(-EUNATCH);
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (!get)
 	{
@@ -1229,7 +1229,7 @@ static int sdla_reconfig(struct net_devi
 	struct conf_data  data;
 	int               i, len;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	len = 0;
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
@@ -1254,7 +1254,7 @@ static int sdla_ioctl(struct net_device 
 	if(!capable(CAP_NET_ADMIN))
 		return -EPERM;
 		
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (!flp->initialized)
 		return(-EINVAL);
@@ -1320,7 +1320,7 @@ static int sdla_change_mtu(struct net_de
 {
 	struct frad_local *flp;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (netif_running(dev))
 		return(-EBUSY);
@@ -1337,7 +1337,7 @@ static int sdla_set_config(struct net_de
 	unsigned base;
 	int err = -EINVAL;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (flp->initialized)
 		return(-EINVAL);
@@ -1592,14 +1592,14 @@ fail:
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
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 11276bf..4414901 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -77,7 +77,7 @@ static void sealevel_input(struct z8530_
  
 static int sealevel_open(struct net_device *d)
 {
-	struct slvl_device *slvl=d->priv;
+	struct slvl_device *slvl=netdev_priv(d);
 	int err = -1;
 	int unit = slvl->channel;
 	
@@ -126,7 +126,7 @@ static int sealevel_open(struct net_devi
 
 static int sealevel_close(struct net_device *d)
 {
-	struct slvl_device *slvl=d->priv;
+	struct slvl_device *slvl=netdev_priv(d);
 	int unit = slvl->channel;
 	
 	/*
@@ -166,7 +166,7 @@ static int sealevel_ioctl(struct net_dev
 
 static struct net_device_stats *sealevel_get_stats(struct net_device *d)
 {
-	struct slvl_device *slvl=d->priv;
+	struct slvl_device *slvl=netdev_priv(d);
 	if(slvl)
 		return z8530_get_stats(slvl->chan);
 	else
@@ -179,7 +179,7 @@ static struct net_device_stats *sealevel
  
 static int sealevel_queue_xmit(struct sk_buff *skb, struct net_device *d)
 {
-	struct slvl_device *slvl=d->priv;
+	struct slvl_device *slvl=netdev_priv(d);
 	return z8530_queue_xmit(slvl->chan, skb);
 }
 
@@ -204,7 +204,7 @@ static int sealevel_neigh_setup_dev(stru
 
 static int sealevel_attach(struct net_device *dev)
 {
-	struct slvl_device *sv = dev->priv;
+	struct slvl_device *sv = netdev_priv(dev);
 	sppp_attach(&sv->pppdev);
 	return 0;
 }
@@ -240,7 +240,7 @@ static inline struct slvl_device *slvl_a
 	if (!d) 
 		return NULL;
 
-	sv = d->priv;
+	sv = netdev_priv(d);
 	sv->if_ptr = &sv->pppdev;
 	sv->pppdev.dev = d;
 	d->base_addr = iobase;
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index c48b1cc..d62821d 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -63,7 +63,7 @@ static struct x25_asy *x25_asy_alloc(voi
 		if (dev == NULL)
 			break;
 
-		sl = dev->priv;
+		sl = netdev_priv(dev);
 		/* Not in use ? */
 		if (!test_and_set_bit(SLF_INUSE, &sl->flags))
 			return sl;
@@ -85,7 +85,7 @@ static struct x25_asy *x25_asy_alloc(voi
 			return NULL;
 
 		/* Initialize channel control data */
-		sl = dev->priv;
+		sl = netdev_priv(dev);
 		dev->base_addr    = i;
 
 		/* register device so that it can be ifconfig'ed       */
@@ -119,7 +119,7 @@ static void x25_asy_free(struct x25_asy 
 
 static int x25_asy_change_mtu(struct net_device *dev, int newmtu)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	unsigned char *xbuff, *rbuff;
 	int len = 2* newmtu;
 
@@ -282,7 +282,7 @@ static void x25_asy_write_wakeup(struct 
 
 static void x25_asy_timeout(struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
+	struct x25_asy *sl = (struct x25_asy*)(netdev_priv(dev));
 
 	spin_lock(&sl->lock);
 	if (netif_queue_stopped(dev)) {
@@ -303,7 +303,7 @@ static void x25_asy_timeout(struct net_d
 
 static int x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
+	struct x25_asy *sl = (struct x25_asy*)(netdev_priv(dev));
 	int err;
 
 	if (!netif_running(sl->dev)) {
@@ -372,7 +372,7 @@ static int x25_asy_data_indication(struc
  
 static void x25_asy_data_transmit(struct net_device *dev, struct sk_buff *skb)
 {
-	struct x25_asy *sl=dev->priv;
+	struct x25_asy *sl=netdev_priv(dev);
 	
 	spin_lock(&sl->lock);
 	if (netif_queue_stopped(sl->dev) || sl->tty == NULL)
@@ -399,7 +399,7 @@ static void x25_asy_data_transmit(struct
  
 static void x25_asy_connected(struct net_device *dev, int reason)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	struct sk_buff *skb;
 	unsigned char *ptr;
 
@@ -418,7 +418,7 @@ static void x25_asy_connected(struct net
 
 static void x25_asy_disconnected(struct net_device *dev, int reason)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	struct sk_buff *skb;
 	unsigned char *ptr;
 
@@ -449,7 +449,7 @@ static struct lapb_register_struct x25_a
 /* Open the low-level part of the X.25 channel. Easy! */
 static int x25_asy_open(struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
+	struct x25_asy *sl = (struct x25_asy*)(netdev_priv(dev));
 	unsigned long len;
 	int err;
 
@@ -499,7 +499,7 @@ norbuff:
 /* Close the low-level part of the X.25 channel. Easy! */
 static int x25_asy_close(struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
+	struct x25_asy *sl = (struct x25_asy*)(netdev_priv(dev));
 	int err;
 
 	spin_lock(&sl->lock);
@@ -615,7 +615,7 @@ static void x25_asy_close_tty(struct tty
 
 static struct net_device_stats *x25_asy_get_stats(struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
+	struct x25_asy *sl = (struct x25_asy*)(netdev_priv(dev));
 
 	return &sl->stats;
 }
@@ -730,7 +730,7 @@ static int x25_asy_ioctl(struct tty_stru
 
 static int x25_asy_open_dev(struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
+	struct x25_asy *sl = (struct x25_asy*)(netdev_priv(dev));
 	if(sl->tty==NULL)
 		return -ENODEV;
 	return 0;
@@ -739,7 +739,7 @@ static int x25_asy_open_dev(struct net_d
 /* Initialise the X.25 driver.  Called by the device init code */
 static void x25_asy_setup(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 
 	sl->magic  = X25_ASY_MAGIC;
 	sl->dev	   = dev;
@@ -805,7 +805,7 @@ static void __exit exit_x25_asy(void)
 	for (i = 0; i < x25_asy_maxdev; i++) {
 		dev = x25_asy_devs[i];
 		if (dev) {
-			struct x25_asy *sl = dev->priv;
+			struct x25_asy *sl = netdev_priv(dev);
 
 			spin_lock_bh(&sl->lock);
 			if (sl->tty) 

