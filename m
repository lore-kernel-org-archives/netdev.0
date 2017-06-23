From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH v3 net] net: ipv6: reset daddr and dport in sk if connect() fails
Date: Fri, 23 Jun 2017 15:25:37 -0700
Message-ID: <20170623222537.130493-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33007 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752606AbdFWWZp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 18:25:45 -0400
Received: by mail-pf0-f196.google.com with SMTP id w12so9220547pfk.0
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 15:25:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

In __ip6_datagram_connect(), reset sk->sk_v6_daddr and inet->dport if
error occurs.
In udp_v6_early_demux(), check for sk_state to make sure it is in
TCP_ESTABLISHED state.
Together, it makes sure unconnected UDP socket won't be considered as a
valid candidate for early demux.

Fixes: 5425077d73e0 ("net: ipv6: Add early demux handler for UDP unicast")

v3: add TCP_ESTABLISHED state check in udp_v6_early_demux()
v2: fix compilation error

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Maciej Żenczykowski <maze@google.com>
---
 net/ipv6/datagram.c | 8 +++++++-
 net/ipv6/udp.c      | 3 ++-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index e011122ebd43..5c786f5ab961 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -250,8 +250,14 @@ int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr,
 	 */
 
 	err = ip6_datagram_dst_update(sk, true);
-	if (err)
+	if (err) {
+		/* Reset daddr and dport so that udp_v6_early_demux()
+		 * fails to find this socket
+		 */
+		memset(&sk->sk_v6_daddr, 0, sizeof(sk->sk_v6_daddr));
+		inet->inet_dport = 0;
 		goto out;
+	}
 
 	sk->sk_state = TCP_ESTABLISHED;
 	sk_set_txhash(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 2b33847bf931..d494b2621b11 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -880,7 +880,8 @@ static struct sock *__udp6_lib_demux_lookup(struct net *net,
 	struct sock *sk;
 
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
-		if (INET6_MATCH(sk, net, rmt_addr, loc_addr, ports, dif))
+		if (sk->sk_state == TCP_ESTABLISHED &&
+		    INET6_MATCH(sk, net, rmt_addr, loc_addr, ports, dif))
 			return sk;
 		/* Only check first socket in chain */
 		break;
-- 
2.13.1.611.g7e3b11ae1-goog
