From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 10/14] net/core/scm.c: target capable() calls to user_ns owning the net_ns
Date: Tue, 26 Jul 2011 18:58:33 +0000
Message-ID: <1311706717-7398-11-git-send-email-serge@hallyn.com>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Cc: dhowells@redhat.com, ebiederm@xmission.com,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	akpm@osdl.org, "Serge E. Hallyn" <serge.hallyn@canonical.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Serge E. Hallyn <serge.hallyn@canonical.com>

The uid/gid comparisons don't have to be pulled out.  This just seemed
more easily proved correct.

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/scm.c |   41 ++++++++++++++++++++++++++++++++++-------
 1 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/net/core/scm.c b/net/core/scm.c
index 4c1ef02..21b5d0b 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -43,17 +43,44 @@
  *	setu(g)id.
  */
 
-static __inline__ int scm_check_creds(struct ucred *creds)
+static __inline__ bool uidequiv(struct cred *src, struct ucred *tgt,
+			       struct user_namespace *ns)
+{
+	if (src->user_ns != ns)
+		goto check_capable;
+	if (src->uid == tgt->uid || src->euid == tgt->uid ||
+	    src->suid == tgt->uid)
+		return true;
+check_capable:
+	if (ns_capable(ns, CAP_SETUID))
+		return true;
+	return false;
+}
+
+static __inline__ bool gidequiv(struct cred *src, struct ucred *tgt,
+			       struct user_namespace *ns)
+{
+	if (src->user_ns != ns)
+		goto check_capable;
+	if (src->gid == tgt->gid || src->egid == tgt->gid ||
+	    src->sgid == tgt->gid)
+		return true;
+check_capable:
+	if (ns_capable(ns, CAP_SETGID))
+		return true;
+	return false;
+}
+
+static __inline__ int scm_check_creds(struct ucred *creds, struct socket *sock)
 {
 	const struct cred *cred = current_cred();
+	struct user_namespace *ns = sock_net(sock->sk)->user_ns;
 
-	if ((creds->pid == task_tgid_vnr(current) || capable(CAP_SYS_ADMIN)) &&
-	    ((creds->uid == cred->uid   || creds->uid == cred->euid ||
-	      creds->uid == cred->suid) || capable(CAP_SETUID)) &&
-	    ((creds->gid == cred->gid   || creds->gid == cred->egid ||
-	      creds->gid == cred->sgid) || capable(CAP_SETGID))) {
+	if ((creds->pid == task_tgid_vnr(current) || ns_capable(ns, CAP_SYS_ADMIN)) &&
+	     uidequiv(cred, creds, ns) && gidequiv(cred, creds, ns)) {
 	       return 0;
 	}
+
 	return -EPERM;
 }
 
@@ -169,7 +196,7 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 			if (cmsg->cmsg_len != CMSG_LEN(sizeof(struct ucred)))
 				goto error;
 			memcpy(&p->creds, CMSG_DATA(cmsg), sizeof(struct ucred));
-			err = scm_check_creds(&p->creds);
+			err = scm_check_creds(&p->creds, sock);
 			if (err)
 				goto error;
 
-- 
1.7.4.1
