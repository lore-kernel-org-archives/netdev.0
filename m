From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH -next] unix stream: Fix use-after-free crashes
Date: Sun, 04 Sep 2011 00:25:07 +0800
Message-ID: <4E6254E3.40402@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sfr@canb.auug.org.au,
	tim.c.chen@linux.intel.com, jirislaby@gmail.com,
	sedat.dilek@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47995 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244Ab1ICQZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Sep 2011 12:25:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0856a30409 (Scm: Remove unnecessary pid & credential references
in Unix socket's send and receive path) introduced a use-after-free bug.
It happens that if skb is consumed and destructed by the receive side
before unix_stream_sendmsg finishes its job.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
Reported-by: Jiri Slaby <jirislaby@gmail.com>
Tested-by: Sedat Dilek <sedat.dilek@googlemail.com>

---
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e6d9d10..70cf1f9 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1577,6 +1577,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	int sent = 0;
 	struct scm_cookie tmp_scm;
 	bool fds_sent = false;
+	bool scm_ref = true;
 	int max_level;
 
 	if (NULL == siocb->scm)
@@ -1637,12 +1638,21 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		 */
 		size = min_t(int, size, skb_tailroom(skb));
 
+		/*
+		 * If a single skb is large enough to hold all data, pass the
+		 * scm reference to the skb. Otherwise we should hold a scm
+		 * reference because the skb can be consumed at any time after
+		 * we queue it into sk_receive_queue.
+		 */
+		if (!fds_sent && sent + size >= len)
+			scm_ref = false;
 
-		/* Only send the fds and no ref to pid in the first buffer */
-		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);
+		/* Only send the fds in the first buffer */
+		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent,
+					fds_sent || scm_ref);
 		if (err < 0) {
 			kfree_skb(skb);
-			goto out;
+			goto out_err;
 		}
 		max_level = err + 1;
 		fds_sent = true;
@@ -1650,7 +1660,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 		if (err) {
 			kfree_skb(skb);
-			goto out;
+			goto out_err;
 		}
 
 		unix_state_lock(other);
@@ -1667,10 +1677,10 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		sent += size;
 	}
 
-	if (skb)
-		scm_release(siocb->scm);
-	else
+	if (scm_ref)
 		scm_destroy(siocb->scm);
+	else
+		scm_release(siocb->scm);
 	siocb->scm = NULL;
 
 	return sent;
@@ -1683,9 +1693,10 @@ pipe_err:
 		send_sig(SIGPIPE, current, 0);
 	err = -EPIPE;
 out_err:
-	if (skb == NULL)
+	if (scm_ref)
 		scm_destroy(siocb->scm);
-out:
+	else
+		scm_release(siocb->scm);
 	siocb->scm = NULL;
 	return sent ? : err;
 }
