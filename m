From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 01/21] userns: Convert net/core/scm.c to use kuids and kgids
Date: Mon, 13 Aug 2012 13:18:15 -0700
Message-ID: <1344889115-21610-1-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ehnav9n5.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

With the existence of kuid_t and kgid_t we can take this further
and remove the usage of struct cred altogether, ensuring we
don't get cache line misses from reference counts.   For now
however start simply and do a straight forward conversion
I can be certain is correct.

In cred_to_ucred use from_kuid_munged and from_kgid_munged
as these values are going directly to userspace and we want to use
the userspace safe values not -1 when reporting a value that does not
map.  The earlier conversion that used from_kuid was buggy in that
respect.  Oops.

Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/core/scm.c  |   31 +++++++++++++++++++++++--------
 net/core/sock.c |    4 ++--
 2 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/net/core/scm.c b/net/core/scm.c
index 8f6ccfd..5472ae7 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -45,12 +45,17 @@
 static __inline__ int scm_check_creds(struct ucred *creds)
 {
 	const struct cred *cred = current_cred();
+	kuid_t uid = make_kuid(cred->user_ns, creds->uid);
+	kgid_t gid = make_kgid(cred->user_ns, creds->gid);
+
+	if (!uid_valid(uid) || !gid_valid(gid))
+		return -EINVAL;
 
 	if ((creds->pid == task_tgid_vnr(current) || capable(CAP_SYS_ADMIN)) &&
-	    ((creds->uid == cred->uid   || creds->uid == cred->euid ||
-	      creds->uid == cred->suid) || capable(CAP_SETUID)) &&
-	    ((creds->gid == cred->gid   || creds->gid == cred->egid ||
-	      creds->gid == cred->sgid) || capable(CAP_SETGID))) {
+	    ((uid_eq(uid, cred->uid)   || uid_eq(uid, cred->euid) ||
+	      uid_eq(uid, cred->suid)) || capable(CAP_SETUID)) &&
+	    ((gid_eq(gid, cred->gid)   || gid_eq(gid, cred->egid) ||
+	      gid_eq(gid, cred->sgid)) || capable(CAP_SETGID))) {
 	       return 0;
 	}
 	return -EPERM;
@@ -149,6 +154,9 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 				goto error;
 			break;
 		case SCM_CREDENTIALS:
+		{
+			kuid_t uid;
+			kgid_t gid;
 			if (cmsg->cmsg_len != CMSG_LEN(sizeof(struct ucred)))
 				goto error;
 			memcpy(&p->creds, CMSG_DATA(cmsg), sizeof(struct ucred));
@@ -166,22 +174,29 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 				p->pid = pid;
 			}
 
+			err = -EINVAL;
+			uid = make_kuid(current_user_ns(), p->creds.uid);
+			gid = make_kgid(current_user_ns(), p->creds.gid);
+			if (!uid_valid(uid) || !gid_valid(gid))
+				goto error;
+
 			if (!p->cred ||
-			    (p->cred->euid != p->creds.uid) ||
-			    (p->cred->egid != p->creds.gid)) {
+			    !uid_eq(p->cred->euid, uid) ||
+			    !gid_eq(p->cred->egid, gid)) {
 				struct cred *cred;
 				err = -ENOMEM;
 				cred = prepare_creds();
 				if (!cred)
 					goto error;
 
-				cred->uid = cred->euid = p->creds.uid;
-				cred->gid = cred->egid = p->creds.gid;
+				cred->uid = cred->euid = uid;
+				cred->gid = cred->egid = gid;
 				if (p->cred)
 					put_cred(p->cred);
 				p->cred = cred;
 			}
 			break;
+		}
 		default:
 			goto error;
 		}
diff --git a/net/core/sock.c b/net/core/sock.c
index 6b654b3..9c7fe4f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -868,8 +868,8 @@ void cred_to_ucred(struct pid *pid, const struct cred *cred,
 	if (cred) {
 		struct user_namespace *current_ns = current_user_ns();
 
-		ucred->uid = from_kuid(current_ns, cred->euid);
-		ucred->gid = from_kgid(current_ns, cred->egid);
+		ucred->uid = from_kuid_munged(current_ns, cred->euid);
+		ucred->gid = from_kgid_munged(current_ns, cred->egid);
 	}
 }
 EXPORT_SYMBOL_GPL(cred_to_ucred);
-- 
1.7.5.4
