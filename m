From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] netns: Don't leak others' openreq-s in proc
Date: Mon, 22 Nov 2010 16:26:12 +0300
Message-ID: <4CEA6F74.6010107@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:30468 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753587Ab0KVN0U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Nov 2010 08:26:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The /proc/net/tcp leaks openreq sockets from other namespaces.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 69ccbc1..e13da6d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2043,7 +2043,9 @@ get_req:
 	}
 get_sk:
 	sk_nulls_for_each_from(sk, node) {
-		if (sk->sk_family == st->family && net_eq(sock_net(sk), net)) {
+		if (!net_eq(sock_net(sk), net))
+			continue;
+		if (sk->sk_family == st->family) {
 			cur = sk;
 			goto out;
 		}
