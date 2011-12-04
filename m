From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCHv2 net-next 4/4] caif: Stash away hijacked skb destructor and call it later
Date: Sun,  4 Dec 2011 11:10:50 +0100
Message-ID: <1322993450-8802-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1322993450-8802-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@stericsson.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63713 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492Ab1LDKLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 05:11:16 -0500
Received: by mail-ey0-f174.google.com with SMTP id k14so3546710eaa.19
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2011 02:11:15 -0800 (PST)
In-Reply-To: <1322993450-8802-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds functionality for avoiding orphaning SKB too early.
The original skb is stashed away and the original destructor is called
from the hi-jacked flow-on callback. If CAIF interface goes down and a
hi-jacked SKB exists, the original skb->destructor is restored.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
This functionality is added after V1 of this patchset.

 net/caif/caif_dev.c |   34 +++++++++++++++++++++++++++++++++-
 1 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 1980404..a82d89f 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -37,6 +37,8 @@ struct caif_device_entry {
 	struct net_device *netdev;
 	int __percpu *pcpu_refcnt;
 	spinlock_t flow_lock;
+	struct sk_buff *xoff_skb;
+	void (*xoff_skb_dtor)(struct sk_buff *skb);
 	bool xoff;
 };
=20
@@ -134,6 +136,7 @@ static struct caif_device_entry *caif_get(struct ne=
t_device *dev)
 void caif_flow_cb(struct sk_buff *skb)
 {
 	struct caif_device_entry *caifd;
+	void (*dtor)(struct sk_buff *skb) =3D NULL;
 	bool send_xoff;
=20
 	WARN_ON(skb->dev =3D=3D NULL);
@@ -146,8 +149,17 @@ void caif_flow_cb(struct sk_buff *skb)
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
@@ -211,8 +223,10 @@ static int transmit(struct cflayer *layer, struct =
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
