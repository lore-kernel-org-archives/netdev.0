From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/2] [SCTP] Fix assertion (!atomic_read(&sk->sk_rmem_alloc)) failed message
Date: Tue, 10 Apr 2007 17:21:23 -0400
Message-ID: <11762400842444-git-send-email-vladislav.yasevich@hp.com>
References: <11762400848-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, Tsutomu Fujii <t-fujii@nb.jp.nec.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:43185 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753897AbXDJVVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 17:21:30 -0400
In-Reply-To: <11762400848-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tsutomu Fujii <t-fujii@nb.jp.nec.com>

In current implementation, LKSCTP does receive buffer accounting for
data in sctp_receive_queue and pd_lobby. However, LKSCTP don't do
accounting for data in frag_list when data is fragmented. In addition,
LKSCTP doesn't do accounting for data in reasm and lobby queue in
structure sctp_ulpq.
When there are date in these queue, assertion failed message is printed
in inet_sock_destruct because sk_rmem_alloc of oldsk does not become 0
when socket is destroyed.

Signed-off-by: Tsutomu Fujii <t-fujii@nb.jp.nec.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |   48 ++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 44 insertions(+), 4 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 536298c..523e73e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5638,6 +5638,36 @@ void sctp_wait_for_close(struct sock *sk, long timeout)
 	finish_wait(sk->sk_sleep, &wait);
 }
 
+static void sctp_sock_rfree_frag(struct sk_buff *skb)
+{
+	struct sk_buff *frag;
+
+	if (!skb->data_len)
+		goto done;
+
+	/* Don't forget the fragments. */
+	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next)
+		sctp_sock_rfree_frag(frag);
+
+done:
+	sctp_sock_rfree(skb);
+}
+
+static void sctp_skb_set_owner_r_frag(struct sk_buff *skb, struct sock *sk)
+{
+	struct sk_buff *frag;
+
+	if (!skb->data_len)
+		goto done;
+
+	/* Don't forget the fragments. */
+	for (frag = skb_shinfo(skb)->frag_list; frag; frag = frag->next)
+		sctp_skb_set_owner_r_frag(frag, sk);
+
+done:
+	sctp_skb_set_owner_r(skb, sk);
+}
+
 /* Populate the fields of the newsk from the oldsk and migrate the assoc
  * and its messages to the newsk.
  */
@@ -5692,10 +5722,10 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	sctp_skb_for_each(skb, &oldsk->sk_receive_queue, tmp) {
 		event = sctp_skb2event(skb);
 		if (event->asoc == assoc) {
-			sctp_sock_rfree(skb);
+			sctp_sock_rfree_frag(skb);
 			__skb_unlink(skb, &oldsk->sk_receive_queue);
 			__skb_queue_tail(&newsk->sk_receive_queue, skb);
-			sctp_skb_set_owner_r(skb, newsk);
+			sctp_skb_set_owner_r_frag(skb, newsk);
 		}
 	}
 
@@ -5723,10 +5753,10 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 		sctp_skb_for_each(skb, &oldsp->pd_lobby, tmp) {
 			event = sctp_skb2event(skb);
 			if (event->asoc == assoc) {
-				sctp_sock_rfree(skb);
+				sctp_sock_rfree_frag(skb);
 				__skb_unlink(skb, &oldsp->pd_lobby);
 				__skb_queue_tail(queue, skb);
-				sctp_skb_set_owner_r(skb, newsk);
+				sctp_skb_set_owner_r_frag(skb, newsk);
 			}
 		}
 
@@ -5738,6 +5768,16 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 
 	}
 
+	sctp_skb_for_each(skb, &assoc->ulpq.reasm, tmp) {
+		sctp_sock_rfree_frag(skb);
+		sctp_skb_set_owner_r_frag(skb, newsk);
+	}
+
+	sctp_skb_for_each(skb, &assoc->ulpq.lobby, tmp) {
+		sctp_sock_rfree_frag(skb);
+		sctp_skb_set_owner_r_frag(skb, newsk);
+	}
+
 	/* Set the type of socket to indicate that it is peeled off from the
 	 * original UDP-style socket or created with the accept() call on a
 	 * TCP-style socket..
-- 
1.5.0.3.438.gc49b2

