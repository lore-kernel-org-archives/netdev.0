From: frank.blaschka@de.ibm.com
Subject: [patch 1/6] [PATCH] af_iucv: remove IUCV-pathes completely
Date: Wed, 08 Feb 2012 11:19:45 +0100
Message-ID: <20120208102029.117792481@de.ibm.com>
References: <20120208101944.272235343@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:39904 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756345Ab2BHKUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 05:20:41 -0500
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 8 Feb 2012 10:20:35 -0000
Content-Disposition: inline; filename=601-af_iucv-remove-path.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

A SEVER is missing in the callback of a receiving SEVERED. This may
inhibit z/VM to remove the corresponding IUCV-path completely.
This patch adds a SEVER in iucv_callback_connrej (together with
additional locking.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 net/iucv/af_iucv.c |   71 +++++++++++++++++++++++++++--------------------------
 1 file changed, 37 insertions(+), 34 deletions(-)

--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -90,6 +90,7 @@ do {									\
 
 static void iucv_sock_kill(struct sock *sk);
 static void iucv_sock_close(struct sock *sk);
+static void iucv_sever_path(struct sock *, int);
 
 static int afiucv_hs_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct packet_type *pt, struct net_device *orig_dev);
@@ -181,11 +182,7 @@ static int afiucv_pm_freeze(struct devic
 		case IUCV_DISCONN:
 		case IUCV_CLOSING:
 		case IUCV_CONNECTED:
-			if (iucv->path) {
-				err = pr_iucv->path_sever(iucv->path, NULL);
-				iucv_path_free(iucv->path);
-				iucv->path = NULL;
-			}
+			iucv_sever_path(sk, 0);
 			break;
 		case IUCV_OPEN:
 		case IUCV_BOUND:
@@ -194,6 +191,8 @@ static int afiucv_pm_freeze(struct devic
 		default:
 			break;
 		}
+		skb_queue_purge(&iucv->send_skb_q);
+		skb_queue_purge(&iucv->backlog_skb_q);
 	}
 	read_unlock(&iucv_sk_list.lock);
 	return err;
@@ -447,10 +446,29 @@ static void iucv_sock_kill(struct sock *
 	sock_put(sk);
 }
 
+/* Terminate an IUCV path */
+static void iucv_sever_path(struct sock *sk, int with_user_data)
+{
+	unsigned char user_data[16];
+	struct iucv_sock *iucv = iucv_sk(sk);
+	struct iucv_path *path = iucv->path;
+
+	if (iucv->path) {
+		iucv->path = NULL;
+		if (with_user_data) {
+			low_nmcpy(user_data, iucv->src_name);
+			high_nmcpy(user_data, iucv->dst_name);
+			ASCEBC(user_data, sizeof(user_data));
+			pr_iucv->path_sever(path, user_data);
+		} else
+			pr_iucv->path_sever(path, NULL);
+		iucv_path_free(path);
+	}
+}
+
 /* Close an IUCV socket */
 static void iucv_sock_close(struct sock *sk)
 {
-	unsigned char user_data[16];
 	struct iucv_sock *iucv = iucv_sk(sk);
 	unsigned long timeo;
 	int err, blen;
@@ -494,25 +512,14 @@ static void iucv_sock_close(struct sock
 		sk->sk_state = IUCV_CLOSED;
 		sk->sk_state_change(sk);
 
-		if (iucv->path) {
-			low_nmcpy(user_data, iucv->src_name);
-			high_nmcpy(user_data, iucv->dst_name);
-			ASCEBC(user_data, sizeof(user_data));
-			pr_iucv->path_sever(iucv->path, user_data);
-			iucv_path_free(iucv->path);
-			iucv->path = NULL;
-		}
-
 		sk->sk_err = ECONNRESET;
 		sk->sk_state_change(sk);
 
 		iucv_skb_queue_purge(&iucv->send_skb_q);
 		skb_queue_purge(&iucv->backlog_skb_q);
-		break;
 
-	default:
-		/* nothing to do here */
-		break;
+	default:   /* fall through */
+		iucv_sever_path(sk, 1);
 	}
 
 	/* mark socket for deletion by iucv_sock_kill() */
@@ -894,11 +901,8 @@ static int iucv_sock_connect(struct sock
 	if (sk->sk_state == IUCV_DISCONN || sk->sk_state == IUCV_CLOSED)
 		err = -ECONNREFUSED;
 
-	if (err && iucv->transport == AF_IUCV_TRANS_IUCV) {
-		pr_iucv->path_sever(iucv->path, NULL);
-		iucv_path_free(iucv->path);
-		iucv->path = NULL;
-	}
+	if (err && iucv->transport == AF_IUCV_TRANS_IUCV)
+		iucv_sever_path(sk, 0);
 
 done:
 	release_sock(sk);
@@ -1565,13 +1569,6 @@ static int iucv_sock_release(struct sock
 
 	iucv_sock_close(sk);
 
-	/* Unregister with IUCV base support */
-	if (iucv_sk(sk)->path) {
-		pr_iucv->path_sever(iucv_sk(sk)->path, NULL);
-		iucv_path_free(iucv_sk(sk)->path);
-		iucv_sk(sk)->path = NULL;
-	}
-
 	sock_orphan(sk);
 	iucv_sock_kill(sk);
 	return err;
@@ -1750,8 +1747,7 @@ static int iucv_callback_connreq(struct
 	path->msglim = iucv->msglimit;
 	err = pr_iucv->path_accept(path, &af_iucv_handler, nuser_data, nsk);
 	if (err) {
-		err = pr_iucv->path_sever(path, user_data);
-		iucv_path_free(path);
+		iucv_sever_path(nsk, 1);
 		iucv_sock_kill(nsk);
 		goto fail;
 	}
@@ -1828,6 +1824,7 @@ static void iucv_callback_txdone(struct
 	struct sk_buff *list_skb = list->next;
 	unsigned long flags;
 
+	bh_lock_sock(sk);
 	if (!skb_queue_empty(list)) {
 		spin_lock_irqsave(&list->lock, flags);
 
@@ -1849,7 +1846,6 @@ static void iucv_callback_txdone(struct
 			iucv_sock_wake_msglim(sk);
 		}
 	}
-	BUG_ON(!this);
 
 	if (sk->sk_state == IUCV_CLOSING) {
 		if (skb_queue_empty(&iucv_sk(sk)->send_skb_q)) {
@@ -1857,6 +1853,7 @@ static void iucv_callback_txdone(struct
 			sk->sk_state_change(sk);
 		}
 	}
+	bh_unlock_sock(sk);
 
 }
 
@@ -1864,9 +1861,15 @@ static void iucv_callback_connrej(struct
 {
 	struct sock *sk = path->private;
 
+	if (sk->sk_state == IUCV_CLOSED)
+		return;
+
+	bh_lock_sock(sk);
+	iucv_sever_path(sk, 1);
 	sk->sk_state = IUCV_DISCONN;
 
 	sk->sk_state_change(sk);
+	bh_unlock_sock(sk);
 }
 
 /* called if the other communication side shuts down its RECV direction;
