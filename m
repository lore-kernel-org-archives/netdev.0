From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] netem: fix skb_orphan_partial()
Date: Thu, 11 May 2017 15:24:41 -0700
Message-ID: <1494541481.7796.124.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170511094758.2112b00f@xeon-e3>
         <1494522379.7796.112.camel@edumazet-glaptop3.roam.corp.google.com>
         <c5a4858f-1559-7c75-b224-99391e6bb6c4@nabto.com>
         <1494531770.7796.115.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Michael Madsen <mkm@nabto.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35022 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752472AbdEKWYo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 18:24:44 -0400
Received: by mail-pg0-f65.google.com with SMTP id i63so5098000pgd.2
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 15:24:44 -0700 (PDT)
In-Reply-To: <1494531770.7796.115.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I should have known that lowering skb->truesize was dangerous :/

In case packets are not leaving the host via a standard Ethernet device,
but looped back to local sockets, bad things can happen, as reported
by Michael Madsen ( https://bugzilla.kernel.org/show_bug.cgi?id=195713 )

So instead of tweaking skb->truesize, lets change skb->destructor
and keep a reference on the owner socket via its sk_refcnt.

Fixes: f2f872f9272a ("netem: Introduce skb_orphan_partial() helper")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Michael Madsen <mkm@nabto.com>
---
 net/core/sock.c |   20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 79c6aee6af9b817bd7086f04ae8f46342a3bf4b6..e43e71d7856b385111cd4c4b1bd835a78c670c60 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1803,28 +1803,24 @@ EXPORT_SYMBOL(skb_set_owner_w);
  * delay queue. We want to allow the owner socket to send more
  * packets, as if they were already TX completed by a typical driver.
  * But we also want to keep skb->sk set because some packet schedulers
- * rely on it (sch_fq for example). So we set skb->truesize to a small
- * amount (1) and decrease sk_wmem_alloc accordingly.
+ * rely on it (sch_fq for example).
  */
 void skb_orphan_partial(struct sk_buff *skb)
 {
-	/* If this skb is a TCP pure ACK or already went here,
-	 * we have nothing to do. 2 is already a very small truesize.
-	 */
-	if (skb->truesize <= 2)
+	if (skb_is_tcp_pure_ack(skb))
 		return;
 
-	/* TCP stack sets skb->ooo_okay based on sk_wmem_alloc,
-	 * so we do not completely orphan skb, but transfert all
-	 * accounted bytes but one, to avoid unexpected reorders.
-	 */
 	if (skb->destructor == sock_wfree
 #ifdef CONFIG_INET
 	    || skb->destructor == tcp_wfree
 #endif
 		) {
-		atomic_sub(skb->truesize - 1, &skb->sk->sk_wmem_alloc);
-		skb->truesize = 1;
+		struct sock *sk = skb->sk;
+
+		if (atomic_inc_not_zero(&sk->sk_refcnt)) {
+			atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
+			skb->destructor = sock_efree;
+		}
 	} else {
 		skb_orphan(skb);
 	}
