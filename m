From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH|[NET]: migrate HARD_TX_LOCK to header file
Date: Sun, 16 Sep 2007 16:57:14 -0400
Message-ID: <1189976234.4230.22.camel@localhost>
References: <1189957725.4241.4.camel@localhost>
	 <20070916.122842.59467739.davem@davemloft.net>
	 <1189974522.4230.3.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-VYurWrtfh0YspbDKgos5"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:8887 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbXIPU5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 16:57:18 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1181717wxd
        for <netdev@vger.kernel.org>; Sun, 16 Sep 2007 13:57:18 -0700 (PDT)
In-Reply-To: <1189974522.4230.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-VYurWrtfh0YspbDKgos5
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2007-16-09 at 16:28 -0400, jamal wrote:

> 
> sounds much better - will resend after a simple test.

Ok, heres the revised version

cheers,
jamal


--=-VYurWrtfh0YspbDKgos5
Content-Disposition: attachment; filename=htxp2
Content-Type: text/plain; name=htxp2; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET]: migrate HARD_TX_LOCK to header file
HARD_TX_LOCK micro is a nice aggregation that could be used
in other spots. move it to netdevice.h
Also makes sure the previously superflous cpu arguement is used.
Thanks to DaveM for the suggestions.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit e467e3cb7fca9b533543aa749395547b7ade4980
tree 5e03a405e32968cc8e9e875ecdaeec4e798b6809
parent f55ad5bb4809bdd07720387c62788fad5359d41c
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 16 Sep 2007 16:54:44 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 16 Sep 2007 16:54:44 -0400

 include/linux/netdevice.h |   21 +++++++++++++++++++--
 net/core/dev.c            |   12 ------------
 2 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dc5e35f..d529a0c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1265,10 +1265,15 @@ static inline void netif_rx_complete(struct net_device *dev,
  *
  * Get network device transmit lock
  */
-static inline void netif_tx_lock(struct net_device *dev)
+static inline void __netif_tx_lock(struct net_device *dev, int cpu)
 {
 	spin_lock(&dev->_xmit_lock);
-	dev->xmit_lock_owner = smp_processor_id();
+	dev->xmit_lock_owner = cpu;
+}
+
+static inline void netif_tx_lock(struct net_device *dev)
+{
+	__netif_tx_lock(dev, smp_processor_id());
 }
 
 static inline void netif_tx_lock_bh(struct net_device *dev)
@@ -1297,6 +1302,18 @@ static inline void netif_tx_unlock_bh(struct net_device *dev)
 	spin_unlock_bh(&dev->_xmit_lock);
 }
 
+#define HARD_TX_LOCK(dev, cpu) {			\
+	if ((dev->features & NETIF_F_LLTX) == 0) {	\
+		__netif_tx_lock(dev, cpu);			\
+	}						\
+}
+
+#define HARD_TX_UNLOCK(dev) {				\
+	if ((dev->features & NETIF_F_LLTX) == 0) {	\
+		netif_tx_unlock(dev);			\
+	}						\
+}
+
 static inline void netif_tx_disable(struct net_device *dev)
 {
 	netif_tx_lock_bh(dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 2897352..a1f6ca6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1574,18 +1574,6 @@ out_kfree_skb:
 	return 0;
 }
 
-#define HARD_TX_LOCK(dev, cpu) {			\
-	if ((dev->features & NETIF_F_LLTX) == 0) {	\
-		netif_tx_lock(dev);			\
-	}						\
-}
-
-#define HARD_TX_UNLOCK(dev) {				\
-	if ((dev->features & NETIF_F_LLTX) == 0) {	\
-		netif_tx_unlock(dev);			\
-	}						\
-}
-
 /**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit

--=-VYurWrtfh0YspbDKgos5--

