From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add __sock_wfree() helper
Date: Mon, 02 May 2016 10:56:27 -0700
Message-ID: <1462211787.5535.269.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36800 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753818AbcEBR43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 13:56:29 -0400
Received: by mail-pa0-f44.google.com with SMTP id bt5so76515503pac.3
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 10:56:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Hosts sending lot of ACK packets exhibit high sock_wfree() cost
because of cache line miss to test SOCK_USE_WRITE_QUEUE

We could move this flag close to sk_wmem_alloc but it is better
to perform the atomic_sub_and_test() on a clean cache line,
as it avoid one extra bus transaction.

skb_orphan_partial() can also have a fast track for packets that either
are TCP acks, or already went through another skb_orphan_partial()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h    |    1 +
 net/core/sock.c       |   24 ++++++++++++++++++++++++
 net/ipv4/tcp_output.c |    2 +-
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 3df778ccaa820b00b4038feedae30cd444e9a212..9be2ffb4b8fcf54cc9c8bd73628dd7572b1d783d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1434,6 +1434,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority);
 
 struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
 			     gfp_t priority);
+void __sock_wfree(struct sk_buff *skb);
 void sock_wfree(struct sk_buff *skb);
 void skb_orphan_partial(struct sk_buff *skb);
 void sock_rfree(struct sk_buff *skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index e16a5db853c6f455b0ac826744d0ee5e96a44863..e1151f11eb4aa0a5afa95bfee9d00a85c4d50af6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1655,6 +1655,17 @@ void sock_wfree(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_wfree);
 
+/* This variant of sock_wfree() is used by TCP,
+ * since it sets SOCK_USE_WRITE_QUEUE.
+ */
+void __sock_wfree(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+
+	if (atomic_sub_and_test(skb->truesize, &sk->sk_wmem_alloc))
+		__sk_free(sk);
+}
+
 void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 {
 	skb_orphan(skb);
@@ -1677,8 +1688,21 @@ void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 }
 EXPORT_SYMBOL(skb_set_owner_w);
 
+/* This helper is used by netem, as it can hold packets in its
+ * delay queue. We want to allow the owner socket to send more
+ * packets, as if they were already TX completed by a typical driver.
+ * But we also want to keep skb->sk set because some packet schedulers
+ * rely on it (sch_fq for example). So we set skb->truesize to a small
+ * amount (1) and decrease sk_wmem_alloc accordingly.
+ */
 void skb_orphan_partial(struct sk_buff *skb)
 {
+	/* If this skb is a TCP pure ACK or already went here,
+	 * we have nothing to do. 2 is already a very small truesize.
+	 */
+	if (skb->truesize <= 2)
+		return;
+
 	/* TCP stack sets skb->ooo_okay based on sk_wmem_alloc,
 	 * so we do not completely orphan skb, but transfert all
 	 * accounted bytes but one, to avoid unexpected reorders.
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1a487ff95d4c0572737e4f972666229f12ef1e08..778ac8f2d84be389478e4d92335e1979482b3817 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -949,7 +949,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 	skb_orphan(skb);
 	skb->sk = sk;
-	skb->destructor = skb_is_tcp_pure_ack(skb) ? sock_wfree : tcp_wfree;
+	skb->destructor = skb_is_tcp_pure_ack(skb) ? __sock_wfree : tcp_wfree;
 	skb_set_hash_from_sk(skb, sk);
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 
