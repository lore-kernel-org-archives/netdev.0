From: frank.blaschka@de.ibm.com
Subject: [patch 05/10] [PATCH] af_iucv: get rid of state IUCV_SEVERED
Date: Tue, 20 Dec 2011 09:56:31 +0100
Message-ID: <20111220085736.014121083@de.ibm.com>
References: <20111220085626.924756639@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:48942 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658Ab1LTI6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 03:58:01 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 20 Dec 2011 08:57:58 -0000
Content-Disposition: inline; filename=605-af_iucv-rm-iucv-severed.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

af_iucv differs unnecessarily between state IUCV_SEVERED and
IUCV_DISCONN. This patch removes state IUCV_SEVERED.
While simplifying af_iucv, this patch removes the 2nd invocation of
cpcmd as well.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 include/net/iucv/af_iucv.h |    1 -
 net/iucv/af_iucv.c         |   35 ++++++++---------------------------
 2 files changed, 8 insertions(+), 28 deletions(-)

--- a/include/net/iucv/af_iucv.h
+++ b/include/net/iucv/af_iucv.h
@@ -27,7 +27,6 @@ enum {
 	IUCV_OPEN,
 	IUCV_BOUND,
 	IUCV_LISTEN,
-	IUCV_SEVERED,
 	IUCV_DISCONN,
 	IUCV_CLOSING,
 	IUCV_CLOSED
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -178,7 +178,6 @@ static int afiucv_pm_freeze(struct devic
 		iucv_skb_queue_purge(&iucv->send_skb_q);
 		skb_queue_purge(&iucv->backlog_skb_q);
 		switch (sk->sk_state) {
-		case IUCV_SEVERED:
 		case IUCV_DISCONN:
 		case IUCV_CLOSING:
 		case IUCV_CONNECTED:
@@ -223,7 +222,6 @@ static int afiucv_pm_restore_thaw(struct
 			sk->sk_state_change(sk);
 			break;
 		case IUCV_DISCONN:
-		case IUCV_SEVERED:
 		case IUCV_CLOSING:
 		case IUCV_LISTEN:
 		case IUCV_BOUND:
@@ -661,16 +659,12 @@ struct sock *iucv_accept_dequeue(struct
 		}
 
 		if (sk->sk_state == IUCV_CONNECTED ||
-		    sk->sk_state == IUCV_SEVERED ||
-		    sk->sk_state == IUCV_DISCONN ||	/* due to PM restore */
+		    sk->sk_state == IUCV_DISCONN ||
 		    !newsock) {
 			iucv_accept_unlink(sk);
 			if (newsock)
 				sock_graft(sk, newsock);
 
-			if (sk->sk_state == IUCV_SEVERED)
-				sk->sk_state = IUCV_DISCONN;
-
 			release_sock(sk);
 			return sk;
 		}
@@ -760,16 +754,13 @@ done:
 static int iucv_sock_autobind(struct sock *sk)
 {
 	struct iucv_sock *iucv = iucv_sk(sk);
-	char query_buffer[80];
 	char name[12];
 	int err = 0;
 
-	/* Set the userid and name */
-	cpcmd("QUERY USERID", query_buffer, sizeof(query_buffer), &err);
-	if (unlikely(err))
+	if (unlikely(!pr_iucv))
 		return -EPROTO;
 
-	memcpy(iucv->src_user_id, query_buffer, 8);
+	memcpy(iucv->src_user_id, iucv_userid, 8);
 
 	write_lock_bh(&iucv_sk_list.lock);
 
@@ -1345,7 +1336,7 @@ static int iucv_sock_recvmsg(struct kioc
 	int blen;
 	int err = 0;
 
-	if ((sk->sk_state == IUCV_DISCONN || sk->sk_state == IUCV_SEVERED) &&
+	if ((sk->sk_state == IUCV_DISCONN) &&
 	    skb_queue_empty(&iucv->backlog_skb_q) &&
 	    skb_queue_empty(&sk->sk_receive_queue) &&
 	    list_empty(&iucv->message_q.list))
@@ -1492,7 +1483,7 @@ unsigned int iucv_sock_poll(struct file
 	if (sk->sk_state == IUCV_CLOSED)
 		mask |= POLLHUP;
 
-	if (sk->sk_state == IUCV_DISCONN || sk->sk_state == IUCV_SEVERED)
+	if (sk->sk_state == IUCV_DISCONN)
 		mask |= POLLIN;
 
 	if (sock_writeable(sk))
@@ -1519,7 +1510,6 @@ static int iucv_sock_shutdown(struct soc
 	switch (sk->sk_state) {
 	case IUCV_DISCONN:
 	case IUCV_CLOSING:
-	case IUCV_SEVERED:
 	case IUCV_CLOSED:
 		err = -ENOTCONN;
 		goto fail;
@@ -1874,10 +1864,7 @@ static void iucv_callback_connrej(struct
 {
 	struct sock *sk = path->private;
 
-	if (!list_empty(&iucv_sk(sk)->accept_q))
-		sk->sk_state = IUCV_SEVERED;
-	else
-		sk->sk_state = IUCV_DISCONN;
+	sk->sk_state = IUCV_DISCONN;
 
 	sk->sk_state_change(sk);
 }
@@ -2037,10 +2024,7 @@ static int afiucv_hs_callback_fin(struct
 	/* other end of connection closed */
 	if (iucv) {
 		bh_lock_sock(sk);
-		if (!list_empty(&iucv->accept_q))
-			sk->sk_state = IUCV_SEVERED;
-		else
-			sk->sk_state = IUCV_DISCONN;
+		sk->sk_state = IUCV_DISCONN;
 		sk->sk_state_change(sk);
 		bh_unlock_sock(sk);
 	}
@@ -2269,10 +2253,7 @@ static void afiucv_hs_callback_txnotify(
 				__skb_unlink(this, list);
 				dev_put(this->dev);
 				kfree_skb(this);
-				if (!list_empty(&iucv->accept_q))
-					sk->sk_state = IUCV_SEVERED;
-				else
-					sk->sk_state = IUCV_DISCONN;
+				sk->sk_state = IUCV_DISCONN;
 				sk->sk_state_change(sk);
 				break;
 			}
