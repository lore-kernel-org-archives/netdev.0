From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] sock_diag: do not broadcast raw socket destruction
Date: Fri, 24 Jun 2016 16:02:35 -0400
Message-ID: <1466798555-40125-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, kraig@google.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34878 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbcFXUCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 16:02:39 -0400
Received: by mail-it0-f67.google.com with SMTP id g127so3631877ith.2
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 13:02:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Diag intends to broadcast tcp_sk and udp_sk socket destruction.
Testing sk->sk_protocol for IPPROTO_TCP/IPPROTO_UDP alone is not
sufficient for this. Raw sockets can have the same type.

Add a test for sk->sk_type.

Fixes: eb4cb008529c ("sock_diag: define destruction multicast groups")
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/sock_diag.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 4018b48..a0596ca0 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -36,6 +36,9 @@ enum sknetlink_groups sock_diag_destroy_group(const struct sock *sk)
 {
 	switch (sk->sk_family) {
 	case AF_INET:
+		if (sk->sk_type == SOCK_RAW)
+			return SKNLGRP_NONE;
+
 		switch (sk->sk_protocol) {
 		case IPPROTO_TCP:
 			return SKNLGRP_INET_TCP_DESTROY;
@@ -45,6 +48,9 @@ enum sknetlink_groups sock_diag_destroy_group(const struct sock *sk)
 			return SKNLGRP_NONE;
 		}
 	case AF_INET6:
+		if (sk->sk_type == SOCK_RAW)
+			return SKNLGRP_NONE;
+
 		switch (sk->sk_protocol) {
 		case IPPROTO_TCP:
 			return SKNLGRP_INET6_TCP_DESTROY;
-- 
2.8.0.rc3.226.g39d4020
