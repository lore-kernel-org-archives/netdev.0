From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] wanrouter: kill netdevice_t, do as all the rest of the tree, use struct net_device
Date: Thu, 15 May 2003 18:52:43 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030515215243.GC12303@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/net-2.5

	Now there are two outstanding changesets in this tree.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1145, 2003-05-15 18:42:15-03:00, acme@conectiva.com.br
  o wanrouter: kill netdevice_t, do as all the rest of the tree, use struct net_device


 drivers/net/wan/sdla_chdlc.c      |   96 +++++++++---------
 drivers/net/wan/sdla_fr.c         |  184 ++++++++++++++++++-----------------
 drivers/net/wan/sdla_ft1.c        |    2 
 drivers/net/wan/sdla_ppp.c        |   89 ++++++++---------
 drivers/net/wan/sdla_x25.c        |  195 ++++++++++++++++++++------------------
 drivers/net/wan/sdlamain.c        |   10 -
 drivers/net/wan/wanpipe_multppp.c |   70 ++++++-------
 include/linux/if_wanpipe.h        |    6 -
 include/linux/if_wanpipe_common.h |    9 -
 include/linux/wanpipe.h           |   26 ++---
 include/linux/wanrouter.h         |   16 +--
 net/wanrouter/af_wanpipe.c        |   75 +++++++-------
 net/wanrouter/wanmain.c           |   39 +++----
 13 files changed, 420 insertions(+), 397 deletions(-)


diff -Nru a/drivers/net/wan/sdla_chdlc.c b/drivers/net/wan/sdla_chdlc.c
--- a/drivers/net/wan/sdla_chdlc.c	Thu May 15 18:49:30 2003
+++ b/drivers/net/wan/sdla_chdlc.c	Thu May 15 18:49:30 2003
@@ -187,20 +187,21 @@
 /****** Function Prototypes *************************************************/
 /* WAN link driver entry points. These are called by the WAN router module. */
 static int update(struct wan_device* wandev);
-static int new_if(struct wan_device* wandev, netdevice_t* dev,
-	wanif_conf_t* conf);
+static int new_if(struct wan_device* wandev, struct net_device* dev,
+		  wanif_conf_t* conf);
 
 /* Network device interface */
-static int if_init   (netdevice_t* dev);
-static int if_open   (netdevice_t* dev);
-static int if_close  (netdevice_t* dev);
-static int if_header (struct sk_buff* skb, netdevice_t* dev,
-	unsigned short type, void* daddr, void* saddr, unsigned len);
+static int if_init(struct net_device* dev);
+static int if_open(struct net_device* dev);
+static int if_close(struct net_device* dev);
+static int if_header(struct sk_buff* skb, struct net_device* dev,
+		     unsigned short type, void* daddr, void* saddr,
+		     unsigned len);
 
 static int if_rebuild_hdr (struct sk_buff *skb);
-static struct net_device_stats* if_stats (netdevice_t* dev);
+static struct net_device_stats* if_stats(struct net_device* dev);
   
-static int if_send (struct sk_buff* skb, netdevice_t* dev);
+static int if_send(struct sk_buff* skb, struct net_device* dev);
 
 /* CHDLC Firmware interface functions */
 static int chdlc_configure 	(sdla_t* card, void* data);
@@ -214,7 +215,7 @@
 
 
 static int chdlc_disable_comm_shutdown (sdla_t *card);
-static void if_tx_timeout (netdevice_t *dev);
+static void if_tx_timeout(struct net_device *dev);
 
 /* Miscellaneous CHDLC Functions */
 static int set_chdlc_config (sdla_t* card);
@@ -230,8 +231,8 @@
 static int config_chdlc (sdla_t *card);
 static void disable_comm (sdla_t *card);
 
-static void trigger_chdlc_poll (netdevice_t *);
-static void chdlc_poll (netdevice_t *);
+static void trigger_chdlc_poll(struct net_device *dev);
+static void chdlc_poll(struct net_device *dev);
 static void chdlc_poll_delay (unsigned long dev_ptr);
 
 
@@ -245,20 +246,20 @@
 static void timer_intr(sdla_t *);
 
 /* Bottom half handlers */
-static void chdlc_work (netdevice_t *);
-static int chdlc_work_cleanup (netdevice_t *);
-static int bh_enqueue (netdevice_t *, struct sk_buff *);
+static void chdlc_work(struct net_device *dev);
+static int chdlc_work_cleanup(struct net_device *dev);
+static int bh_enqueue(struct net_device *dev, struct sk_buff *skb);
 
 /* Miscellaneous functions */
