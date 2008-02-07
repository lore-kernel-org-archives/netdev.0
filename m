From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 2/3] af_iucv: broken send_skb_q results in endless loop
Date: Thu, 07 Feb 2008 15:28:44 +0100
Message-ID: <20080207143534.085581000@linux.vnet.ibm.com>
References: <20080207142842.852003000@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:3439 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759984AbYBGOfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 09:35:38 -0500
Content-Disposition: inline; filename=713-afiucv.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

A race has been detected in iucv_callback_txdone().
skb_unlink has to be done inside the locked area.

In addition checkings for successful allocations are inserted.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 net/iucv/af_iucv.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff -urpN linux-2.6/net/iucv/af_iucv.c linux-2.6-patched/net/iucv/af_iucv.c
--- linux-2.6/net/iucv/af_iucv.c	2008-02-07 13:24:12.000000000 +0100
+++ linux-2.6-patched/net/iucv/af_iucv.c	2008-02-07 13:24:38.000000000 +0100
@@ -482,6 +482,10 @@ static int iucv_sock_connect(struct sock
 	/* Create path. */
 	iucv->path = iucv_path_alloc(IUCV_QUEUELEN_DEFAULT,
 				     IPRMDATA, GFP_KERNEL);
+	if (!iucv->path) {
+		err = -ENOMEM;
+		goto done;
+	}
 	err = iucv_path_connect(iucv->path, &af_iucv_handler,
 				sa->siucv_user_id, NULL, user_data, sk);
 	if (err) {
@@ -1094,6 +1098,8 @@ static void iucv_callback_rx(struct iucv
 
 save_message:
 	save_msg = kzalloc(sizeof(struct sock_msg_q), GFP_ATOMIC | GFP_DMA);
+	if (!save_msg)
+		return;
 	save_msg->path = path;
 	save_msg->msg = *msg;
 
@@ -1118,10 +1124,10 @@ static void iucv_callback_txdone(struct 
 			this = list_skb;
 			list_skb = list_skb->next;
 		} while (memcmp(&msg->tag, this->cb, 4) && list_skb);
+		__skb_unlink(this, list);
 
 		spin_unlock_irqrestore(&list->lock, flags);
 
-		skb_unlink(this, &iucv_sk(sk)->send_skb_q);
 		kfree_skb(this);
 	}
 

-- 
