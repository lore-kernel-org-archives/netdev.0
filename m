From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net] inet: Fix missing return value in inet6_hash
Date: Tue, 25 Oct 2016 18:08:49 -0400
Message-ID: <1477433329-165391-1-git-send-email-kraigatgoog@gmail.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:32919 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752476AbcJYWIx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 18:08:53 -0400
Received: by mail-qk0-f177.google.com with SMTP id n189so270026509qke.0
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 15:08:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

As part of a series to implement faster SO_REUSEPORT lookups,
commit 086c653f5862 ("sock: struct proto hash function may error")
added return values to protocol hash functions and
commit 496611d7b5ea ("inet: create IPv6-equivalent inet_hash function")
implemented a new hash function for IPv6.  However, the latter does
not respect the former's convention.

This properly propagates the hash errors in the IPv6 case.

Fixes: 496611d7b5ea ("inet: create IPv6-equivalent inet_hash function")
Reported-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Craig Gallek <kraig@google.com>
---
 net/ipv6/inet6_hashtables.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 2fd0374a35b1..02761c9fe43e 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -264,13 +264,15 @@ EXPORT_SYMBOL_GPL(inet6_hash_connect);
 
 int inet6_hash(struct sock *sk)
 {
+	int err = 0;
+
 	if (sk->sk_state != TCP_CLOSE) {
 		local_bh_disable();
-		__inet_hash(sk, NULL, ipv6_rcv_saddr_equal);
+		err = __inet_hash(sk, NULL, ipv6_rcv_saddr_equal);
 		local_bh_enable();
 	}
 
-	return 0;
+	return err;
 }
 EXPORT_SYMBOL_GPL(inet6_hash);
 
-- 
2.8.0.rc3.226.g39d4020