-static int chk_bcast_mcast_addr(sdla_t* card, netdevice_t* dev,
+static int chk_bcast_mcast_addr(sdla_t* card, struct net_device* dev,
 				struct sk_buff *skb);
 static int reply_udp( unsigned char *data, unsigned int mbox_len );
 static int intr_test( sdla_t* card);
 static int udp_pkt_type( struct sk_buff *skb , sdla_t* card);
 static int store_udp_mgmt_pkt(char udp_pkt_src, sdla_t* card,
-                                struct sk_buff *skb, netdevice_t* dev,
+                                struct sk_buff *skb, struct net_device* dev,
                                 chdlc_private_area_t* chdlc_priv_area);
-static int process_udp_mgmt_pkt(sdla_t* card, netdevice_t* dev,  
+static int process_udp_mgmt_pkt(sdla_t* card, struct net_device* dev,  
 				chdlc_private_area_t* chdlc_priv_area);
 static unsigned short calc_checksum (char *, int);
 static void s508_lock (sdla_t *card, unsigned long *smp_flags);
@@ -601,7 +602,7 @@
 static int update(struct wan_device* wandev)
 {
 	sdla_t* card = wandev->private;
- 	netdevice_t* dev;
+ 	struct net_device* dev;
         volatile chdlc_private_area_t* chdlc_priv_area;
         SHARED_MEMORY_INFO_STRUCT *flags;
 	unsigned long timeout;
@@ -666,7 +667,7 @@
  * Return:	0	o.k.
  *		< 0	failure (channel will not be created)
  */
-static int new_if(struct wan_device* wandev, netdevice_t* dev,
+static int new_if(struct wan_device* wandev, struct net_device* dev,
 		  wanif_conf_t* conf)
 {
 	sdla_t* card = wandev->private;
@@ -898,7 +899,7 @@
  * interface registration.  Returning anything but zero will fail interface
  * registration.
  */
-static int if_init (netdevice_t* dev)
+static int if_init(struct net_device* dev)
 {
 	chdlc_private_area_t* chdlc_priv_area = dev->priv;
 	sdla_t* card = chdlc_priv_area->card;
@@ -961,7 +962,7 @@
  *
  * Return 0 if O.k. or errno.
  */
-static int if_open (netdevice_t* dev)
+static int if_open(struct net_device* dev)
 {
 	chdlc_private_area_t* chdlc_priv_area = dev->priv;
 	sdla_t* card = chdlc_priv_area->card;
@@ -1014,7 +1015,7 @@
  * o if this is the last close, then disable communications and interrupts.
  * o reset flags.
  */
-static int if_close (netdevice_t* dev)
+static int if_close(struct net_device* dev)
 {
 	chdlc_private_area_t* chdlc_priv_area = dev->priv;
 	sdla_t* card = chdlc_priv_area->card;
@@ -1085,8 +1086,9 @@
  *
  * Return:	media header length.
  */
-static int if_header (struct sk_buff* skb, netdevice_t* dev,
-	unsigned short type, void* daddr, void* saddr, unsigned len)
+static int if_header(struct sk_buff* skb, struct net_device* dev,
+		     unsigned short type, void* daddr, void* saddr,
+		     unsigned len)
 {
 	skb->protocol = htons(type);
 
@@ -1097,7 +1099,7 @@
 /*============================================================================
  * Handle transmit timeout event from netif watchdog
  */
-static void if_tx_timeout (netdevice_t *dev)
+static void if_tx_timeout(struct net_device *dev)
 {
     	chdlc_private_area_t* chan = dev->priv;
 	sdla_t *card = chan->card;
@@ -1145,7 +1147,7 @@
  * 2. Setting tbusy flag will inhibit further transmit requests from the
  *    protocol stack and can be used for flow control with protocol layer.
  */
-static int if_send (struct sk_buff* skb, netdevice_t* dev)
+static int if_send(struct sk_buff* skb, struct net_device* dev)
 {
 	chdlc_private_area_t *chdlc_priv_area = dev->priv;
 	sdla_t *card = chdlc_priv_area->card;
@@ -1279,7 +1281,7 @@
  * multicast source IP address.
  */
 
-static int chk_bcast_mcast_addr(sdla_t *card, netdevice_t* dev,
+static int chk_bcast_mcast_addr(sdla_t *card, struct net_device* dev,
 				struct sk_buff *skb)
 {
 	u32 src_ip_addr;
@@ -1422,7 +1424,7 @@
  * Get ethernet-style interface statistics.
  * Return a pointer to struct enet_statistics.
  */
-static struct net_device_stats* if_stats (netdevice_t* dev)
+static struct net_device_stats* if_stats(struct net_device* dev)
 {
 	sdla_t *my_card;
 	chdlc_private_area_t* chdlc_priv_area;
@@ -1711,7 +1713,7 @@
  *       PREPROCESSOR STATEMENT ABOVE, UNLESS YOU KNOW WHAT YOU ARE
  *       DOING */
 
-static void chdlc_work (netdevice_t * dev)
+static void chdlc_work(struct net_device * dev)
 {
 	chdlc_private_area_t* chan = dev->priv;
 	sdla_t *card = chan->card;
@@ -1752,7 +1754,7 @@
 	return;
 }
 
-static int chdlc_work_cleanup (netdevice_t *dev)
+static int chdlc_work_cleanup(struct net_device *dev)
 {
 	chdlc_private_area_t* chan = dev->priv;
 
@@ -1770,7 +1772,7 @@
 
 
 
-static int bh_enqueue (netdevice_t *dev, struct sk_buff *skb)
+static int bh_enqueue(struct net_device *dev, struct sk_buff *skb)
 {
 	/* Check for full */
 	chdlc_private_area_t* chan = dev->priv;
@@ -1805,7 +1807,7 @@
  */
 static void wpc_isr (sdla_t* card)
 {
-	netdevice_t* dev;
+	struct net_device* dev;
 	SHARED_MEMORY_INFO_STRUCT* flags = NULL;
 	int i;
 	sdla_t *my_card;
@@ -1932,7 +1934,7 @@
  */
 static void rx_intr (sdla_t* card)
 {
-	netdevice_t *dev;
+	struct net_device *dev;
 	chdlc_private_area_t *chdlc_priv_area;
 	SHARED_MEMORY_INFO_STRUCT *flags = card->u.c.flags;
 	CHDLC_DATA_RX_STATUS_EL_STRUCT *rxbuf = card->u.c.rxmb;
@@ -2084,7 +2086,7 @@
  */
 void timer_intr(sdla_t *card)
 {
-        netdevice_t* dev;
+        struct net_device* dev;
         chdlc_private_area_t* chdlc_priv_area = NULL;
         SHARED_MEMORY_INFO_STRUCT* flags = NULL;
 
@@ -2173,7 +2175,7 @@
 		cfg.IP_netmask		= 0;
 		
 	}else if (card->wandev.dev){
-		netdevice_t * dev = card->wandev.dev;
+		struct net_device *dev = card->wandev.dev;
 		chdlc_private_area_t *chdlc_priv_area = dev->priv;
 		
                 struct in_device *in_dev = dev->ip_ptr;
@@ -2403,7 +2405,7 @@
 
 static int configure_ip (sdla_t* card)
 {
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
         chdlc_private_area_t *chdlc_priv_area;
         char err;
 
@@ -2450,7 +2452,7 @@
 
 static int unconfigure_ip (sdla_t* card)
 {
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
 	chdlc_private_area_t *chdlc_priv_area;
 
 	if (!dev)
@@ -2478,7 +2480,7 @@
 
 static void process_route (sdla_t *card)
 {
-        netdevice_t *dev = card->wandev.dev;
+        struct net_device *dev = card->wandev.dev;
         unsigned char port_num;
         chdlc_private_area_t *chdlc_priv_area = NULL;
 	u32 local_IP_addr = 0;
@@ -2659,8 +2661,8 @@
  */
 
 static int store_udp_mgmt_pkt(char udp_pkt_src, sdla_t* card,
-                                struct sk_buff *skb, netdevice_t* dev,
-                                chdlc_private_area_t* chdlc_priv_area )
+			      struct sk_buff *skb, struct net_device* dev,
+			      chdlc_private_area_t* chdlc_priv_area)
 {
 	int udp_pkt_stored = 0;
 
@@ -2687,7 +2689,7 @@
  * Process UDP management packet.
  */
 
-static int process_udp_mgmt_pkt(sdla_t* card, netdevice_t* dev,
+static int process_udp_mgmt_pkt(sdla_t* card, struct net_device* dev,
 				chdlc_private_area_t* chdlc_priv_area ) 
 {
 	unsigned char *buf;
@@ -3264,7 +3266,7 @@
 
                 card->wandev.state = card->u.c.state = state;
 		if (card->wandev.dev){
-			netdevice_t *dev = card->wandev.dev;
+			struct net_device *dev = card->wandev.dev;
 			chdlc_private_area_t *chdlc_priv_area = dev->priv;
 			chdlc_priv_area->common.state = state;
 		}
@@ -3294,7 +3296,7 @@
 
 static int config_chdlc (sdla_t *card)
 {
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
 	chdlc_private_area_t *chdlc_priv_area = dev->priv;
 	SHARED_MEMORY_INFO_STRUCT *flags = card->u.c.flags;
 
@@ -3418,7 +3420,7 @@
  *      the chldc_poll routine.  
  */
 
-static void chdlc_poll (netdevice_t *dev)
+static void chdlc_poll(struct net_device *dev)
 {
 	chdlc_private_area_t *chdlc_priv_area;
 	sdla_t *card;
@@ -3568,7 +3570,7 @@
  *      a polling routine.
  *
  */	
-static void trigger_chdlc_poll (netdevice_t *dev)
+static void trigger_chdlc_poll(struct net_device *dev)
 {
 	chdlc_private_area_t *chdlc_priv_area;
 	sdla_t *card;
@@ -3593,7 +3595,7 @@
 
 static void chdlc_poll_delay (unsigned long dev_ptr)
 {
-	netdevice_t *dev = (netdevice_t *)dev_ptr;
+	struct net_device *dev = (struct net_device *)dev_ptr;
 	trigger_chdlc_poll(dev);
 }
 
diff -Nru a/drivers/net/wan/sdla_fr.c b/drivers/net/wan/sdla_fr.c
--- a/drivers/net/wan/sdla_fr.c	Thu May 15 18:49:30 2003
+++ b/drivers/net/wan/sdla_fr.c	Thu May 15 18:49:30 2003
@@ -324,27 +324,27 @@
 
 /* WAN link driver entry points. These are called by the WAN router module. */
 static int update(struct wan_device *wandev);
-static int new_if(struct wan_device *wandev, netdevice_t *dev,
+static int new_if(struct wan_device *wandev, struct net_device *dev,
 		  wanif_conf_t *conf);
-static int del_if(struct wan_device *wandev, netdevice_t *dev);
+static int del_if(struct wan_device *wandev, struct net_device *dev);
 static void disable_comm (sdla_t *card);
 
 /* WANPIPE-specific entry points */
 static int wpf_exec(struct sdla *card, void *u_cmd, void *u_data);
 
 /* Network device interface */
-static int if_init(netdevice_t *dev);
-static int if_open(netdevice_t *dev);
-static int if_close(netdevice_t *dev);
+static int if_init(struct net_device *dev);
+static int if_open(struct net_device *dev);
+static int if_close(struct net_device *dev);
 
-static void if_tx_timeout (netdevice_t *dev);
+static void if_tx_timeout(struct net_device *dev);
 
 static int if_rebuild_hdr (struct sk_buff *skb);
 
-static int if_send(struct sk_buff *skb, netdevice_t *dev);
-static int chk_bcast_mcast_addr(sdla_t *card, netdevice_t* dev,
+static int if_send(struct sk_buff *skb, struct net_device *dev);
+static int chk_bcast_mcast_addr(sdla_t *card, struct net_device* dev,
                                 struct sk_buff *skb);
-static struct net_device_stats *if_stats(netdevice_t *dev);
+static struct net_device_stats *if_stats(struct net_device *dev);
 
 /* Interrupt handlers */
 static void fr_isr(sdla_t *card);
@@ -383,9 +383,9 @@
 static int fr_dlci_change(sdla_t *card, fr_mbox_t *mbox);
 
 /* Miscellaneous functions */
-static int update_chan_state(netdevice_t *dev);
-static void set_chan_state(netdevice_t *dev, int state);
-static netdevice_t *find_channel(sdla_t *card, unsigned dlci);
+static int update_chan_state(struct net_device *dev);
+static void set_chan_state(struct net_device *dev, int state);
+static struct net_device *find_channel(sdla_t *card, unsigned dlci);
 static int is_tx_ready(sdla_t *card, fr_channel_t *chan);
 static unsigned int dec_to_uint(unsigned char *str, int len);
 static int reply_udp( unsigned char *data, unsigned int mbox_len );
@@ -394,22 +394,23 @@
 static void init_chan_statistics( fr_channel_t* chan );
 static void init_global_statistics( sdla_t* card );
 static void read_DLCI_IB_mapping( sdla_t* card, fr_channel_t* chan );
-static int setup_for_delayed_transmit(netdevice_t* dev, struct sk_buff *skb);
+static int setup_for_delayed_transmit(struct net_device* dev,
+				      struct sk_buff *skb);
 
-netdevice_t * move_dev_to_next (sdla_t *, netdevice_t *);
-static int check_tx_status(sdla_t *, netdevice_t *);
+struct net_device *move_dev_to_next(sdla_t *card, struct net_device *dev);
+static int check_tx_status(sdla_t *card, struct net_device *dev);
 
 /* Frame Relay Socket API */
 static void trigger_fr_bh (fr_channel_t *);
-static void fr_bh (netdevice_t *);
-static int fr_bh_cleanup (netdevice_t *);
-static int bh_enqueue (netdevice_t *, struct sk_buff *);
-
-static void trigger_fr_poll (netdevice_t *);
-static void fr_poll (netdevice_t *);
-//static void add_gateway (netdevice_t *);
+static void fr_bh(struct net_device *dev);
+static int fr_bh_cleanup(struct net_device *dev);
+static int bh_enqueue(struct net_device *dev, struct sk_buff *skb);
+
+static void trigger_fr_poll(struct net_device *dev);
+static void fr_poll(struct net_device *dev);
+//static void add_gateway(struct net_device *dev);
 
-static void trigger_unconfig_fr (netdevice_t *dev);
+static void trigger_unconfig_fr(struct net_device *dev);
 static void unconfig_fr (sdla_t *);
 
 static void trigger_config_fr (sdla_t *);
@@ -417,11 +418,11 @@
 
 
 /* Inverse ARP and Dynamic routing functions */
-int process_ARP(arphdr_1490_t *ArpPacket, sdla_t *card, netdevice_t *dev);
+int process_ARP(arphdr_1490_t *ArpPacket, sdla_t *card, struct net_device *dev);
 int is_arp(void *buf);
-int send_inarp_request(sdla_t *card, netdevice_t *dev);
+int send_inarp_request(sdla_t *card, struct net_device *dev);
 
-static void trigger_fr_arp (netdevice_t *);
+static void trigger_fr_arp(struct net_device *dev);
 static void fr_arp (unsigned long data);
 
 
@@ -443,7 +444,8 @@
 void 	s508_s514_lock(sdla_t *card, unsigned long *smp_flags);
 
 unsigned short calc_checksum (char *, int);
-static int setup_fr_header(struct sk_buff** skb, netdevice_t* dev, char op_mode);
+static int setup_fr_header(struct sk_buff** skb,
+			   struct net_device* dev, char op_mode);
 
 
 /****** Public Functions ****************************************************/
@@ -792,7 +794,7 @@
  * Return:	0	o.k.
  *		< 0	failure (channel will not be created)
  */
-static int new_if(struct wan_device* wandev, netdevice_t* dev,
+static int new_if(struct wan_device* wandev, struct net_device* dev,
 		  wanif_conf_t* conf)
 {
 	sdla_t* card = wandev->private;
@@ -1022,7 +1024,7 @@
 /*============================================================================
  * Delete logical channel.
  */
-static int del_if(struct wan_device* wandev, netdevice_t* dev)
+static int del_if(struct wan_device* wandev, struct net_device* dev)
 {
 	fr_channel_t* chan = dev->priv;
 	unsigned long smp_flags=0;
@@ -1118,7 +1120,7 @@
  * interface registration.  Returning anything but zero will fail interface
  * registration.
  */
-static int if_init (netdevice_t* dev)
+static int if_init(struct net_device* dev)
 {
 	fr_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -1196,7 +1198,7 @@
  *
  * Return 0 if O.k. or errno.
  */
-static int if_open (netdevice_t* dev)
+static int if_open(struct net_device* dev)
 {
 	fr_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -1238,7 +1240,7 @@
  * o if this is the last open, then disable communications and interrupts.
  * o reset flags.
  */
-static int if_close (netdevice_t* dev)
+static int if_close(struct net_device* dev)
 {
 	fr_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -1261,8 +1263,7 @@
  */
 static int if_rebuild_hdr (struct sk_buff* skb)
 {
-
-	netdevice_t *dev = skb->dev;
+	struct net_device *dev = skb->dev;
 	fr_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
 
@@ -1274,7 +1275,7 @@
 /*============================================================================
  * Handle transmit timeout event from netif watchdog
  */
-static void if_tx_timeout (netdevice_t *dev)
+static void if_tx_timeout(struct net_device *dev)
 {
     	fr_channel_t* chan = dev->priv;
 	sdla_t *card = chan->card;
@@ -1317,7 +1318,7 @@
  *    will inhibit further transmit requests from the protocol stack 
  *    and can be used for flow control with protocol layer.
  */
-static int if_send (struct sk_buff* skb, netdevice_t* dev)
+static int if_send(struct sk_buff* skb, struct net_device* dev)
 {
     	fr_channel_t* chan = dev->priv;
     	sdla_t* card = chan->card;
@@ -1564,7 +1565,8 @@
  * Setup so that a frame can be transmitted on the occurrence of a transmit
  * interrupt.
  */
-static int setup_for_delayed_transmit (netdevice_t* dev, struct sk_buff *skb)
+static int setup_for_delayed_transmit(struct net_device* dev,
+				      struct sk_buff *skb)
 {
         fr_channel_t* chan = dev->priv;
         sdla_t* card = chan->card;
@@ -1616,7 +1618,7 @@
  * Return 0 if not broadcast/multicast address, otherwise return 1.
  */
 
-static int chk_bcast_mcast_addr(sdla_t *card, netdevice_t* dev,
+static int chk_bcast_mcast_addr(sdla_t *card, struct net_device* dev,
                                 struct sk_buff *skb)
 {
         u32 src_ip_addr;
@@ -1828,7 +1830,7 @@
  * Get ethernet-style interface statistics.
  * Return a pointer to struct enet_statistics.
  */
-static struct net_device_stats *if_stats(netdevice_t *dev)
+static struct net_device_stats *if_stats(struct net_device *dev)
 {
 	fr_channel_t* chan = dev->priv;
 	
@@ -1954,7 +1956,7 @@
 	fr_channel_t* chan;
 	char *ptr = &flags->iflag;
 	struct sk_buff* skb;
-	netdevice_t* dev;
+	struct net_device* dev;
 	void* buf;
 	unsigned dlci, len, offs, len_incl_hdr;
 	int i, udp_type;	
@@ -2225,7 +2227,7 @@
 {
         fr508_flags_t* flags = card->flags;
         fr_tx_buf_ctl_t* bctl;
-        netdevice_t* dev;
+        struct net_device* dev;
         fr_channel_t* chan;
 
         if(card->hw.type == SDLA_S514){
@@ -2354,9 +2356,10 @@
 	/* Update the channel state call.  This is call is
          * triggered by if_send() function */
 	if (card->u.f.timer_int_enabled & TMR_INT_ENABLED_UPDATE_STATE){
-		netdevice_t *dev;
+		struct net_device *dev;
 		if (card->wandev.state == WAN_CONNECTED){
-			for (dev=card->wandev.dev; dev; dev = *((netdevice_t **)dev->priv)){
+			for (dev = card->wandev.dev; dev;
+			     dev = *((struct net_device **)dev->priv)){
 				fr_channel_t *chan = dev->priv;	
 				if (chan->common.state != WAN_CONNECTED){
 					update_chan_state(dev);
@@ -2382,7 +2385,7 @@
 	/* Transmit ARP packets */
 	if (card->u.f.timer_int_enabled & TMR_INT_ENABLED_ARP){
 		int i=0;
-		netdevice_t *dev;
+		struct net_device *dev;
 
 		if (card->u.f.arp_dev == NULL)
 			card->u.f.arp_dev = card->wandev.dev;
@@ -2586,7 +2589,7 @@
  *	This function is called by fr_poll() polling funtion.
  */
 
-static void process_route (netdevice_t *dev)
+static void process_route(struct net_device *dev)
 {
 	fr_channel_t *chan = dev->priv;
 	sdla_t *card = chan->card;
@@ -2987,7 +2990,7 @@
 
 static unsigned int fr_send_hdr (sdla_t*card, int dlci, unsigned int offset)
 {
-	netdevice_t *dev = find_channel(card,dlci);	
+	struct net_device *dev = find_channel(card,dlci);	
 	fr_channel_t *chan;
 
 	if (!dev || !(chan=dev->priv))
@@ -3090,12 +3093,12 @@
 		case FRRES_MODEM_FAILURE:
 			return fr_modem_failure(card, mbox);
 
-		case FRRES_CHANNEL_DOWN:
-			{
-			netdevice_t *dev;
+		case FRRES_CHANNEL_DOWN: {
+			struct net_device *dev;
 
 			/* Remove all routes from associated DLCI's */
-			for (dev = card->wandev.dev; dev; dev = *((netdevice_t **)dev->priv)) {
+			for (dev = card->wandev.dev; dev;
+			     dev = *((struct net_device **)dev->priv)) {
 				fr_channel_t *chan = dev->priv;
 				if (chan->route_flag == ROUTE_ADDED) {
 					chan->route_flag = REMOVE_ROUTE;
@@ -3116,13 +3119,13 @@
 			return 1;
 			}
 
-		case FRRES_CHANNEL_UP:
-			{
-			netdevice_t *dev;
+		case FRRES_CHANNEL_UP: {
+			struct net_device *dev;
 
 			/* FIXME: Only startup devices that are on the list */
 			
-			for (dev = card->wandev.dev; dev; dev = *((netdevice_t **)dev->priv)) {
+			for (dev = card->wandev.dev; dev;
+			     dev = *((struct net_device **)dev->priv)) {
 				
 				set_chan_state(dev,WAN_CONNECTED);
 			}
@@ -3196,13 +3199,13 @@
 	dlci_status_t* status = (void*)mbox->data;
 	int cnt = mbox->cmd.length / sizeof(dlci_status_t);
 	fr_channel_t *chan;
-	netdevice_t* dev2;
+	struct net_device* dev2;
 	
 
 	for (; cnt; --cnt, ++status) {
 
 		unsigned short dlci= status->dlci;
-		netdevice_t* dev = find_channel(card, dlci);
+		struct net_device* dev = find_channel(card, dlci);
 		
 		if (dev == NULL){
 			printk(KERN_INFO 
@@ -3261,7 +3264,8 @@
 		}
 	}
 	
-	for (dev2 =card->wandev.dev; dev2; dev2 = *((netdevice_t **)dev2->priv)){
+	for (dev2 = card->wandev.dev; dev2;
+	     dev2 = *((struct net_device **)dev2->priv)){
 		
 		chan = dev2->priv;
 	
@@ -3317,7 +3321,7 @@
 /*============================================================================
  * Update channel state. 
  */
-static int update_chan_state (netdevice_t* dev)
+static int update_chan_state(struct net_device* dev)
 {
 	fr_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -3363,7 +3367,7 @@
 /*============================================================================
  * Set channel state.
  */
-static void set_chan_state (netdevice_t* dev, int state)
+static void set_chan_state(struct net_device* dev, int state)
 {
 	fr_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -3416,7 +3420,7 @@
  * NOTE: del_if() functions updates this array, it uses
  *       the spin locks to avoid corruption.
  */
-static netdevice_t* find_channel (sdla_t* card, unsigned dlci)
+static struct net_device* find_channel(sdla_t* card, unsigned dlci)
 {
 	if(dlci > HIGHEST_VALID_DLCI)
 		return NULL;
@@ -3473,7 +3477,7 @@
 {
         int udp_pkt_stored = 0;
 	
-	netdevice_t *dev=find_channel(card,dlci);
+	struct net_device *dev = find_channel(card, dlci);
 	fr_channel_t *chan;
 	
 	if (!dev || !(chan=dev->priv))
@@ -3519,7 +3523,7 @@
 	int err;
 	struct timeval tv;
 	int udp_mgmt_req_valid = 1;
-        netdevice_t* dev;
+        struct net_device* dev;
         fr_channel_t* chan;
         fr_udp_pkt_t *fr_udp_pkt;
 	unsigned short num_trc_els;
@@ -3920,7 +3924,7 @@
  * Send Inverse ARP Request
  */
 
-int send_inarp_request(sdla_t *card, netdevice_t *dev)
+int send_inarp_request(sdla_t *card, struct net_device *dev)
 {
 	int err=0;
 
@@ -3997,7 +4001,7 @@
  * Process ARP Packet Type
  */
 
-int process_ARP(arphdr_1490_t *ArpPacket, sdla_t *card, netdevice_t* dev)
+int process_ARP(arphdr_1490_t *ArpPacket, sdla_t *card, struct net_device* dev)
 {
 
 
@@ -4154,7 +4158,7 @@
  *      at a later date.
  */	
 
-static void trigger_fr_arp (netdevice_t *dev)
+static void trigger_fr_arp(struct net_device *dev)
 {
 	fr_channel_t* chan = dev->priv;
 
@@ -4175,7 +4179,7 @@
 
 static void fr_arp (unsigned long data)
 {
-	netdevice_t *dev = (netdevice_t *)data;
+	struct net_device *dev = (struct net_device *)data;
 	fr_channel_t *chan = dev->priv;
 	volatile sdla_t *card = chan->card;
 	fr508_flags_t* flags = card->flags;
@@ -4367,7 +4371,7 @@
  *
  */
 
-static int bh_enqueue (netdevice_t *dev, struct sk_buff *skb)
+static int bh_enqueue(struct net_device *dev, struct sk_buff *skb)
 {
 	/* Check for full */
 	fr_channel_t* chan = dev->priv;
@@ -4440,7 +4444,7 @@
  *
  */	
 
-static void fr_bh (netdevice_t * dev)
+static void fr_bh(struct net_device * dev)
 {
 	fr_channel_t* chan = dev->priv;
 	sdla_t *card = chan->card;
@@ -4487,7 +4491,7 @@
 	return;
 }
 
-static int fr_bh_cleanup (netdevice_t *dev)
+static int fr_bh_cleanup(struct net_device *dev)
 {
 	fr_channel_t* chan = dev->priv;
 
@@ -4521,7 +4525,7 @@
  *      a polling routine.
  *
  */	
-static void trigger_fr_poll (netdevice_t *dev)
+static void trigger_fr_poll(struct net_device *dev)
 {
 	fr_channel_t* chan = dev->priv;
 	schedule_task(&chan->fr_poll_task);
@@ -4551,7 +4555,7 @@
  *      the fr_poll routine.  
  */
 
-static void fr_poll (netdevice_t *dev)
+static void fr_poll(struct net_device *dev)
 {
 
 	fr_channel_t* chan;
@@ -4638,7 +4642,7 @@
  *      an interrupt.
  */
 
-static int check_tx_status(sdla_t *card, netdevice_t *dev)
+static int check_tx_status(sdla_t *card, struct net_device *dev)
 {
 
 	if (card->hw.type == SDLA_S514){
@@ -4668,14 +4672,13 @@
  *
  */
 
-netdevice_t * move_dev_to_next (sdla_t *card, netdevice_t *dev)
+struct net_device *move_dev_to_next(sdla_t *card, struct net_device *dev)
 {
 	if (card->wandev.new_if_cnt != 1){
-		if (*((netdevice_t **)dev->priv) == NULL){
+		if (!*((struct net_device **)dev->priv))
 			return card->wandev.dev;
-		}else{
-			return *((netdevice_t **)dev->priv);
-		}
+		else
+			return *((struct net_device **)dev->priv);
 	}
 	return dev;
 }
@@ -4725,10 +4728,11 @@
 
 static void config_fr (sdla_t *card)
 {
-	netdevice_t *dev;
+	struct net_device *dev;
 	fr_channel_t *chan;
 
-	for (dev=card->wandev.dev; dev; dev=*((netdevice_t **)dev->priv)){
+	for (dev = card->wandev.dev; dev;
+	     dev = *((struct net_device **)dev->priv)) {
 	
 		if ((chan=dev->priv) == NULL)
 			continue;
@@ -4797,7 +4801,7 @@
  *
  */
 
-static void trigger_unconfig_fr (netdevice_t *dev)
+static void trigger_unconfig_fr(struct net_device *dev)
 {
 	fr_channel_t *chan = dev->priv;
 	volatile sdla_t *card = chan->card;
@@ -4849,10 +4853,11 @@
 
 static void unconfig_fr (sdla_t *card)
 {
-	netdevice_t *dev;
+	struct net_device *dev;
 	fr_channel_t *chan;
 
-	for (dev=card->wandev.dev; dev; dev=*((netdevice_t **)dev->priv)){
+	for (dev = card->wandev.dev; dev;
+	     dev = *((struct net_device **)dev->priv)){
 	
 		if ((chan=dev->priv) == NULL)
 			continue;
@@ -4871,7 +4876,8 @@
 	}
 }
 
-static int setup_fr_header(struct sk_buff ** skb_orig, netdevice_t* dev, char op_mode)
+static int setup_fr_header(struct sk_buff **skb_orig, struct net_device* dev,
+			   char op_mode)
 {
 	struct sk_buff *skb = *skb_orig;
 	fr_channel_t *chan=dev->priv;
@@ -4929,7 +4935,7 @@
 	fr_conf_t *conf=NULL;
 	unsigned short dlci_num = chan->dlci;
 	int dlci_offset=0;
-	netdevice_t *dev=NULL;
+	struct net_device *dev = NULL;
 	
 	mbox->cmd.command = FR_READ_CONFIG;
 	mbox->cmd.length = 0;
@@ -4941,9 +4947,9 @@
 		return 0;
 	}
 
-	for (dev=card->wandev.dev; dev; dev=*((netdevice_t**)dev->priv)){
+	for (dev = card->wandev.dev; dev;
+	     dev=*((struct net_device **)dev->priv))
 		set_chan_state(dev,WAN_DISCONNECTED);
-	}
 	
 	printk(KERN_INFO "DLCI %i Not configured, configuring\n",dlci_num);
 	
@@ -4971,7 +4977,8 @@
 	conf = (fr_conf_t *)mbox->data;
 
 	dlci_offset=0;
-	for (dev=card->wandev.dev; dev; dev=*((netdevice_t**)dev->priv)){
+	for (dev = card->wandev.dev; dev;
+	     dev = *((struct net_device **)dev->priv)) {
 		fr_channel_t *chan_tmp = dev->priv;
 		conf->dlci[dlci_offset] = chan_tmp->dlci;		
 		dlci_offset++;
@@ -5005,7 +5012,8 @@
 
 	printk(KERN_INFO "Enabling Communications \n");
 
-	for (dev=card->wandev.dev; dev; dev=*((netdevice_t**)dev->priv)){
+	for (dev = card->wandev.dev; dev;
+	     dev = *((struct net_device **)dev->priv)) {
 		fr_channel_t *chan_tmp = dev->priv;
 		fr_init_dlci(card,chan_tmp);
 		fr_add_dlci(card, chan_tmp->dlci);
diff -Nru a/drivers/net/wan/sdla_ft1.c b/drivers/net/wan/sdla_ft1.c
--- a/drivers/net/wan/sdla_ft1.c	Thu May 15 18:49:30 2003
+++ b/drivers/net/wan/sdla_ft1.c	Thu May 15 18:49:30 2003
@@ -70,7 +70,7 @@
 
 typedef struct chdlc_private_area
 {
-	netdevice_t 	*slave;
+	struct net_device *slave;
 	sdla_t		*card;
 	int 		TracingEnabled;		/* For enabling Tracing */
 	unsigned long 	curr_trace_addr;	/* Used for Tracing */
diff -Nru a/drivers/net/wan/sdla_ppp.c b/drivers/net/wan/sdla_ppp.c
--- a/drivers/net/wan/sdla_ppp.c	Thu May 15 18:49:30 2003
+++ b/drivers/net/wan/sdla_ppp.c	Thu May 15 18:49:30 2003
@@ -168,7 +168,7 @@
   
 typedef struct ppp_private_area
 {
-	netdevice_t *slave;
+	struct net_device *slave;
 	sdla_t* card;	
 	unsigned long router_start_time;	/*router start time in sec */
 	unsigned long tick_counter;		/*used for 5 second counter*/
@@ -232,25 +232,26 @@
 
 /* WAN link driver entry points. These are called by the WAN router module. */
 static int update(struct wan_device *wandev);
-static int new_if(struct wan_device *wandev, netdevice_t *dev,
+static int new_if(struct wan_device *wandev, struct net_device *dev,
 		  wanif_conf_t *conf);
-static int del_if(struct wan_device *wandev, netdevice_t *dev);
+static int del_if(struct wan_device *wandev, struct net_device *dev);
 
 /* WANPIPE-specific entry points */
 static int wpp_exec (struct sdla *card, void *u_cmd, void *u_data);
 
 /* Network device interface */
-static int if_init(netdevice_t *dev);
-static int if_open(netdevice_t *dev);
-static int if_close(netdevice_t *dev);
-static int if_header(struct sk_buff *skb, netdevice_t *dev, unsigned short type, 
+static int if_init(struct net_device *dev);
+static int if_open(struct net_device *dev);
+static int if_close(struct net_device *dev);
+static int if_header(struct sk_buff *skb, struct net_device *dev,
+		     unsigned short type, 
 		     void *daddr, void *saddr, unsigned len);
 
-static void if_tx_timeout (netdevice_t *dev);
+static void if_tx_timeout(struct net_device *dev);
 
 static int if_rebuild_hdr(struct sk_buff *skb);
-static struct net_device_stats *if_stats(netdevice_t *dev);
-static int if_send(struct sk_buff *skb, netdevice_t *dev);
+static struct net_device_stats *if_stats(struct net_device *dev);
+static int if_send(struct sk_buff *skb, struct net_device *dev);
 
 
 /* PPP firmware interface functions */
@@ -279,10 +280,10 @@
 static int read_info( sdla_t *card );
 static int read_connection_info (sdla_t *card);
 static void remove_route( sdla_t *card );
-static int config508(netdevice_t *dev, sdla_t *card);
+static int config508(struct net_device *dev, sdla_t *card);
 static void show_disc_cause(sdla_t * card, unsigned cause);
 static int reply_udp( unsigned char *data, unsigned int mbox_len );
-static void process_udp_mgmt_pkt(sdla_t *card, netdevice_t *dev, 
+static void process_udp_mgmt_pkt(sdla_t *card, struct net_device *dev, 
 				ppp_private_area_t *ppp_priv_area);
 static void init_ppp_tx_rx_buff( sdla_t *card );
 static int intr_test( sdla_t *card );
@@ -291,12 +292,12 @@
 static void init_global_statistics( sdla_t *card );
 static int tokenize(char *str, char **tokens);
 static char* strstrip(char *str, char *s);
-static int chk_bcast_mcast_addr(sdla_t* card, netdevice_t* dev,
+static int chk_bcast_mcast_addr(sdla_t* card, struct net_device* dev,
 				struct sk_buff *skb);
 
 static int config_ppp (sdla_t *);
-static void ppp_poll(netdevice_t *);
-static void trigger_ppp_poll(netdevice_t *);
+static void ppp_poll(struct net_device *dev);
+static void trigger_ppp_poll(struct net_device *dev);
 static void ppp_poll_delay (unsigned long dev_ptr);
 
 
@@ -316,7 +317,7 @@
 static void s508_unlock (sdla_t *card, unsigned long *smp_flags);
 
 static int store_udp_mgmt_pkt(char udp_pkt_src, sdla_t* card,
-                                struct sk_buff *skb, netdevice_t* dev,
+                                struct sk_buff *skb, struct net_device* dev,
                                 ppp_private_area_t* ppp_priv_area );
 static unsigned short calc_checksum (char *data, int len);
 static void disable_comm (sdla_t *card);
@@ -448,7 +449,7 @@
 static int update(struct wan_device *wandev)
 {
 	sdla_t* card = wandev->private;
- 	netdevice_t* dev;
+ 	struct net_device* dev;
         volatile ppp_private_area_t *ppp_priv_area;
 	ppp_flags_t *flags = card->flags;
 	unsigned long timeout;
@@ -505,7 +506,7 @@
  * Return:	0	o.k.
  *		< 0	failure (channel will not be created)
  */
-static int new_if(struct wan_device *wandev, netdevice_t *dev,
+static int new_if(struct wan_device *wandev, struct net_device *dev,
 		  wanif_conf_t *conf)
 {
 	sdla_t *card = wandev->private;
@@ -624,7 +625,7 @@
 /*============================================================================
  * Delete logical channel.
  */
-static int del_if(struct wan_device *wandev, netdevice_t *dev)
+static int del_if(struct wan_device *wandev, struct net_device *dev)
 {
 	return 0;
 }
@@ -683,7 +684,7 @@
  * interface registration.  Returning anything but zero will fail interface
  * registration.
  */
-static int if_init(netdevice_t *dev)
+static int if_init(struct net_device *dev)
 {
 	ppp_private_area_t *ppp_priv_area = dev->priv;
 	sdla_t *card = ppp_priv_area->card;
@@ -732,7 +733,7 @@
  *
  * Return 0 if O.k. or errno.
  */
-static int if_open (netdevice_t *dev)
+static int if_open(struct net_device *dev)
 {
 	ppp_private_area_t *ppp_priv_area = dev->priv;
 	sdla_t *card = ppp_priv_area->card;
@@ -771,7 +772,7 @@
  * o if this is the last open, then disable communications and interrupts.
  * o reset flags.
  */
-static int if_close(netdevice_t *dev)
+static int if_close(struct net_device *dev)
 {
 	ppp_private_area_t *ppp_priv_area = dev->priv;
 	sdla_t *card = ppp_priv_area->card;
@@ -792,7 +793,7 @@
  *
  * Return:	media header length.
  */
-static int if_header(struct sk_buff *skb, netdevice_t *dev,
+static int if_header(struct sk_buff *skb, struct net_device *dev,
 	unsigned short type, void *daddr, void *saddr, unsigned len)
 {
 	switch (type)
@@ -817,7 +818,7 @@
  */
 static int if_rebuild_hdr (struct sk_buff *skb)
 {
-	netdevice_t *dev = skb->dev;
+	struct net_device *dev = skb->dev;
 	ppp_private_area_t *ppp_priv_area = dev->priv;
 	sdla_t *card = ppp_priv_area->card;
 
@@ -829,7 +830,7 @@
 /*============================================================================
  * Handle transmit timeout event from netif watchdog
  */
-static void if_tx_timeout (netdevice_t *dev)
+static void if_tx_timeout(struct net_device *dev)
 {
     	ppp_private_area_t* chan = dev->priv;
 	sdla_t *card = chan->card;
@@ -867,7 +868,7 @@
  * 2. Setting tbusy flag will inhibit further transmit requests from the
  *    protocol stack and can be used for flow control with protocol layer.
  */
-static int if_send (struct sk_buff *skb, netdevice_t *dev)
+static int if_send (struct sk_buff *skb, struct net_device *dev)
 {
 	ppp_private_area_t *ppp_priv_area = dev->priv;
 	sdla_t *card = ppp_priv_area->card;
@@ -997,7 +998,7 @@
  */
 
 static int store_udp_mgmt_pkt(char udp_pkt_src, sdla_t* card,
-                                struct sk_buff *skb, netdevice_t* dev,
+                                struct sk_buff *skb, struct net_device* dev,
                                 ppp_private_area_t* ppp_priv_area )
 {
 	int udp_pkt_stored = 0;
@@ -1191,7 +1192,7 @@
  * Get ethernet-style interface statistics.
  * Return a pointer to struct net_device_stats.
  */
-static struct net_device_stats *if_stats(netdevice_t *dev)
+static struct net_device_stats *if_stats(struct net_device *dev)
 {
 
 	ppp_private_area_t *ppp_priv_area = dev->priv;
@@ -1571,7 +1572,7 @@
 {
 	ppp_flags_t *flags = card->flags;
 	char *ptr = &flags->iflag;
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
 	int i;
 
 	card->in_isr = 1;
@@ -1651,7 +1652,7 @@
 static void rx_intr(sdla_t *card)
 {
 	ppp_buf_ctl_t *rxbuf = card->rxmb;
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
 	ppp_private_area_t *ppp_priv_area;
 	struct sk_buff *skb;
 	unsigned len;
@@ -1791,7 +1792,7 @@
 void event_intr (sdla_t *card)
 {
 
- 	netdevice_t* dev = card->wandev.dev;
+ 	struct net_device* dev = card->wandev.dev;
         ppp_private_area_t* ppp_priv_area = dev->priv;
 	volatile ppp_flags_t *flags = card->flags;
 
@@ -1910,7 +1911,7 @@
 void timer_intr (sdla_t *card)
 {
 
-        netdevice_t* dev = card->wandev.dev;
+        struct net_device* dev = card->wandev.dev;
         ppp_private_area_t* ppp_priv_area = dev->priv;
 	ppp_flags_t *flags = card->flags;
 
@@ -2107,7 +2108,7 @@
 static void process_route (sdla_t *card)
 {
 	ppp_flags_t *flags = card->flags;
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
 	ppp_private_area_t *ppp_priv_area = dev->priv;
 	
 	if ((card->u.p.ip_mode == WANOPT_PPP_PEER) &&
@@ -2149,7 +2150,7 @@
  */
 static void retrigger_comm(sdla_t *card)
 {
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
 
 	if (dev && ((jiffies - card->state_tick) > HOLD_DOWN_TIME)) {
 
@@ -2166,7 +2167,7 @@
 /*============================================================================
  * Configure S508 adapter.
  */
-static int config508(netdevice_t *dev, sdla_t *card)
+static int config508(struct net_device *dev, sdla_t *card)
 {
 	ppp508_conf_t cfg;
 	struct in_device *in_dev = dev->ip_ptr;
@@ -2338,7 +2339,7 @@
 /*=============================================================================
  * Process UDP call of type PTPIPEAB.
  */
-static void process_udp_mgmt_pkt(sdla_t *card, netdevice_t *dev, 
+static void process_udp_mgmt_pkt(sdla_t *card, struct net_device *dev, 
 				 ppp_private_area_t *ppp_priv_area ) 
 {
 	unsigned char buf2[5];
@@ -2849,7 +2850,7 @@
  */
 static int read_info( sdla_t *card )
 {
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
 	ppp_private_area_t *ppp_priv_area = dev->priv;
 	int err;
 
@@ -2898,7 +2899,7 @@
 static void remove_route( sdla_t *card )
 {
 
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
 	long ip_addr;
 	int err;
 
@@ -3024,7 +3025,7 @@
  * multicast source IP address.
  */
 
-static int chk_bcast_mcast_addr(sdla_t *card, netdevice_t* dev,
+static int chk_bcast_mcast_addr(sdla_t *card, struct net_device* dev,
 				struct sk_buff *skb)
 {
 	u32 src_ip_addr;
@@ -3075,7 +3076,7 @@
 static int read_connection_info (sdla_t *card)
 {
 	ppp_mbox_t *mb = card->mbox;
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
 	ppp_private_area_t *ppp_priv_area = dev->priv;
 	ppp508_connect_info_t *ppp508_connect_info;
 	int err;
@@ -3124,7 +3125,7 @@
 static int config_ppp (sdla_t *card)
 {
 
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
 	ppp_flags_t *flags = card->flags;
 	ppp_private_area_t *ppp_priv_area = dev->priv;
 
@@ -3232,7 +3233,7 @@
  *      trigger_ppp_poll() function is used to kick
  *      the ppp_poll routine.  
  */
-static void ppp_poll (netdevice_t *dev)
+static void ppp_poll(struct net_device *dev)
 {
 	ppp_private_area_t *ppp_priv_area; 	
 	sdla_t *card;
@@ -3377,7 +3378,7 @@
  *
  */	
 
-static void trigger_ppp_poll (netdevice_t *dev)
+static void trigger_ppp_poll(struct net_device *dev)
 {
 	ppp_private_area_t *ppp_priv_area;
 	if ((ppp_priv_area=dev->priv) != NULL){ 	
@@ -3399,7 +3400,7 @@
 
 static void ppp_poll_delay (unsigned long dev_ptr)
 {
-	netdevice_t *dev = (netdevice_t *)dev_ptr;
+	struct net_device *dev = (struct net_device *)dev_ptr;
 	trigger_ppp_poll(dev);
 }
 
diff -Nru a/drivers/net/wan/sdla_x25.c b/drivers/net/wan/sdla_x25.c
--- a/drivers/net/wan/sdla_x25.c	Thu May 15 18:49:30 2003
+++ b/drivers/net/wan/sdla_x25.c	Thu May 15 18:49:30 2003
@@ -241,7 +241,7 @@
  *	
  * Assumptions:
  *
- * Description:	This is an extention of the 'netdevice_t' 
+ * Description:	This is an extention of the struct net_device
  *              we create for each network interface to keep 
  *              the rest of X.25 channel-specific data. 
  *
@@ -271,7 +271,7 @@
 	atomic_t  bh_buff_used;
 
 	sdla_t* card;			/* -> owner */
-	netdevice_t *dev;		/* -> bound devce */
+	struct net_device *dev;		/* -> bound devce */
 
 	int ch_idx;
 	unsigned char enable_IPX;
@@ -331,9 +331,9 @@
  * called by the WAN router module.
  */
 static int update(struct wan_device* wandev);
-static int new_if(struct wan_device* wandev, netdevice_t* dev,
+static int new_if(struct wan_device* wandev, struct net_device* dev,
 		  wanif_conf_t* conf);
-static int del_if(struct wan_device* wandev, netdevice_t* dev);
+static int del_if(struct wan_device* wandev, struct net_device* dev);
 static void disable_comm (sdla_t* card);
 static void disable_comm_shutdown(sdla_t *card);
 
@@ -343,24 +343,24 @@
  *	WANPIPE-specific entry points 
  */
 static int wpx_exec (struct sdla* card, void* u_cmd, void* u_data);
-static void x25api_bh (netdevice_t *);
-static int x25api_bh_cleanup (netdevice_t *);
-static int bh_enqueue (netdevice_t *, struct sk_buff *);
+static void x25api_bh(struct net_device *dev);
+static int x25api_bh_cleanup(struct net_device *dev);
+static int bh_enqueue(struct net_device *dev, struct sk_buff *skb);
 
 
 /*=================================================  
  * 	Network device interface 
  */
-static int if_init   (netdevice_t* dev);
-static int if_open   (netdevice_t* dev);
-static int if_close  (netdevice_t* dev);
-static int if_header (struct sk_buff* skb, netdevice_t* dev,
+static int if_init(struct net_device* dev);
+static int if_open(struct net_device* dev);
+static int if_close(struct net_device* dev);
+static int if_header(struct sk_buff* skb, struct net_device* dev,
 	unsigned short type, void* daddr, void* saddr, unsigned len);
 static int if_rebuild_hdr (struct sk_buff* skb);
-static int if_send (struct sk_buff* skb, netdevice_t* dev);
-static struct net_device_stats *if_stats (netdevice_t* dev);
+static int if_send(struct sk_buff* skb, struct net_device* dev);
+static struct net_device_stats *if_stats(struct net_device* dev);
 
-static void if_tx_timeout (netdevice_t *dev);
+static void if_tx_timeout(struct net_device *dev);
 
 /*=================================================  
  * 	Interrupt handlers 
@@ -373,8 +373,9 @@
 static void spur_intr	(sdla_t *);
 static void timer_intr  (sdla_t *);
 
-static int tx_intr_send(sdla_t *, netdevice_t *);
-static netdevice_t * move_dev_to_next (sdla_t *, netdevice_t *);
+static int tx_intr_send(sdla_t *card, struct net_device *dev);
+static struct net_device *move_dev_to_next(sdla_t *card,
+					   struct net_device *dev);
 
 /*=================================================  
  *	Background polling routines 
@@ -425,35 +426,41 @@
  */
 static int connect (sdla_t* card);
 static int disconnect (sdla_t* card);
-static netdevice_t* get_dev_by_lcn(struct wan_device* wandev, unsigned lcn);
-static int chan_connect (netdevice_t* dev);
-static int chan_disc (netdevice_t* dev);
-static void set_chan_state (netdevice_t* dev, int state);
-static int chan_send (netdevice_t* , void* , unsigned, unsigned char);
+static struct net_device* get_dev_by_lcn(struct wan_device* wandev,
+					 unsigned lcn);
+static int chan_connect(struct net_device* dev);
+static int chan_disc(struct net_device* dev);
+static void set_chan_state(struct net_device* dev, int state);
+static int chan_send(struct net_device *dev, void* buff, unsigned data_len,
+		     unsigned char tx_intr);
 static unsigned char bps_to_speed_code (unsigned long bps);
 static unsigned int dec_to_uint (unsigned char* str, int len);
 static unsigned int hex_to_uint (unsigned char*, int);
 static void parse_call_info (unsigned char*, x25_call_info_t*);
-static netdevice_t * find_channel(sdla_t *, unsigned);
-static void bind_lcn_to_dev (sdla_t *, netdevice_t *,unsigned);
-static void setup_for_delayed_transmit (netdevice_t*, void*, unsigned);
+static struct net_device *find_channel(sdla_t *card, unsigned lcn);
+static void bind_lcn_to_dev(sdla_t *card, struct net_device *dev, unsigned lcn);
+static void setup_for_delayed_transmit(struct net_device *dev,
+				       void *buf, unsigned len);
 
 
 /*=================================================  
  *      X25 API Functions 
  */
-static int wanpipe_pull_data_in_skb (sdla_t *, netdevice_t *, struct sk_buff **);
+static int wanpipe_pull_data_in_skb(sdla_t *card, struct net_device *dev,
+				    struct sk_buff **);
 static void timer_intr_exec(sdla_t *, unsigned char);
-static int execute_delayed_cmd (sdla_t*, netdevice_t *, mbox_cmd_t *,char);
+static int execute_delayed_cmd(sdla_t *card, struct net_device *dev,
+			       mbox_cmd_t *usr_cmd, char bad_cmd);
 static int api_incoming_call (sdla_t*, TX25Mbox *, int);
 static int alloc_and_init_skb_buf (sdla_t *,struct sk_buff **, int);
-static void send_delayed_cmd_result(sdla_t *, netdevice_t *dev, TX25Mbox*);
+static void send_delayed_cmd_result(sdla_t *card, struct net_device *dev,
+				    TX25Mbox* mbox);
 static int clear_confirm_event (sdla_t *, TX25Mbox*);
-static void send_oob_msg (sdla_t *, netdevice_t *, TX25Mbox *);
+static void send_oob_msg (sdla_t *card, struct net_device *dev, TX25Mbox *mbox);
 static int timer_intr_cmd_exec(sdla_t *card);
 static void api_oob_event (sdla_t *card,TX25Mbox *mbox);
-static int check_bad_command (sdla_t *, netdevice_t *);
-static int channel_disconnect (sdla_t*, netdevice_t *);
+static int check_bad_command(sdla_t *card, struct net_device *dev);
+static int channel_disconnect(sdla_t* card, struct net_device *dev);
 static void hdlc_link_down (sdla_t*);
 
 /*=================================================
@@ -464,7 +471,9 @@
 static int reply_udp( unsigned char *, unsigned int); 
 static void init_x25_channel_struct( x25_channel_t *);
 static void init_global_statistics( sdla_t *);
-static int store_udp_mgmt_pkt(int, char, sdla_t*, netdevice_t *, struct sk_buff *, int);
+static int store_udp_mgmt_pkt(int udp_type, char udp_pkt_src, sdla_t *card,
+			      struct net_device *dev,
+			      struct sk_buff *skb, int lcn);
 static unsigned short calc_checksum (char *, int);
 
 
@@ -895,7 +904,7 @@
  * Return: 	0 	Ok
  *		<0 	Failed (channel will not be created)
  */
-static int new_if(struct wan_device* wandev, netdevice_t* dev,
+static int new_if(struct wan_device* wandev, struct net_device* dev,
 		  wanif_conf_t* conf)
 {
 	sdla_t* card = wandev->private;
@@ -1030,7 +1039,7 @@
 
 //FIXME Del IF Should be taken out now.
 
-static int del_if(struct wan_device* wandev, netdevice_t* dev)
+static int del_if(struct wan_device* wandev, struct net_device* dev)
 {
 	return 0;
 }
@@ -1096,7 +1105,7 @@
  *
  * Return: 	0 	Ok : Void function.
  */
-static int if_init (netdevice_t* dev)
+static int if_init(struct net_device* dev)
 {
 	x25_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -1168,7 +1177,7 @@
  * 		<0 	Failur: Interface will not come up.
  */
 
-static int if_open (netdevice_t* dev)
+static int if_open(struct net_device* dev)
 {
 	x25_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -1261,7 +1270,7 @@
  * Return: 	0 	Ok
  * 		<0 	Failure: Interface will not exit properly.
  */
-static int if_close (netdevice_t* dev)
+static int if_close(struct net_device* dev)
 {
 	x25_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -1319,8 +1328,9 @@
  * 	Return:		media header length.
  *======================================================================*/
 
-static int if_header (struct sk_buff* skb, netdevice_t* dev,
-	unsigned short type, void* daddr, void* saddr, unsigned len)
+static int if_header(struct sk_buff* skb, struct net_device* dev,
+		     unsigned short type, void* daddr, void* saddr,
+		     unsigned len)
 {
 	x25_channel_t* chan = dev->priv;
 	int hdr_len = dev->hard_header_len;
@@ -1345,7 +1355,7 @@
 
 static int if_rebuild_hdr (struct sk_buff* skb)
 {
-	netdevice_t *dev = skb->dev; 
+	struct net_device *dev = skb->dev; 
 	x25_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
 
@@ -1358,7 +1368,7 @@
 /*============================================================================
  * Handle transmit timeout event from netif watchdog
  */
-static void if_tx_timeout (netdevice_t *dev)
+static void if_tx_timeout(struct net_device *dev)
 {
     	x25_channel_t* chan = dev->priv;
 	sdla_t *card = chan->card;
@@ -1395,7 +1405,7 @@
  *
  *========================================================================*/
 
-static int if_send (struct sk_buff* skb, netdevice_t* dev)
+static int if_send(struct sk_buff* skb, struct net_device* dev)
 {
 	x25_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -1528,8 +1538,8 @@
  * interrupt.
  *===========================================================================*/
 
-static void setup_for_delayed_transmit (netdevice_t* dev, void* buf,
-	unsigned len)
+static void setup_for_delayed_transmit(struct net_device* dev, void* buf,
+				       unsigned len)
 {
         x25_channel_t* chan = dev->priv;
         sdla_t* card = chan->card;
@@ -1580,7 +1590,7 @@
  * 	Return a pointer to struct enet_statistics.
  *
  *==============================================================*/
-static struct net_device_stats *if_stats (netdevice_t* dev)
+static struct net_device_stats *if_stats(struct net_device* dev)
 {
 	x25_channel_t *chan = dev->priv;
 
@@ -1676,7 +1686,7 @@
 {
 	TX25Mbox* rxmb = card->rxmb;
 	unsigned lcn = rxmb->cmd.lcn;
-	netdevice_t* dev = find_channel(card,lcn);
+	struct net_device* dev = find_channel(card,lcn);
 	x25_channel_t* chan;
 	struct sk_buff* skb=NULL;
 
@@ -1774,7 +1784,8 @@
 }
 
 
-static int wanpipe_pull_data_in_skb (sdla_t *card, netdevice_t *dev, struct sk_buff **skb)
+static int wanpipe_pull_data_in_skb(sdla_t *card, struct net_device *dev,
+				    struct sk_buff **skb)
 {
 	void *bufptr;
 	TX25Mbox* rxmb = card->rxmb;
@@ -1884,7 +1895,7 @@
 
 static void tx_intr (sdla_t* card)
 {
-	netdevice_t *dev;
+	struct net_device *dev;
 	TX25Status* status = card->flags;
 	unsigned char more_to_tx=0;
 	x25_channel_t *chan=NULL;
@@ -1978,14 +1989,13 @@
  *===============================================================*/
 
 
-netdevice_t * move_dev_to_next (sdla_t *card, netdevice_t *dev)
+struct net_device *move_dev_to_next(sdla_t *card, struct net_device *dev)
 {
 	if (card->u.x.no_dev != 1){
-		if (*((netdevice_t**)dev->priv) == NULL){
+		if (!*((struct net_device **)dev->priv))
 			return card->wandev.dev;
-		}else{
-			return *((netdevice_t**)dev->priv);
-		}
+		else
+			return *((struct net_device **)dev->priv);
 	}
 	return dev;
 }
@@ -1996,7 +2006,7 @@
  *
  *===============================================================*/
 
-static int tx_intr_send(sdla_t *card, netdevice_t *dev)
+static int tx_intr_send(sdla_t *card, struct net_device *dev)
 {
 	x25_channel_t* chan = dev->priv; 
 
@@ -2059,7 +2069,7 @@
 
 	}else if (card->u.x.timer_int_enabled & TMR_INT_ENABLED_POLL_ACTIVE) {
 
-		netdevice_t *dev = card->u.x.poll_device;
+		struct net_device *dev = card->u.x.poll_device;
 		x25_channel_t *chan = NULL;
 
 		if (!dev){
@@ -2080,7 +2090,7 @@
 
 		wanpipe_set_state(card, WAN_CONNECTED);
 		if (card->u.x.LAPB_hdlc){
-			netdevice_t *dev = card->wandev.dev;
+			struct net_device *dev = card->wandev.dev;
 			set_chan_state(dev,WAN_CONNECTED);
 			send_delayed_cmd_result(card,dev,card->mbox);	
 		}
@@ -2136,7 +2146,7 @@
 
 	TX25Mbox* mbox = card->mbox;
 	TX25ModemStatus *modem_status;
-	netdevice_t *dev;
+	struct net_device *dev;
 	x25_channel_t *chan;
 	int err;
 
@@ -2165,7 +2175,8 @@
 				mbox->cmd.result = 0x08;
 
 				/* Send a OOB to all connected sockets */
-				for (dev = card->wandev.dev; dev; dev = *((netdevice_t**)dev->priv)){
+				for (dev = card->wandev.dev; dev;
+				     dev = *((struct net_device**)dev->priv)) {
 					chan=dev->priv;
 					if (chan->common.usedby == API){
 						send_oob_msg(card,dev,mbox);				
@@ -2295,7 +2306,7 @@
 
 static void poll_disconnected (sdla_t* card)
 {
-	netdevice_t *dev; 
+	struct net_device *dev; 
 	x25_channel_t *chan;
 	TX25Status* status = card->flags;
 
@@ -2332,10 +2343,11 @@
 
 static void poll_active (sdla_t* card)
 {
-	netdevice_t* dev;
+	struct net_device* dev;
 	TX25Status* status = card->flags;
 
-	for (dev = card->wandev.dev; dev; dev = *((netdevice_t**)dev->priv)){
+	for (dev = card->wandev.dev; dev;
+	     dev = *((struct net_device **)dev->priv)){
 		x25_channel_t* chan = dev->priv;
 
 		/* If SVC has been idle long enough, close virtual circuit */
@@ -3104,7 +3116,7 @@
 {
 	struct wan_device* wandev = &card->wandev;
 	int new_lcn = mb->cmd.lcn;
-	netdevice_t* dev = get_dev_by_lcn(wandev, new_lcn);
+	struct net_device* dev = get_dev_by_lcn(wandev, new_lcn);
 	x25_channel_t* chan = NULL;
 	int accept = 0;		/* set to '1' if o.k. to accept call */
 	unsigned int user_data;
@@ -3156,7 +3168,7 @@
 	user_data = hex_to_uint(info->user,2);
 
 	/* Find available channel */
-	for (dev = wandev->dev; dev; dev = *((netdevice_t**)dev->priv)){
+	for (dev = wandev->dev; dev; dev = *((struct net_device **)dev->priv)) {
 		chan = dev->priv;
 
 		if (chan->common.usedby == API)
@@ -3253,7 +3265,7 @@
 static int call_accepted (sdla_t* card, int cmd, int lcn, TX25Mbox* mb)
 {
 	unsigned new_lcn = mb->cmd.lcn;
-	netdevice_t* dev = find_channel(card, new_lcn);
+	struct net_device* dev = find_channel(card, new_lcn);
 	x25_channel_t* chan;
 
 	if (dev == NULL){
@@ -3293,7 +3305,7 @@
 static int call_cleared (sdla_t* card, int cmd, int lcn, TX25Mbox* mb)
 {
 	unsigned new_lcn = mb->cmd.lcn;
-	netdevice_t* dev = find_channel(card, new_lcn);
+	struct net_device* dev = find_channel(card, new_lcn);
 	x25_channel_t *chan;
 	unsigned char old_state;
 
@@ -3338,7 +3350,7 @@
 static int restart_event (sdla_t* card, int cmd, int lcn, TX25Mbox* mb)
 {
 	struct wan_device* wandev = &card->wandev;
-	netdevice_t* dev;
+	struct net_device* dev;
 	x25_channel_t *chan;
 	unsigned char old_state;
 
@@ -3347,7 +3359,7 @@
 		card->devname, mb->cmd.cause, mb->cmd.diagn);
 
 	/* down all logical channels */
-	for (dev = wandev->dev; dev; dev = *((netdevice_t**)dev->priv)){
+	for (dev = wandev->dev; dev; dev = *((struct net_device **)dev->priv)) {
 		chan=dev->priv;
 		old_state = chan->common.state;
 
@@ -3378,7 +3390,7 @@
 
 	if (mb->cmd.pktType == 0x05)	/* call request time out */
 	{
-		netdevice_t* dev = find_channel(card,new_lcn);
+		struct net_device* dev = find_channel(card,new_lcn);
 
 		printk(KERN_INFO "%s: X.25 call timed timeout on LCN %d!\n",
 			card->devname, new_lcn);
@@ -3448,11 +3460,12 @@
  * Find network device by its channel number.
  */
 
-static netdevice_t* get_dev_by_lcn(struct wan_device* wandev, unsigned lcn)
+static struct net_device* get_dev_by_lcn(struct wan_device* wandev,
+					 unsigned lcn)
 {
-	netdevice_t* dev;
+	struct net_device* dev;
 
-	for (dev = wandev->dev; dev; dev = *((netdevice_t**)dev->priv))
+	for (dev = wandev->dev; dev; dev = *((struct net_device **)dev->priv))
 		if (((x25_channel_t*)dev->priv)->common.lcn == lcn) 
 			break;
 	return dev;
@@ -3468,7 +3481,7 @@
  *			<0	failure
  */
 
-static int chan_connect (netdevice_t* dev)
+static int chan_connect(struct net_device* dev)
 {
 	x25_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -3501,7 +3514,7 @@
  * 	o if SVC then clear X.25 call
  */
 
-static int chan_disc (netdevice_t* dev)
+static int chan_disc(struct net_device* dev)
 {
 	x25_channel_t* chan = dev->priv;
 
@@ -3524,7 +3537,7 @@
  * 	Set logical channel state.
  */
 
-static void set_chan_state (netdevice_t* dev, int state)
+static void set_chan_state(struct net_device* dev, int state)
 {
 	x25_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -3614,7 +3627,8 @@
  *    	to the router.
  */
 
-static int chan_send (netdevice_t* dev, void* buff, unsigned data_len, unsigned char tx_intr)
+static int chan_send(struct net_device* dev, void* buff, unsigned data_len,
+		     unsigned char tx_intr)
 {
 	x25_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -4081,7 +4095,7 @@
  *===============================================================*/
 
 
-netdevice_t * find_channel(sdla_t *card, unsigned lcn)
+struct net_device *find_channel(sdla_t *card, unsigned lcn)
 {
 	if (card->u.x.LAPB_hdlc){
 
@@ -4128,7 +4142,7 @@
 	}
 }
 
-void bind_lcn_to_dev (sdla_t *card, netdevice_t *dev,unsigned lcn)
+void bind_lcn_to_dev(sdla_t *card, struct net_device *dev, unsigned lcn)
 {
 	x25_channel_t *chan = dev->priv;
 
@@ -4155,7 +4169,7 @@
  *
  *==============================================================*/
 
-static void x25api_bh (netdevice_t * dev)
+static void x25api_bh(struct net_device* dev)
 {
 	x25_channel_t* chan = dev->priv;
 	sdla_t* card = chan->card;
@@ -4231,7 +4245,7 @@
  *
  *==============================================================*/
 
-static int x25api_bh_cleanup (netdevice_t *dev)
+static int x25api_bh_cleanup(struct net_device *dev)
 {
 	x25_channel_t* chan = dev->priv;
 	sdla_t *card = chan->card;
@@ -4270,7 +4284,7 @@
  *
  *==============================================================*/
 
-static int bh_enqueue (netdevice_t *dev, struct sk_buff *skb)
+static int bh_enqueue(struct net_device *dev, struct sk_buff *skb)
 {
 	x25_channel_t* chan = dev->priv;
 	sdla_t *card = chan->card;
@@ -4310,7 +4324,7 @@
 
 static int timer_intr_cmd_exec (sdla_t* card)
 {
-	netdevice_t *dev;
+	struct net_device *dev;
 	unsigned char more_to_exec=0;
 	volatile x25_channel_t *chan=NULL;
 	int i=0,bad_cmd=0,err=0;	
@@ -4437,7 +4451,8 @@
  *
  *===============================================================*/
 
-static int execute_delayed_cmd (sdla_t* card, netdevice_t *dev, mbox_cmd_t *usr_cmd,char bad_cmd)
+static int execute_delayed_cmd(sdla_t* card, struct net_device *dev,
+			       mbox_cmd_t *usr_cmd, char bad_cmd)
 {
 	TX25Mbox* mbox = card->mbox;
 	int err;
@@ -4670,7 +4685,8 @@
  *      the result to a waiting sock. 
  *
  *===============================================================*/
-static void send_delayed_cmd_result(sdla_t *card, netdevice_t *dev, TX25Mbox* mbox)
+static void send_delayed_cmd_result(sdla_t *card, struct net_device *dev,
+				    TX25Mbox* mbox)
 {
 	x25_channel_t *chan = dev->priv;
 	mbox_cmd_t *usr_cmd = (mbox_cmd_t *)chan->common.mbox;
@@ -4725,7 +4741,7 @@
 
 static int clear_confirm_event (sdla_t *card, TX25Mbox* mb)
 {
-	netdevice_t *dev;
+	struct net_device *dev;
 	x25_channel_t *chan;
 	unsigned char old_state;	
 
@@ -4773,7 +4789,7 @@
  *
  *===============================================================*/
 
-static void send_oob_msg (sdla_t *card, netdevice_t *dev, TX25Mbox *mbox)
+static void send_oob_msg(sdla_t *card, struct net_device *dev, TX25Mbox *mbox)
 {
 	x25_channel_t *chan = dev->priv;
 	mbox_cmd_t *usr_cmd = (mbox_cmd_t *)chan->common.mbox;
@@ -4871,7 +4887,7 @@
 
 static void api_oob_event (sdla_t *card,TX25Mbox *mbox)
 {
-	netdevice_t *dev = find_channel(card,mbox->cmd.lcn);
+	struct net_device *dev = find_channel(card, mbox->cmd.lcn);
 	x25_channel_t *chan;
 
 	if (!dev)
@@ -4887,7 +4903,7 @@
 
 
 
-static int channel_disconnect (sdla_t* card, netdevice_t *dev)
+static int channel_disconnect(sdla_t* card, struct net_device *dev)
 {
 
 	int err;
@@ -4961,7 +4977,7 @@
 	
 }
 
-static int check_bad_command (sdla_t* card, netdevice_t *dev)
+static int check_bad_command(sdla_t* card, struct net_device *dev)
 {
 	x25_channel_t *chan = dev->priv;
 	int bad_cmd = 0;
@@ -5014,7 +5030,7 @@
 	TX25Mbox       *mbox = card->mbox;
 	int            err;
 	int            udp_mgmt_req_valid = 1;
-	netdevice_t  *dev;
+	struct net_device *dev;
         x25_channel_t  *chan;
 	unsigned short lcn;
 	struct timeval tv;
@@ -5338,7 +5354,8 @@
  */
 
 static int store_udp_mgmt_pkt(int udp_type, char udp_pkt_src, sdla_t* card,
-                                netdevice_t *dev, struct sk_buff *skb, int lcn)
+			      struct net_device *dev, struct sk_buff *skb,
+			      int lcn)
 {
         int udp_pkt_stored = 0;
 
diff -Nru a/drivers/net/wan/sdlamain.c b/drivers/net/wan/sdlamain.c
--- a/drivers/net/wan/sdlamain.c	Thu May 15 18:49:30 2003
+++ b/drivers/net/wan/sdlamain.c	Thu May 15 18:49:30 2003
@@ -64,8 +64,6 @@
 #include <linux/sdlapci.h>
 #include <linux/if_wanpipe_common.h>
 
-#define netdevice_t struct net_device
-
 #include <asm/uaccess.h>	/* kernel <-> user copy */
 #include <linux/inetdevice.h>
 
@@ -1255,7 +1253,7 @@
 	}
 } 
 
-void wakeup_sk_bh (netdevice_t *dev)
+void wakeup_sk_bh(struct net_device *dev)
 {
 	wanpipe_common_t *chan = dev->priv;
 
@@ -1268,7 +1266,7 @@
 	}
 }
 
-int change_dev_flags (netdevice_t *dev, unsigned flags)
+int change_dev_flags(struct net_device *dev, unsigned flags)
 {
 	struct ifreq if_info;
 	mm_segment_t fs = get_fs();
@@ -1285,7 +1283,7 @@
 	return err;
 }
 
-unsigned long get_ip_address (netdevice_t *dev, int option)
+unsigned long get_ip_address(struct net_device *dev, int option)
 {
 	
 	struct in_ifaddr *ifaddr;
@@ -1323,7 +1321,7 @@
 	return 0;
 }	
 
-void add_gateway(sdla_t *card, netdevice_t *dev)
+void add_gateway(sdla_t *card, struct net_device *dev)
 {
 	mm_segment_t oldfs;
 	struct rtentry route;
diff -Nru a/drivers/net/wan/wanpipe_multppp.c b/drivers/net/wan/wanpipe_multppp.c
--- a/drivers/net/wan/wanpipe_multppp.c	Thu May 15 18:49:30 2003
+++ b/drivers/net/wan/wanpipe_multppp.c	Thu May 15 18:49:30 2003
@@ -131,18 +131,18 @@
 /****** Function Prototypes *************************************************/
 /* WAN link driver entry points. These are called by the WAN router module. */
 static int update(struct wan_device* wandev);
-static int new_if(struct wan_device* wandev, netdevice_t* dev,
-	wanif_conf_t* conf);
-static int del_if(struct wan_device* wandev, netdevice_t* dev);
+static int new_if(struct wan_device* wandev, struct net_device* dev,
+		  wanif_conf_t* conf);
+static int del_if(struct wan_device* wandev, struct net_device* dev);
 
 /* Network device interface */
-static int if_init   (netdevice_t* dev);
-static int if_open   (netdevice_t* dev);
-static int if_close  (netdevice_t* dev);
-static int if_send (struct sk_buff* skb, netdevice_t* dev);
-static struct net_device_stats* if_stats (netdevice_t* dev);
+static int if_init(struct net_device* dev);
+static int if_open(struct net_device* dev);
+static int if_close(struct net_device* dev);
+static int if_send(struct sk_buff* skb, struct net_device* dev);
+static struct net_device_stats* if_stats(struct net_device* dev);
 
-static void if_tx_timeout (netdevice_t *dev);
+static void if_tx_timeout(struct net_device *dev);
 
 /* CHDLC Firmware interface functions */
 static int chdlc_configure 	(sdla_t* card, void* data);
@@ -158,7 +158,7 @@
 
 /* Miscellaneous CHDLC Functions */
 static int set_chdlc_config (sdla_t* card);
-static void init_chdlc_tx_rx_buff( sdla_t* card, netdevice_t *dev );
+static void init_chdlc_tx_rx_buff(sdla_t* card, struct net_device *dev);
 static int chdlc_error (sdla_t *card, int err, CHDLC_MAILBOX_STRUCT *mb);
 static int process_chdlc_exception(sdla_t *card);
 static int process_global_exception(sdla_t *card);
@@ -176,14 +176,14 @@
 static int intr_test( sdla_t* card);
 static int udp_pkt_type( struct sk_buff *skb , sdla_t* card);
 static int store_udp_mgmt_pkt(char udp_pkt_src, sdla_t* card,
-                                struct sk_buff *skb, netdevice_t* dev,
-                                chdlc_private_area_t* chdlc_priv_area);
-static int process_udp_mgmt_pkt(sdla_t* card, netdevice_t* dev,  
+			      struct sk_buff *skb, struct net_device* dev,
+			      chdlc_private_area_t* chdlc_priv_area);
+static int process_udp_mgmt_pkt(sdla_t* card, struct net_device* dev,  
 				chdlc_private_area_t* chdlc_priv_area);
 static unsigned short calc_checksum (char *, int);
 static void s508_lock (sdla_t *card, unsigned long *smp_flags);
 static void s508_unlock (sdla_t *card, unsigned long *smp_flags);
-static void send_ppp_term_request (netdevice_t*);
+static void send_ppp_term_request(struct net_device *dev);
 
 
 static int  Intr_test_counter;
@@ -459,7 +459,7 @@
 static int update(struct wan_device* wandev)
 {
 	sdla_t* card = wandev->private;
- 	netdevice_t* dev;
+ 	struct net_device* dev;
         volatile chdlc_private_area_t* chdlc_priv_area;
         SHARED_MEMORY_INFO_STRUCT *flags;
 	unsigned long timeout;
@@ -522,12 +522,12 @@
  * Return:	0	o.k.
  *		< 0	failure (channel will not be created)
  */
-static int new_if(struct wan_device* wandev, netdevice_t* pdev,
+static int new_if(struct wan_device* wandev, struct net_device* pdev,
 		  wanif_conf_t* conf)
 {
 
 	struct ppp_device *pppdev = (struct ppp_device *)pdev;
-	netdevice_t *dev=NULL;
+	struct net_device *dev = NULL;
 	struct sppp *sp;
 	sdla_t* card = wandev->private;
 	chdlc_private_area_t* chdlc_priv_area;
@@ -617,7 +617,7 @@
 /*============================================================================
  * Delete logical channel.
  */
-static int del_if(struct wan_device* wandev, netdevice_t* dev)
+static int del_if(struct wan_device* wandev, struct net_device* dev)
 {
 	chdlc_private_area_t *chdlc_priv_area = dev->priv;
 	sdla_t *card = chdlc_priv_area->card;
@@ -652,8 +652,8 @@
  * interface registration.  Returning anything but zero will fail interface
  * registration.
  */
-static int if_init (netdevice_t* dev)
-	{
+static int if_init(struct net_device* dev)
+{
 	chdlc_private_area_t* chdlc_priv_area = dev->priv;
 	sdla_t* card = chdlc_priv_area->card;
 	struct wan_device* wandev = &card->wandev;
@@ -695,7 +695,7 @@
 /*============================================================================
  * Handle transmit timeout event from netif watchdog
  */
-static void if_tx_timeout (netdevice_t *dev)
+static void if_tx_timeout(struct net_device *dev)
 {
     	chdlc_private_area_t* chan = dev->priv;
 	sdla_t *card = chan->card;
@@ -720,7 +720,7 @@
  *
  * Return 0 if O.k. or errno.
  */
-static int if_open (netdevice_t* dev)
+static int if_open(struct net_device* dev)
 {
 	chdlc_private_area_t* chdlc_priv_area = dev->priv;
 	sdla_t* card = chdlc_priv_area->card;
@@ -753,7 +753,7 @@
  * o if this is the last close, then disable communications and interrupts.
  * o reset flags.
  */
-static int if_close (netdevice_t* dev)
+static int if_close(struct net_device* dev)
 {
 	chdlc_private_area_t* chdlc_priv_area = dev->priv;
 	sdla_t* card = chdlc_priv_area->card;
@@ -784,7 +784,7 @@
  * 2. Setting tbusy flag will inhibit further transmit requests from the
  *    protocol stack and can be used for flow control with protocol layer.
  */
-static int if_send (struct sk_buff* skb, netdevice_t* dev)
+static int if_send(struct sk_buff* skb, struct net_device* dev)
 {
 	chdlc_private_area_t *chdlc_priv_area = dev->priv;
 	sdla_t *card = chdlc_priv_area->card;
@@ -974,7 +974,7 @@
  * Get ethernet-style interface statistics.
  * Return a pointer to struct enet_statistics.
  */
-static struct net_device_stats* if_stats (netdevice_t* dev)
+static struct net_device_stats* if_stats(struct net_device* dev)
 {
 	sdla_t *my_card;
 	chdlc_private_area_t* chdlc_priv_area;
@@ -1243,7 +1243,7 @@
  */
 STATIC void wsppp_isr (sdla_t* card)
 {
-	netdevice_t* dev;
+	struct net_device* dev;
 	SHARED_MEMORY_INFO_STRUCT* flags = NULL;
 	int i;
 	sdla_t *my_card;
@@ -1356,7 +1356,7 @@
  */
 static void rx_intr (sdla_t* card)
 {
-	netdevice_t *dev;
+	struct net_device *dev;
 	chdlc_private_area_t *chdlc_priv_area;
 	SHARED_MEMORY_INFO_STRUCT *flags = card->u.c.flags;
 	CHDLC_DATA_RX_STATUS_EL_STRUCT *rxbuf = card->u.c.rxmb;
@@ -1478,7 +1478,7 @@
  */
 void timer_intr(sdla_t *card)
 {
-        netdevice_t* dev;
+        struct net_device* dev;
         chdlc_private_area_t* chdlc_priv_area = NULL;
         SHARED_MEMORY_INFO_STRUCT* flags = NULL;
 
@@ -1666,8 +1666,8 @@
  */
 
 static int store_udp_mgmt_pkt(char udp_pkt_src, sdla_t* card,
-                                struct sk_buff *skb, netdevice_t* dev,
-                                chdlc_private_area_t* chdlc_priv_area )
+			      struct sk_buff *skb, struct net_device* dev,
+			      chdlc_private_area_t* chdlc_priv_area )
 {
 	int udp_pkt_stored = 0;
 
@@ -1693,7 +1693,7 @@
  * Process UDP management packet.
  */
 
-static int process_udp_mgmt_pkt(sdla_t* card, netdevice_t* dev,
+static int process_udp_mgmt_pkt(sdla_t* card, struct net_device* dev,
 				chdlc_private_area_t* chdlc_priv_area ) 
 {
 	unsigned char *buf;
@@ -2077,7 +2077,7 @@
  * Initialize Receive and Transmit Buffers.
  */
 
-static void init_chdlc_tx_rx_buff( sdla_t* card, netdevice_t *dev )
+static void init_chdlc_tx_rx_buff(sdla_t* card, struct net_device *dev)
 {
 	CHDLC_MAILBOX_STRUCT* mb = card->mbox;
 	CHDLC_TX_STATUS_EL_CFG_STRUCT *tx_config;
@@ -2214,7 +2214,7 @@
  */
 static void port_set_state (sdla_t *card, int state)
 {
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
 	chdlc_private_area_t *chdlc_priv_area = dev->priv;
 
         if (card->u.c.state != state)
@@ -2285,7 +2285,7 @@
 
 static int config_chdlc (sdla_t *card)
 {
-	netdevice_t *dev = card->wandev.dev;
+	struct net_device *dev = card->wandev.dev;
 	SHARED_MEMORY_INFO_STRUCT *flags = card->u.c.flags;
 
 	if (card->u.c.comm_enabled){
@@ -2331,7 +2331,7 @@
 }
 
 
-static void send_ppp_term_request (netdevice_t *dev)
+static void send_ppp_term_request(struct net_device *dev)
 {
 	struct sk_buff *new_skb;
 	unsigned char *buf;
diff -Nru a/include/linux/if_wanpipe.h b/include/linux/if_wanpipe.h
--- a/include/linux/if_wanpipe.h	Thu May 15 18:49:30 2003
+++ b/include/linux/if_wanpipe.h	Thu May 15 18:49:30 2003
@@ -101,16 +101,12 @@
 
 #ifdef __KERNEL__
 
-#ifndef netdevice_t
-#define netdevice_t struct net_device
-#endif
-
 /* Private wanpipe socket structures. */
 struct wanpipe_opt
 {
 	void   *mbox;		/* Mail box  */
 	void   *card; 		/* Card bouded to */
-	netdevice_t *dev;	/* Bounded device */
+	struct net_device *dev;	/* Bounded device */
 	unsigned short lcn;	/* Binded LCN */
 	unsigned char  svc;	/* 0=pvc, 1=svc */
 	unsigned char  timer;   /* flag for delayed transmit*/	
diff -Nru a/include/linux/if_wanpipe_common.h b/include/linux/if_wanpipe_common.h
--- a/include/linux/if_wanpipe_common.h	Thu May 15 18:49:30 2003
+++ b/include/linux/if_wanpipe_common.h	Thu May 15 18:49:30 2003
@@ -19,11 +19,8 @@
 
 #include <linux/version.h>
 
-#define netdevice_t struct net_device
-
-
 typedef struct {
-	netdevice_t *slave;
+	struct net_device *slave;
 	atomic_t packet_sent;
 	atomic_t receive_block;
 	atomic_t command;
@@ -32,8 +29,8 @@
 	long common_critical;
 	struct timer_list *tx_timer;
 	struct sock *sk;		/* Wanpipe Sock bind's here */ 
-	int   (*func) (struct sk_buff *, netdevice_t *, 
-                       struct sock *);
+	int (*func)(struct sk_buff *skb, struct net_device *dev, 
+		    struct sock *sk);
 
 	struct work_struct wanpipe_work;    /* deferred keventd work */
 	unsigned char rw_bind;			  /* Sock bind state */
diff -Nru a/include/linux/wanpipe.h b/include/linux/wanpipe.h
--- a/include/linux/wanpipe.h	Thu May 15 18:49:30 2003
+++ b/include/linux/wanpipe.h	Thu May 15 18:49:30 2003
@@ -39,8 +39,6 @@
 #ifndef	_WANPIPE_H
 #define	_WANPIPE_H
 
-#define netdevice_t struct net_device
-
 #include <linux/wanrouter.h>
 
 /* Defines */
@@ -335,22 +333,22 @@
 			u32 hi_pvc;
 			u32 lo_svc;
 			u32 hi_svc;
-			netdevice_t *svc_to_dev_map[MAX_X25_LCN];
-			netdevice_t *pvc_to_dev_map[MAX_X25_LCN];
-			netdevice_t *tx_dev;
-			netdevice_t *cmd_dev;
+			struct net_device *svc_to_dev_map[MAX_X25_LCN];
+			struct net_device *pvc_to_dev_map[MAX_X25_LCN];
+			struct net_device *tx_dev;
+			struct net_device *cmd_dev;
 			u32 no_dev;
 			volatile u8 *hdlc_buf_status;
 			u32 tx_interrupts_pending;
                         u16 timer_int_enabled;
-			netdevice_t *poll_device;
+			struct net_device *poll_device;
 			atomic_t command_busy;
 
 			u16 udp_pkt_lgth;
                         u32 udp_type;
                         u8  udp_pkt_src;
 			u32 udp_lcn;
-                        netdevice_t * udp_dev;
+                        struct net_device *udp_dev;
                         s8 udp_pkt_data[MAX_LGTH_UDP_MGNT_PKT];
 
 		 	u8 LAPB_hdlc;		/* Option to turn off X25 and run only LAPB */
@@ -369,7 +367,7 @@
 			unsigned rx_top;	/* S508 receive buffer end */
 			unsigned short node_dlci[100];
 			unsigned short dlci_num;
-                        netdevice_t *dlci_to_dev_map[991 + 1];
+                        struct net_device *dlci_to_dev_map[991 + 1];
                         unsigned tx_interrupts_pending;
                         unsigned short timer_int_enabled;
                         unsigned short udp_pkt_lgth;
@@ -382,7 +380,7 @@
                         void *curr_trc_el;      		/* current trace element */
                         unsigned short trc_bfr_space; 		/* trace buffer space */
 			unsigned char  update_comms_stats;
-			netdevice_t *arp_dev;
+			struct net_device *arp_dev;
 			spinlock_t if_send_lock;
 		} f;
 		struct			/****** PPP-specific data ***********/
@@ -483,10 +481,10 @@
 
 extern void wanpipe_queue_work (struct work_struct *);
 extern void wanpipe_mark_bh (void);
-extern void wakeup_sk_bh (netdevice_t *);
-extern int change_dev_flags (netdevice_t *, unsigned); 
-extern unsigned long get_ip_address (netdevice_t *dev, int option);
-extern void add_gateway(sdla_t *, netdevice_t *);
+extern void wakeup_sk_bh(struct net_device *dev);
+extern int change_dev_flags(struct net_device *dev, unsigned flags);
+extern unsigned long get_ip_address(struct net_device *dev, int option);
+extern void add_gateway(sdla_t *card, struct net_device *dev);
 
 
 #endif	/* __KERNEL__ */
diff -Nru a/include/linux/wanrouter.h b/include/linux/wanrouter.h
--- a/include/linux/wanrouter.h	Thu May 15 18:49:30 2003
+++ b/include/linux/wanrouter.h	Thu May 15 18:49:30 2003
@@ -44,8 +44,6 @@
 * Jan 02, 1997	Gene Kozin	Initial version (based on wanpipe.h).
 *****************************************************************************/
 
-#define netdevice_t struct net_device
-
 #include <linux/spinlock.h>       /* Support for SMP Locking */
 
 #ifndef	_ROUTER_H
@@ -505,12 +503,12 @@
 	int (*update) (struct wan_device *wandev);
 	int (*ioctl) (struct wan_device *wandev, unsigned cmd,
 		unsigned long arg);
-	int (*new_if) (struct wan_device *wandev, netdevice_t *dev,
-		wanif_conf_t *conf);
-	int (*del_if) (struct wan_device *wandev, netdevice_t *dev);
+	int (*new_if)(struct wan_device *wandev, struct net_device *dev,
+		      wanif_conf_t *conf);
+	int (*del_if)(struct wan_device *wandev, struct net_device *dev);
 					/****** maintained by the router ****/
 	struct wan_device* next;	/* -> next device */
-	netdevice_t* dev;		/* list of network interfaces */
+	struct net_device* dev;		/* list of network interfaces */
 	unsigned ndev;			/* number of interfaces */
 	struct proc_dir_entry *dent;	/* proc filesystem entry */
 };
@@ -518,8 +516,10 @@
 /* Public functions available for device drivers */
 extern int register_wan_device(struct wan_device *wandev);
 extern int unregister_wan_device(char *name);
-unsigned short wanrouter_type_trans(struct sk_buff *skb, netdevice_t *dev);
-int wanrouter_encapsulate(struct sk_buff *skb, netdevice_t *dev,unsigned short type);
+unsigned short wanrouter_type_trans(struct sk_buff *skb,
+				    struct net_device *dev);
+int wanrouter_encapsulate(struct sk_buff *skb, struct net_device *dev,
+			  unsigned short type);
 
 /* Proc interface functions. These must not be called by the drivers! */
 extern int wanrouter_proc_init(void);
diff -Nru a/net/wanrouter/af_wanpipe.c b/net/wanrouter/af_wanpipe.c
--- a/net/wanrouter/af_wanpipe.c	Thu May 15 18:49:30 2003
+++ b/net/wanrouter/af_wanpipe.c	Thu May 15 18:49:30 2003
@@ -170,7 +170,7 @@
 {
 	void   *mbox;		/* Mail box  */
 	void   *card; 		/* Card bouded to */
-	netdevice_t *dev;	/* Bounded device */
+	struct net_device *dev;	/* Bounded device */
 	unsigned short lcn;	/* Binded LCN */
 	unsigned char  svc;	/* 0=pvc, 1=svc */
 	unsigned char  timer;   /* flag for delayed transmit*/	
@@ -185,25 +185,26 @@
 extern struct proto_ops wanpipe_ops;
 static unsigned long find_free_critical;
 
-static void wanpipe_unlink_driver (struct sock *);
-static void wanpipe_link_driver (netdevice_t *,struct sock *sk);
+static void wanpipe_unlink_driver(struct sock *sk);
+static void wanpipe_link_driver(struct net_device *dev, struct sock *sk);
 static void wanpipe_wakeup_driver(struct sock *sk);
 static int execute_command(struct sock *, unsigned char, unsigned int);
-static int check_dev (netdevice_t *, sdla_t *);
-netdevice_t * wanpipe_find_free_dev (sdla_t *);
+static int check_dev(struct net_device *dev, sdla_t *card);
+struct net_device *wanpipe_find_free_dev(sdla_t *card);
 static void wanpipe_unlink_card (struct sock *);
 static int wanpipe_link_card (struct sock *);
 static struct sock *wanpipe_make_new(struct sock *);
 static struct sock *wanpipe_alloc_socket(void);
-static inline int get_atomic_device (netdevice_t *);
+static inline int get_atomic_device(struct net_device *dev);
 static int wanpipe_exec_cmd(struct sock *, int, unsigned int);
 static int get_ioctl_cmd (struct sock *, void *);
 static int set_ioctl_cmd (struct sock *, void *);
-static void release_device (netdevice_t *);
+static void release_device(struct net_device *dev);
 static void wanpipe_kill_sock_timer (unsigned long data);
 static void wanpipe_kill_sock_irq (struct sock *);
 static void wanpipe_kill_sock_accept (struct sock *);
-static int wanpipe_do_bind(struct sock *, netdevice_t *, int);
+static int wanpipe_do_bind(struct sock *sk, struct net_device *dev,
+			   int protocol);
 struct sock * get_newsk_from_skb (struct sk_buff *);
 static int wanpipe_debug (struct sock *, void *);
 static void wanpipe_delayed_transmit (unsigned long data);
@@ -225,7 +226,8 @@
  *      WANPIPE driver private.
  *===========================================================*/
 
-static int wanpipe_rcv(struct sk_buff *skb, netdevice_t *dev,  struct sock *sk)
+static int wanpipe_rcv(struct sk_buff *skb, struct net_device *dev,
+		       struct sock *sk)
 {
 	struct wan_sockaddr_ll *sll = (struct wan_sockaddr_ll*)skb->cb;
 	wanpipe_common_t *chan = dev->priv;
@@ -323,7 +325,7 @@
 	wanpipe_opt *wp = wp_sk(sk), *newwp;
 	struct wan_sockaddr_ll *sll = (struct wan_sockaddr_ll*)skb->cb;
 	struct sock *newsk;
-	netdevice_t *dev; 
+	struct net_device *dev; 
 	sdla_t *card;
 	mbox_cmd_t *mbox_ptr;
 	wanpipe_common_t *chan;
@@ -539,7 +541,7 @@
 	struct sock *sk = sock->sk;
 	struct wan_sockaddr_ll *saddr=(struct wan_sockaddr_ll *)msg->msg_name;
 	struct sk_buff *skb;
-	netdevice_t *dev;
+	struct net_device *dev;
 	unsigned short proto;
 	unsigned char *addr;
 	int ifindex, err, reserve = 0;
@@ -664,7 +666,7 @@
 	struct sock *sk=(struct sock *)data;
 	struct sk_buff *skb;
 	wanpipe_opt *wp = wp_sk(sk);
-	netdevice_t *dev = wp->dev;
+	struct net_device *dev = wp->dev;
 	sdla_t *card = (sdla_t*)wp->card;
 
 	if (!card || !dev){
@@ -756,7 +758,7 @@
 static int execute_command(struct sock *sk,  unsigned char cmd, unsigned int flags)
 {
 	wanpipe_opt *wp = wp_sk(sk);
-	netdevice_t *dev;
+	struct net_device *dev;
 	wanpipe_common_t *chan=NULL;
 	int err=0;
 	DECLARE_WAITQUEUE(wait, current);
@@ -861,7 +863,7 @@
  *===========================================================*/
 static void wanpipe_unlink_driver (struct sock *sk)
 {
-	netdevice_t *dev;
+	struct net_device *dev;
 	wanpipe_common_t *chan=NULL;
 
 	sk->zapped=0;
@@ -901,7 +903,7 @@
  *      data up the socket.
  *===========================================================*/
 
-static void wanpipe_link_driver (netdevice_t *dev, struct sock *sk)
+static void wanpipe_link_driver(struct net_device *dev, struct sock *sk)
 {
 	wanpipe_opt *wp = wp_sk(sk);
 	wanpipe_common_t *chan = dev->priv;
@@ -926,7 +928,7 @@
  *===========================================================*/
 
 
-static void release_device (netdevice_t *dev)
+static void release_device(struct net_device *dev)
 {
 	wanpipe_common_t *chan=dev->priv;
 	clear_bit(0,(void*)&chan->rw_bind);
@@ -965,7 +967,7 @@
 
 	if (wp->num == htons(X25_PROT) &&
 	    sk->state != WANSOCK_DISCONNECTED && sk->zapped) {
-		netdevice_t *dev = dev_get_by_index(sk->bound_dev_if);
+		struct net_device *dev = dev_get_by_index(sk->bound_dev_if);
 		wanpipe_common_t *chan;
 		if (dev){
 			chan=dev->priv;
@@ -1153,7 +1155,7 @@
 
 	if (wp_sk(sk)->num == htons(X25_PROT) &&
 	    sk->state != WANSOCK_DISCONNECTED){
-		netdevice_t *dev = dev_get_by_index(sk->bound_dev_if);
+		struct net_device *dev = dev_get_by_index(sk->bound_dev_if);
 		wanpipe_common_t *chan;
 		if (dev){
 			chan=dev->priv;
@@ -1268,7 +1270,8 @@
  *      sock to the driver.
  *===========================================================*/
 
-static int wanpipe_do_bind(struct sock *sk, netdevice_t *dev, int protocol)
+static int wanpipe_do_bind(struct sock *sk, struct net_device *dev,
+			   int protocol)
 {
 	wanpipe_opt *wp = wp_sk(sk);
 	wanpipe_common_t *chan=NULL;
@@ -1341,7 +1344,7 @@
 	struct wan_sockaddr_ll *sll = (struct wan_sockaddr_ll*)uaddr;
 	struct sock *sk=sock->sk;
 	wanpipe_opt *wp = wp_sk(sk);
-	netdevice_t *dev = NULL;
+	struct net_device *dev = NULL;
 	sdla_t *card=NULL;
 	char name[15];
 
@@ -1436,7 +1439,7 @@
  *===========================================================*/
 
 
-static inline int get_atomic_device (netdevice_t *dev)
+static inline int get_atomic_device(struct net_device *dev)
 {
 	wanpipe_common_t *chan = dev->priv;
 	if (!test_and_set_bit(0,(void *)&chan->rw_bind)){
@@ -1451,11 +1454,12 @@
  *  	Check that device name belongs to a particular card.
  *===========================================================*/
 
-static int check_dev (netdevice_t *dev, sdla_t *card)
+static int check_dev(struct net_device *dev, sdla_t *card)
 {
-	netdevice_t* tmp_dev;
+	struct net_device* tmp_dev;
 
-	for (tmp_dev = card->wandev.dev; tmp_dev; tmp_dev=*((netdevice_t**)tmp_dev->priv)){
+	for (tmp_dev = card->wandev.dev; tmp_dev;
+	     tmp_dev = *((struct net_device **)tmp_dev->priv)) {
 		if (tmp_dev->ifindex == dev->ifindex){ 
 			return 0;	
 		}
@@ -1471,16 +1475,17 @@
  *      X25API Specific.
  *===========================================================*/
 
-netdevice_t * wanpipe_find_free_dev (sdla_t *card)
+struct net_device *wanpipe_find_free_dev(sdla_t *card)
 {
-	netdevice_t* dev;
+	struct net_device* dev;
 	volatile wanpipe_common_t *chan;
 
 	if (test_and_set_bit(0,&find_free_critical)){
 		printk(KERN_INFO "CRITICAL in Find Free\n");
 	}	
 
-	for (dev = card->wandev.dev; dev; dev=*((netdevice_t**)dev->priv)){
+	for (dev = card->wandev.dev; dev;
+	     dev = *((struct net_device **)dev->priv)) {
 		chan = dev->priv;
 		if (!chan) 
 			continue;
@@ -1646,7 +1651,7 @@
 
 static void wanpipe_wakeup_driver(struct sock *sk)
 {
-	netdevice_t *dev=NULL;
+	struct net_device *dev = NULL;
 	wanpipe_common_t *chan=NULL;
 
 	dev = dev_get_by_index(sk->bound_dev_if);
@@ -1680,7 +1685,7 @@
 static int wanpipe_getname(struct socket *sock, struct sockaddr *uaddr,
 			  int *uaddr_len, int peer)
 {
-	netdevice_t *dev;
+	struct net_device *dev;
 	struct sock *sk = sock->sk;
 	struct wan_sockaddr_ll *sll = (struct wan_sockaddr_ll*)uaddr;
 
@@ -1718,7 +1723,7 @@
 static int wanpipe_notifier(struct notifier_block *this, unsigned long msg, void *data)
 {
 	struct sock *sk;
-	netdevice_t *dev = (netdevice_t*)data;
+	struct net_device *dev = (struct net_device *)data;
 	struct wanpipe_opt *po;
 
 	for (sk = wanpipe_sklist; sk; sk = sk->next) {
@@ -1867,7 +1872,7 @@
 static int wanpipe_debug (struct sock *origsk, void *arg)
 {
 	struct sock *sk=NULL;
-	netdevice_t *dev=NULL;
+	struct net_device *dev = NULL;
 	wanpipe_common_t *chan=NULL;
 	int cnt=0, err=0;
 	wan_debug_t *dbg_data = (wan_debug_t *)arg;
@@ -2010,7 +2015,7 @@
 
 	if (!wp_sk(sk)->mbox) {
 		void *mbox_ptr;
-		netdevice_t *dev = dev_get_by_index(sk->bound_dev_if);
+		struct net_device *dev = dev_get_by_index(sk->bound_dev_if);
 		if (!dev)
 			return -ENODEV;
 
@@ -2351,7 +2356,7 @@
 
 static int check_driver_busy (struct sock *sk)
 {
-	netdevice_t *dev = dev_get_by_index(sk->bound_dev_if);
+	struct net_device *dev = dev_get_by_index(sk->bound_dev_if);
 	wanpipe_common_t *chan;
 
 	if (!dev)
@@ -2456,7 +2461,7 @@
 
 struct sock * get_newsk_from_skb (struct sk_buff *skb)
 {
-	netdevice_t *dev = skb->dev;
+	struct net_device *dev = skb->dev;
 	wanpipe_common_t *chan;	
 
 	if (!dev){
@@ -2486,7 +2491,7 @@
 {
 	struct sock *sk = sock->sk;
 	struct wan_sockaddr_ll *addr = (struct wan_sockaddr_ll*)uaddr;
-	netdevice_t *dev;
+	struct net_device *dev;
 	int err;
 
 	if (wp_sk(sk)->num != htons(X25_PROT))
diff -Nru a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
--- a/net/wanrouter/wanmain.c	Thu May 15 18:49:30 2003
+++ b/net/wanrouter/wanmain.c	Thu May 15 18:49:30 2003
@@ -363,8 +363,8 @@
  */
 
 
-int wanrouter_encapsulate (struct sk_buff *skb, netdevice_t *dev,
-	unsigned short type)
+int wanrouter_encapsulate(struct sk_buff *skb, struct net_device *dev,
+			  unsigned short type)
 {
 	int hdr_len = 0;
 
@@ -406,7 +406,7 @@
  */
 
 
-unsigned short wanrouter_type_trans (struct sk_buff *skb, netdevice_t *dev)
+unsigned short wanrouter_type_trans(struct sk_buff *skb, struct net_device *dev)
 {
 	int cnt = skb->data[0] ? 0 : 1;	/* there may be a pad present */
 	unsigned short ethertype;
@@ -597,7 +597,7 @@
 
 static int device_shutdown(struct wan_device *wandev)
 {
-	netdevice_t *dev;
+	struct net_device *dev;
 	int err=0;
 
 	if (wandev->state == WAN_UNCONFIGURED)
@@ -661,7 +661,7 @@
 static int device_new_if(struct wan_device *wandev, wanif_conf_t *u_conf)
 {
 	wanif_conf_t conf;
-	netdevice_t *dev=NULL;
+	struct net_device *dev = NULL;
 #ifdef CONFIG_WANPIPE_MULTPPP
 	struct ppp_device *pppdev=NULL;
 #endif
@@ -682,13 +682,14 @@
 		if (pppdev == NULL)
 			return -ENOBUFS;
 		memset(pppdev, 0, sizeof(struct ppp_device));
-		pppdev->dev = kmalloc(sizeof(netdevice_t), GFP_KERNEL);
+		pppdev->dev = kmalloc(sizeof(struct net_device), GFP_KERNEL);
 		if (pppdev->dev == NULL) {
 			kfree(pppdev);
 			return -ENOBUFS;
 		}
-		memset(pppdev->dev, 0, sizeof(netdevice_t));
-		err = wandev->new_if(wandev, (netdevice_t *)pppdev, &conf);
+		memset(pppdev->dev, 0, sizeof(struct net_device));
+		err = wandev->new_if(wandev,
+				     (struct net_device *)pppdev, &conf);
 		dev = pppdev->dev;
 #else
 		printk(KERN_INFO "%s: Wanpipe Mulit-Port PPP support has not been compiled in!\n",
@@ -696,10 +697,10 @@
 		return -EPROTONOSUPPORT;
 #endif
 	} else {
-		dev = kmalloc(sizeof(netdevice_t), GFP_KERNEL);
+		dev = kmalloc(sizeof(struct net_device), GFP_KERNEL);
 		if (dev == NULL)
 			return -ENOBUFS;
-		memset(dev, 0, sizeof(netdevice_t));
+		memset(dev, 0, sizeof(struct net_device));
 		err = wandev->new_if(wandev, dev, &conf);
 	}
 
@@ -722,7 +723,7 @@
 
 			err = register_netdev(dev);
 			if (!err) {
-				netdevice_t *slave=NULL;
+				struct net_device *slave = NULL;
 				unsigned long smp_flags=0;
 
 				lock_adapter_irq(&wandev->lock, &smp_flags);
@@ -731,10 +732,10 @@
 					wandev->dev = dev;
 				} else {
 					for (slave=wandev->dev;
-					     *((netdevice_t**)slave->priv);
-					     slave=*((netdevice_t**)slave->priv));
+					 *((struct net_device **)slave->priv);
+				 slave = *((struct net_device **)slave->priv));
 
-					*((netdevice_t**)slave->priv) = dev;
+				     *((struct net_device **)slave->priv) = dev;
 				}
 				++wandev->ndev;
 
@@ -843,14 +844,14 @@
 
 static int delete_interface(struct wan_device *wandev, char *name)
 {
-	netdevice_t *dev=NULL, *prev=NULL;
+	struct net_device *dev = NULL, *prev = NULL;
 	unsigned long smp_flags=0;
 
 	lock_adapter_irq(&wandev->lock, &smp_flags);
 	dev = wandev->dev;
 	prev = NULL;
 	while (dev && strcmp(name, dev->name)) {
-		netdevice_t **slave = dev->priv;
+		struct net_device **slave = dev->priv;
 		prev = dev;
 		dev = *slave;
 	}
@@ -867,12 +868,12 @@
 
 	lock_adapter_irq(&wandev->lock, &smp_flags);
 	if (prev) {
-		netdevice_t **prev_slave = prev->priv;
-		netdevice_t **slave = dev->priv;
+		struct net_device **prev_slave = prev->priv;
+		struct net_device **slave = dev->priv;
 
 		*prev_slave = *slave;
 	} else {
-		netdevice_t **slave = dev->priv;
+		struct net_device **slave = dev->priv;
 		wandev->dev = *slave;
 	}
 	--wandev->ndev;

===================================================================


This BitKeeper patch contains the following changesets:
1.1145
## Wrapped with gzip_uu ##


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
<YWS4;UE#]]=FMW@S<<<J#*9R^+_U?$9()(H     
 
