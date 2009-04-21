From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 13/13] [PATCH] af_iucv: Fix race when queuing incoming iucv messages
Date: Tue, 21 Apr 2009 12:35:10 +0200
Message-ID: <20090421103706.782136000@linux.vnet.ibm.com>
References: <20090421103457.965299000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:45233 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754561AbZDUKhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:37:08 -0400
Content-Disposition: inline; filename=613-af_iucv-incoming-race.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

AF_IUCV runs into a race when queuing incoming iucv messages
and receiving the resulting backlog.

If the Linux system is under pressure (high load or steal time),
the message queue grows up, but messages are not received and queued
onto the backlog queue. In that case, applications do not
receive any data with recvmsg() even if AF_IUCV puts incoming
messages onto the message queue.

The race can be avoided if the message queue spinlock in the
message_pending callback is spreaded across the entire callback
function.

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

Index: net-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6-uschi/net/iucv/af_iucv.c
@@ -1409,6 +1409,8 @@ static void iucv_callback_rx(struct iucv
 		return;
 	}
 
+	spin_lock(&iucv->message_q.lock);
+
 	if (!list_empty(&iucv->message_q.list) ||
 	    !skb_queue_empty(&iucv->backlog_skb_q))
 		goto save_message;
@@ -1422,9 +1424,8 @@ static void iucv_callback_rx(struct iucv
 	if (!skb)
 		goto save_message;
 
-	spin_lock(&iucv->message_q.lock);
 	iucv_process_message(sk, skb, path, msg);
-	spin_unlock(&iucv->message_q.lock);
+	goto out_unlock;
 
 	return;
 
@@ -1435,8 +1436,9 @@ save_message:
 	save_msg->path = path;
 	save_msg->msg = *msg;
 
-	spin_lock(&iucv->message_q.lock);
 	list_add_tail(&save_msg->list, &iucv->message_q.list);
+
+out_unlock:
 	spin_unlock(&iucv->message_q.lock);
 }
 

