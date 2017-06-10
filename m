From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next 1/1] net: reflect mark on tcp syn ack packets
Date: Sat, 10 Jun 2017 09:31:01 -0400
Message-ID: <1497101461-20921-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, lorenzo@google.com, mrv@mojatatu.com,
        Jamal Hadi Salim <hadi@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34678 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751583AbdFJNb2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 09:31:28 -0400
Received: by mail-it0-f65.google.com with SMTP id 201so6405124itu.1
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 06:31:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@mojatatu.com>

SYN-ACK responses on a server in response to a SYN from a client
did not get the injected skb mark that was tagged on the SYN packet.

Fixes: 84f39b08d786 ("net: support marking accepting TCP sockets")
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/ipv4/ip_output.c  | 3 ++-
 net/ipv4/tcp_output.c | 2 ++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7a3fd25..a8fd5f0 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -173,7 +173,8 @@ int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
 	}
 
 	skb->priority = sk->sk_priority;
-	skb->mark = sk->sk_mark;
+	if (!skb->mark)
+		skb->mark = sk->sk_mark;
 
 	/* Send it out. */
 	return ip_local_out(net, skb->sk, skb);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9a9c395..8c3661a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3212,6 +3212,8 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	tcp_ecn_make_synack(req, th);
 	th->source = htons(ireq->ir_num);
 	th->dest = ireq->ir_rmt_port;
+	if (sock_net(sk)->ipv4.sysctl_tcp_fwmark_accept)
+		skb->mark = ireq->ir_mark;
 	/* Setting of flags are superfluous here for callers (and ECE is
 	 * not even correctly set)
 	 */
-- 
1.9.1
