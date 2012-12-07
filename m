From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/10] tipc: add lock nesting notation to quiet lockdep warning
Date: Fri, 7 Dec 2012 09:28:17 -0500
Message-ID: <1354890498-6448-10-git-send-email-paul.gortmaker@windriver.com>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45652 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030766Ab2LGO2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 09:28:39 -0500
In-Reply-To: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

TIPC accept() call grabs the socket lock on a newly allocated
socket while holding the socket lock on an old socket. But lockdep
worries that this might be a recursive lock attempt:

  [ INFO: possible recursive locking detected ]
  ---------------------------------------------
  kworker/u:0/6 is trying to acquire lock:
  (sk_lock-AF_TIPC){+.+.+.}, at: [<c8c1226c>] accept+0x15c/0x310 [tipc]

  but task is already holding lock:
  (sk_lock-AF_TIPC){+.+.+.}, at: [<c8c12138>] accept+0x28/0x310 [tipc]

  other info that might help us debug this:
  Possible unsafe locking scenario:

          CPU0
          ----
          lock(sk_lock-AF_TIPC);
          lock(sk_lock-AF_TIPC);

          *** DEADLOCK ***

  May be due to missing lock nesting notation
  [...]

Tell lockdep that this locking is safe by using lock_sock_nested().
This is similar to what was done in commit 5131a184a3458d9 for
SCTP code ("SCTP: lock_sock_nested in sctp_sock_migrate").

Also note that this is isn't something that is seen normally,
as it was uncovered with some experimental work-in-progress
code not yet ready for mainline.  So no need for stable
backports or similar of this commit.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 0df42fa..38613cf 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1551,7 +1551,8 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 		u32 new_ref = new_tport->ref;
 		struct tipc_msg *msg = buf_msg(buf);
 
-		lock_sock(new_sk);
+		/* we lock on new_sk; but lockdep sees the lock on sk */
+		lock_sock_nested(new_sk, SINGLE_DEPTH_NESTING);
 
 		/*
 		 * Reject any stray messages received by new socket
-- 
1.7.12.1
