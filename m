From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [next] unix stream crashes
Date: Fri, 02 Sep 2011 16:55:03 -0700
Message-ID: <1315007703.2576.2965.camel@schen9-DESK>
References: <4E5FEF28.60406@gmail.com>
	 <3179.1314924559@turing-police.cc.vt.edu>
	 <1314927645.2576.2939.camel@schen9-DESK>
	 <6805.1314979936@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-R8z0zoj60uOyb+ALM1/W"
Cc: Jiri Slaby <jirislaby@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Sedat Dilek <sedat.dilek@googlemail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8656 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751176Ab1IBXxX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 19:53:23 -0400
In-Reply-To: <6805.1314979936@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-R8z0zoj60uOyb+ALM1/W
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Fri, 2011-09-02 at 12:12 -0400, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 01 Sep 2011 18:40:45 PDT, Tim Chen said:
> 
> > Yes, Jiri's log does indicate that something went wrong when releasing
> > the skb, most likely due to changes in the pid and credentials ref
> > count.  Unfortunately, I cannot duplicate the problem on my system.  Any
> > info on your system to help me debug will be appreciated.  I'll try to
> > take another look at the patch tomorrow.
> 
> Dell Latitude E6500, Core2 T8700 processor, x86_64 kernel, a slightly mangled
> Fedora Rawhide userspace.  I'd not be surprised if there's an idiocyncratic
> setting in my .config that makes the bug crawl out of the woodwork on my box,
> so I'm attaching the .config in case it provides some enlightenment.
> 
> If you want me to try a debugging or test patch, let me know...

Valdis,

I've tried your config on a few different machines but I'm still not
able to reproduce the problem.  Can you help me narrow things down?
Please revert my original patch.  I've separated my original changes
into two parts.  Try apply only the recv_scm.patch attached and try to
boot.  Then apply only the send_scm.patch without the rcv_scm.patch and
repeat.  Let me know which patch causes the boot problem.

I'll like to isolate the problem to either the send path or receive
path. My suspicion is the error handling portion of the send path is not
quite right but I haven't yet found any issues after reviewing the
patch.  

Thanks.

Tim

--=-R8z0zoj60uOyb+ALM1/W
Content-Disposition: attachment; filename="scm_recv.patch"
Content-Type: text/x-patch; name="scm_recv.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

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
index ec68e1c..e6d9d10 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1777,7 +1789,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 		siocb->scm = &tmp_scm;
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
-	scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
+	scm_set_cred_noref(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
 	unix_set_secdata(siocb->scm, skb);
 
 	if (!(flags & MSG_PEEK)) {
@@ -1939,7 +1951,8 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			}
 		} else {
 			/* Copy credentials */
-			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
+			scm_set_cred_noref(siocb->scm, UNIXCB(skb).pid,
+					   UNIXCB(skb).cred);
 			check_creds = 1;
 		}
 

--=-R8z0zoj60uOyb+ALM1/W
Content-Disposition: attachment; filename="scm_send.patch"
Content-Type: text/x-patch; name="scm_send.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/include/net/scm.h b/include/net/scm.h
index 745460f..68e1e48 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
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
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index ec68e1c..e6d9d10 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1378,11 +1378,17 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
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
@@ -1407,7 +1413,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	int namelen = 0; /* fake GCC */
 	int err;
 	unsigned hash;
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	long timeo;
 	struct scm_cookie tmp_scm;
 	int max_level;
@@ -1448,7 +1454,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (skb == NULL)
 		goto out;
 
-	err = unix_scm_to_skb(siocb->scm, skb, true);
+	err = unix_scm_to_skb(siocb->scm, skb, true, false);
 	if (err < 0)
 		goto out_free;
 	max_level = err + 1;
@@ -1544,7 +1550,7 @@ restart:
 	unix_state_unlock(other);
 	other->sk_data_ready(other, len);
 	sock_put(other);
-	scm_destroy(siocb->scm);
+	scm_release(siocb->scm);
 	return len;
 
 out_unlock:
@@ -1554,7 +1560,8 @@ out_free:
 out:
 	if (other)
 		sock_put(other);
-	scm_destroy(siocb->scm);
+	if (skb == NULL)
+		scm_destroy(siocb->scm);
 	return err;
 }
 
@@ -1566,7 +1573,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct sock *other = NULL;
 	int err, size;
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	int sent = 0;
 	struct scm_cookie tmp_scm;
 	bool fds_sent = false;
@@ -1631,11 +1638,11 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
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
@@ -1643,7 +1650,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 		if (err) {
 			kfree_skb(skb);
-			goto out_err;
+			goto out;
 		}
 
 		unix_state_lock(other);
@@ -1660,7 +1667,10 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		sent += size;
 	}
 
-	scm_destroy(siocb->scm);
+	if (skb)
+		scm_release(siocb->scm);
+	else
+		scm_destroy(siocb->scm);
 	siocb->scm = NULL;
 
 	return sent;
@@ -1673,7 +1683,9 @@ pipe_err:
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

--=-R8z0zoj60uOyb+ALM1/W--
