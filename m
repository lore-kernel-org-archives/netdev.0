From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/2] scm: Stop passing struct cred
Date: Wed, 03 Apr 2013 20:28:16 -0700
Message-ID: <87li8zezzj.fsf_-_@xmission.com>
References: <20130402221104.163133110@linuxfoundation.org>
	<20130402221116.307254752@linuxfoundation.org>
	<87vc833kpf.fsf@turtle.gmx.de> <87k3ojnosa.fsf@xmission.com>
	<1365034777.13853.46.camel@edumazet-glaptop>
	<1365035424.13853.48.camel@edumazet-glaptop>
	<878v4zjei0.fsf@xmission.com> <87li8zhwkw.fsf_-_@xmission.com>
	<87d2ubhwiw.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sven Joachim <svenjoac@gmx.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org,
	Ding Tianhong <dingtianhong@huawei.com>,
	Eric Dumazet <edumazet@google.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Karel Srot <ksrot@redhat.com>, <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d2ubhwiw.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Wed, 03 Apr 2013 19:14:47 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Now that uids and gids are completely encapsulated in kuid_t
and kgid_t we no longer need to pass struct cred which allowed
us to test both the uid and the user namespace for equality.

Passing struct cred potentially allows us to pass the entire group
list as BSD does but I don't believe the cost of cache line misses
justifies retaining code for a future potential application.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

Included in this patchset because there are trivial dependencies,
and since we are sort of arguing about this anyway.  This definitely is
not for stable.

 include/net/af_unix.h |    3 ++-
 include/net/scm.h     |   16 ++++++----------
 net/core/scm.c        |   16 ----------------
 net/unix/af_unix.c    |   16 ++++++++--------
 4 files changed, 16 insertions(+), 35 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 0a996a3..a8836e8 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -29,7 +29,8 @@ struct unix_address {
 
 struct unix_skb_parms {
 	struct pid		*pid;		/* Skb credentials	*/
-	const struct cred	*cred;
+	kuid_t			uid;
+	kgid_t			gid;
 	struct scm_fp_list	*fp;		/* Passed files		*/
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Security ID		*/
diff --git a/include/net/scm.h b/include/net/scm.h
index 975cca0..5a4c6a9 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -26,7 +26,6 @@ struct scm_fp_list {
 
 struct scm_cookie {
 	struct pid		*pid;		/* Skb credentials */
-	const struct cred	*cred;
 	struct scm_fp_list	*fp;		/* Passed files		*/
 	struct scm_creds	creds;		/* Skb credentials	*/
 #ifdef CONFIG_SECURITY_NETWORK
@@ -51,23 +50,18 @@ static __inline__ void unix_get_peersec_dgram(struct socket *sock, struct scm_co
 #endif /* CONFIG_SECURITY_NETWORK */
 
 static __inline__ void scm_set_cred(struct scm_cookie *scm,
-				    struct pid *pid, const struct cred *cred)
+				    struct pid *pid, kuid_t uid, kgid_t gid)
 {
 	scm->pid  = get_pid(pid);
-	scm->cred = cred ? get_cred(cred) : NULL;
 	scm->creds.pid = pid_vnr(pid);
-	scm->creds.uid = cred ? cred->euid : INVALID_UID;
-	scm->creds.gid = cred ? cred->egid : INVALID_GID;
+	scm->creds.uid = uid;
+	scm->creds.gid = gid;
 }
 
 static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
 {
 	put_pid(scm->pid);
 	scm->pid  = NULL;
-
-	if (scm->cred)
-		put_cred(scm->cred);
-	scm->cred = NULL;
 }
 
 static __inline__ void scm_destroy(struct scm_cookie *scm)
@@ -81,8 +75,10 @@ static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
 			       struct scm_cookie *scm, bool forcecreds)
 {
 	memset(scm, 0, sizeof(*scm));
+	scm->creds.uid = INVALID_UID;
+	scm->creds.gid = INVALID_GID;
 	if (forcecreds)
-		scm_set_cred(scm, task_tgid(current), current_cred());
+		scm_set_cred(scm, task_tgid(current), current_euid(), current_egid());
 	unix_get_peersec_dgram(sock, scm);
 	if (msg->msg_controllen <= 0)
 		return 0;
diff --git a/net/core/scm.c b/net/core/scm.c
index 2dc6cda..83b2b38 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -187,22 +187,6 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 
 			p->creds.uid = uid;
 			p->creds.gid = gid;
-
-			if (!p->cred ||
-			    !uid_eq(p->cred->euid, uid) ||
-			    !gid_eq(p->cred->egid, gid)) {
-				struct cred *cred;
-				err = -ENOMEM;
-				cred = prepare_creds();
-				if (!cred)
-					goto error;
-
-				cred->uid = cred->euid = uid;
-				cred->gid = cred->egid = gid;
-				if (p->cred)
-					put_cred(p->cred);
-				p->cred = cred;
-			}
 			break;
 		}
 		default:
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 2db702d..f5594b5 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1340,7 +1340,6 @@ static void unix_destruct_scm(struct sk_buff *skb)
 	struct scm_cookie scm;
 	memset(&scm, 0, sizeof(scm));
 	scm.pid  = UNIXCB(skb).pid;
-	scm.cred = UNIXCB(skb).cred;
 	if (UNIXCB(skb).fp)
 		unix_detach_fds(&scm, skb);
 
@@ -1391,8 +1390,8 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 	int err = 0;
 
 	UNIXCB(skb).pid  = get_pid(scm->pid);
-	if (scm->cred)
-		UNIXCB(skb).cred = get_cred(scm->cred);
+	UNIXCB(skb).uid = scm->creds.uid;
+	UNIXCB(skb).gid = scm->creds.gid;
 	UNIXCB(skb).fp = NULL;
 	if (scm->fp && send_fds)
 		err = unix_attach_fds(scm, skb);
@@ -1409,13 +1408,13 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
 			    const struct sock *other)
 {
-	if (UNIXCB(skb).cred)
+	if (UNIXCB(skb).pid)
 		return;
 	if (test_bit(SOCK_PASSCRED, &sock->flags) ||
 	    !other->sk_socket ||
 	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
 		UNIXCB(skb).pid  = get_pid(task_tgid(current));
-		UNIXCB(skb).cred = get_current_cred();
+		current_euid_egid(&UNIXCB(skb).uid, &UNIXCB(skb).gid);
 	}
 }
 
@@ -1819,7 +1818,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 		siocb->scm = &tmp_scm;
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
-	scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
+	scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
 	unix_set_secdata(siocb->scm, skb);
 
 	if (!(flags & MSG_PEEK)) {
@@ -1991,11 +1990,12 @@ again:
 		if (check_creds) {
 			/* Never glue messages from different writers */
 			if ((UNIXCB(skb).pid  != siocb->scm->pid) ||
-			    (UNIXCB(skb).cred != siocb->scm->cred))
+			    !uid_eq(UNIXCB(skb).uid, siocb->scm->creds.uid) ||
+			    !gid_eq(UNIXCB(skb).gid, siocb->scm->creds.gid))
 				break;
 		} else if (test_bit(SOCK_PASSCRED, &sock->flags)) {
 			/* Copy credentials */
-			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
+			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
 			check_creds = 1;
 		}
 
-- 
1.7.5.4
