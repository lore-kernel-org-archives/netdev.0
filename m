From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net v2 1/1] net: reflect mark on tcp syn ack packets
Date: Mon,  3 Jul 2017 09:51:50 -0400
Message-ID: <1499089910-20034-2-git-send-email-jhs@emojatatu.com>
References: <1499089910-20034-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, lorenzo@google.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32972 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934032AbdGCNwD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 09:52:03 -0400
Received: by mail-io0-f195.google.com with SMTP id z62so8558149ioi.0
        for <netdev@vger.kernel.org>; Mon, 03 Jul 2017 06:52:03 -0700 (PDT)
In-Reply-To: <1499089910-20034-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

SYN-ACK responses on a server in response to a SYN from a client
did not get the injected skb mark that was tagged on the SYN packet.

Fixes: 84f39b08d786 ("net: support marking accepting TCP sockets")
Reviewed-by: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/ipv4/ip_output.c  | 3 ++-
 net/ipv4/tcp_output.c | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 532b36e..94b36d9 100644
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
index 4858e19..b1604d0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3134,6 +3134,7 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	tcp_ecn_make_synack(req, th);
 	th->source = htons(ireq->ir_num);
 	th->dest = ireq->ir_rmt_port;
+	skb->mark = ireq->ir_mark;
 	/* Setting of flags are superfluous here for callers (and ECE is
 	 * not even correctly set)
 	 */
-- 
1.9.1
