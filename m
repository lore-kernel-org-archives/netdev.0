From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 5/5] [PATCH] af_iucv: Fix race when queuing incoming iucv messages
Date: Tue, 21 Apr 2009 18:04:24 +0200
Message-ID: <20090421161444.842034000@linux.vnet.ibm.com>
References: <20090421160419.971500000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:38885 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275AbZDUQOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 12:14:47 -0400
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
@@ -1124,6 +1124,8 @@ static void iucv_callback_rx(struct iucv
 		return;
 	}
 
+	spin_lock(&iucv->message_q.lock);
+
 	if (!list_empty(&iucv->message_q.list) ||
 	    !skb_queue_empty(&iucv->backlog_skb_q))
 		goto save_message;
@@ -1137,9 +1139,8 @@ static void iucv_callback_rx(struct iucv
 	if (!skb)
 		goto save_message;
 
-	spin_lock(&iucv->message_q.lock);
 	iucv_process_message(sk, skb, path, msg);
-	spin_unlock(&iucv->message_q.lock);
+	goto out_unlock;
 
 	return;
 
@@ -1150,8 +1151,9 @@ save_message:
 	save_msg->path = path;
 	save_msg->msg = *msg;
 
-	spin_lock(&iucv->message_q.lock);
 	list_add_tail(&save_msg->list, &iucv->message_q.list);
+
+out_unlock:
 	spin_unlock(&iucv->message_q.lock);
 }
 

