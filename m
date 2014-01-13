From: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v4 1/3] Send loginuid and sessionid in SCM_AUDIT
Date: Mon, 13 Jan 2014 09:01:47 +0100
Message-ID: <1389600109-30739-2-git-send-email-jkaluza@redhat.com>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
	<1389600109-30739-1-git-send-email-jkaluza@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1389600109-30739-1-git-send-email-jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Server-like processes in many cases need credentials and other
metadata of the peer, to decide if the calling process is allowed to
request a specific action, or the server just wants to log away this
type of information for auditing tasks.

The current practice to retrieve such process metadata is to look that
information up in procfs with the $PID received over SCM_CREDENTIALS.
This is sufficient for long-running tasks, but introduces a race which
cannot be worked around for short-living processes; the calling
process and all the information in /proc/$PID/ is gone before the
receiver of the socket message can look it up.

This introduces a new SCM type called SCM_AUDIT to allow the direct
attaching of "loginuid" and "sessionid" to SCM, which is significantly more
efficient and will reliably avoid the race with the round-trip over
procfs.

Signed-off-by: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/socket.h |  6 ++++++
 include/net/af_unix.h  |  2 ++
 include/net/scm.h      | 28 ++++++++++++++++++++++++++--
 net/unix/af_unix.c     |  7 +++++++
 4 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 5d488a6..eeac565 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -130,6 +130,7 @@ static inline struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsghdr
 #define	SCM_RIGHTS	0x01		/* rw: access rights (array of int) */
 #define SCM_CREDENTIALS 0x02		/* rw: struct ucred		*/
 #define SCM_SECURITY	0x03		/* rw: security label		*/
+#define SCM_AUDIT	0x04		/* rw: struct uaudit		*/
 
 struct ucred {
 	__u32	pid;
@@ -137,6 +138,11 @@ struct ucred {
 	__u32	gid;
 };
 
+struct uaudit {
+	__u32	loginuid;
+	__u32	sessionid;
+};
+
 /* Supported address families. */
 #define AF_UNSPEC	0
 #define AF_UNIX		1	/* Unix domain sockets 		*/
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index a175ba4..3b9d22a 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -36,6 +36,8 @@ struct unix_skb_parms {
 	u32			secid;		/* Security ID		*/
 #endif
 	u32			consumed;
+	kuid_t			loginuid;
+	unsigned int		sessionid;
 };
 
 #define UNIXCB(skb) 	(*(struct unix_skb_parms *)&((skb)->cb))
diff --git a/include/net/scm.h b/include/net/scm.h
index 262532d..67de64f 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -6,6 +6,7 @@
 #include <linux/security.h>
 #include <linux/pid.h>
 #include <linux/nsproxy.h>
+#include <linux/audit.h>
 
 /* Well, we should have at least one descriptor open
  * to accept passed FDs 8)
@@ -18,6 +19,11 @@ struct scm_creds {
 	kgid_t	gid;
 };
 
+struct scm_audit {
+	kuid_t loginuid;
+	unsigned int sessionid;
+};
+
 struct scm_fp_list {
 	short			count;
 	short			max;
@@ -28,6 +34,7 @@ struct scm_cookie {
 	struct pid		*pid;		/* Skb credentials */
 	struct scm_fp_list	*fp;		/* Passed files		*/
 	struct scm_creds	creds;		/* Skb credentials	*/
+	struct scm_audit	audit;		/* Skb audit	*/
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Passed security ID 	*/
 #endif
@@ -58,6 +65,13 @@ static __inline__ void scm_set_cred(struct scm_cookie *scm,
 	scm->creds.gid = gid;
 }
 
+static inline void scm_set_audit(struct scm_cookie *scm,
+				    kuid_t loginuid, unsigned int sessionid)
+{
+	scm->audit.loginuid = loginuid;
+	scm->audit.sessionid = sessionid;
+}
+
 static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
 {
 	put_pid(scm->pid);
@@ -77,8 +91,12 @@ static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
 	memset(scm, 0, sizeof(*scm));
 	scm->creds.uid = INVALID_UID;
 	scm->creds.gid = INVALID_GID;
-	if (forcecreds)
-		scm_set_cred(scm, task_tgid(current), current_uid(), current_gid());
+	if (forcecreds) {
+		scm_set_cred(scm, task_tgid(current), current_uid(),
+			     current_gid());
+		scm_set_audit(scm, audit_get_loginuid(current),
+			      audit_get_sessionid(current));
+	}
 	unix_get_peersec_dgram(sock, scm);
 	if (msg->msg_controllen <= 0)
 		return 0;
@@ -123,7 +141,13 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 			.uid = from_kuid_munged(current_ns, scm->creds.uid),
 			.gid = from_kgid_munged(current_ns, scm->creds.gid),
 		};
+		struct uaudit uaudits = {
+			.loginuid = from_kuid_munged(current_ns,
+						     scm->audit.loginuid),
+			.sessionid = scm->audit.sessionid,
+		};
 		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(ucreds), &ucreds);
+		put_cmsg(msg, SOL_SOCKET, SCM_AUDIT, sizeof(uaudits), &uaudits);
 	}
 
 	scm_destroy_cred(scm);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 800ca61..bc02a25 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1413,6 +1413,8 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 	UNIXCB(skb).pid  = get_pid(scm->pid);
 	UNIXCB(skb).uid = scm->creds.uid;
 	UNIXCB(skb).gid = scm->creds.gid;
+	UNIXCB(skb).loginuid = scm->audit.loginuid;
+	UNIXCB(skb).sessionid = scm->audit.sessionid;
 	UNIXCB(skb).fp = NULL;
 	if (scm->fp && send_fds)
 		err = unix_attach_fds(scm, skb);
@@ -1436,6 +1438,8 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
 	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
 		UNIXCB(skb).pid  = get_pid(task_tgid(current));
 		current_uid_gid(&UNIXCB(skb).uid, &UNIXCB(skb).gid);
+		UNIXCB(skb).loginuid = audit_get_loginuid(current);
+		UNIXCB(skb).sessionid = audit_get_sessionid(current);
 	}
 }
 
@@ -1829,6 +1833,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
 	scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
+	scm_set_audit(siocb->scm, UNIXCB(skb).loginuid, UNIXCB(skb).sessionid);
 	unix_set_secdata(siocb->scm, skb);
 
 	if (!(flags & MSG_PEEK)) {
@@ -2008,6 +2013,8 @@ again:
 		} else if (test_bit(SOCK_PASSCRED, &sock->flags)) {
 			/* Copy credentials */
 			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
+			scm_set_audit(siocb->scm, UNIXCB(skb).loginuid,
+				      UNIXCB(skb).sessionid);
 			check_creds = 1;
 		}
 
-- 
1.8.3.1
