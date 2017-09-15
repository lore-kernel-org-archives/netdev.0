From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix data delivery rate
Date: Fri, 15 Sep 2017 16:47:42 -0700
Message-ID: <1505519262.29839.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <3c750ac3-8739-89ed-ce41-d4cde755171e@huawei.com>
         <1505313647.15310.165.camel@edumazet-glaptop3.roam.corp.google.com>
         <1505359839.15310.209.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170915.143706.992734259378949259.davem@davemloft.net>
         <1505517411.29839.1.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: liujian56@huawei.com, edumazet@google.com, ycheng@google.com,
        hkchu@google.com, netdev@vger.kernel.org, weiyongjun1@huawei.com,
        wangkefeng.wang@huawei.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34958 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751197AbdIOXro (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 19:47:44 -0400
Received: by mail-pg0-f67.google.com with SMTP id j16so2036649pga.2
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 16:47:44 -0700 (PDT)
In-Reply-To: <1505517411.29839.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Now skb->mstamp_skb is updated later, we also need to call
tcp_rate_skb_sent() after the update is done.

Fixes: 8c72c65b426b ("tcp: update skb->skb_mstamp more carefully")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a85a8c2948e54b931f8cd956aa7938f7efd355bd..1c839c99114cd22bbfbd181cf702acccb3aeb61b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1002,8 +1002,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	if (clone_it) {
 		TCP_SKB_CB(skb)->tx.in_flight = TCP_SKB_CB(skb)->end_seq
 			- tp->snd_una;
-		tcp_rate_skb_sent(sk, skb);
-
 		oskb = skb;
 		if (unlikely(skb_cloned(skb)))
 			skb = pskb_copy(skb, gfp_mask);
@@ -1128,9 +1126,10 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		tcp_enter_cwr(sk);
 		err = net_xmit_eval(err);
 	}
-	if (!err && oskb)
+	if (!err && oskb) {
 		oskb->skb_mstamp = tp->tcp_mstamp;
-
+		tcp_rate_skb_sent(sk, oskb);
+	}
 	return err;
 }
 
