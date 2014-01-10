From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] inet_diag: fix inet_diag_dump_icsk() to use correct state for timewait sockets
Date: Fri, 10 Jan 2014 15:34:45 -0500
Message-ID: <1389386085-22659-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:48551 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758094AbaAJUmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 15:42:05 -0500
Received: by mail-qc0-f202.google.com with SMTP id i17so490134qcy.5
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 12:42:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix inet_diag_dump_icsk() to reflect the fact that both TCP_TIME_WAIT
and TCP_FIN_WAIT2 connections are represented by inet_timewait_sock
(not just TIME_WAIT), and for such sockets the tw_substate field holds
the real state, which can be either TCP_TIME_WAIT or TCP_FIN_WAIT2.

This brings the inet_diag state-matching code in line with the field
it uses to populate idiag_state. This is also analogous to the info
exported in /proc/net/tcp, where get_tcp4_sock() exports sk->sk_state
and get_timewait4_sock() exports tw->tw_substate.

Before fixing this, (a) neither "ss -nemoi" nor "ss -nemoi state
fin-wait-2" would return a socket in TCP_FIN_WAIT2; and (b) "ss -nemoi
state time-wait" would also return sockets in state TCP_FIN_WAIT2.

This is an old bug that predates 05dbc7b ("tcp/dccp: remove twchain").

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index a0f52da..e34dccb 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -930,12 +930,15 @@ skip_listen_ht:
 		spin_lock_bh(lock);
 		sk_nulls_for_each(sk, node, &head->chain) {
 			int res;
+			int state;
 
 			if (!net_eq(sock_net(sk), net))
 				continue;
 			if (num < s_num)
 				goto next_normal;
-			if (!(r->idiag_states & (1 << sk->sk_state)))
+			state = (sk->sk_state == TCP_TIME_WAIT) ?
+				inet_twsk(sk)->tw_substate : sk->sk_state;
+			if (!(r->idiag_states & (1 << state)))
 				goto next_normal;
 			if (r->sdiag_family != AF_UNSPEC &&
 			    sk->sk_family != r->sdiag_family)
-- 
1.8.5.1
