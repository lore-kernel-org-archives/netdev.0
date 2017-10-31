From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix tcp_mtu_probe() vs highest_sack
Date: Mon, 30 Oct 2017 23:08:20 -0700
Message-ID: <1509430100.3828.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170921014620.GA20906@castle>
         <CAK6E8=eBZ6XhRg7ihoQ_2=4bTk1RSdxT2zJ_Z7-4X-HzNeaiQQ@mail.gmail.com>
         <CAK6E8=c3mNnjuWDaA8rjnCjn8mAih=ReQiZwGUgB5X2xrjaRiA@mail.gmail.com>
         <2325466.Xo6SG5M5hd@natalenko.name>
         <CAK6E8=eju-MgROynJXntRCQ4KtXZ+qrgQC02bGJ27rp1wMmUjg@mail.gmail.com>
         <20171026020724.bgobtktvcpkhco4h@ast-mbp>
         <CAK6E8=ddfOpvr9wqb+3bo+-pQm2XLXuLhGSQk6xk0Tb8-UvHeA@mail.gmail.com>
         <CANn89iKm6E6vJ6m81ULFZVoVO3B5-pshB0=wPdvYgbYS+Wg8eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Oleksandr Natalenko <oleksandr@natalenko.name>,
        Roman Gushchin <guro@fb.com>, netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Lawrence Brakmo <brakmo@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:50104 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751610AbdJaGIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 02:08:24 -0400
Received: by mail-io0-f196.google.com with SMTP id n137so32596612iod.6
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 23:08:24 -0700 (PDT)
In-Reply-To: <CANn89iKm6E6vJ6m81ULFZVoVO3B5-pshB0=wPdvYgbYS+Wg8eQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Based on SNMP values provided by Roman, Yuchung made the observation
that some crashes in tcp_sacktag_walk() might be caused by MTU probing.

Looking at tcp_mtu_probe(), I found that when a new skb was placed
in front of the write queue, we were not updating tcp highest sack.

If one skb is freed because all its content was copied to the new skb
(for MTU probing), then tp->highest_sack could point to a now freed skb.

Bad things would then happen, including infinite loops.

This patch renames tcp_highest_sack_combine() and uses it
from tcp_mtu_probe() to fix the bug.

Note that I also removed one test against tp->sacked_out,
since we want to replace tp->highest_sack regardless of whatever
condition, since keeping a stale pointer to freed skb is a recipe
for disaster.

Fixes: a47e5a988a57 ("[TCP]: Convert highest_sack to sk_buff to allow direct access")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Reported-by: Roman Gushchin <guro@fb.com>
Reported-by: Oleksandr Natalenko <oleksandr@natalenko.name>
---
 include/net/tcp.h     |    6 +++---
 net/ipv4/tcp_output.c |    3 ++-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 33599d17522d6a19b9d9a316cc1579cd5e71ee32..e6d0002a1b0bc5f28c331a760823c8dc92f8fe24 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1771,12 +1771,12 @@ static inline void tcp_highest_sack_reset(struct sock *sk)
 	tcp_sk(sk)->highest_sack = tcp_write_queue_head(sk);
 }
 
-/* Called when old skb is about to be deleted (to be combined with new skb) */
-static inline void tcp_highest_sack_combine(struct sock *sk,
+/* Called when old skb is about to be deleted and replaced by new skb */
+static inline void tcp_highest_sack_replace(struct sock *sk,
 					    struct sk_buff *old,
 					    struct sk_buff *new)
 {
-	if (tcp_sk(sk)->sacked_out && (old == tcp_sk(sk)->highest_sack))
+	if (old == tcp_highest_sack(sk))
 		tcp_sk(sk)->highest_sack = new;
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ae60dd3faed0adc71731bc686f878afd4c628d32..823003eef3a21a5cc5c27e0be9f46159afa060df 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2062,6 +2062,7 @@ static int tcp_mtu_probe(struct sock *sk)
 	nskb->ip_summed = skb->ip_summed;
 
 	tcp_insert_write_queue_before(nskb, skb, sk);
+	tcp_highest_sack_replace(sk, skb, nskb);
 
 	len = 0;
 	tcp_for_write_queue_from_safe(skb, next, sk) {
@@ -2665,7 +2666,7 @@ static bool tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 		else if (!skb_shift(skb, next_skb, next_skb_size))
 			return false;
 	}
-	tcp_highest_sack_combine(sk, next_skb, skb);
+	tcp_highest_sack_replace(sk, next_skb, skb);
 
 	tcp_unlink_write_queue(next_skb, sk);
 
