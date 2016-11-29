From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/2] tcp: allow to turn tcp timestamp randomization off
Date: Tue, 29 Nov 2016 16:45:42 +0100
Message-ID: <1480434342-12367-2-git-send-email-fw@strlen.de>
References: <1480434342-12367-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:42224 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755727AbcK2Ppf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:45:35 -0500
In-Reply-To: <1480434342-12367-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric says: "By looking at tcpdump, and TS val of xmit packets of multiple
flows, we can deduct the relative qdisc delays (think of fq pacing).
This should work even if we have one flow per remote peer."

Having random per flow (or host) offsets doesn't allow that anymore so add
a way to turn this off.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Documentation/networking/ip-sysctl.txt |  9 +++++++--
 net/ipv4/tcp_input.c                   | 10 +++++++---
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 5af48dd7c5fc..de2448313799 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -610,8 +610,13 @@ tcp_syn_retries - INTEGER
 	with the current initial RTO of 1second. With this the final timeout
 	for an active TCP connection attempt will happen after 127seconds.
 
-tcp_timestamps - BOOLEAN
-	Enable timestamps as defined in RFC1323.
+tcp_timestamps - INTEGER
+Enable timestamps as defined in RFC1323.
+	0: Disabled.
+	1: Enable timestamps as defined in RFC1323.
+	2: Like 1, but also use a random offset for each connection
+	rather than only using the current time.
+	Default: 2
 
 tcp_min_tso_segs - INTEGER
 	Minimal number of segments per TSO frame.
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1b1921c71f7c..ebed73703198 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -76,7 +76,7 @@
 #include <asm/unaligned.h>
 #include <linux/errqueue.h>
 
-int sysctl_tcp_timestamps __read_mostly = 1;
+int sysctl_tcp_timestamps __read_mostly = 2;
 int sysctl_tcp_window_scaling __read_mostly = 1;
 int sysctl_tcp_sack __read_mostly = 1;
 int sysctl_tcp_fack __read_mostly = 1;
@@ -6323,10 +6323,12 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
-	if (isn && tmp_opt.tstamp_ok)
+	if (isn && tmp_opt.tstamp_ok && sysctl_tcp_timestamps == 2)
 		af_ops->init_seq(skb, &tcp_rsk(req)->ts_off);
 
 	if (!want_cookie && !isn) {
+		u32 ts_off;
+
 		/* VJ's idea. We save last timestamp seen
 		 * from the destination in peer table, when entering
 		 * state TIME-WAIT, and check against it before
@@ -6366,7 +6368,9 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 			goto drop_and_release;
 		}
 
-		isn = af_ops->init_seq(skb, &tcp_rsk(req)->ts_off);
+		isn = af_ops->init_seq(skb, &ts_off);
+		if (sysctl_tcp_timestamps == 2)
+			tcp_rsk(req)->ts_off = ts_off;
 	}
 	if (!dst) {
 		dst = af_ops->route_req(sk, &fl, req, NULL);
-- 
2.7.3
