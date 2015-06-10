From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: [PATCH net-next] net/unix: support SCM_SECURITY for stream sockets
Date: Wed, 10 Jun 2015 08:44:59 -0400
Message-ID: <1433940299-6207-1-git-send-email-sds@tycho.nsa.gov>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	paul@paul-moore.com, Stephen Smalley <sds@tycho.nsa.gov>
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SCM_SECURITY was originally only implemented for datagram sockets,
not for stream sockets.  However, SCM_CREDENTIALS is supported on
Unix stream sockets.  For consistency, implement Unix stream support
for SCM_SECURITY as well.  Also clean up the existing code and get
rid of the superfluous UNIXSID macro.

Motivated by https://bugzilla.redhat.com/show_bug.cgi?id=1224211,
where systemd was using SCM_CREDENTIALS and assumed wrongly that
SCM_SECURITY was also supported on Unix stream sockets.

Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
Acked-by: Paul Moore <paul@paul-moore.com>
---
 include/net/af_unix.h |  1 -
 net/unix/af_unix.c    | 20 ++++++++++++++++----
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index a175ba4..4a167b3 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -39,7 +39,6 @@ struct unix_skb_parms {
 };
 
 #define UNIXCB(skb) 	(*(struct unix_skb_parms *)&((skb)->cb))
-#define UNIXSID(skb)	(&UNIXCB((skb)).secid)
 
 #define unix_state_lock(s)	spin_lock(&unix_sk(s)->lock)
 #define unix_state_unlock(s)	spin_unlock(&unix_sk(s)->lock)
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f25e167..03ee4d3 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -140,12 +140,17 @@ static struct hlist_head *unix_sockets_unbound(void *addr)
 #ifdef CONFIG_SECURITY_NETWORK
 static void unix_get_secdata(struct scm_cookie *scm, struct sk_buff *skb)
 {
-	memcpy(UNIXSID(skb), &scm->secid, sizeof(u32));
+	UNIXCB(skb).secid = scm->secid;
 }
 
 static inline void unix_set_secdata(struct scm_cookie *scm, struct sk_buff *skb)
 {
-	scm->secid = *UNIXSID(skb);
+	scm->secid = UNIXCB(skb).secid;
+}
+
+static inline bool unix_secdata_eq(struct scm_cookie *scm, struct sk_buff *skb)
+{
+	return (scm->secid == UNIXCB(skb).secid);
 }
 #else
 static inline void unix_get_secdata(struct scm_cookie *scm, struct sk_buff *skb)
@@ -153,6 +158,11 @@ static inline void unix_get_secdata(struct scm_cookie *scm, struct sk_buff *skb)
 
 static inline void unix_set_secdata(struct scm_cookie *scm, struct sk_buff *skb)
 { }
+
+static inline bool unix_secdata_eq(struct scm_cookie *scm, struct sk_buff *skb)
+{
+	return true;
+}
 #endif /* CONFIG_SECURITY_NETWORK */
 
 /*
@@ -1414,6 +1424,7 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 	UNIXCB(skb).uid = scm->creds.uid;
 	UNIXCB(skb).gid = scm->creds.gid;
 	UNIXCB(skb).fp = NULL;
+	unix_get_secdata(scm, skb);
 	if (scm->fp && send_fds)
 		err = unix_attach_fds(scm, skb);
 
@@ -1509,7 +1520,6 @@ static int unix_dgram_sendmsg(struct socket *sock, struct msghdr *msg,
 	if (err < 0)
 		goto out_free;
 	max_level = err + 1;
-	unix_get_secdata(&scm, skb);
 
 	skb_put(skb, len - data_len);
 	skb->data_len = data_len;
@@ -2118,11 +2128,13 @@ unlock:
 			/* Never glue messages from different writers */
 			if ((UNIXCB(skb).pid  != scm.pid) ||
 			    !uid_eq(UNIXCB(skb).uid, scm.creds.uid) ||
-			    !gid_eq(UNIXCB(skb).gid, scm.creds.gid))
+			    !gid_eq(UNIXCB(skb).gid, scm.creds.gid) ||
+			    !unix_secdata_eq(&scm, skb))
 				break;
 		} else if (test_bit(SOCK_PASSCRED, &sock->flags)) {
 			/* Copy credentials */
 			scm_set_cred(&scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
+			unix_set_secdata(&scm, skb);
 			check_creds = true;
 		}
 
-- 
2.1.0

