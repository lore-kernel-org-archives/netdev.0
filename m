From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net] soreuseport: fix NULL ptr dereference SO_REUSEPORT after bind
Date: Tue, 19 Jan 2016 14:27:08 -0500
Message-ID: <1453231628-18603-1-git-send-email-kraigatgoog@gmail.com>
Cc: marc.c.dionne@gmail.com
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36606 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932980AbcAST1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 14:27:12 -0500
Received: by mail-qg0-f42.google.com with SMTP id e32so500519680qgf.3
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 11:27:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

Marc Dionne discovered a NULL pointer dereference when setting
SO_REUSEPORT on a socket after it is bound.
This patch removes the assumption that at least one socket in the
reuseport group is bound with the SO_REUSEPORT option before other
bind calls occur.

Fixes: e32ea7e74727 ("soreuseport: fast reuseport UDP socket selection")
Reported-by: Marc Dionne <marc.c.dionne@gmail.com>
Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/net/sock_reuseport.h | 2 +-
 net/core/sock_reuseport.c    | 9 ++++++++-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/net/sock_reuseport.h b/include/net/sock_reuseport.h
index 7dda3d7adba8..aecd30308d50 100644
--- a/include/net/sock_reuseport.h
+++ b/include/net/sock_reuseport.h
@@ -16,7 +16,7 @@ struct sock_reuseport {
 };
 
 extern int reuseport_alloc(struct sock *sk);
-extern int reuseport_add_sock(struct sock *sk, const struct sock *sk2);
+extern int reuseport_add_sock(struct sock *sk, struct sock *sk2);
 extern void reuseport_detach_sock(struct sock *sk);
 extern struct sock *reuseport_select_sock(struct sock *sk,
 					  u32 hash,
diff --git a/net/core/sock_reuseport.c b/net/core/sock_reuseport.c
index 1df98c557440..e92b759d906c 100644
--- a/net/core/sock_reuseport.c
+++ b/net/core/sock_reuseport.c
@@ -93,10 +93,17 @@ static struct sock_reuseport *reuseport_grow(struct sock_reuseport *reuse)
  *  @sk2: Socket belonging to the existing reuseport group.
  *  May return ENOMEM and not add socket to group under memory pressure.
  */
-int reuseport_add_sock(struct sock *sk, const struct sock *sk2)
+int reuseport_add_sock(struct sock *sk, struct sock *sk2)
 {
 	struct sock_reuseport *reuse;
 
+	if (!rcu_access_pointer(sk2->sk_reuseport_cb)) {
+		int err = reuseport_alloc(sk2);
+
+		if (err)
+			return err;
+	}
+
 	spin_lock_bh(&reuseport_lock);
 	reuse = rcu_dereference_protected(sk2->sk_reuseport_cb,
 					  lockdep_is_held(&reuseport_lock)),
-- 
2.6.0.rc2.230.g3dd15c0
