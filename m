From: jamal <hadi@cyberus.ca>
Subject: [PATCH|[NET]: migrate HARD_TX_LOCK to header file
Date: Sun, 16 Sep 2007 11:48:45 -0400
Message-ID: <1189957725.4241.4.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-JugxfVA+kXzfC3+j4X6k"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:29837 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbXIPPst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 11:48:49 -0400
Received: by an-out-0708.google.com with SMTP id d31so193892and
        for <netdev@vger.kernel.org>; Sun, 16 Sep 2007 08:48:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-JugxfVA+kXzfC3+j4X6k
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I wanted to get rid of the extrenous cpu arguement and ended moving this
to the header files since it looks common enough an operation that could
be used elsewhere.
It is a trivial change - i could resend with leaving it in dev.c and
just getting rid of the cpu arguement.


cheers,
jamal


--=-JugxfVA+kXzfC3+j4X6k
Content-Disposition: attachment; filename=htxp1
Content-Type: text/plain; name=htxp1; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET]: migrate HARD_TX_LOCK to header file

HARD_TX_LOCK micro is a nice aggregation that could be used
in other spots. move it to netdevice.h
Also get rid of superflous cpu arguement while doing this ..

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 1bc3a7393737ab1f5239bd8dc2f2953dcee5391e
tree 83a7f39b61fe45282eee825286996ba4bf72c0f6
parent 1f08657fc9b0b56039a9378ca030c2c8ed7bd8ac
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 16 Sep 2007 11:29:48 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 16 Sep 2007 11:29:48 -0400

 include/linux/netdevice.h |   12 ++++++++++++
 net/core/dev.c            |   14 +-------------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dc5e35f..c83e667 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1297,6 +1297,18 @@ static inline void netif_tx_unlock_bh(struct net_device *dev)
 	spin_unlock_bh(&dev->_xmit_lock);
 }
 
+#define HARD_TX_LOCK(dev) {			\
+	if ((dev->features & NETIF_F_LLTX) == 0) {	\
+		netif_tx_lock(dev);			\
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
index 2897352..7934d28 100644
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
@@ -1710,7 +1698,7 @@ gso:
 
 		if (dev->xmit_lock_owner != cpu) {
 
-			HARD_TX_LOCK(dev, cpu);
+			HARD_TX_LOCK(dev);
 
 			if (!netif_queue_stopped(dev) &&
 			    !netif_subqueue_stopped(dev, skb->queue_mapping)) {

--=-JugxfVA+kXzfC3+j4X6k--

