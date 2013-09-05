From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: fix no cwnd growth after timeout
Date: Thu,  5 Sep 2013 15:36:09 -0700
Message-ID: <1378420569-12370-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:52668 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab3IEWgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 18:36:33 -0400
Received: by mail-qa0-f73.google.com with SMTP id bv4so29383qab.0
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 15:36:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 0f7cc9a3 "tcp: increase throughput when reordering is high",
it only allows cwnd to increase in Open state. This mistakenly disables
slow start after timeout (CA_Loss). Moreover cwnd won't grow if the
state moves from Disorder to Open later in tcp_fastretrans_alert().

Therefore the correct logic should be to allow cwnd to grow as long
as the data is received in order in Open, Loss, or even Disorder state.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1969e16..894bc17 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3162,16 +3162,14 @@ static inline bool tcp_may_raise_cwnd(const struct sock *sk, const int flag)
 
 	/* If reordering is high then always grow cwnd whenever data is
 	 * delivered regardless of its ordering. Otherwise stay conservative
-	 * and only grow cwnd on in-order delivery in Open state, and retain
-	 * cwnd in Disordered state (RFC5681). A stretched ACK with
+	 * and only grow cwnd on in-order delivery (RFC5681). A stretched ACK w/
 	 * new SACK or ECE mark may first advance cwnd here and later reduce
 	 * cwnd in tcp_fastretrans_alert() based on more states.
 	 */
 	if (tcp_sk(sk)->reordering > sysctl_tcp_reordering)
 		return flag & FLAG_FORWARD_PROGRESS;
 
-	return inet_csk(sk)->icsk_ca_state == TCP_CA_Open &&
-	       flag & FLAG_DATA_ACKED;
+	return flag & FLAG_DATA_ACKED;
 }
 
 /* Check that window update is acceptable.
-- 
1.8.4
