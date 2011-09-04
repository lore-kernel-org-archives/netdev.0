From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Sun, 04 Sep 2011 13:44:18 +0800
Message-ID: <4E631032.6050606@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60600 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659Ab1IDFoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Sep 2011 01:44:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0856a30409 (Scm: Remove unnecessary pid & credential references
in Unix socket's send and receive path) introduced a use-after-free bug.
It passes the scm reference to the first skb. Skb(s) afterwards may
reference freed data structure because the first skb can be destructed
by the receiver at anytime. The fix is by passing the scm reference to
the very last skb.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
Reported-by: Jiri Slaby <jirislaby@gmail.com>
---
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e6d9d10..77ec8e8 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1577,6 +1577,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	int sent = 0;
 	struct scm_cookie tmp_scm;
 	bool fds_sent = false;
+	bool scm_ref = true;
 	int max_level;
 
 	if (NULL == siocb->scm)
@@ -1637,12 +1638,15 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		 */
 		size = min_t(int, size, skb_tailroom(skb));
 
+		/* pass the scm reference to the very last skb */
+		if (sent + size >= len)
+			scm_ref = false;
 
-		/* Only send the fds and no ref to pid in the first buffer */
-		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);
+		/* Only send the fds in the first buffer */
+		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, scm_ref);
 		if (err < 0) {
 			kfree_skb(skb);
-			goto out;
+			goto out_err;
 		}
 		max_level = err + 1;
 		fds_sent = true;
@@ -1650,7 +1654,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 		if (err) {
 			kfree_skb(skb);
-			goto out;
+			goto out_err;
 		}
 
 		unix_state_lock(other);
@@ -1667,10 +1671,10 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
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
@@ -1683,9 +1687,10 @@ pipe_err:
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
