From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] wanrouter: don't use typedefs for wan_device, just struct wan_device
Date: Thu, 15 May 2003 17:29:14 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030515202914.GF11319@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/net-2.5

	Next one is to kill the obnoxious netdevice_t 8) Then, to fix the
MOD_{INC,DEC}_USE_COUNT stuff.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1144, 2003-05-15 17:17:01-03:00, acme@conectiva.com.br
  o wanrouter: don't use typedefs for wan_device, just struct wan_device


 drivers/net/wan/cycx_main.c       |   14 +++++------
 drivers/net/wan/cycx_x25.c        |   44 +++++++++++++++++++-----------------
 drivers/net/wan/sdla_chdlc.c      |   13 +++++-----
 drivers/net/wan/sdla_fr.c         |   16 +++++++------
 drivers/net/wan/sdla_ppp.c        |   16 +++++++------
 drivers/net/wan/sdla_x25.c        |   25 ++++++++++----------
 drivers/net/wan/sdlamain.c        |   14 +++++------
 drivers/net/wan/wanpipe_multppp.c |   15 ++++++------
 include/linux/cyclomx.h           |    2 -
 include/linux/wanpipe.h           |    2 -
 include/linux/wanrouter.h         |   13 ++++------
 net/wanrouter/wanmain.c           |   46 +++++++++++++++++++-------------------
 net/wanrouter/wanproc.c           |   18 +++++++-------
 13 files changed, 123 insertions(+), 115 deletions(-)


diff -Nru a/drivers/net/wan/cycx_main.c b/drivers/net/wan/cycx_main.c
--- a/drivers/net/wan/cycx_main.c	Thu May 15 17:24:14 2003
+++ b/drivers/net/wan/cycx_main.c	Thu May 15 17:24:14 2003
@@ -70,9 +70,9 @@
 /* Function Prototypes */
 
 /* WAN link driver entry points */
-static int setup (wan_device_t *wandev, wandev_conf_t *conf);
-static int shutdown (wan_device_t *wandev);
-static int ioctl (wan_device_t *wandev, unsigned cmd, unsigned long arg);
+static int setup(struct wan_device *wandev, wandev_conf_t *conf);
+static int shutdown(struct wan_device *wandev);
+static int ioctl(struct wan_device *wandev, unsigned cmd, unsigned long arg);
 
 /* Miscellaneous functions */
 static irqreturn_t cycx_isr (int irq, void *dev_id, struct pt_regs *regs);
