From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 6/8] scm: Capture the full credentials of the scm sender.
Date: Sun, 13 Jun 2010 06:32:34 -0700
Message-ID: <m1d3vvgirx.fsf@fess.ebiederm.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	<netdev@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47978 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410Ab0FMNcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 09:32:39 -0400
In-Reply-To: <m1hbl7hxo3.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 13 Jun 2010 06\:25\:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Start capturing not only the userspace pid, uid and gid values of the
sending process but also the struct pid and struct cred of the sending
process as well.

This is in preparation for properly supporting SCM_CREDENTIALS for
sockets that have different uid and/or pid namespaces at the different
ends.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/scm.h |   28 ++++++++++++++++++++++++----
 net/core/scm.c    |   24 ++++++++++++++++++++++++
 2 files changed, 48 insertions(+), 4 deletions(-)

diff --git a/include/net/scm.h b/include/net/scm.h
index 17d9d2e..3165650 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -19,6 +19,8 @@ struct scm_fp_list {
 };
 
 struct scm_cookie {
+	struct pid		*pid;		/* Skb credentials */
+	const struct cred	*cred;
 	struct scm_fp_list	*fp;		/* Passed files		*/
 	struct ucred		creds;		/* Skb credentials	*/
 #ifdef CONFIG_SECURITY_NETWORK
@@ -42,8 +44,27 @@ static __inline__ void unix_get_peersec_dgram(struct socket *sock, struct scm_co
 { }
 #endif /* CONFIG_SECURITY_NETWORK */
 
+static __inline__ void scm_set_cred(struct scm_cookie *scm,
+				    struct pid *pid, const struct cred *cred)
+{
+	scm->pid  = get_pid(pid);
+	scm->cred = get_cred(cred);
+	cred_to_ucred(pid, cred, &scm->creds);
+}
+
+static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
+{
+	put_pid(scm->pid);
+	scm->pid  = NULL;
+
+	if (scm->cred)
+		put_cred(scm->cred);
+	scm->cred = NULL;
+}
+
 static __inline__ void scm_destroy(struct scm_cookie *scm)
 {
+	scm_destroy_cred(scm);
 	if (scm && scm->fp)
 		__scm_destroy(scm);
 }
@@ -51,10 +72,7 @@ static __inline__ void scm_destroy(struct scm_cookie *scm)
 static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
 			       struct scm_cookie *scm)
 {
-	struct task_struct *p = current;
-	scm->creds.uid = current_uid();
-	scm->creds.gid = current_gid();
-	scm->creds.pid = task_tgid_vnr(p);
+	scm_set_cred(scm, task_tgid(current), current_cred());
 	scm->fp = NULL;
 	unix_get_peersec_dgram(sock, scm);
 	if (msg->msg_controllen <= 0)
@@ -96,6 +114,8 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 	if (test_bit(SOCK_PASSCRED, &sock->flags))
 		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(scm->creds), &scm->creds);
 
+	scm_destroy_cred(scm);
+
 	scm_passec(sock, msg, scm);
 
 	if (!scm->fp)
diff --git a/net/core/scm.c b/net/core/scm.c
index b88f6f9..681c976 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -170,6 +170,30 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 			err = scm_check_creds(&p->creds);
 			if (err)
 				goto error;
+
+			if (pid_vnr(p->pid) != p->creds.pid) {
+				struct pid *pid;
+				err = -ESRCH;
+				pid = find_get_pid(p->creds.pid);
+				if (!pid)
+					goto error;
+				put_pid(p->pid);
+				p->pid = pid;
+			}
+
+			if ((p->cred->euid != p->creds.uid) ||
+				(p->cred->egid != p->creds.gid)) {
+				struct cred *cred;
+				err = -ENOMEM;
+				cred = prepare_creds();
+				if (!cred)
+					goto error;
+
+				cred->uid = cred->euid = p->creds.uid;
+				cred->gid = cred->egid = p->creds.uid;
+				put_cred(p->cred);
+				p->cred = cred;
+			}
 			break;
 		default:
 			goto error;
-- 
1.6.5.2.143.g8cc62

