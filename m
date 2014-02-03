From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-stable 3.3..3.12] inet_diag: fix inet_diag_dump_icsk() timewait socket state logic
Date: Sun,  2 Feb 2014 20:40:13 -0500
Message-ID: <1391391613-687-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:63090 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbaBCBkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Feb 2014 20:40:21 -0500
Received: by mail-pd0-f201.google.com with SMTP id q10so911828pdj.4
        for <netdev@vger.kernel.org>; Sun, 02 Feb 2014 17:40:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix inet_diag_dump_icsk() to reflect the fact that both TIME_WAIT and
FIN_WAIT2 connections are represented by inet_timewait_sock (not just
TIME_WAIT). Thus:

(a) We need to iterate through the time_wait buckets if the user wants
either TIME_WAIT or FIN_WAIT2. (Before fixing this, "ss -nemoi state
fin-wait-2" would not return any sockets, even if there were some in
FIN_WAIT2.)

(b) We need to check tw_substate to see if the user wants to dump
sockets in the particular substate (TIME_WAIT or FIN_WAIT2) that a
given connection is in. (Before fixing this, "ss -nemoi state
time-wait" would actually return sockets in state FIN_WAIT2.)

An analogous fix is in v3.13: 70315d22d3c7383f9a508d0aab21e2eb35b2303a
("inet_diag: fix inet_diag_dump_icsk() to use correct state for
timewait sockets") but that patch is quite different because 3.13 code
is very different in this area due to the unification of TCP hash
tables in 05dbc7b ("tcp/dccp: remove twchain") in v3.13-rc1.

I tested that this applies cleanly between v3.3 and v3.12, and tested
that it works in both 3.3 and 3.12. It does not apply cleanly to 3.2
and earlier (though it makes semantic sense), and semantically is not
the right fix for 3.13 and beyond (as mentioned above).

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 5f64875..7d5126e 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -945,7 +945,7 @@ next_normal:
 			++num;
 		}
 
-		if (r->idiag_states & TCPF_TIME_WAIT) {
+		if (r->idiag_states & (TCPF_TIME_WAIT | TCPF_FIN_WAIT2)) {
 			struct inet_timewait_sock *tw;
 
 			inet_twsk_for_each(tw, node,
@@ -955,6 +955,8 @@ next_normal:
 
 				if (num < s_num)
 					goto next_dying;
+				if (!(r->idiag_states & (1 << tw->tw_substate)))
+					goto next_dying;
 				if (r->sdiag_family != AF_UNSPEC &&
 						tw->tw_family != r->sdiag_family)
 					goto next_dying;
-- 
1.9.0.rc1.175.g0b1dcb5
