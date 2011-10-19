From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
Subject: [PATCH 9/9] make net/core/scm.c uid comparisons user namespace aware
 (v2)
Date: Tue, 18 Oct 2011 21:25:52 -0500
Message-ID: <20111019022552.GA29251@sergelap>
References: <1318974898-21431-1-git-send-email-serge@hallyn.com>
 <1318974898-21431-10-git-send-email-serge@hallyn.com>
 <1318976049.2273.7.camel@Joe-Laptop>
 <20111018232242.GA22950@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, akpm@linux-foundation.org, oleg@redhat.com,
	richard@nod.at, mikevs@xs4all.net, segoon@openwall.com,
	gregkh@suse.de, dhowells@redhat.com, eparis@redhat.com,
	netdev@vger.kernel.org
To: "Serge E. Hallyn" <serge@hallyn.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111018232242.GA22950@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Thanks for the suggestions, Joe.)

Currently uids are compared without regard for the user namespace.
Fix that to prevent tasks in a different user namespace from
wrongly matching on SCM_CREDENTIALS.

In the past, either your uids had to match, or you had to have
CAP_SETXID.  In a namespaced world, you must either (both be in the
same user namespace and have your uids match), or you must have
CAP_SETXID targeted at the other user namespace.  The latter can
happen for instance if uid 500 created a new user namespace and
now interacts with uid 0 in it.

Changelog: Oct 18:
	Per Joe Perches: don't mark uidequiv and gidequiv fns inline
	(let the compiler do that if appropriate), and change the flow
	of id comparisons to make it clearer.

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Joe Perches <joe@perches.com>
---
 net/core/scm.c |   43 ++++++++++++++++++++++++++++++++++++-------
 1 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/net/core/scm.c b/net/core/scm.c
index 811b53f..2261607 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -43,17 +43,46 @@
  *	setu(g)id.
  */
 
-static __inline__ int scm_check_creds(struct ucred *creds)
+static bool uidequiv(const struct cred *src, struct ucred *tgt,
+			       struct user_namespace *ns)
+{
+	if (src->user_ns != ns)
+		goto check_capable;
+	if (tgt->uid == src->uid ||
+	    tgt->uid == src->euid ||
+	    tgt->uid == src->suid)
+		return true;
+check_capable:
+	if (ns_capable(ns, CAP_SETUID))
+		return true;
+	return false;
+}
+
+static bool gidequiv(const struct cred *src, struct ucred *tgt,
+			       struct user_namespace *ns)
+{
+	if (src->user_ns != ns)
+		goto check_capable;
+	if (tgt->gid == src->gid ||
+	    tgt->gid == src->egid ||
+	    tgt->gid == src->sgid)
+		return true;
+check_capable:
+	if (ns_capable(ns, CAP_SETGID))
+		return true;
+	return false;
+}
+
+static int scm_check_creds(struct ucred *creds, struct socket *sock)
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
 
@@ -169,7 +198,7 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 			if (cmsg->cmsg_len != CMSG_LEN(sizeof(struct ucred)))
 				goto error;
 			memcpy(&p->creds, CMSG_DATA(cmsg), sizeof(struct ucred));
-			err = scm_check_creds(&p->creds);
+			err = scm_check_creds(&p->creds, sock);
 			if (err)
 				goto error;
 
-- 
1.7.5.4
