From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [Patch] Scm: Remove unnecessary pid & credential references in
 Unix socket's send and receive path
Date: Mon, 22 Aug 2011 17:57:26 -0700
Message-ID: <1314061046.2576.2922.camel@schen9-DESK>
References: <1313625374.2576.2908.camel@schen9-DESK>
	 <20110818.220432.1711182086933489213.davem@davemloft.net>
	 <1313772298.2576.2916.camel@schen9-DESK>
	 <20110822.174013.353730308624819543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, viro@zeniv.linux.org.uk,
	ebiederm@xmission.com, ak@linux.intel.com,
	matt.fleming@linux.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13443 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754605Ab1HWA4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Aug 2011 20:56:55 -0400
In-Reply-To: <20110822.174013.353730308624819543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-08-22 at 17:40 -0700, David Miller wrote:
> From: Tim Chen <tim.c.chen@linux.intel.com>
> Date: Fri, 19 Aug 2011 09:44:58 -0700
> 
> > -		/* Only send the fds in the first buffer */
> > -		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent);
> > +		/* Only send the fds and no ref to pid in the first buffer */
> > +		if (fds_sent)
> > +			err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, true);
> > +		else
> > +			err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, false);
> 
> Just set this final boolean the way the third argument is, there is no
> reason to replicate the entire function call twice just to set the
> final argument to what "fds_sent" evaluates to as a boolean.
> 
> 		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);
> 
> ought to suffice.

Good point.  Patch updated as suggested.

Tim

-----------

Patch series 109f6e39..7361c36c back in 2.6.36 added functionality to
allow credentials to work across pid namespaces for packets sent via
UNIX sockets.  However, the atomic reference counts on pid and
credentials caused plenty of cache bouncing when there are numerous
threads of the same pid sharing a UNIX socket.  This patch mitigates the
problem by eliminating extraneous reference counts on pid and
credentials on both send and receive path of UNIX sockets. I found a 2x
improvement in hackbench's threaded case.

On the receive path in unix_dgram_recvmsg, currently there is an
increment of reference count on pid and credentials in scm_set_cred.
Then there are two decrement of the reference counts.  Once in scm_recv
and once when skb_free_datagram call skb->destructor function
unix_destruct_scm.  One pair of increment and decrement of ref count on
pid and credentials can be eliminated from the receive path.  Until we
destroy the skb, we already set a reference when we created the skb on
the send side.

On the send path, there are two increments of ref count on pid and
credentials, once in scm_send and once in unix_scm_to_skb.  Then there
is a decrement of the reference counts in scm_destroy's call to
scm_destroy_cred at the end of unix_dgram_sendmsg functions.   One pair
of increment and decrement of the reference counts can be removed so we
only need to increment the ref counts once.

By incorporating these changes, for hackbench running on a 4 socket
NHM-EX machine with 40 cores, the execution of hackbench on
50 groups of 20 threads sped up by factor of 2.

Hackbench command used for testing:
./hackbench 50 thread 2000

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
diff --git a/include/net/scm.h b/include/net/scm.h
index 745460f..68e1e48 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -53,6 +53,14 @@ static __inline__ void scm_set_cred(struct scm_cookie *scm,
 	cred_to_ucred(pid, cred, &scm->creds);
 }
 
+static __inline__ void scm_set_cred_noref(struct scm_cookie *scm,
+				    struct pid *pid, const struct cred *cred)
+{
+	scm->pid  = pid;
+	scm->cred = cred;
+	cred_to_ucred(pid, cred, &scm->creds);
+}
+
 static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
 {
 	put_pid(scm->pid);
@@ -70,6 +78,15 @@ static __inline__ void scm_destroy(struct scm_cookie *scm)
 		__scm_destroy(scm);
 }
 
+static __inline__ void scm_release(struct scm_cookie *scm)
+{
+	/* keep ref on pid and cred */
+	scm->pid = NULL;
+	scm->cred = NULL;
+	if (scm->fp)
+		__scm_destroy(scm);
+}
+
 static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
 			       struct scm_cookie *scm)
 {
@@ -108,15 +125,14 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 	if (!msg->msg_control) {
 		if (test_bit(SOCK_PASSCRED, &sock->flags) || scm->fp)
 			msg->msg_flags |= MSG_CTRUNC;
-		scm_destroy(scm);
+		if (scm && scm->fp)
+			__scm_destroy(scm);
 		return;
 	}
 
 	if (test_bit(SOCK_PASSCRED, &sock->flags))
 		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(scm->creds), &scm->creds);
 
