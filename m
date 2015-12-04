From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net 2/3] sctp: update the netstamp_needed counter when copying sockets
Date: Fri,  4 Dec 2015 15:14:04 -0200
Message-ID: <351c05ec8d79bdc03f38c021bb112d29908a6a5e.1449249050.git.marcelo.leitner@gmail.com>
References: <20151203184316.GF4164@mrl.redhat.com> <cover.1449249050.git.marcelo.leitner@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	linux-sctp@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756202AbbLDRPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 12:15:03 -0500
In-Reply-To: <cover.1449249050.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Vyukov reported that SCTP was triggering a WARN on socket destroy
related to disabling sock timestamp.

When SCTP accepts an association or peel one off, it copies sock flags
but forgot to call net_enable_timestamp() if a packet timestamping flag
was copied, leading to extra calls to net_disable_timestamp() whenever
such clones were closed.

The fix is to call net_enable_timestamp() whenever we copy a sock with
that flag on, like tcp does.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sock.h | 2 ++
 net/core/sock.c    | 2 --
 net/sctp/socket.c  | 3 +++
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 52d27ee924f47867026d8f65c65551a9137219d3..b1d475b5db6825e13df3e3e147fed8654e1cf086 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -740,6 +740,8 @@ enum sock_flags {
 	SOCK_SELECT_ERR_QUEUE, /* Wake select on error queue */
 };
 
+#define SK_FLAGS_TIMESTAMP ((1UL << SOCK_TIMESTAMP) | (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE))
+
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
 {
 	nsk->sk_flags = osk->sk_flags;
diff --git a/net/core/sock.c b/net/core/sock.c
index e31dfcee1729aa23bdd2ed692fda1b90bd75afb8..d01c8f42dbb2f040fd48009b2767bd4e80aea8ab 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -433,8 +433,6 @@ static bool sock_needs_netstamp(const struct sock *sk)
 	}
 }
 
-#define SK_FLAGS_TIMESTAMP ((1UL << SOCK_TIMESTAMP) | (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE))
-
 static void sock_disable_timestamp(struct sock *sk, unsigned long flags)
 {
 	if (sk->sk_flags & flags) {
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 03c8256063ec6355fcce034366aa5d005d75b5f7..4c9282bdd06790a0cca7f7c33986e7eb6c541398 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -7199,6 +7199,9 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
 	newinet->mc_ttl = 1;
 	newinet->mc_index = 0;
 	newinet->mc_list = NULL;
+
+	if (newsk->sk_flags & SK_FLAGS_TIMESTAMP)
+		net_enable_timestamp();
 }
 
 static inline void sctp_copy_descendant(struct sock *sk_to,
-- 
2.5.0
