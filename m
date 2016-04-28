From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH v3 net] soreuseport: Fix TCP listener hash collision
Date: Thu, 28 Apr 2016 19:24:32 -0400
Message-ID: <1461885872-27358-1-git-send-email-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35617 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbcD1XYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 19:24:36 -0400
Received: by mail-ig0-f173.google.com with SMTP id bi2so7129575igb.0
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 16:24:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

I forgot to include a check for listener port equality when deciding
if two sockets should belong to the same reuseport group.  This was
not caught previously because it's only necessary when two listening
sockets for the same user happen to hash to the same listener bucket.
The same error does not exist in the UDP path.

Fixes: c125e80b8868("soreuseport: fast reuseport TCP socket selection")
Signed-off-by: Craig Gallek <kraig@google.com>
---
v3 Changes
  - Eric pointed out that the net namespace check isn't necessary when
    comparing bucket pointers.  They can not be equal across namespaces.
v2 Changes
  - Suggestions from Eric Dumazet to include network namespace equality
    check and to avoid a dreference by simply checking inet_bind_bucket
    pointer equality.
---
 net/ipv4/inet_hashtables.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index bc68eced0105..0d9e9d7bb029 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -470,6 +470,7 @@ static int inet_reuseport_add_sock(struct sock *sk,
 						     const struct sock *sk2,
 						     bool match_wildcard))
 {
+	struct inet_bind_bucket *tb = inet_csk(sk)->icsk_bind_hash;
 	struct sock *sk2;
 	struct hlist_nulls_node *node;
 	kuid_t uid = sock_i_uid(sk);
@@ -479,6 +480,7 @@ static int inet_reuseport_add_sock(struct sock *sk,
 		    sk2->sk_family == sk->sk_family &&
 		    ipv6_only_sock(sk2) == ipv6_only_sock(sk) &&
 		    sk2->sk_bound_dev_if == sk->sk_bound_dev_if &&
+		    inet_csk(sk2)->icsk_bind_hash == tb &&
 		    sk2->sk_reuseport && uid_eq(uid, sock_i_uid(sk2)) &&
 		    saddr_same(sk, sk2, false))
 			return reuseport_add_sock(sk, sk2);
-- 
2.8.0.rc3.226.g39d4020
