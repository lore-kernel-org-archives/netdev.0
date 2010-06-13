From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 7/8] af_unix: Allow credentials to work across user and pid namespaces.
Date: Sun, 13 Jun 2010 06:34:33 -0700
Message-ID: <m17hm3giom.fsf@fess.ebiederm.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	<netdev@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:48356 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab0FMNeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 09:34:37 -0400
In-Reply-To: <m1hbl7hxo3.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 13 Jun 2010 06\:25\:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In unix_skb_parms store pointers to struct pid and struct cred instead
of raw uid, gid, and pid values, then translate the credentials on
reception into values that are meaningful in the receiving processes
namespaces.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/af_unix.h |    4 +-
 net/unix/af_unix.c    |   53 ++++++++++++++++++++++++++++--------------------
 2 files changed, 33 insertions(+), 24 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 1614d78..59d636c 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -23,7 +23,8 @@ struct unix_address {
 };
 
 struct unix_skb_parms {
-	struct ucred		creds;		/* Skb credentials	*/
+	struct pid		*pid;		/* Skb credentials	*/
+	const struct cred	*cred;
 	struct scm_fp_list	*fp;		/* Passed files		*/
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Security ID		*/
@@ -31,7 +32,6 @@ struct unix_skb_parms {
 };
 
 #define UNIXCB(skb) 	(*(struct unix_skb_parms*)&((skb)->cb))
-#define UNIXCREDS(skb)	(&UNIXCB((skb)).creds)
 #define UNIXSID(skb)	(&UNIXCB((skb)).secid)
 
 #define unix_state_lock(s)	spin_lock(&unix_sk(s)->lock)
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 028fa25..78d412a 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1315,18 +1315,20 @@ static void unix_detach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 	int i;
 
 	scm->fp = UNIXCB(skb).fp;
-	skb->destructor = sock_wfree;
 	UNIXCB(skb).fp = NULL;
 
 	for (i = scm->fp->count-1; i >= 0; i--)
 		unix_notinflight(scm->fp->fp[i]);
 }
 
-static void unix_destruct_fds(struct sk_buff *skb)
+static void unix_destruct_scm(struct sk_buff *skb)
 {
 	struct scm_cookie scm;
 	memset(&scm, 0, sizeof(scm));
-	unix_detach_fds(&scm, skb);
+	scm.pid  = UNIXCB(skb).pid;
+	scm.cred = UNIXCB(skb).cred;
+	if (UNIXCB(skb).fp)
+		unix_detach_fds(&scm, skb);
 
 	/* Alas, it calls VFS */
 	/* So fscking what? fput() had been SMP-safe since the last Summer */
@@ -1349,10 +1351,22 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 
 	for (i = scm->fp->count-1; i >= 0; i--)
 		unix_inflight(scm->fp->fp[i]);
-	skb->destructor = unix_destruct_fds;
 	return 0;
 }
 
+static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool send_fds)
+{
+	int err = 0;
+	UNIXCB(skb).pid  = get_pid(scm->pid);
+	UNIXCB(skb).cred = get_cred(scm->cred);
+	UNIXCB(skb).fp = NULL;
+ 	if (scm->fp && send_fds)
+ 		err = unix_attach_fds(scm, skb);
+ 
+	skb->destructor = unix_destruct_scm;
+ 	return err;
+}
+
 /*
  *	Send AF_UNIX data.
  */
@@ -1409,12 +1423,9 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (skb == NULL)
 		goto out;
 
-	memcpy(UNIXCREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
-	if (siocb->scm->fp) {
-		err = unix_attach_fds(siocb->scm, skb);
-		if (err)
-			goto out_free;
-	}
+	err = unix_scm_to_skb(siocb->scm, skb, true);
+	if (err)
+		goto out_free;
 	unix_get_secdata(siocb->scm, skb);
 
 	skb_reset_transport_header(skb);
@@ -1584,16 +1595,14 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		 */
 		size = min_t(int, size, skb_tailroom(skb));
 
-		memcpy(UNIXCREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
+		
 		/* Only send the fds in the first buffer */
-		if (siocb->scm->fp && !fds_sent) {
-			err = unix_attach_fds(siocb->scm, skb);
-			if (err) {
-				kfree_skb(skb);
-				goto out_err;
-			}
-			fds_sent = true;
+		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent);
+		if (err) {
+			kfree_skb(skb);
+			goto out_err;
 		}
+		fds_sent = true;
 
 		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 		if (err) {
@@ -1710,7 +1719,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 		siocb->scm = &tmp_scm;
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
-	siocb->scm->creds = *UNIXCREDS(skb);
+	scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
 	unix_set_secdata(siocb->scm, skb);
 
 	if (!(flags & MSG_PEEK)) {
@@ -1859,14 +1868,14 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 		if (check_creds) {
 			/* Never glue messages from different writers */
-			if (memcmp(UNIXCREDS(skb), &siocb->scm->creds,
-				   sizeof(siocb->scm->creds)) != 0) {
+			if ((UNIXCB(skb).pid  != siocb->scm->pid) ||
+			    (UNIXCB(skb).cred != siocb->scm->cred)) {
 				skb_queue_head(&sk->sk_receive_queue, skb);
 				break;
 			}
 		} else {
 			/* Copy credentials */
-			siocb->scm->creds = *UNIXCREDS(skb);
+			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
 			check_creds = 1;
 		}
 
-- 
1.6.5.2.143.g8cc62

