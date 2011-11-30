From: =?UTF-8?q?Sjur=20Br=81=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [RFC 1/3] caif: Add support for flow-control on device's tx-queue
Date: Wed, 30 Nov 2011 21:44:04 +0100
Message-ID: <1322685846-7790-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1322685846-7790-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Alexey Orishko <alexey.orishko@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52107 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab1K3Uoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 15:44:32 -0500
Received: by mail-ee0-f46.google.com with SMTP id u47so633125eeu.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 12:44:31 -0800 (PST)
In-Reply-To: <1322685846-7790-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

=46low control is implemented by inspecting the qdisc queue length
in order to detect potential overflow on the TX queue. When a threshold
is reached flow-off is sent upwards in the CAIF stack. At the same time
the skb->destructor is hi-jacked in order to detect when the last packe=
t
put on queue is consumed. When this "hi-jacked" packet is consumed, flo=
w-on
is sent upwards in the CAIF stack.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_dev.c |   48 +++++++++++++++++++++++++++++++++++++++++++=
+++++
 1 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index f7e8c70..415353e 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -34,6 +34,7 @@ struct caif_device_entry {
 	struct list_head list;
 	struct net_device *netdev;
 	int __percpu *pcpu_refcnt;
+	bool xoff;
 };
=20
 struct caif_device_entry_list {
@@ -48,6 +49,7 @@ struct caif_net {
 };
=20
 static int caif_net_id;
+static int q_high =3D 50; /* Percent */
=20
 struct cfcnfg *get_cfcnfg(struct net *net)
 {
@@ -126,9 +128,28 @@ static struct caif_device_entry *caif_get(struct n=
et_device *dev)
 	return NULL;
 }
=20
+void caif_flow_cb(struct sk_buff *skb)
+{
+	struct caif_device_entry *caifd;
+	WARN_ON(skb->dev =3D=3D NULL);
+
+	rcu_read_lock();
+	caifd =3D caif_get(skb->dev);
+	caifd->xoff =3D 0;
+	caifd_hold(caifd);
+	rcu_read_unlock();
+
+	caifd->layer.up->
+		ctrlcmd(caifd->layer.up,
+			_CAIF_CTRLCMD_PHYIF_FLOW_ON_IND,
+			caifd->layer.id);
+	caifd_put(caifd);
+}
+
 static int transmit(struct cflayer *layer, struct cfpkt *pkt)
 {
 	int err;
+	struct caif_dev_common *caifdev;
 	struct caif_device_entry *caifd =3D
 	    container_of(layer, struct caif_device_entry, layer);
 	struct sk_buff *skb;
@@ -137,6 +158,33 @@ static int transmit(struct cflayer *layer, struct =
cfpkt *pkt)
 	skb->dev =3D caifd->netdev;
 	skb_reset_network_header(skb);
 	skb->protocol =3D htons(ETH_P_CAIF);
+	caifdev =3D netdev_priv(caifd->netdev);
+
+	if (caifdev->flowctrl =3D=3D NULL && caifd->netdev->tx_queue_len > 0 =
&&
+			!caifd->xoff) {
+		struct netdev_queue *txq;
+		int high;
+
+		txq =3D netdev_get_tx_queue(skb->dev, 0);
+		high =3D (caifd->netdev->tx_queue_len * q_high) / 100;
+
+		/* If we run with a TX queue, check if the queue is too long*/
+		if (netif_queue_stopped(caifd->netdev) ||
+			qdisc_qlen(txq->qdisc) > high) {
+
+			pr_debug("queue stop(%d) or full (%d>%d) - XOFF\n",
+					netif_queue_stopped(caifd->netdev),
+					qdisc_qlen(txq->qdisc), high);
+			caifd->xoff =3D 1;
+			/* Hijack this skb free callback function. */
+			skb_orphan(skb);
+			skb->destructor =3D caif_flow_cb;
+			caifd->layer.up->
+				ctrlcmd(caifd->layer.up,
+					_CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND,
+					caifd->layer.id);
+		}
+	}
=20
 	err =3D dev_queue_xmit(skb);
 	if (err > 0)
--=20
1.7.0.4
