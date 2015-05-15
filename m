From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net] tcp/ipv6: fix flow label setting in TIME_WAIT state
Date: Sat, 16 May 2015 00:24:59 +0200
Message-ID: <1431728699-7767-1-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1431438429.566.79.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:34186 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932319AbbEOWeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 18:34:09 -0400
In-Reply-To: <1431438429.566.79.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1d13a96c74fc ("ipv6: tcp: fix flowlabel value in ACK messages
send from TIME_WAIT") added the flow label in the last TCP packets.
Unfortunately, it was not casted properly.

This patch replace the buggy shift with be32_to_cpu/cpu_to_be32.

Fixes: 1d13a96c74fc ("ipv6: tcp: fix flowlabel value in ACK messages")
Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv4/tcp_minisocks.c | 2 +-
 net/ipv6/tcp_ipv6.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index ebe2ab2..d322e84 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -300,7 +300,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 			tw->tw_v6_daddr = sk->sk_v6_daddr;
 			tw->tw_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
 			tw->tw_tclass = np->tclass;
-			tw->tw_flowlabel = np->flow_label >> 12;
+			tw->tw_flowlabel = be32_to_cpu(np->flow_label & IPV6_FLOWLABEL_MASK);
 			tw->tw_ipv6only = sk->sk_ipv6only;
 		}
 #endif
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b6575d6..3adffb3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -914,7 +914,7 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
 			tcp_time_stamp + tcptw->tw_ts_offset,
 			tcptw->tw_ts_recent, tw->tw_bound_dev_if, tcp_twsk_md5_key(tcptw),
-			tw->tw_tclass, (tw->tw_flowlabel << 12));
+			tw->tw_tclass, cpu_to_be32(tw->tw_flowlabel));
 
 	inet_twsk_put(tw);
 }
-- 
2.1.4
