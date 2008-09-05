From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 14/18] netdevice airo: Convert directly reference of netdev->priv
 to netdev->ml_priv
Date: Fri, 05 Sep 2008 11:27:39 +0800
Message-ID: <48C0A72B.9050407@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53397 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751898AbYIEDaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 23:30:04 -0400
In-Reply-To: <48C0A219.2030004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have some reasons to kill netdev->priv:
1. netdev->priv is equal to netdev_priv().
2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
   netdev_priv() is more flexible than netdev->priv.
But we cann't kill netdev->priv, because so many drivers reference to it
directly.

OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
and I want to kill netdev->priv later, I decided to convert all the direct
reference of netdev->priv first.

Different to readonly reference of netdev->priv, in this driver, netdev->priv
was changed. I use netdev->ml_priv to replace netdev->priv.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/wireless/airo.c |  171 ++++++++++++++++++++++---------------------
 1 files changed, 86 insertions(+), 85 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index b5cd850..f65cd91 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -1270,6 +1270,7 @@ static int flashrestart(struct airo_info *ai,struct net_device *dev);
 #define airo_print_err(name, fmt, args...) \
 	airo_print(KERN_ERR, name, fmt, ##args)
 
+#define AIRO_FLASH(dev) (((struct airo_info *)dev->ml_priv)->flash)
 
 /***********************************************************************
  *                              MIC ROUTINES                           *
@@ -1865,7 +1866,7 @@ static void try_auto_wep(struct airo_info *ai)
 }
 
 static int airo_open(struct net_device *dev) {
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	int rc = 0;
 
 	if (test_bit(FLAG_FLASHING, &ai->flags))
@@ -1912,7 +1913,7 @@ static int airo_open(struct net_device *dev) {
 static int mpi_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 	int npacks, pending;
 	unsigned long flags;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 
 	if (!skb) {
 		airo_print_err(dev->name, "%s: skb == NULL!",__FUNCTION__);
@@ -1956,7 +1957,7 @@ static int mpi_send_packet (struct net_device *dev)
 	unsigned char *buffer;
 	s16 len;
 	__le16 *payloadLen;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	u8 *sendbuf;
 
 	/* get a packet to send */
@@ -2085,7 +2086,7 @@ static void get_tx_error(struct airo_info *ai, s32 fid)
 static void airo_end_xmit(struct net_device *dev) {
 	u16 status;
 	int i;
-	struct airo_info *priv = dev->priv;
+	struct airo_info *priv = dev->ml_priv;
 	struct sk_buff *skb = priv->xmit.skb;
 	int fid = priv->xmit.fid;
 	u32 *fids = priv->fids;
@@ -2111,7 +2112,7 @@ static void airo_end_xmit(struct net_device *dev) {
 static int airo_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 	s16 len;
 	int i, j;
-	struct airo_info *priv = dev->priv;
+	struct airo_info *priv = dev->ml_priv;
 	u32 *fids = priv->fids;
 
 	if ( skb == NULL ) {
@@ -2150,7 +2151,7 @@ static int airo_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 static void airo_end_xmit11(struct net_device *dev) {
 	u16 status;
 	int i;
-	struct airo_info *priv = dev->priv;
+	struct airo_info *priv = dev->ml_priv;
 	struct sk_buff *skb = priv->xmit11.skb;
 	int fid = priv->xmit11.fid;
 	u32 *fids = priv->fids;
@@ -2176,7 +2177,7 @@ static void airo_end_xmit11(struct net_device *dev) {
 static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev) {
 	s16 len;
 	int i, j;
-	struct airo_info *priv = dev->priv;
+	struct airo_info *priv = dev->ml_priv;
 	u32 *fids = priv->fids;
 
 	if (test_bit(FLAG_MPI, &priv->flags)) {
@@ -2220,7 +2221,7 @@ static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev) {
 
 static void airo_read_stats(struct net_device *dev)
 {
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	StatsRid stats_rid;
 	__le32 *vals = stats_rid.vals;
 
@@ -2254,7 +2255,7 @@ static void airo_read_stats(struct net_device *dev)
 
 static struct net_device_stats *airo_get_stats(struct net_device *dev)
 {
-	struct airo_info *local =  dev->priv;
+	struct airo_info *local =  dev->ml_priv;
 
 	if (!test_bit(JOB_STATS, &local->jobs)) {
 		/* Get stats out of the card if available */
@@ -2281,7 +2282,7 @@ static void airo_set_promisc(struct airo_info *ai) {
 }
 
 static void airo_set_multicast_list(struct net_device *dev) {
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 
 	if ((dev->flags ^ ai->flags) & IFF_PROMISC) {
 		change_bit(FLAG_PROMISC, &ai->flags);
@@ -2299,7 +2300,7 @@ static void airo_set_multicast_list(struct net_device *dev) {
 
 static int airo_set_mac_address(struct net_device *dev, void *p)
 {
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	struct sockaddr *addr = p;
 
 	readConfigRid(ai, 1);
@@ -2339,7 +2340,7 @@ static void del_airo_dev(struct airo_info *ai)
 }
 
 static int airo_close(struct net_device *dev) {
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 
 	netif_stop_queue(dev);
 
@@ -2365,7 +2366,7 @@ static int airo_close(struct net_device *dev) {
 
 void stop_airo_card( struct net_device *dev, int freeres )
 {
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 
 	set_bit(FLAG_RADIO_DOWN, &ai->flags);
 	disable_MAC(ai, 1);
@@ -2665,7 +2666,7 @@ static struct net_device *init_wifidev(struct airo_info *ai,
 	struct net_device *dev = alloc_netdev(0, "wifi%d", wifi_setup);
 	if (!dev)
 		return NULL;
-	dev->priv = ethdev->priv;
+	dev->ml_priv = ethdev->ml_priv;
 	dev->irq = ethdev->irq;
 	dev->base_addr = ethdev->base_addr;
 	dev->wireless_data = ethdev->wireless_data;
@@ -2680,7 +2681,7 @@ static struct net_device *init_wifidev(struct airo_info *ai,
 }
 
 static int reset_card( struct net_device *dev , int lock) {
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 
 	if (lock && down_interruptible(&ai->sem))
 		return -1;
@@ -2766,7 +2767,7 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 		return NULL;
 	}
 
-	ai = dev->priv;
+	ai = dev->ml_priv = netdev_priv(dev);
 	ai->wifidev = NULL;
 	ai->flags = 1 << FLAG_RADIO_DOWN;
 	ai->jobs = 0;
@@ -2868,7 +2869,7 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 		for( i = 0; i < MAX_FIDS; i++ )
 			ai->fids[i] = transmit_allocate(ai,AIRO_DEF_MTU,i>=MAX_FIDS/2);
 
-	if (setup_proc_entry(dev, dev->priv) < 0)
+	if (setup_proc_entry(dev, dev->ml_priv) < 0)
 		goto err_out_wifi;
 
 	return dev;
@@ -2917,7 +2918,7 @@ static int waitbusy (struct airo_info *ai) {
 int reset_airo_card( struct net_device *dev )
 {
 	int i;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	DECLARE_MAC_BUF(mac);
 
 	if (reset_card (dev, 1))
@@ -2942,7 +2943,7 @@ int reset_airo_card( struct net_device *dev )
 EXPORT_SYMBOL(reset_airo_card);
 
 static void airo_send_event(struct net_device *dev) {
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	union iwreq_data wrqu;
 	StatusRid status_rid;
 
@@ -3019,7 +3020,7 @@ out:
 
 static int airo_thread(void *data) {
 	struct net_device *dev = data;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	int locked;
 
 	set_freezable();
@@ -3134,7 +3135,7 @@ static irqreturn_t airo_interrupt(int irq, void *dev_id)
 	struct net_device *dev = dev_id;
 	u16 status;
 	u16 fid;
-	struct airo_info *apriv = dev->priv;
+	struct airo_info *apriv = dev->ml_priv;
 	u16 savedInterrupts = 0;
 	int handled = 0;
 
@@ -4604,7 +4605,7 @@ static int proc_status_open(struct inode *inode, struct file *file)
 	struct proc_data *data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
-	struct airo_info *apriv = dev->priv;
+	struct airo_info *apriv = dev->ml_priv;
 	CapabilityRid cap_rid;
 	StatusRid status_rid;
 	u16 mode;
@@ -4687,7 +4688,7 @@ static int proc_stats_rid_open( struct inode *inode,
 	struct proc_data *data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
-	struct airo_info *apriv = dev->priv;
+	struct airo_info *apriv = dev->ml_priv;
 	StatsRid stats;
 	int i, j;
 	__le32 *vals = stats.vals;
@@ -4750,7 +4751,7 @@ static void proc_config_on_close(struct inode *inode, struct file *file)
 	struct proc_data *data = file->private_data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	char *line;
 
 	if ( !data->writelen ) return;
@@ -4962,7 +4963,7 @@ static int proc_config_open(struct inode *inode, struct file *file)
 	struct proc_data *data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	int i;
 	__le16 mode;
 
@@ -5053,7 +5054,7 @@ static void proc_SSID_on_close(struct inode *inode, struct file *file)
 	struct proc_data *data = (struct proc_data *)file->private_data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	SsidRid SSID_rid;
 	int i;
 	char *p = data->wbuffer;
@@ -5096,7 +5097,7 @@ static void proc_APList_on_close( struct inode *inode, struct file *file ) {
 	struct proc_data *data = (struct proc_data *)file->private_data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	APListRid APList_rid;
 	int i;
 
@@ -5191,7 +5192,7 @@ static void proc_wepkey_on_close( struct inode *inode, struct file *file ) {
 	struct proc_data *data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	int i;
 	char key[16];
 	u16 index = 0;
@@ -5233,7 +5234,7 @@ static int proc_wepkey_open( struct inode *inode, struct file *file )
 	struct proc_data *data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	char *ptr;
 	WepKeyRid wkr;
 	__le16 lastindex;
@@ -5282,7 +5283,7 @@ static int proc_SSID_open(struct inode *inode, struct file *file)
 	struct proc_data *data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	int i;
 	char *ptr;
 	SsidRid SSID_rid;
@@ -5326,7 +5327,7 @@ static int proc_APList_open( struct inode *inode, struct file *file ) {
 	struct proc_data *data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	int i;
 	char *ptr;
 	APListRid APList_rid;
@@ -5368,7 +5369,7 @@ static int proc_BSSList_open( struct inode *inode, struct file *file ) {
 	struct proc_data *data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	char *ptr;
 	BSSListRid BSSList_rid;
 	int rc;
@@ -5447,7 +5448,7 @@ static int proc_close( struct inode *inode, struct file *file )
    associated we will check every minute to see if anything has
    changed. */
 static void timer_func( struct net_device *dev ) {
-	struct airo_info *apriv = dev->priv;
+	struct airo_info *apriv = dev->ml_priv;
 
 /* We don't have a link so try changing the authtype */
 	readConfigRid(apriv, 0);
@@ -5518,7 +5519,7 @@ static void __devexit airo_pci_remove(struct pci_dev *pdev)
 static int airo_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	Cmd cmd;
 	Resp rsp;
 
@@ -5550,7 +5551,7 @@ static int airo_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 static int airo_pci_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	pci_power_t prev_state = pdev->current_state;
 
 	pci_set_power_state(pdev, PCI_D0);
@@ -5729,7 +5730,7 @@ static int airo_set_freq(struct net_device *dev,
 			 struct iw_freq *fwrq,
 			 char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	int rc = -EINPROGRESS;		/* Call commit handler */
 
 	/* If setting by frequency, convert to a channel */
@@ -5774,7 +5775,7 @@ static int airo_get_freq(struct net_device *dev,
 			 struct iw_freq *fwrq,
 			 char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	StatusRid status_rid;		/* Card status info */
 	int ch;
 
@@ -5805,7 +5806,7 @@ static int airo_set_essid(struct net_device *dev,
 			  struct iw_point *dwrq,
 			  char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	SsidRid SSID_rid;		/* SSIDs */
 
 	/* Reload the list of current SSID */
@@ -5851,7 +5852,7 @@ static int airo_get_essid(struct net_device *dev,
 			  struct iw_point *dwrq,
 			  char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	StatusRid status_rid;		/* Card status info */
 
 	readStatusRid(local, &status_rid, 1);
@@ -5879,7 +5880,7 @@ static int airo_set_wap(struct net_device *dev,
 			struct sockaddr *awrq,
 			char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	Cmd cmd;
 	Resp rsp;
 	APListRid APList_rid;
@@ -5916,7 +5917,7 @@ static int airo_get_wap(struct net_device *dev,
 			struct sockaddr *awrq,
 			char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	StatusRid status_rid;		/* Card status info */
 
 	readStatusRid(local, &status_rid, 1);
@@ -5937,7 +5938,7 @@ static int airo_set_nick(struct net_device *dev,
 			 struct iw_point *dwrq,
 			 char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 
 	/* Check the size of the string */
 	if(dwrq->length > 16) {
@@ -5960,7 +5961,7 @@ static int airo_get_nick(struct net_device *dev,
 			 struct iw_point *dwrq,
 			 char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 
 	readConfigRid(local, 1);
 	strncpy(extra, local->config.nodeName, 16);
@@ -5979,7 +5980,7 @@ static int airo_set_rate(struct net_device *dev,
 			 struct iw_param *vwrq,
 			 char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	CapabilityRid cap_rid;		/* Card capability info */
 	u8	brate = 0;
 	int	i;
@@ -6049,7 +6050,7 @@ static int airo_get_rate(struct net_device *dev,
 			 struct iw_param *vwrq,
 			 char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	StatusRid status_rid;		/* Card status info */
 
 	readStatusRid(local, &status_rid, 1);
@@ -6071,7 +6072,7 @@ static int airo_set_rts(struct net_device *dev,
 			struct iw_param *vwrq,
 			char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	int rthr = vwrq->value;
 
 	if(vwrq->disabled)
@@ -6095,7 +6096,7 @@ static int airo_get_rts(struct net_device *dev,
 			struct iw_param *vwrq,
 			char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 
 	readConfigRid(local, 1);
 	vwrq->value = le16_to_cpu(local->config.rtsThres);
@@ -6114,7 +6115,7 @@ static int airo_set_frag(struct net_device *dev,
 			 struct iw_param *vwrq,
 			 char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	int fthr = vwrq->value;
 
 	if(vwrq->disabled)
@@ -6139,7 +6140,7 @@ static int airo_get_frag(struct net_device *dev,
 			 struct iw_param *vwrq,
 			 char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 
 	readConfigRid(local, 1);
 	vwrq->value = le16_to_cpu(local->config.fragThresh);
@@ -6158,7 +6159,7 @@ static int airo_set_mode(struct net_device *dev,
 			 __u32 *uwrq,
 			 char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	int reset = 0;
 
 	readConfigRid(local, 1);
@@ -6221,7 +6222,7 @@ static int airo_get_mode(struct net_device *dev,
 			 __u32 *uwrq,
 			 char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 
 	readConfigRid(local, 1);
 	/* If not managed, assume it's ad-hoc */
@@ -6258,7 +6259,7 @@ static int airo_set_encode(struct net_device *dev,
 			   struct iw_point *dwrq,
 			   char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	CapabilityRid cap_rid;		/* Card capability info */
 	int perm = ( dwrq->flags & IW_ENCODE_TEMP ? 0 : 1 );
 	__le16 currentAuthType = local->config.authType;
@@ -6345,7 +6346,7 @@ static int airo_get_encode(struct net_device *dev,
 			   struct iw_point *dwrq,
 			   char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	int index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
 	CapabilityRid cap_rid;		/* Card capability info */
 
@@ -6393,7 +6394,7 @@ static int airo_set_encodeext(struct net_device *dev,
 			    union iwreq_data *wrqu,
 			    char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	struct iw_point *encoding = &wrqu->encoding;
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
 	CapabilityRid cap_rid;		/* Card capability info */
@@ -6479,7 +6480,7 @@ static int airo_get_encodeext(struct net_device *dev,
 			    union iwreq_data *wrqu,
 			    char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	struct iw_point *encoding = &wrqu->encoding;
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
 	CapabilityRid cap_rid;		/* Card capability info */
@@ -6542,7 +6543,7 @@ static int airo_set_auth(struct net_device *dev,
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	struct iw_param *param = &wrqu->param;
 	__le16 currentAuthType = local->config.authType;
 
@@ -6610,7 +6611,7 @@ static int airo_get_auth(struct net_device *dev,
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	struct iw_param *param = &wrqu->param;
 	__le16 currentAuthType = local->config.authType;
 
@@ -6659,7 +6660,7 @@ static int airo_set_txpow(struct net_device *dev,
 			  struct iw_param *vwrq,
 			  char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	CapabilityRid cap_rid;		/* Card capability info */
 	int i;
 	int rc = -EINVAL;
@@ -6696,7 +6697,7 @@ static int airo_get_txpow(struct net_device *dev,
 			  struct iw_param *vwrq,
 			  char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 
 	readConfigRid(local, 1);
 	vwrq->value = le16_to_cpu(local->config.txPower);
@@ -6716,7 +6717,7 @@ static int airo_set_retry(struct net_device *dev,
 			  struct iw_param *vwrq,
 			  char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	int rc = -EINVAL;
 
 	if(vwrq->disabled) {
@@ -6754,7 +6755,7 @@ static int airo_get_retry(struct net_device *dev,
 			  struct iw_param *vwrq,
 			  char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 
 	vwrq->disabled = 0;      /* Can't be disabled */
 
@@ -6785,7 +6786,7 @@ static int airo_get_range(struct net_device *dev,
 			  struct iw_point *dwrq,
 			  char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	struct iw_range *range = (struct iw_range *) extra;
 	CapabilityRid cap_rid;		/* Card capability info */
 	int		i;
@@ -6910,7 +6911,7 @@ static int airo_set_power(struct net_device *dev,
 			  struct iw_param *vwrq,
 			  char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 
 	readConfigRid(local, 1);
 	if (vwrq->disabled) {
@@ -6967,7 +6968,7 @@ static int airo_get_power(struct net_device *dev,
 			  struct iw_param *vwrq,
 			  char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	__le16 mode;
 
 	readConfigRid(local, 1);
@@ -6998,7 +6999,7 @@ static int airo_set_sens(struct net_device *dev,
 			 struct iw_param *vwrq,
 			 char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 
 	readConfigRid(local, 1);
 	local->config.rssiThreshold =
@@ -7017,7 +7018,7 @@ static int airo_get_sens(struct net_device *dev,
 			 struct iw_param *vwrq,
 			 char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 
 	readConfigRid(local, 1);
 	vwrq->value = le16_to_cpu(local->config.rssiThreshold);
@@ -7037,7 +7038,7 @@ static int airo_get_aplist(struct net_device *dev,
 			   struct iw_point *dwrq,
 			   char *extra)
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 	struct sockaddr *address = (struct sockaddr *) extra;
 	struct iw_quality qual[IW_MAX_AP];
 	BSSListRid BSSList;
@@ -7110,7 +7111,7 @@ static int airo_set_scan(struct net_device *dev,
 			 struct iw_param *vwrq,
 			 char *extra)
 {
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	Cmd cmd;
 	Resp rsp;
 	int wake = 0;
@@ -7156,7 +7157,7 @@ static inline char *airo_translate_scan(struct net_device *dev,
 					char *end_buf,
 					BSSListRid *bss)
 {
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	struct iw_event		iwe;		/* Temporary buffer */
 	__le16			capabilities;
 	char *			current_val;	/* For rates */
@@ -7338,7 +7339,7 @@ static int airo_get_scan(struct net_device *dev,
 			 struct iw_point *dwrq,
 			 char *extra)
 {
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	BSSListElement *net;
 	int err = 0;
 	char *current_ev = extra;
@@ -7382,7 +7383,7 @@ static int airo_config_commit(struct net_device *dev,
 			      void *zwrq,			/* NULL */
 			      char *extra)			/* NULL */
 {
-	struct airo_info *local = dev->priv;
+	struct airo_info *local = dev->ml_priv;
 
 	if (!test_bit (FLAG_COMMIT, &local->flags))
 		return 0;
@@ -7527,7 +7528,7 @@ static const struct iw_handler_def	airo_handler_def =
 static int airo_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	int rc = 0;
-	struct airo_info *ai = (struct airo_info *)dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 
 	if (ai->power.event)
 		return 0;
@@ -7655,7 +7656,7 @@ static void airo_read_wireless_stats(struct airo_info *local)
 
 static struct iw_statistics *airo_get_wireless_stats(struct net_device *dev)
 {
-	struct airo_info *local =  dev->priv;
+	struct airo_info *local =  dev->ml_priv;
 
 	if (!test_bit(JOB_WSTATS, &local->jobs)) {
 		/* Get stats out of the card if available */
@@ -7680,7 +7681,7 @@ static int readrids(struct net_device *dev, aironet_ioctl *comp) {
 	unsigned short ridcode;
 	unsigned char *iobuf;
 	int len;
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 
 	if (test_bit(FLAG_FLASHING, &ai->flags))
 		return -EIO;
@@ -7746,7 +7747,7 @@ static int readrids(struct net_device *dev, aironet_ioctl *comp) {
  */
 
 static int writerids(struct net_device *dev, aironet_ioctl *comp) {
-	struct airo_info *ai = dev->priv;
+	struct airo_info *ai = dev->ml_priv;
 	int  ridcode;
         int  enabled;
 	static int (* writer)(struct airo_info *, u16 rid, const void *, int, int);
@@ -7869,41 +7870,41 @@ static int flashcard(struct net_device *dev, aironet_ioctl *comp) {
 	switch(comp->command)
 	{
 	case AIROFLSHRST:
-		return cmdreset((struct airo_info *)dev->priv);
+		return cmdreset((struct airo_info *)dev->ml_priv);
 
 	case AIROFLSHSTFL:
-		if (!((struct airo_info *)dev->priv)->flash &&
-			(((struct airo_info *)dev->priv)->flash = kmalloc (FLASHSIZE, GFP_KERNEL)) == NULL)
+		if (!AIRO_FLASH(dev) &&
+		    (AIRO_FLASH(dev) = kmalloc(FLASHSIZE, GFP_KERNEL)) == NULL)
 			return -ENOMEM;
-		return setflashmode((struct airo_info *)dev->priv);
+		return setflashmode((struct airo_info *)dev->ml_priv);
 
 	case AIROFLSHGCHR: /* Get char from aux */
 		if(comp->len != sizeof(int))
 			return -EINVAL;
 		if (copy_from_user(&z,comp->data,comp->len))
 			return -EFAULT;
-		return flashgchar((struct airo_info *)dev->priv,z,8000);
+		return flashgchar((struct airo_info *)dev->ml_priv, z, 8000);
 
 	case AIROFLSHPCHR: /* Send char to card. */
 		if(comp->len != sizeof(int))
 			return -EINVAL;
 		if (copy_from_user(&z,comp->data,comp->len))
 			return -EFAULT;
-		return flashpchar((struct airo_info *)dev->priv,z,8000);
+		return flashpchar((struct airo_info *)dev->ml_priv, z, 8000);
 
 	case AIROFLPUTBUF: /* Send 32k to card */
-		if (!((struct airo_info *)dev->priv)->flash)
+		if (!AIRO_FLASH(dev))
 			return -ENOMEM;
 		if(comp->len > FLASHSIZE)
 			return -EINVAL;
-		if(copy_from_user(((struct airo_info *)dev->priv)->flash,comp->data,comp->len))
+		if (copy_from_user(AIRO_FLASH(dev), comp->data, comp->len))
 			return -EFAULT;
 
-		flashputbuf((struct airo_info *)dev->priv);
+		flashputbuf((struct airo_info *)dev->ml_priv);
 		return 0;
 
 	case AIRORESTART:
-		if(flashrestart((struct airo_info *)dev->priv,dev))
+		if (flashrestart((struct airo_info *)dev->ml_priv, dev))
 			return -EIO;
 		return 0;
 	}
-- 
1.5.3.4


