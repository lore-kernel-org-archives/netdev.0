From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH] NetLabel: Fix memory leak in SELinux glue code
Date: Fri, 18 Jan 2008 22:26:13 -0500
Message-ID: <20080119032613.8942.71850.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: cebbert@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:50574
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759811AbYASD34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 22:29:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a memory leak in security_netlbl_sid_to_secattr() as reported here:
 * https://bugzilla.redhat.com/show_bug.cgi?id=352281

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 security/selinux/netlabel.c    |    7 +++++--
 security/selinux/ss/services.c |    2 --
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index d243ddc..66e013d 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -53,10 +53,11 @@ static int selinux_netlbl_sock_setsid(struct sock *sk, u32 sid)
 	struct sk_security_struct *sksec = sk->sk_security;
 	struct netlbl_lsm_secattr secattr;
 
+	netlbl_secattr_init(&secattr);
+
 	rc = security_netlbl_sid_to_secattr(sid, &secattr);
 	if (rc != 0)
-		return rc;
-
+		goto sock_setsid_return;
 	rc = netlbl_sock_setattr(sk, &secattr);
 	if (rc == 0) {
 		spin_lock_bh(&sksec->nlbl_lock);
@@ -64,6 +65,8 @@ static int selinux_netlbl_sock_setsid(struct sock *sk, u32 sid)
 		spin_unlock_bh(&sksec->nlbl_lock);
 	}
 
+sock_setsid_return:
+	netlbl_secattr_destroy(&secattr);
 	return rc;
 }
 
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index d572dc9..f83b19d 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -2606,8 +2606,6 @@ int security_netlbl_sid_to_secattr(u32 sid, struct netlbl_lsm_secattr *secattr)
 	int rc = -ENOENT;
 	struct context *ctx;
 
-	netlbl_secattr_init(secattr);
-
 	if (!ss_initialized)
 		return 0;
 

