From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next] netdevice hdlc: Convert directly reference of netdev->priv
Date: Fri, 21 Nov 2008 17:02:49 +0800
Message-ID: <49267939.9090808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54867 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751769AbYKUJDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 04:03:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof said that he will take this one, but not.
I sent this to Dave again. :)

For killing directly reference of netdev->priv, use netdev->ml_priv to replace it.
Because the private pvc data comes from add_pvc() and can't be allocated in
alloc_netdev().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Acked-by: Krzysztof Halasa <khc@pm.waw.pl>
---
 drivers/net/wan/hdlc_fr.c |   10 +++++-----
 include/linux/hdlc.h      |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index d3d5055..f1ddd7c 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -342,7 +342,7 @@ static int fr_hard_header(struct sk_buff **skb_p, u16 dlci)
 
 static int pvc_open(struct net_device *dev)
 {
-	pvc_device *pvc = dev->priv;
+	pvc_device *pvc = dev->ml_priv;
 
 	if ((pvc->frad->flags & IFF_UP) == 0)
 		return -EIO;  /* Frad must be UP in order to activate PVC */
@@ -362,7 +362,7 @@ static int pvc_open(struct net_device *dev)
 
 static int pvc_close(struct net_device *dev)
 {
-	pvc_device *pvc = dev->priv;
+	pvc_device *pvc = dev->ml_priv;
 
 	if (--pvc->open_count == 0) {
 		hdlc_device *hdlc = dev_to_hdlc(pvc->frad);
@@ -381,7 +381,7 @@ static int pvc_close(struct net_device *dev)
 
 static int pvc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	pvc_device *pvc = dev->priv;
+	pvc_device *pvc = dev->ml_priv;
 	fr_proto_pvc_info info;
 
 	if (ifr->ifr_settings.type == IF_GET_PROTO) {
@@ -409,7 +409,7 @@ static int pvc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	pvc_device *pvc = dev->priv;
+	pvc_device *pvc = dev->ml_priv;
 
 	if (pvc->state.active) {
 		if (dev->type == ARPHRD_ETHER) {
@@ -1111,7 +1111,7 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	dev->change_mtu = pvc_change_mtu;
 	dev->mtu = HDLC_MAX_MTU;
 	dev->tx_queue_len = 0;
-	dev->priv = pvc;
+	dev->ml_priv = pvc;
 
 	result = dev_alloc_name(dev, dev->name);
 	if (result < 0) {
diff --git a/include/linux/hdlc.h b/include/linux/hdlc.h
index c597696..e960faa 100644
--- a/include/linux/hdlc.h
+++ b/include/linux/hdlc.h
@@ -80,7 +80,7 @@ struct net_device *alloc_hdlcdev(void *priv);
 
 static inline struct hdlc_device* dev_to_hdlc(struct net_device *dev)
 {
-	return dev->priv;
+	return netdev_priv(dev);
 }
 
 static __inline__ void debug_frame(const struct sk_buff *skb)
-- 
1.5.3.4