-	scm_destroy_cred(scm);
-
 	scm_passec(sock, msg, scm);
 
 	if (!scm->fp)
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 0722a25..136298c 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1382,11 +1382,17 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 	return max_level;
 }
 
-static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool send_fds)
+static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb,
+			   bool send_fds, bool ref)
 {
 	int err = 0;
-	UNIXCB(skb).pid  = get_pid(scm->pid);
-	UNIXCB(skb).cred = get_cred(scm->cred);
+	if (ref) {
+		UNIXCB(skb).pid  = get_pid(scm->pid);
+		UNIXCB(skb).cred = get_cred(scm->cred);
+	} else {
+		UNIXCB(skb).pid  = scm->pid;
+		UNIXCB(skb).cred = scm->cred;
+	}
 	UNIXCB(skb).fp = NULL;
 	if (scm->fp && send_fds)
 		err = unix_attach_fds(scm, skb);
@@ -1411,7 +1417,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	int namelen = 0; /* fake GCC */
 	int err;
 	unsigned hash;
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	long timeo;
 	struct scm_cookie tmp_scm;
 	int max_level;
@@ -1452,7 +1458,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (skb == NULL)
 		goto out;
 
-	err = unix_scm_to_skb(siocb->scm, skb, true);
+	err = unix_scm_to_skb(siocb->scm, skb, true, false);
 	if (err < 0)
 		goto out_free;
 	max_level = err + 1;
@@ -1548,7 +1554,7 @@ restart:
 	unix_state_unlock(other);
 	other->sk_data_ready(other, len);
 	sock_put(other);
-	scm_destroy(siocb->scm);
+	scm_release(siocb->scm);
 	return len;
 
 out_unlock:
@@ -1558,7 +1564,8 @@ out_free:
 out:
 	if (other)
 		sock_put(other);
-	scm_destroy(siocb->scm);
+	if (skb == NULL)
+		scm_destroy(siocb->scm);
 	return err;
 }
 
@@ -1570,7 +1577,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct sock *other = NULL;
 	int err, size;
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	int sent = 0;
 	struct scm_cookie tmp_scm;
 	bool fds_sent = false;
@@ -1635,11 +1642,11 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		size = min_t(int, size, skb_tailroom(skb));
 
 
-		/* Only send the fds in the first buffer */
-		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent);
+		/* Only send the fds and no ref to pid in the first buffer */
+		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);
 		if (err < 0) {
 			kfree_skb(skb);
-			goto out_err;
+			goto out;
 		}
 		max_level = err + 1;
 		fds_sent = true;
@@ -1647,7 +1654,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 		if (err) {
 			kfree_skb(skb);
-			goto out_err;
+			goto out;
 		}
 
 		unix_state_lock(other);
@@ -1664,7 +1671,10 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		sent += size;
 	}
 
-	scm_destroy(siocb->scm);
+	if (skb)
+		scm_release(siocb->scm);
+	else
+		scm_destroy(siocb->scm);
 	siocb->scm = NULL;
 
 	return sent;
@@ -1677,7 +1687,9 @@ pipe_err:
 		send_sig(SIGPIPE, current, 0);
 	err = -EPIPE;
 out_err:
-	scm_destroy(siocb->scm);
+	if (skb == NULL)
+		scm_destroy(siocb->scm);
+out:
 	siocb->scm = NULL;
 	return sent ? : err;
 }
@@ -1781,7 +1793,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 		siocb->scm = &tmp_scm;
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
-	scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
+	scm_set_cred_noref(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
 	unix_set_secdata(siocb->scm, skb);
 
 	if (!(flags & MSG_PEEK)) {
@@ -1943,7 +1955,8 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			}
 		} else {
 			/* Copy credentials */
-			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
+			scm_set_cred_noref(siocb->scm, UNIXCB(skb).pid,
+					   UNIXCB(skb).cred);
 			check_creds = 1;
 		}
 


