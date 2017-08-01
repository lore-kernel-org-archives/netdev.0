From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 08/10] net: Add sdif to sk_lookup
Date: Mon, 31 Jul 2017 20:13:24 -0700
Message-ID: <1501557206-27503-9-git-send-email-dsahern@gmail.com>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35660 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751740AbdHADNs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 23:13:48 -0400
Received: by mail-pg0-f67.google.com with SMTP id l64so571175pge.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 20:13:48 -0700 (PDT)
In-Reply-To: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a second device index, sdif, to the socket lookup struct. sdif
will be the device index for devices enslaved to an l3mdev. It allows
the lookups to consider the enslaved device as well as the L3 master
device when searching for a socket.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/sock.h | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index a2db5fd30192..c5d93a4bcd0a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -507,23 +507,27 @@ struct sk_lookup {
 	unsigned short hnum;
 
 	int dif;
+	int sdif;
 	bool exact_dif;
 };
 
-/* Compare sk_bound_dev_if to socket lookup dif
+/* Compare sk_bound_dev_if to socket lookup dif and sdif
  * Returns:
  *   -1   exact dif required and not met
  *    0   sk_bound_dev_if is either not set or does not match
- *    1   sk_bound_dev_if is set and matches dif
+ *    1   sk_bound_dev_if is set and matches dif or sdif
  */
 static inline int sk_lookup_device_cmp(const struct sock *sk,
 				       const struct sk_lookup *params)
 {
+	bool dev_match = (sk->sk_bound_dev_if == params->dif ||
+			  sk->sk_bound_dev_if == params->sdif);
+
 	/* exact_dif true == l3mdev case */
-	if (params->exact_dif && sk->sk_bound_dev_if != params->dif)
+	if (params->exact_dif && !dev_match)
 		return -1;
 
-	if (sk->sk_bound_dev_if && sk->sk_bound_dev_if == params->dif)
+	if (sk->sk_bound_dev_if && dev_match)
 		return 1;
 
 	return 0;
-- 
2.1.4
