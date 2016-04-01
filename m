From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 10/11] ipv4: tcp: set SOCK_USE_WRITE_QUEUE for ip_send_unicast_reply()
Date: Fri,  1 Apr 2016 08:52:21 -0700
Message-ID: <1459525942-30399-11-git-send-email-edumazet@google.com>
References: <1459525942-30399-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:32843 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759107AbcDAPwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:52:49 -0400
Received: by mail-pa0-f52.google.com with SMTP id zm5so94044033pac.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:52:49 -0700 (PDT)
In-Reply-To: <1459525942-30399-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP uses per cpu 'sockets' to send some packets :
- RST packets ( tcp_v4_send_reset()) )
- ACK packets for SYN_RECV and TIMEWAIT sockets

By setting SOCK_USE_WRITE_QUEUE flag, we tell sock_wfree()
to not call sk_write_space() since these internal sockets
do not care.

This gives a small performance improvement, merely by allowing
cpu to properly predict the sock_wfree() conditional branch,
and avoiding one atomic operation.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f3ce0afe70aa..456ff3d6a132 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2384,6 +2384,7 @@ static int __net_init tcp_sk_init(struct net *net)
 					   IPPROTO_TCP, net);
 		if (res)
 			goto fail;
+		sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 		*per_cpu_ptr(net->ipv4.tcp_sk, cpu) = sk;
 	}
 
-- 
2.8.0.rc3.226.g39d4020
