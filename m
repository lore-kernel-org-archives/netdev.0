From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: reset timer after any SYNACK retransmit
Date: Mon, 29 Apr 2013 11:44:51 -0700
Message-ID: <1367261091-28052-1-git-send-email-ycheng@google.com>
Cc: hagen@jauu.net, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:60850 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758477Ab3D2Sui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 14:50:38 -0400
Received: by mail-qc0-f201.google.com with SMTP id o22so689609qcr.2
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 11:50:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux immediately returns SYNACK on (spurious) SYN retransmits, but
keeps the SYNACK timer running independently. Thus the timer may
fire right after the SYNACK retransmit and causes a SYN-SYNACK
cross-fire burst.

Adopt the fast retransmit/recovery idea in established state by
re-arming the SYNACK timer after the fast (SYNACK) retransmit. The
timer may fire late up to 500ms due to the current SYNACK timer wheel,
but it's OK to be conservative when network is congested. Eric's new
listener design should address this issue.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_minisocks.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 05eaf89..0f01788 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -551,8 +551,13 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 		 *
 		 * Note that even if there is new data in the SYN packet
 		 * they will be thrown away too.
+		 *
+		 * Reset timer after retransmitting SYNACK, similar to
+		 * the idea of fast retransmit in recovery.
 		 */
-		inet_rtx_syn_ack(sk, req);
+		if (!inet_rtx_syn_ack(sk, req))
+			req->expires = min(TCP_TIMEOUT_INIT << req->num_timeout,
+					   TCP_RTO_MAX) + jiffies;
 		return NULL;
 	}
 
-- 
1.8.2.1
