From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp/dccp: fix inet_reuseport_add_sock()
Date: Wed, 06 Apr 2016 22:07:34 -0700
Message-ID: <1460005654.6473.377.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5705A392.2000207@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	edumazet@google.com
To: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:33525 "EHLO
	mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbcDGFHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 01:07:37 -0400
Received: by mail-yw0-f180.google.com with SMTP id t10so83697175ywa.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 22:07:37 -0700 (PDT)
In-Reply-To: <5705A392.2000207@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

David Ahern reported panics in __inet_hash() caused by my recent commit.

The reason is inet_reuseport_add_sock() was still using
sk_nulls_for_each_rcu() instead of sk_for_each_rcu().
SO_REUSEPORT enabled listeners were causing an instant crash.

While chasing this bug, I found that I forgot to clear SOCK_RCU_FREE
flag, as it is inherited from the parent at clone time.

Fixes: 3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under synflood")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/inet_connection_sock.c |    3 +++
 net/ipv4/inet_hashtables.c      |    3 +--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index bc5196ea1bdf..ab69da2d2a77 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -661,6 +661,9 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
 		inet_sk(newsk)->inet_sport = htons(inet_rsk(req)->ir_num);
 		newsk->sk_write_space = sk_stream_write_space;
 
+		/* listeners have SOCK_RCU_FREE, not the children */
+		sock_reset_flag(newsk, SOCK_RCU_FREE);
+
 		newsk->sk_mark = inet_rsk(req)->ir_mark;
 		atomic64_set(&newsk->sk_cookie,
 			     atomic64_read(&inet_rsk(req)->ir_cookie));
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 98ba03b6f87d..fcadb670f50b 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -439,10 +439,9 @@ static int inet_reuseport_add_sock(struct sock *sk,
 						     bool match_wildcard))
 {
 	struct sock *sk2;
-	struct hlist_nulls_node *node;
 	kuid_t uid = sock_i_uid(sk);
 
-	sk_nulls_for_each_rcu(sk2, node, &ilb->head) {
+	sk_for_each_rcu(sk2, &ilb->head) {
 		if (sk2 != sk &&
 		    sk2->sk_family == sk->sk_family &&
 		    ipv6_only_sock(sk2) == ipv6_only_sock(sk) &&
