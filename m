From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net 1/2] rose: limit sk_filter trim to payload
Date: Tue, 12 Jul 2016 18:18:56 -0400
Message-ID: <1468361937-102786-2-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1468361937-102786-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	davem@davemloft.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35120 "EHLO
	mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbcGLWf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 18:35:57 -0400
Received: by mail-qt0-f193.google.com with SMTP id q11so1078430qtb.2
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 15:35:43 -0700 (PDT)
In-Reply-To: <1468361937-102786-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Sockets can have a filter program attached that drops or trims
incoming packets based on the filter program return value.

Rose requires data packets to have at least ROSE_MIN_LEN bytes. It
verifies this on arrival in rose_route_frame and unconditionally pulls
the bytes in rose_recvmsg. The filter can trim packets to below this
value in-between, causing pull to fail, leaving the partial header at
the time of skb_copy_datagram_msg.

Place a lower bound on the size to which sk_filter may trim packets
by introducing sk_filter_trim_cap and call this for rose packets.

Signed-off-by: Willem de Bruijn <willemb@google.com>

---

No Fixes tag, because this codepath goes back to the start of the
git repo history.
---
 include/linux/filter.h |  6 +++++-
 net/core/filter.c      | 10 +++++-----
 net/rose/rose_in.c     |  3 ++-
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 6fc31ef..8f74f3d 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -467,7 +467,11 @@ static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
 }
 #endif /* CONFIG_DEBUG_SET_MODULE_RONX */
 
-int sk_filter(struct sock *sk, struct sk_buff *skb);
+int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap);
+static inline int sk_filter(struct sock *sk, struct sk_buff *skb)
+{
+	return sk_filter_trim_cap(sk, skb, 1);
+}
 
 struct bpf_prog *bpf_prog_select_runtime(struct bpf_prog *fp, int *err);
 void bpf_prog_free(struct bpf_prog *fp);
diff --git a/net/core/filter.c b/net/core/filter.c
index c4b330c..e759d90 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -53,9 +53,10 @@
 #include <net/sock_reuseport.h>
 
 /**
- *	sk_filter - run a packet through a socket filter
+ *	sk_filter_trim_cap - run a packet through a socket filter
  *	@sk: sock associated with &sk_buff
  *	@skb: buffer to filter
+ *	@cap: limit on how short the eBPF program may trim the packet
  *
  * Run the eBPF program and then cut skb->data to correct size returned by
  * the program. If pkt_len is 0 we toss packet. If skb->len is smaller
@@ -64,7 +65,7 @@
  * be accepted or -EPERM if the packet should be tossed.
  *
  */
-int sk_filter(struct sock *sk, struct sk_buff *skb)
+int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap)
 {
 	int err;
 	struct sk_filter *filter;
@@ -85,14 +86,13 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
 	filter = rcu_dereference(sk->sk_filter);
 	if (filter) {
 		unsigned int pkt_len = bpf_prog_run_save_cb(filter->prog, skb);
-
-		err = pkt_len ? pskb_trim(skb, pkt_len) : -EPERM;
+		err = pkt_len ? pskb_trim(skb, max(cap, pkt_len)) : -EPERM;
 	}
 	rcu_read_unlock();
 
 	return err;
 }
-EXPORT_SYMBOL(sk_filter);
+EXPORT_SYMBOL(sk_filter_trim_cap);
 
 static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 {
diff --git a/net/rose/rose_in.c b/net/rose/rose_in.c
index 79c4abc..0a63947 100644
--- a/net/rose/rose_in.c
+++ b/net/rose/rose_in.c
@@ -164,7 +164,8 @@ static int rose_state3_machine(struct sock *sk, struct sk_buff *skb, int framety
 		rose_frames_acked(sk, nr);
 		if (ns == rose->vr) {
 			rose_start_idletimer(sk);
-			if (sock_queue_rcv_skb(sk, skb) == 0) {
+			if (sk_filter_trim_cap(sk, skb, ROSE_MIN_LEN) == 0 &&
+			    __sock_queue_rcv_skb(sk, skb) == 0) {
 				rose->vr = (rose->vr + 1) % ROSE_MODULUS;
 				queued = 1;
 			} else {
-- 
2.8.0.rc3.226.g39d4020
