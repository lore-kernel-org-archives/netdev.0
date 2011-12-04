From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCHv3 net-next 4/4] caif: Stash away hijacked skb destructor and call it later
Date: Sun,  4 Dec 2011 22:22:55 +0100
Message-ID: <1323033775-3496-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1323033775-3496-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@stericsson.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64245 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262Ab1LDVXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 16:23:31 -0500
Received: by mail-ee0-f46.google.com with SMTP id q14so1589448eea.19
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2011 13:23:31 -0800 (PST)
In-Reply-To: <1323033775-3496-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds functionality for avoiding orphaning SKB too early.
The original skb is stashed away and the original destructor is called
from the hi-jacked flow-on callback. If CAIF interface goes down and a
hi-jacked SKB exists, the original skb->destructor is restored.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_dev.c |   34 +++++++++++++++++++++++++++++++++-
 1 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 74c1273..9b298c1 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -36,6 +36,8 @@ struct caif_device_entry {
 	struct net_device *netdev;
 	int __percpu *pcpu_refcnt;
 	spinlock_t flow_lock;
+	struct sk_buff *xoff_skb;
+	void (*xoff_skb_dtor)(struct sk_buff *skb);
 	bool xoff;
 };
=20
@@ -133,6 +135,7 @@ static struct caif_device_entry *caif_get(struct ne=
t_device *dev)
 void caif_flow_cb(struct sk_buff *skb)
 {
 	struct caif_device_entry *caifd;
+	void (*dtor)(struct sk_buff *skb) =3D NULL;
 	bool send_xoff;
=20
 	WARN_ON(skb->dev =3D=3D NULL);
@@ -145,8 +148,17 @@ void caif_flow_cb(struct sk_buff *skb)
 	spin_lock_bh(&caifd->flow_lock);
 	send_xoff =3D caifd->xoff;
 	caifd->xoff =3D 0;
+	if (!WARN_ON(caifd->xoff_skb_dtor =3D=3D NULL)) {
+		WARN_ON(caifd->xoff_skb !=3D skb);
+		dtor =3D caifd->xoff_skb_dtor;
+		caifd->xoff_skb =3D NULL;
+		caifd->xoff_skb_dtor =3D NULL;
+	}
 	spin_unlock_bh(&caifd->flow_lock);
=20
+	if (dtor)
+		dtor(skb);
+
 	if (send_xoff)
 		caifd->layer.up->
 			ctrlcmd(caifd->layer.up,
@@ -210,8 +222,10 @@ static int transmit(struct cflayer *layer, struct =
cfpkt *pkt)
 			netif_queue_stopped(caifd->netdev),
 			qlen, high);
 	caifd->xoff =3D 1;
+	caifd->xoff_skb =3D skb;
+	caifd->xoff_skb_dtor =3D skb->destructor;
+	skb->destructor =3D caif_flow_cb;
 	spin_unlock_bh(&caifd->flow_lock);
-	skb_orphan(skb);
=20
 	caifd->layer.up->ctrlcmd(caifd->layer.up,
 					_CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND,
@@ -420,6 +434,24 @@ static int caif_device_notify(struct notifier_bloc=
k *me, unsigned long what,
 		caifd->layer.up->ctrlcmd(caifd->layer.up,
 					 _CAIF_CTRLCMD_PHYIF_DOWN_IND,
 					 caifd->layer.id);
+
+		spin_lock_bh(&caifd->flow_lock);
+
+		/*
+		 * Replace our xoff-destructor with original destructor.
+		 * We trust that skb->destructor *always* is called before
+		 * the skb reference is invalid. The hijacked SKB destructor
+		 * takes the flow_lock so manipulating the skb->destructor here
+		 * should be safe.
+		*/
+		if (caifd->xoff_skb_dtor !=3D NULL && caifd->xoff_skb !=3D NULL)
+			caifd->xoff_skb->destructor =3D caifd->xoff_skb_dtor;
+
+		caifd->xoff =3D 0;
+		caifd->xoff_skb_dtor =3D NULL;
+		caifd->xoff_skb =3D NULL;
+
+		spin_unlock_bh(&caifd->flow_lock);
 		caifd_put(caifd);
 		break;
=20
--=20
1.7.0.4
