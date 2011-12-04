From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCHv2 net-next 3/4] caif: Add support for flow-control on device's tx-queue
Date: Sun,  4 Dec 2011 11:10:49 +0100
Message-ID: <1322993450-8802-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1322993450-8802-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@stericsson.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40103 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686Ab1LDKLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 05:11:13 -0500
Received: by eeaq14 with SMTP id q14so1458960eea.19
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2011 02:11:12 -0800 (PST)
In-Reply-To: <1322993450-8802-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46low control is implemented by inspecting the qdisc queue length
in order to detect potential overflow on the TX queue. When a threshold
is reached flow-off is sent upwards in the CAIF stack. At the same time
the skb->destructor is hi-jacked by orphaning the SKB and the original=20
destructor is replaced with a "flow-on" callback. When the "hi-jacked"
SKB is consumed the queue should be empty, and the "flow-on" callback
is called and xon is sent upwards in the CAIF stack.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
Changes from V1:
	- Add RCU protection when accessing qdisc.
	- Add a spin_lock when setting xoff/xon.

 net/caif/caif_dev.c |   85 +++++++++++++++++++++++++++++++++++++++++++=
+++++++-
 1 files changed, 84 insertions(+), 1 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index f7be07e..1980404 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -17,6 +17,7 @@
 #include <linux/netdevice.h>
 #include <linux/mutex.h>
 #include <linux/module.h>
+#include <linux/spinlock.h>
 #include <net/netns/generic.h>
 #include <net/net_namespace.h>
 #include <net/pkt_sched.h>
@@ -35,6 +36,8 @@ struct caif_device_entry {
 	struct list_head list;
 	struct net_device *netdev;
 	int __percpu *pcpu_refcnt;
+	spinlock_t flow_lock;
+	bool xoff;
 };
=20
 struct caif_device_entry_list {
@@ -49,6 +52,7 @@ struct caif_net {
 };
=20
 static int caif_net_id;
+static int q_high =3D 50; /* Percent */
=20
 struct cfcnfg *get_cfcnfg(struct net *net)
 {
@@ -127,17 +131,94 @@ static struct caif_device_entry *caif_get(struct =
net_device *dev)
 	return NULL;
 }
=20
+void caif_flow_cb(struct sk_buff *skb)
+{
+	struct caif_device_entry *caifd;
+	bool send_xoff;
+
+	WARN_ON(skb->dev =3D=3D NULL);
+
+	rcu_read_lock();
+	caifd =3D caif_get(skb->dev);
+	caifd_hold(caifd);
+	rcu_read_unlock();
+
+	spin_lock_bh(&caifd->flow_lock);
+	send_xoff =3D caifd->xoff;
+	caifd->xoff =3D 0;
+	spin_unlock_bh(&caifd->flow_lock);
+
+	if (send_xoff)
+		caifd->layer.up->
+			ctrlcmd(caifd->layer.up,
+				_CAIF_CTRLCMD_PHYIF_FLOW_ON_IND,
+				caifd->layer.id);
+	caifd_put(caifd);
+}
+
 static int transmit(struct cflayer *layer, struct cfpkt *pkt)
 {
-	int err;
+	int err, high =3D 0, qlen =3D 0;
+	struct caif_dev_common *caifdev;
 	struct caif_device_entry *caifd =3D
 	    container_of(layer, struct caif_device_entry, layer);
 	struct sk_buff *skb;
+	struct netdev_queue *txq;
+
+	rcu_read_lock_bh();
=20
 	skb =3D cfpkt_tonative(pkt);
 	skb->dev =3D caifd->netdev;
 	skb_reset_network_header(skb);
 	skb->protocol =3D htons(ETH_P_CAIF);
+	caifdev =3D netdev_priv(caifd->netdev);
+
+	/* Check if we need to handle xoff */
+	if (likely(caifd->netdev->tx_queue_len =3D=3D 0))
+		goto noxoff;
+
+	if (unlikely(caifd->xoff))
+		goto noxoff;
+
+	if (likely(!netif_queue_stopped(caifd->netdev))) {
+		/* If we run with a TX queue, check if the queue is too long*/
+		txq =3D netdev_get_tx_queue(skb->dev, 0);
+		qlen =3D qdisc_qlen(rcu_dereference_bh(txq->qdisc));
+
+		if (likely(qlen =3D=3D 0))
+			goto noxoff;
+
+		high =3D (caifd->netdev->tx_queue_len * q_high) / 100;
+		if (likely(qlen < high))
+			goto noxoff;
+	}
+
+	/* Hold lock while accessing xoff */
+	spin_lock_bh(&caifd->flow_lock);
+	if (caifd->xoff) {
+		spin_unlock_bh(&caifd->flow_lock);
+		goto noxoff;
+	}
+
+	/*
+	 * Handle flow off, we do this by temporary hi-jacking this
+	 * skb's destructor function, and replace it with our own
+	 * flow-on callback. The callback will set flow-on and call
+	 * the original destructor.
+	 */
+
+	pr_debug("queue has stopped(%d) or is full (%d > %d)\n",
+			netif_queue_stopped(caifd->netdev),
+			qlen, high);
+	caifd->xoff =3D 1;
+	spin_unlock_bh(&caifd->flow_lock);
+	skb_orphan(skb);
+
+	caifd->layer.up->ctrlcmd(caifd->layer.up,
+					_CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND,
+					caifd->layer.id);
+noxoff:
+	rcu_read_unlock_bh();
=20
 	err =3D dev_queue_xmit(skb);
 	if (err > 0)
@@ -233,6 +314,7 @@ void caif_enroll_dev(struct net_device *dev, struct=
 caif_dev_common *caifdev,
 	if (!caifd)
 		return;
 	*layer =3D &caifd->layer;
+	spin_lock_init(&caifd->flow_lock);
=20
 	switch (caifdev->link_select) {
 	case CAIF_LINK_HIGH_BANDW:
@@ -316,6 +398,7 @@ static int caif_device_notify(struct notifier_block=
 *me, unsigned long what,
 			break;
 		}
=20
+		caifd->xoff =3D 0;
 		cfcnfg_set_phy_state(cfg, &caifd->layer, true);
 		rcu_read_unlock();
=20
--=20
1.7.0.4
