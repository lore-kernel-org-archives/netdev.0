From: Natale Patriciello <natale.patriciello@gmail.com>
Subject: [RFC PATCH v1 3/5] tcp: PSH frames sent without timer involved
Date: Fri, 28 Jul 2017 21:59:17 +0200
Message-ID: <20170728195919.10099-4-natale.patriciello@gmail.com>
References: <20170728195919.10099-1-natale.patriciello@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Natale Patriciello <natale.patriciello@gmail.com>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33854 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752859AbdG1UA4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 16:00:56 -0400
Received: by mail-wr0-f196.google.com with SMTP id o33so19741955wrb.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 13:00:56 -0700 (PDT)
In-Reply-To: <20170728195919.10099-1-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Segments flagged with 'PSH' should be sent as soon as possible,
ignoring the timing set by the congestion control (if any).
This patch avoids the waiting of 'PSH' segments in the TCP queue.

Signed-off-by: Natale Patriciello <natale.patriciello@gmail.com>
Tested-by: Ahmed Said <ahmed.said@uniroma2.it>
---
 net/ipv4/tcp.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 40aca7803cf2..ebaedbf75b63 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -975,9 +975,9 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 
 		if (forced_push(tp)) {
 			tcp_mark_push(tp, skb);
-			__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_PUSH);
-		} else if (skb == tcp_send_head(sk))
 			tcp_push_one(sk, mss_now);
+		} else if (skb == tcp_send_head(sk))
+			__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_PUSH);
 		continue;
 
 wait_for_sndbuf:
@@ -1320,9 +1320,9 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 
 		if (forced_push(tp)) {
 			tcp_mark_push(tp, skb);
-			__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_PUSH);
-		} else if (skb == tcp_send_head(sk))
 			tcp_push_one(sk, mss_now);
+		} else if (skb == tcp_send_head(sk))
+			__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_PUSH);
 		continue;
 
 wait_for_sndbuf:
-- 
2.13.2
