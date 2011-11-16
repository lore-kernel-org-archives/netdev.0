From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH 5/5] tcp: skip cwnd moderation in TCP_CA_Open in tcp_try_to_open
Date: Wed, 16 Nov 2011 13:58:05 -0500
Message-ID: <1321469885-10885-5-git-send-email-ncardwell@google.com>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f74.google.com ([74.125.82.74]:64323 "EHLO
	mail-ww0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962Ab1KPTGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 14:06:14 -0500
Received: by wwe5 with SMTP id 5so19639wwe.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 11:06:12 -0800 (PST)
In-Reply-To: <1321469885-10885-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem: Senders were overriding cwnd values picked during an undo
by calling tcp_moderate_cwnd() in tcp_try_to_open().

The fix: Don't moderate cwnd in tcp_try_to_open() if we're in
TCP_CA_Open, since doing so is generally unnecessary and specifically
would override a DSACK-based undo of a cwnd reduction made in fast
recovery.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a4efdd7..78dd38c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2881,7 +2881,8 @@ static void tcp_try_to_open(struct sock *sk, int flag)
 
 	if (inet_csk(sk)->icsk_ca_state != TCP_CA_CWR) {
 		tcp_try_keep_open(sk);
-		tcp_moderate_cwnd(tp);
+		if (inet_csk(sk)->icsk_ca_state != TCP_CA_Open)
+			tcp_moderate_cwnd(tp);
 	} else {
 		tcp_cwnd_down(sk, flag);
 	}
-- 
1.7.3.1
