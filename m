From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH v2 net] udpv6: reset daddr and dport in sk if connect() fails
Date: Thu, 22 Jun 2017 12:03:41 -0700
Message-ID: <20170622190341.87998-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33676 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753367AbdFVTE1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 15:04:27 -0400
Received: by mail-pf0-f195.google.com with SMTP id w12so4268988pfk.0
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 12:04:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

In __ip6_datagram_connect(), reset sk->sk_v6_daddr and inet->dport if
error occurs so that udp_v6_early_demux() won't consider this socket
as a valid candidate for early demux.

v2: fix compilation error

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Maciej Żenczykowski <maze@google.com>
---
 net/ipv6/datagram.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

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
-- 
2.13.1.611.g7e3b11ae1-goog
