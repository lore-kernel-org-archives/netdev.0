From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 12/18] netdevice hdlc: Convert directly reference of netdev->priv
 to netdev->ml_priv
Date: Fri, 05 Sep 2008 11:24:34 +0800
Message-ID: <48C0A672.9080102@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>,
	Krzysztof Halasa <khc@pm.waw.pl>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51653 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752564AbYIED05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 23:26:57 -0400
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