@@ -122,7 +122,7 @@
 	/* Register adapters with WAN router */
 	for (cnt = 0; cnt < ncards; ++cnt) {
 		cycx_t *card = &card_array[cnt];
-		wan_device_t *wandev = &card->wandev;
+		struct wan_device *wandev = &card->wandev;
 
 		sprintf(card->devname, "%s%d", drvname, cnt + 1);
 		wandev->magic    = ROUTER_MAGIC;
@@ -181,7 +181,7 @@
  * configuration structure is in kernel memory (including extended data, if
  * any).
  */
-static int setup (wan_device_t *wandev, wandev_conf_t *conf)
+static int setup(struct wan_device *wandev, wandev_conf_t *conf)
 {
 	int err = -EFAULT;
 	cycx_t *card;
@@ -273,7 +273,7 @@
  * This function is called by the router when device is being unregistered or
  * when it handles ROUTER_DOWN IOCTL.
  */
-static int shutdown (wan_device_t *wandev)
+static int shutdown(struct wan_device *wandev)
 {
 	int ret = -EFAULT;
 	cycx_t *card;
@@ -305,7 +305,7 @@
  *
  * no reserved ioctls for the cyclom 2x up to now
  */
-static int ioctl (wan_device_t *wandev, unsigned cmd, unsigned long arg)
+static int ioctl(struct wan_device *wandev, unsigned cmd, unsigned long arg)
 {
 	return -EINVAL;
 }
diff -Nru a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
--- a/drivers/net/wan/cycx_x25.c	Thu May 15 17:24:14 2003
+++ b/drivers/net/wan/cycx_x25.c	Thu May 15 17:24:14 2003
@@ -120,10 +120,10 @@
 
 /* Function Prototypes */
 /* WAN link driver entry points. These are called by the WAN router module. */
-static int update (wan_device_t *wandev),
-	   new_if (wan_device_t *wandev, struct net_device *dev,
-		   wanif_conf_t *conf),
-	   del_if (wan_device_t *wandev, struct net_device *dev);
+static int update(struct wan_device *wandev),
+	   new_if(struct wan_device *wandev, struct net_device *dev,
+		  wanif_conf_t *conf),
+	   del_if(struct wan_device *wandev, struct net_device *dev);
 
 /* Network device interface */
 static int if_init (struct net_device *dev),
@@ -175,14 +175,15 @@
 
 static unsigned dec_to_uint (u8 *str, int len);
 
-static struct net_device *get_dev_by_lcn (wan_device_t *wandev, s16 lcn);
-static struct net_device *get_dev_by_dte_addr (wan_device_t *wandev, char *dte);
+static struct net_device *get_dev_by_lcn(struct wan_device *wandev, s16 lcn);
+static struct net_device *get_dev_by_dte_addr(struct wan_device *wandev,
+					      char *dte);
 
 #ifdef CYCLOMX_X25_DEBUG
 static void hex_dump(char *msg, unsigned char *p, int len);
 static void x25_dump_config(TX25Config *conf);
 static void x25_dump_stats(TX25Stats *stats);
-static void x25_dump_devs(wan_device_t *wandev);
+static void x25_dump_devs(struct wan_device *wandev);
 #else
 #define hex_dump(msg, p, len)
 #define x25_dump_config(conf)
@@ -318,7 +319,7 @@
 
 /* WAN Device Driver Entry Points */
 /* Update device status & statistics. */
-static int update (wan_device_t *wandev)
+static int update(struct wan_device *wandev)
 {
 	/* sanity checks */
 	if (!wandev || !wandev->private)
@@ -342,8 +343,8 @@
  *
  * Return:	0	o.k.
  *		< 0	failure (channel will not be created) */
-static int new_if (wan_device_t *wandev, struct net_device *dev,
-		   wanif_conf_t *conf)
+static int new_if(struct wan_device *wandev, struct net_device *dev,
+		  wanif_conf_t *conf)
 {
 	cycx_t *card = wandev->private;
 	x25_channel_t *chan;
@@ -431,7 +432,7 @@
 }
 
 /* Delete logical channel. */
-static int del_if (wan_device_t *wandev, struct net_device *dev)
+static int del_if(struct wan_device *wandev, struct net_device *dev)
 {
 	if (dev->priv) {
 		x25_channel_t *chan = dev->priv;
@@ -461,7 +462,7 @@
 {
 	x25_channel_t *chan = dev->priv;
 	cycx_t *card = chan->card;
-	wan_device_t *wandev = &card->wandev;
+	struct wan_device *wandev = &card->wandev;
 
 	/* Initialize device driver entry points */
 	dev->open = if_open;
@@ -711,7 +712,7 @@
 static void tx_intr (cycx_t *card, TX25Cmd *cmd)
 {
 	struct net_device *dev;
-	wan_device_t *wandev = &card->wandev;
+	struct wan_device *wandev = &card->wandev;
 	u8 lcn;
 
 	cycx_peek(&card->hw, cmd->buf, &lcn, sizeof(lcn));
@@ -741,7 +742,7 @@
  *    socket buffers available) the whole packet sequence must be discarded. */
 static void rx_intr (cycx_t *card, TX25Cmd *cmd)
 {
-	wan_device_t *wandev = &card->wandev;
+	struct wan_device *wandev = &card->wandev;
 	struct net_device *dev;
 	x25_channel_t *chan;
 	struct sk_buff *skb;
@@ -825,7 +826,7 @@
 /* Connect interrupt handler. */
 static void connect_intr (cycx_t *card, TX25Cmd *cmd)
 {
-	wan_device_t *wandev = &card->wandev;
+	struct wan_device *wandev = &card->wandev;
 	struct net_device *dev = NULL;
 	x25_channel_t *chan;
 	u8 d[32],
@@ -867,7 +868,7 @@
 /* Connect confirm interrupt handler. */
 static void connect_confirm_intr (cycx_t *card, TX25Cmd *cmd)
 {
-	wan_device_t *wandev = &card->wandev;
+	struct wan_device *wandev = &card->wandev;
 	struct net_device *dev;
 	x25_channel_t *chan;
 	u8 lcn, key;
@@ -894,7 +895,7 @@
 /* Disconnect confirm interrupt handler. */
 static void disconnect_confirm_intr (cycx_t *card, TX25Cmd *cmd)
 {
-	wan_device_t *wandev = &card->wandev;
+	struct wan_device *wandev = &card->wandev;
 	struct net_device *dev;
 	u8 lcn;
 
@@ -914,7 +915,7 @@
 /* disconnect interrupt handler. */
 static void disconnect_intr (cycx_t *card, TX25Cmd *cmd)
 {
-	wan_device_t *wandev = &card->wandev;
+	struct wan_device *wandev = &card->wandev;
 	struct net_device *dev;
 	u8 lcn;
 
@@ -1255,7 +1256,7 @@
 
 /* Miscellaneous */
 /* Find network device by its channel number.  */
-static struct net_device *get_dev_by_lcn (wan_device_t *wandev, s16 lcn)
+static struct net_device *get_dev_by_lcn(struct wan_device *wandev, s16 lcn)
 {
 	struct net_device *dev = wandev->dev;
 	x25_channel_t *chan;
@@ -1271,7 +1272,8 @@
 }
 
 /* Find network device by its remote dte address. */
-static struct net_device *get_dev_by_dte_addr (wan_device_t *wandev, char *dte)
+static struct net_device *get_dev_by_dte_addr(struct wan_device *wandev,
+					      char *dte)
 {
 	struct net_device *dev = wandev->dev;
 	x25_channel_t *chan;
@@ -1556,7 +1558,7 @@
 	printk(KERN_INFO "rx_aborts=%d\n", stats->rx_aborts);
 }
 
-static void x25_dump_devs(wan_device_t *wandev)
+static void x25_dump_devs(struct wan_device *wandev)
 {
 	struct net_device *dev = wandev->dev;
 
diff -Nru a/drivers/net/wan/sdla_chdlc.c b/drivers/net/wan/sdla_chdlc.c
--- a/drivers/net/wan/sdla_chdlc.c	Thu May 15 17:24:14 2003
+++ b/drivers/net/wan/sdla_chdlc.c	Thu May 15 17:24:14 2003
@@ -186,8 +186,8 @@
 
 /****** Function Prototypes *************************************************/
 /* WAN link driver entry points. These are called by the WAN router module. */
-static int update (wan_device_t* wandev);
-static int new_if (wan_device_t* wandev, netdevice_t* dev,
+static int update(struct wan_device* wandev);
+static int new_if(struct wan_device* wandev, netdevice_t* dev,
 	wanif_conf_t* conf);
 
 /* Network device interface */
@@ -598,7 +598,7 @@
  * as to minimize the time that we are inside the interrupt handler.
  *
  */
-static int update (wan_device_t* wandev)
+static int update(struct wan_device* wandev)
 {
 	sdla_t* card = wandev->private;
  	netdevice_t* dev;
@@ -666,7 +666,8 @@
  * Return:	0	o.k.
  *		< 0	failure (channel will not be created)
  */
-static int new_if (wan_device_t* wandev, netdevice_t* dev, wanif_conf_t* conf)
+static int new_if(struct wan_device* wandev, netdevice_t* dev,
+		  wanif_conf_t* conf)
 {
 	sdla_t* card = wandev->private;
 	chdlc_private_area_t* chdlc_priv_area;
@@ -898,10 +899,10 @@
  * registration.
  */
 static int if_init (netdevice_t* dev)
-	{
+{
 	chdlc_private_area_t* chdlc_priv_area = dev->priv;
 	sdla_t* card = chdlc_priv_area->card;
-	wan_device_t* wandev = &card->wandev;
+	struct wan_device* wandev = &card->wandev;
 
 	/* Initialize device driver entry points */
 	dev->open		= &if_open;
diff -Nru a/drivers/net/wan/sdla_fr.c b/drivers/net/wan/sdla_fr.c
--- a/drivers/net/wan/sdla_fr.c	Thu May 15 17:24:14 2003
+++ b/drivers/net/wan/sdla_fr.c	Thu May 15 17:24:14 2003
@@ -323,9 +323,10 @@
 /****** Function Prototypes *************************************************/
 
 /* WAN link driver entry points. These are called by the WAN router module. */
-static int update(wan_device_t *wandev);
-static int new_if(wan_device_t *wandev, netdevice_t *dev, wanif_conf_t *conf);
-static int del_if(wan_device_t *wandev, netdevice_t *dev);
+static int update(struct wan_device *wandev);
+static int new_if(struct wan_device *wandev, netdevice_t *dev,
+		  wanif_conf_t *conf);
+static int del_if(struct wan_device *wandev, netdevice_t *dev);
 static void disable_comm (sdla_t *card);
 
 /* WANPIPE-specific entry points */
@@ -746,7 +747,7 @@
 /*============================================================================
  * Update device status & statistics.
  */
-static int update (wan_device_t* wandev)
+static int update(struct wan_device* wandev)
 {
 	volatile sdla_t* card;
 	unsigned long timeout;
@@ -791,7 +792,8 @@
  * Return:	0	o.k.
  *		< 0	failure (channel will not be created)
  */
-static int new_if (wan_device_t* wandev, netdevice_t* dev, wanif_conf_t* conf)
+static int new_if(struct wan_device* wandev, netdevice_t* dev,
+		  wanif_conf_t* conf)
 {
 	sdla_t* card = wandev->private;
 	fr_channel_t* chan;
@@ -1020,7 +1022,7 @@
 /*============================================================================
  * Delete logical channel.
  */
-static int del_if (wan_device_t* wandev, netdevice_t* dev)
+static int del_if(struct wan_device* wandev, netdevice_t* dev)
 {
 	fr_channel_t* chan = dev->priv;
 	unsigned long smp_flags=0;
@@ -1120,7 +1122,7 @@
 {
 	fr_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
-	wan_device_t* wandev = &card->wandev;
+	struct wan_device* wandev = &card->wandev;
 
 	/* Initialize device driver entry points */
 	dev->open		= &if_open;
diff -Nru a/drivers/net/wan/sdla_ppp.c b/drivers/net/wan/sdla_ppp.c
--- a/drivers/net/wan/sdla_ppp.c	Thu May 15 17:24:14 2003
+++ b/drivers/net/wan/sdla_ppp.c	Thu May 15 17:24:14 2003
@@ -231,9 +231,10 @@
 /****** Function Prototypes *************************************************/
 
 /* WAN link driver entry points. These are called by the WAN router module. */
-static int update(wan_device_t *wandev);
-static int new_if(wan_device_t *wandev, netdevice_t *dev, wanif_conf_t *conf);
-static int del_if(wan_device_t *wandev, netdevice_t *dev);
+static int update(struct wan_device *wandev);
+static int new_if(struct wan_device *wandev, netdevice_t *dev,
+		  wanif_conf_t *conf);
+static int del_if(struct wan_device *wandev, netdevice_t *dev);
 
 /* WANPIPE-specific entry points */
 static int wpp_exec (struct sdla *card, void *u_cmd, void *u_data);
@@ -444,7 +445,7 @@
 /*============================================================================
  * Update device status & statistics.
  */
-static int update(wan_device_t *wandev)
+static int update(struct wan_device *wandev)
 {
 	sdla_t* card = wandev->private;
  	netdevice_t* dev;
@@ -504,7 +505,8 @@
  * Return:	0	o.k.
  *		< 0	failure (channel will not be created)
  */
-static int new_if(wan_device_t *wandev, netdevice_t *dev, wanif_conf_t *conf)
+static int new_if(struct wan_device *wandev, netdevice_t *dev,
+		  wanif_conf_t *conf)
 {
 	sdla_t *card = wandev->private;
 	ppp_private_area_t *ppp_priv_area;
@@ -622,7 +624,7 @@
 /*============================================================================
  * Delete logical channel.
  */
-static int del_if(wan_device_t *wandev, netdevice_t *dev)
+static int del_if(struct wan_device *wandev, netdevice_t *dev)
 {
 	return 0;
 }
@@ -685,7 +687,7 @@
 {
 	ppp_private_area_t *ppp_priv_area = dev->priv;
 	sdla_t *card = ppp_priv_area->card;
-	wan_device_t *wandev = &card->wandev;
+	struct wan_device *wandev = &card->wandev;
 
 	/* Initialize device driver entry points */
 	dev->open		= &if_open;
diff -Nru a/drivers/net/wan/sdla_x25.c b/drivers/net/wan/sdla_x25.c
--- a/drivers/net/wan/sdla_x25.c	Thu May 15 17:24:14 2003
+++ b/drivers/net/wan/sdla_x25.c	Thu May 15 17:24:14 2003
@@ -330,10 +330,10 @@
  * WAN link driver entry points. These are 
  * called by the WAN router module.
  */
-static int update (wan_device_t* wandev);
-static int new_if (wan_device_t* wandev, netdevice_t* dev,
-	wanif_conf_t* conf);
-static int del_if (wan_device_t* wandev, netdevice_t* dev);
+static int update(struct wan_device* wandev);
+static int new_if(struct wan_device* wandev, netdevice_t* dev,
+		  wanif_conf_t* conf);
+static int del_if(struct wan_device* wandev, netdevice_t* dev);
 static void disable_comm (sdla_t* card);
 static void disable_comm_shutdown(sdla_t *card);
 
@@ -425,7 +425,7 @@
  */
 static int connect (sdla_t* card);
 static int disconnect (sdla_t* card);
-static netdevice_t* get_dev_by_lcn(wan_device_t* wandev, unsigned lcn);
+static netdevice_t* get_dev_by_lcn(struct wan_device* wandev, unsigned lcn);
 static int chan_connect (netdevice_t* dev);
 static int chan_disc (netdevice_t* dev);
 static void set_chan_state (netdevice_t* dev, int state);
@@ -830,7 +830,7 @@
  * 		<0	Failed (or busy).
  */
 
-static int update (wan_device_t* wandev)
+static int update(struct wan_device* wandev)
 {
 	volatile sdla_t* card;
 	TX25Status* status;
@@ -895,7 +895,8 @@
  * Return: 	0 	Ok
  *		<0 	Failed (channel will not be created)
  */
-static int new_if (wan_device_t* wandev, netdevice_t* dev, wanif_conf_t* conf)
+static int new_if(struct wan_device* wandev, netdevice_t* dev,
+		  wanif_conf_t* conf)
 {
 	sdla_t* card = wandev->private;
 	x25_channel_t* chan;
@@ -1029,7 +1030,7 @@
 
 //FIXME Del IF Should be taken out now.
 
-static int del_if (wan_device_t* wandev, netdevice_t* dev)
+static int del_if(struct wan_device* wandev, netdevice_t* dev)
 {
 	return 0;
 }
@@ -1099,7 +1100,7 @@
 {
 	x25_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
-	wan_device_t* wandev = &card->wandev;
+	struct wan_device* wandev = &card->wandev;
 
 	/* Initialize device driver entry points */
 	dev->open		= &if_open;
@@ -3101,7 +3102,7 @@
 
 static int incoming_call (sdla_t* card, int cmd, int lcn, TX25Mbox* mb)
 {
-	wan_device_t* wandev = &card->wandev;
+	struct wan_device* wandev = &card->wandev;
 	int new_lcn = mb->cmd.lcn;
 	netdevice_t* dev = get_dev_by_lcn(wandev, new_lcn);
 	x25_channel_t* chan = NULL;
@@ -3336,7 +3337,7 @@
 
 static int restart_event (sdla_t* card, int cmd, int lcn, TX25Mbox* mb)
 {
-	wan_device_t* wandev = &card->wandev;
+	struct wan_device* wandev = &card->wandev;
 	netdevice_t* dev;
 	x25_channel_t *chan;
 	unsigned char old_state;
@@ -3447,7 +3448,7 @@
  * Find network device by its channel number.
  */
 
-static netdevice_t* get_dev_by_lcn (wan_device_t* wandev, unsigned lcn)
+static netdevice_t* get_dev_by_lcn(struct wan_device* wandev, unsigned lcn)
 {
 	netdevice_t* dev;
 
diff -Nru a/drivers/net/wan/sdlamain.c b/drivers/net/wan/sdlamain.c
--- a/drivers/net/wan/sdlamain.c	Thu May 15 17:24:14 2003
+++ b/drivers/net/wan/sdlamain.c	Thu May 15 17:24:14 2003
@@ -184,9 +184,9 @@
 void cleanup_module (void);
 
 /* WAN link driver entry points */
-static int setup    (wan_device_t* wandev, wandev_conf_t* conf);
-static int shutdown (wan_device_t* wandev);
-static int ioctl    (wan_device_t* wandev, unsigned cmd, unsigned long arg);
+static int setup(struct wan_device* wandev, wandev_conf_t* conf);
+static int shutdown(struct wan_device* wandev);
+static int ioctl(struct wan_device* wandev, unsigned cmd, unsigned long arg);
 
 /* IOCTL handlers */
 static int ioctl_dump	(sdla_t* card, sdla_dump_t* u_dump);
@@ -279,7 +279,7 @@
 	/* Register adapters with WAN router */
 	for (cnt = 0; cnt < ncards; ++ cnt) {
 		sdla_t* card = &card_array[cnt];
-		wan_device_t* wandev = &card->wandev;
+		struct wan_device* wandev = &card->wandev;
 
 		card->next = NULL;
 		sprintf(card->devname, "%s%d", drvname, cnt + 1);
@@ -352,7 +352,7 @@
  * any).
  */
  
-static int setup (wan_device_t* wandev, wandev_conf_t* conf)
+static int setup(struct wan_device* wandev, wandev_conf_t* conf)
 {
 	sdla_t* card;
 	int err = 0;
@@ -779,7 +779,7 @@
  * This function is called by the router when device is being unregistered or
  * when it handles ROUTER_DOWN IOCTL.
  */
-static int shutdown (wan_device_t* wandev)
+static int shutdown(struct wan_device* wandev)
 {
 	sdla_t *card;
 	int err=0;
@@ -888,7 +888,7 @@
  * This function is called when router handles one of the reserved user
  * IOCTLs.  Note that 'arg' stil points to user address space.
  */
-static int ioctl (wan_device_t* wandev, unsigned cmd, unsigned long arg)
+static int ioctl(struct wan_device* wandev, unsigned cmd, unsigned long arg)
 {
 	sdla_t* card;
 	int err;
diff -Nru a/drivers/net/wan/wanpipe_multppp.c b/drivers/net/wan/wanpipe_multppp.c
--- a/drivers/net/wan/wanpipe_multppp.c	Thu May 15 17:24:14 2003
+++ b/drivers/net/wan/wanpipe_multppp.c	Thu May 15 17:24:14 2003
@@ -130,10 +130,10 @@
 
 /****** Function Prototypes *************************************************/
 /* WAN link driver entry points. These are called by the WAN router module. */
-static int update (wan_device_t* wandev);
-static int new_if (wan_device_t* wandev, netdevice_t* dev,
+static int update(struct wan_device* wandev);
+static int new_if(struct wan_device* wandev, netdevice_t* dev,
 	wanif_conf_t* conf);
-static int del_if (wan_device_t* wandev, netdevice_t* dev);
+static int del_if(struct wan_device* wandev, netdevice_t* dev);
 
 /* Network device interface */
 static int if_init   (netdevice_t* dev);
@@ -456,7 +456,7 @@
  * as to minimize the time that we are inside the interrupt handler.
  *
  */
-static int update (wan_device_t* wandev)
+static int update(struct wan_device* wandev)
 {
 	sdla_t* card = wandev->private;
  	netdevice_t* dev;
@@ -522,7 +522,8 @@
  * Return:	0	o.k.
  *		< 0	failure (channel will not be created)
  */
-static int new_if (wan_device_t* wandev, netdevice_t* pdev, wanif_conf_t* conf)
+static int new_if(struct wan_device* wandev, netdevice_t* pdev,
+		  wanif_conf_t* conf)
 {
 
 	struct ppp_device *pppdev = (struct ppp_device *)pdev;
@@ -616,7 +617,7 @@
 /*============================================================================
  * Delete logical channel.
  */
-static int del_if (wan_device_t* wandev, netdevice_t* dev)
+static int del_if(struct wan_device* wandev, netdevice_t* dev)
 {
 	chdlc_private_area_t *chdlc_priv_area = dev->priv;
 	sdla_t *card = chdlc_priv_area->card;
@@ -655,7 +656,7 @@
 	{
 	chdlc_private_area_t* chdlc_priv_area = dev->priv;
 	sdla_t* card = chdlc_priv_area->card;
-	wan_device_t* wandev = &card->wandev;
+	struct wan_device* wandev = &card->wandev;
 	
 	/* NOTE: Most of the dev initialization was
          *       done in sppp_attach(), called by new_if() 
diff -Nru a/include/linux/cyclomx.h b/include/linux/cyclomx.h
--- a/include/linux/cyclomx.h	Thu May 15 17:24:14 2003
+++ b/include/linux/cyclomx.h	Thu May 15 17:24:14 2003
@@ -46,7 +46,7 @@
 typedef struct cycx {
 	char devname[WAN_DRVNAME_SZ+1];	/* card name */
 	cycxhw_t hw;			/* hardware configuration */
-	wan_device_t wandev;		/* WAN device data space */
+	struct wan_device wandev;	/* WAN device data space */
 	u32 open_cnt;			/* number of open interfaces */
 	u32 state_tick;			/* link state timestamp */
 	spinlock_t lock;
diff -Nru a/include/linux/wanpipe.h b/include/linux/wanpipe.h
--- a/include/linux/wanpipe.h	Thu May 15 17:24:14 2003
+++ b/include/linux/wanpipe.h	Thu May 15 17:24:14 2003
@@ -286,7 +286,7 @@
 {
 	char devname[WAN_DRVNAME_SZ+1];	/* card name */
 	sdlahw_t hw;			/* hardware configuration */
-	wan_device_t wandev;		/* WAN device data space */
+	struct wan_device wandev;	/* WAN device data space */
 	
 	unsigned open_cnt;		/* number of open interfaces */
 	unsigned long state_tick;	/* link state timestamp */
diff -Nru a/include/linux/wanrouter.h b/include/linux/wanrouter.h
--- a/include/linux/wanrouter.h	Thu May 15 17:24:14 2003
+++ b/include/linux/wanrouter.h	Thu May 15 17:24:14 2003
@@ -462,8 +462,7 @@
 /*----------------------------------------------------------------------------
  * WAN device data space.
  */
-typedef struct wan_device
-{
+struct wan_device {
 	unsigned magic;			/* magic number */
 	char* name;			/* -> WAN device name (ASCIIZ) */
 	void* private;			/* -> driver private data */
@@ -514,10 +513,10 @@
 	netdevice_t* dev;		/* list of network interfaces */
 	unsigned ndev;			/* number of interfaces */
 	struct proc_dir_entry *dent;	/* proc filesystem entry */
-} wan_device_t;
+};
 
 /* Public functions available for device drivers */
-extern int register_wan_device(wan_device_t *wandev);
+extern int register_wan_device(struct wan_device *wandev);
 extern int unregister_wan_device(char *name);
 unsigned short wanrouter_type_trans(struct sk_buff *skb, netdevice_t *dev);
 int wanrouter_encapsulate(struct sk_buff *skb, netdevice_t *dev,unsigned short type);
@@ -525,8 +524,8 @@
 /* Proc interface functions. These must not be called by the drivers! */
 extern int wanrouter_proc_init(void);
 extern void wanrouter_proc_cleanup(void);
-extern int wanrouter_proc_add(wan_device_t *wandev);
-extern int wanrouter_proc_delete(wan_device_t *wandev);
+extern int wanrouter_proc_add(struct wan_device *wandev);
+extern int wanrouter_proc_delete(struct wan_device *wandev);
 extern int wanrouter_ioctl( struct inode *inode, struct file *file, unsigned int cmd, unsigned long arg);
 
 extern void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
@@ -535,7 +534,7 @@
 
 
 /* Public Data */
-extern wan_device_t *router_devlist;	/* list of registered devices */
+extern struct wan_device *router_devlist;	/* list of registered devices */
 
 #endif	/* __KERNEL__ */
 #endif	/* _ROUTER_H */
diff -Nru a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
--- a/net/wanrouter/wanmain.c	Thu May 15 17:24:14 2003
+++ b/net/wanrouter/wanmain.c	Thu May 15 17:24:14 2003
@@ -127,18 +127,18 @@
  *	WAN device IOCTL handlers
  */
 
-static int device_setup(wan_device_t *wandev, wandev_conf_t *u_conf);
-static int device_stat(wan_device_t *wandev, wandev_stat_t *u_stat);
-static int device_shutdown(wan_device_t *wandev);
-static int device_new_if(wan_device_t *wandev, wanif_conf_t *u_conf);
-static int device_del_if(wan_device_t *wandev, char *u_name);
+static int device_setup(struct wan_device *wandev, wandev_conf_t *u_conf);
+static int device_stat(struct wan_device *wandev, wandev_stat_t *u_stat);
+static int device_shutdown(struct wan_device *wandev);
+static int device_new_if(struct wan_device *wandev, wanif_conf_t *u_conf);
+static int device_del_if(struct wan_device *wandev, char *u_name);
 
 /*
  *	Miscellaneous
  */
 
-static wan_device_t *find_device (char *name);
-static int delete_interface (wan_device_t *wandev, char *name);
+static struct wan_device *find_device (char *name);
+static int delete_interface (struct wan_device *wandev, char *name);
 void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
 void unlock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
 
@@ -148,11 +148,11 @@
  *	Global Data
  */
 
-static char fullname[]		= "Sangoma WANPIPE Router";
-static char copyright[]		= "(c) 1995-2000 Sangoma Technologies Inc.";
-static char modname[]		= ROUTER_NAME;	/* short module name */
-wan_device_t* router_devlist 	= NULL;	/* list of registered devices */
-static int devcnt 		= 0;
+static char fullname[]	= "Sangoma WANPIPE Router";
+static char copyright[]	= "(c) 1995-2000 Sangoma Technologies Inc.";
+static char modname[]   = ROUTER_NAME;	/* short module name */
+struct wan_device* router_devlist;	/* list of registered devices */
+static int devcnt;
 
 /*
  *	Organize Unique Identifiers for encapsulation/decapsulation
@@ -262,7 +262,7 @@
  */
 
 
-int register_wan_device(wan_device_t *wandev)
+int register_wan_device(struct wan_device *wandev)
 {
 	int err, namelen;
 
@@ -322,7 +322,7 @@
 
 int unregister_wan_device(char *name)
 {
-	wan_device_t *wandev, *prev;
+	struct wan_device *wandev, *prev;
 
 	if (name == NULL)
 		return -EINVAL;
@@ -457,7 +457,7 @@
 {
 	int err = 0;
 	struct proc_dir_entry *dent;
-	wan_device_t *wandev;
+	struct wan_device *wandev;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -519,7 +519,7 @@
  *	o call driver's setup() entry point
  */
 
-static int device_setup (wan_device_t *wandev, wandev_conf_t *u_conf)
+static int device_setup(struct wan_device *wandev, wandev_conf_t *u_conf)
 {
 	void *data = NULL;
 	wandev_conf_t *conf;
@@ -595,7 +595,7 @@
  *	o call driver's shutdown() entry point
  */
 
-static int device_shutdown (wan_device_t *wandev)
+static int device_shutdown(struct wan_device *wandev)
 {
 	netdevice_t *dev;
 	int err=0;
@@ -628,7 +628,7 @@
  *	Get WAN device status & statistics.
  */
 
-static int device_stat (wan_device_t *wandev, wandev_stat_t *u_stat)
+static int device_stat(struct wan_device *wandev, wandev_stat_t *u_stat)
 {
 	wandev_stat_t stat;
 
@@ -658,7 +658,7 @@
  *	o register network interface
  */
 
-static int device_new_if (wan_device_t *wandev, wanif_conf_t *u_conf)
+static int device_new_if(struct wan_device *wandev, wanif_conf_t *u_conf)
 {
 	wanif_conf_t conf;
 	netdevice_t *dev=NULL;
@@ -774,7 +774,7 @@
  *	 o copy configuration data to kernel address space
  */
 
-static int device_del_if (wan_device_t *wandev, char *u_name)
+static int device_del_if(struct wan_device *wandev, char *u_name)
 {
 	char name[WAN_IFNAME_SZ + 1];
         int err = 0;
@@ -815,9 +815,9 @@
  *	Return pointer to the WAN device data space or NULL if device not found.
  */
 
-static wan_device_t *find_device(char *name)
+static struct wan_device *find_device(char *name)
 {
-	wan_device_t *wandev;
+	struct wan_device *wandev;
 
 	for (wandev = router_devlist;wandev && strcmp(wandev->name, name);
 		wandev = wandev->next);
@@ -841,7 +841,7 @@
  *	sure that opened interfaces are not removed!
  */
 
-static int delete_interface (wan_device_t *wandev, char *name)
+static int delete_interface(struct wan_device *wandev, char *name)
 {
 	netdevice_t *dev=NULL, *prev=NULL;
 	unsigned long smp_flags=0;
diff -Nru a/net/wanrouter/wanproc.c b/net/wanrouter/wanproc.c
--- a/net/wanrouter/wanproc.c	Thu May 15 17:24:14 2003
+++ b/net/wanrouter/wanproc.c	Thu May 15 17:24:14 2003
@@ -96,7 +96,7 @@
  */
 static void *r_start(struct seq_file *m, loff_t *pos)
 {
-	wan_device_t *wandev;
+	struct wan_device *wandev;
 	loff_t l = *pos;
 
 	lock_kernel();
@@ -108,7 +108,7 @@
 }
 static void *r_next(struct seq_file *m, void *v, loff_t *pos)
 {
-	wan_device_t *wandev = v;
+	struct wan_device *wandev = v;
 	(*pos)++;
 	return (v == (void *)1) ? router_devlist : wandev->next;
 }
@@ -119,7 +119,7 @@
 
 static int config_show(struct seq_file *m, void *v)
 {
-	wan_device_t *p = v;
+	struct wan_device *p = v;
 	if (v == (void *)1) {
 		seq_puts(m, "Device name    | port |IRQ|DMA|  mem.addr  |");
 		seq_puts(m, "mem.size|option1|option2|option3|option4\n");
@@ -135,7 +135,7 @@
 
 static int status_show(struct seq_file *m, void *v)
 {
-	wan_device_t *p = v;
+	struct wan_device *p = v;
 	if (v == (void *)1) {
 		seq_puts(m, "Device name    |protocol|station|interface|");
 		seq_puts(m, "clocking|baud rate| MTU |ndev|link state\n");
@@ -221,7 +221,7 @@
 
 static int wandev_show(struct seq_file *m, void *v)
 {
-	wan_device_t *wandev = v;
+	struct wan_device *wandev = v;
 
 	if (wandev->magic != ROUTER_MAGIC)
 		return 0;
@@ -339,7 +339,7 @@
  *	Add directory entry for WAN device.
  */
 
-int wanrouter_proc_add (wan_device_t* wandev)
+int wanrouter_proc_add(struct wan_device* wandev)
 {
 	if (wandev->magic != ROUTER_MAGIC)
 		return -EINVAL;
@@ -356,7 +356,7 @@
  *	Delete directory entry for WAN device.
  */
  
-int wanrouter_proc_delete(wan_device_t* wandev)
+int wanrouter_proc_delete(struct wan_device* wandev)
 {
 	if (wandev->magic != ROUTER_MAGIC)
 		return -EINVAL;
@@ -379,12 +379,12 @@
 {
 }
 
-int wanrouter_proc_add(wan_device_t *wandev)
+int wanrouter_proc_add(struct wan_device *wandev)
 {
 	return 0;
 }
 
-int wanrouter_proc_delete(wan_device_t *wandev)
+int wanrouter_proc_delete(struct wan_device *wandev)
 {
 	return 0;
 }

===================================================================


This BitKeeper patch contains the following changesets:
1.1144
## Wrapped with gzip_uu ##


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
K'A+K&$'/]W"^9[>$2IOAX_\6(KI/HH_KS?PV9A0<NY0Z_P5(,64J@T(     
 
