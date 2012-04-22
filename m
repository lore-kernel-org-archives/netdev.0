From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] tcp: fix TCP_MAXSEG for established IPv6 passive sockets
Date: Sun, 22 Apr 2012 15:45:47 -0400
Message-ID: <1335123947-9906-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>, ilpo.jarvinen@helsinki.fi,
	maze@google.com, Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f202.google.com ([209.85.220.202]:47266 "EHLO
	mail-vx0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643Ab2DVTpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2012 15:45:52 -0400
Received: by vcbfk26 with SMTP id fk26so1269098vcb.1
        for <netdev@vger.kernel.org>; Sun, 22 Apr 2012 12:45:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f5fff5d forgot to fix TCP_MAXSEG behavior IPv6 sockets, so IPv6
TCP server sockets that used TCP_MAXSEG would find that the advmss of
child sockets would be incorrect. This commit mirrors the advmss logic
from tcp_v4_syn_recv_sock in tcp_v6_syn_recv_sock. Eventually this
logic should probably be shared between IPv4 and IPv6, but this at
least fixes this issue.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv6/tcp_ipv6.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 86cfe60..98256cf 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1383,6 +1383,10 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	tcp_mtup_init(newsk);
 	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric_advmss(dst);
+	if (tcp_sk(sk)->rx_opt.user_mss &&
+	    tcp_sk(sk)->rx_opt.user_mss < newtp->advmss)
+		newtp->advmss = tcp_sk(sk)->rx_opt.user_mss;
+
 	tcp_initialize_rcv_mss(newsk);
 	if (tcp_rsk(req)->snt_synack)
 		tcp_valid_rtt_meas(newsk,
-- 
1.7.7.3
