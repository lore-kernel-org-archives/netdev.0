From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 1/3] Generic HDLC - fix kernel panic
Date: Fri, 01 Feb 2008 22:34:30 +0100
Message-ID: <m3abmknyxl.fsf@maximus.localdomain>
References: <m3ejbwnz2e.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:53947 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760059AbYBAVec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 16:34:32 -0500
In-Reply-To: <m3ejbwnz2e.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Fri\, 01 Feb 2008 22\:31\:37 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes kernel panic in Frame Relay mode

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 7926842..327b218 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -135,6 +135,10 @@ typedef struct pvc_device_struct {
 	}state;
 }pvc_device;
 
+struct pvc_desc {
+	struct net_device_stats stats;
+	pvc_device *pvc;
+};
 
 struct frad_state {
 	fr_proto settings;
@@ -170,17 +174,20 @@ static inline void dlci_to_q922(u8 *hdr, u16 dlci)
 }
 
 
-static inline struct frad_state * state(hdlc_device *hdlc)
+static inline struct frad_state* state(hdlc_device *hdlc)
 {
 	return(struct frad_state *)(hdlc->state);
 }
 
-
-static __inline__ pvc_device* dev_to_pvc(struct net_device *dev)
+static inline struct pvc_desc* pvcdev_to_desc(struct net_device *dev)
 {
 	return dev->priv;
 }
 
+static inline struct net_device_stats* pvc_get_stats(struct net_device *dev)
+{
+	return &pvcdev_to_desc(dev)->stats;
+}
 
 static inline pvc_device* find_pvc(hdlc_device *hdlc, u16 dlci)
 {
@@ -350,7 +357,7 @@ static int fr_hard_header(struct sk_buff **skb_p, u16 dlci)
 
 static int pvc_open(struct net_device *dev)
 {
-	pvc_device *pvc = dev_to_pvc(dev);
+	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
 
 	if ((pvc->frad->flags & IFF_UP) == 0)
 		return -EIO;  /* Frad must be UP in order to activate PVC */
@@ -370,7 +377,7 @@ static int pvc_open(struct net_device *dev)
 
 static int pvc_close(struct net_device *dev)
 {
-	pvc_device *pvc = dev_to_pvc(dev);
+	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
 
 	if (--pvc->open_count == 0) {
 		hdlc_device *hdlc = dev_to_hdlc(pvc->frad);
@@ -389,7 +396,7 @@ static int pvc_close(struct net_device *dev)
 
 static int pvc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	pvc_device *pvc = dev_to_pvc(dev);
+	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
 	fr_proto_pvc_info info;
 
 	if (ifr->ifr_settings.type == IF_GET_PROTO) {
@@ -415,17 +422,9 @@ static int pvc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EINVAL;
 }
 
-
-static inline struct net_device_stats *pvc_get_stats(struct net_device *dev)
-{
-	return &dev_to_desc(dev)->stats;
-}
-
-
-
 static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	pvc_device *pvc = dev_to_pvc(dev);
+	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
 	struct net_device_stats *stats = pvc_get_stats(dev);
 
 	if (pvc->state.active) {
@@ -1108,11 +1107,10 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	used = pvc_is_used(pvc);
 
 	if (type == ARPHRD_ETHER)
-		dev = alloc_netdev(sizeof(struct net_device_stats),
-				   "pvceth%d", ether_setup);
+		dev = alloc_netdev(sizeof(struct pvc_desc), "pvceth%d",
+				   ether_setup);
 	else
-		dev = alloc_netdev(sizeof(struct net_device_stats),
-				   "pvc%d", pvc_setup);
+		dev = alloc_netdev(sizeof(struct pvc_desc), "pvc%d", pvc_setup);
 
 	if (!dev) {
 		printk(KERN_WARNING "%s: Memory squeeze on fr_pvc()\n",
@@ -1135,7 +1133,7 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	dev->change_mtu = pvc_change_mtu;
 	dev->mtu = HDLC_MAX_MTU;
 	dev->tx_queue_len = 0;
-	dev->priv = pvc;
+	pvcdev_to_desc(dev)->pvc = pvc;
 
 	result = dev_alloc_name(dev, dev->name);
 	if (result < 0) {
