From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] Fix NULL pointer dereference and lockup.
Date: Mon, 26 May 2008 09:23:45 +0100
Message-ID: <20080526082345.GA27219@linux-mips.org>
References: <001a01c87692$cfca8d00$453c822c@dg8ngn> <20080224195101.GA2961@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Jann Traschewski <jann@gmx.de>,
	Thomas Osterried <thomas@osterried.de>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vigor.karmaclothing.net ([217.169.26.28]:36875 "EHLO
	vigor.karmaclothing.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbYEZIYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 04:24:05 -0400
Content-Disposition: inline
In-Reply-To: <20080224195101.GA2961@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>

There is only one function in AX25 calling skb_append(), and it really
looks suspicious: appends skb after previously enqueued one, but in
the meantime this previous skb could be removed from the queue.

This patch Fixes it the simple way, so this is not fully compatible with
the current method, but testing hasn't shown any problems.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
I'm told Jarek is currently not reachable, so I'm submitting this for 2.6.26
and -stable.

diff --git a/net/ax25/ax25_subr.c b/net/ax25/ax25_subr.c
index d8f2157..034aa10 100644
--- a/net/ax25/ax25_subr.c
+++ b/net/ax25/ax25_subr.c
@@ -64,20 +64,15 @@ void ax25_frames_acked(ax25_cb *ax25, unsigned short nr)
 
 void ax25_requeue_frames(ax25_cb *ax25)
 {
-	struct sk_buff *skb, *skb_prev = NULL;
+	struct sk_buff *skb;
 
 	/*
 	 * Requeue all the un-ack-ed frames on the output queue to be picked
 	 * up by ax25_kick called from the timer. This arrangement handles the
 	 * possibility of an empty output queue.
 	 */
-	while ((skb = skb_dequeue(&ax25->ack_queue)) != NULL) {
-		if (skb_prev == NULL)
-			skb_queue_head(&ax25->write_queue, skb);
-		else
-			skb_append(skb_prev, skb, &ax25->write_queue);
-		skb_prev = skb;
-	}
+	while ((skb = skb_dequeue_tail(&ax25->ack_queue)) != NULL)
+		skb_queue_head(&ax25->write_queue, skb);
 }
 
 /*
