From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] af_unix: introduce unix_sk_const helper
Date: Tue, 06 Oct 2015 22:52:46 +0200
Message-ID: <10735490.HC94hyceBX@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Aaron Conole <aconole@bytheb.org>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	linux-security-module@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 124613012db1 ("af_unix: Convert the unix_sk macro to an inline
function for type safety") was recently added to catch incorrect
uses of the unix_sk helper using compiler warnings.

It has now caught one such case in lsm_audit.c. The code is technically
correct, but as it converts a const pointer to a non-const pointer,
the annotation got lost, which gcc now warns about.

This patch avoids the warning by introducing an additional helper
that has const input and output, which makes the lsm_audit code build
cleanly again.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
I'm not entirely happy with this workaround myself, but could not come
up with a better one.

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index cb1b9bbda332..1871b6436ee9 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -69,6 +69,11 @@ static inline struct unix_sock *unix_sk(struct sock *sk)
 	return (struct unix_sock *)sk;
 }
 
+static inline const struct unix_sock *unix_sk_const(const struct sock *sk)
+{
+	return (const struct unix_sock *)sk;
+}
+
 #define peer_wait peer_wq.wait
 
 long unix_inq_len(struct sock *sk);
diff --git a/security/lsm_audit.c b/security/lsm_audit.c
index 2deace208db2..cb07f1318a27 100644
--- a/security/lsm_audit.c
+++ b/security/lsm_audit.c
@@ -307,7 +307,7 @@ static void dump_common_audit_data(struct audit_buffer *ab,
 	case LSM_AUDIT_DATA_NET:
 		if (a->u.net->sk) {
 			const struct sock *sk = a->u.net->sk;
-			struct unix_sock *u;
+			const struct unix_sock *u;
 			int len = 0;
 			char *p = NULL;
 
@@ -337,7 +337,7 @@ static void dump_common_audit_data(struct audit_buffer *ab,
 			}
 #endif
 			case AF_UNIX:
-				u = unix_sk(sk);
+				u = unix_sk_const(sk);
 				if (u->path.dentry) {
 					audit_log_d_path(ab, " path=", &u->path);
 					break;
