From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 1/2] bpf: make programs see skb->data == L2 for ingress and egress
Date: Thu,  4 Jun 2015 10:11:53 -0700
Message-ID: <1433437914-15808-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:34067 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932370AbbFDRMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 13:12:02 -0400
Received: by qgf75 with SMTP id 75so18476643qgf.1
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 10:12:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eBPF programs attached to ingress and egress qdiscs see inconsistent skb->data.
For ingress L2 header is already pulled, whereas for egress it's present.
This is known to program writers which are currently forced to use
BPF_LL_OFF workaround.
Since programs don't change skb internal pointers it is safe to do
pull/push right around invocation of the program and earlier taps and
later pt->func() will not be affected.
Multiple taps via packet_rcv(), tpacket_rcv() are doing the same trick
around run_filter/BPF_PROG_RUN even if skb_shared.

This fix finally allows programs to use optimized LD_ABS/IND instructions
without BPF_LL_OFF for higher performance.
tc ingress + cls_bpf + samples/bpf/tcbpf1_kern.o
       w/o JIT   w/JIT
before  20.5     23.6 Mpps
after   21.8     26.6 Mpps

Old programs with BPF_LL_OFF will still work as-is.

We can now undo most of the earlier workaround commit:
a166151cbe33 ("bpf: fix bpf helpers to use skb->mac_header relative offsets")

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
new V1->V2: fixed u32->bool and added a check for CONFIG_NET_CLS_ACT
This patch is on top of 'fix build due to tc_verd':
http://patchwork.ozlabs.org/patch/480783/

Earlier versions were trying to do too much to make ingress and egress qdisc
consistent for all classifiers and actions or had too big of a scope of push/pull:
v1: http://thread.gmane.org/gmane.linux.network/358168/focus=358168
v2: http://thread.gmane.org/gmane.linux.network/358524/focus=358532
v3: http://thread.gmane.org/gmane.linux.network/358733/focus=358734
v4: http://thread.gmane.org/gmane.linux.network/359129/focus=359694

skb->data will still be different for all non-bpf classifiers/actions.

This fix will still allow us to explore further optimizations like
moving skb_pull() from eth_type_trans() into netif_receive_skb() in the future.

Here is how ingress callchain looks:

netif_receive_skb,          // likely skb->users == 1
  deliver_skb
    packet_rcv              // skb->users == 2
      orig_skb_data = skb->data
      push l2
      res = BPF_PROG_RUN
      if (!res) {
        skb->data = orig_skb_data
        consume_skb(skb)    // skb->users == 1
        goto out
      }

      skb2 = skb_clone(skb)
      skb->data = orig_skb_data
      consume_skb(skb)      // skb->users == 1
      __skb_queue_tail(skb2)

  deliver_skb
    Tpacket_rcv             // skb->users == 2
      orig_skb_data = skb->data
      push l2
      res = BPF_PROG_RUN
      if (!res) {
        skb->data = orig_skb_data
        kfree_skb(skb)      // skb->users == 1
	goto out
      }

      if (...) {
        skb2 = skb_clone(skb)
        __skb_queue_tail(skb2)
      }
      skb_copy_bits(skb)
      skb->data = orig_skb_data
      kfree_skb(skb)        // skb->users == 1

  tc_classify
     cls_u32 and other classifiers don't touch skb
       actions like mirred do clone before redirect, etc.

     cls_bpf               // skb->users == 1
       push l2
       res = BPF_PROG_RUN
       pull l2
       actions             // still see skb->data at L3

     cls_xxx               // still see skb->data at L3
       actions

  netfilter
  vlan_do_receive
  bridge

  deliver_skb
    mpls_forward and other ptype specific taps

  ip_rcv                   // skb->users == 1

 net/core/filter.c         |   26 +++-----------------------
 net/sched/act_bpf.c       |    9 ++++++++-
 net/sched/cls_bpf.c       |   16 +++++++++++++++-
 samples/bpf/tcbpf1_kern.c |    8 ++++----
 4 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 09b2062eb5b8..36a69e33d76b 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1238,21 +1238,6 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 	return 0;
 }
 
-/**
- *	bpf_skb_clone_not_writable - is the header of a clone not writable
- *	@skb: buffer to check
- *	@len: length up to which to write, can be negative
- *
- *	Returns true if modifying the header part of the cloned buffer
- *	does require the data to be copied. I.e. this version works with
- *	negative lengths needed for eBPF case!
- */
-static bool bpf_skb_clone_unwritable(const struct sk_buff *skb, int len)
-{
-	return skb_header_cloned(skb) ||
-	       (int) skb_headroom(skb) + len > skb->hdr_len;
-}
-
 #define BPF_RECOMPUTE_CSUM(flags)	((flags) & 1)
 
 static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
@@ -1275,9 +1260,8 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 	if (unlikely((u32) offset > 0xffff || len > sizeof(buf)))
 		return -EFAULT;
 
-	offset -= skb->data - skb_mac_header(skb);
 	if (unlikely(skb_cloned(skb) &&
-		     bpf_skb_clone_unwritable(skb, offset + len)))
+		     !skb_clone_writable(skb, offset + len)))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, len, buf);
@@ -1321,9 +1305,8 @@ static u64 bpf_l3_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 	if (unlikely((u32) offset > 0xffff))
 		return -EFAULT;
 
-	offset -= skb->data - skb_mac_header(skb);
 	if (unlikely(skb_cloned(skb) &&
-		     bpf_skb_clone_unwritable(skb, offset + sizeof(sum))))
+		     !skb_clone_writable(skb, offset + sizeof(sum))))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
@@ -1369,9 +1352,8 @@ static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 	if (unlikely((u32) offset > 0xffff))
 		return -EFAULT;
 
-	offset -= skb->data - skb_mac_header(skb);
 	if (unlikely(skb_cloned(skb) &&
-		     bpf_skb_clone_unwritable(skb, offset + sizeof(sum))))
+		     !skb_clone_writable(skb, offset + sizeof(sum))))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
@@ -1425,8 +1407,6 @@ static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 	if (unlikely(!skb2))
 		return -ENOMEM;
 
-	skb_push(skb2, skb2->data - skb_mac_header(skb2));
-
 	if (BPF_IS_REDIRECT_INGRESS(flags))
 		return dev_forward_skb(dev, skb2);
 
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index dc6a2d324bd8..1d56903fd4c7 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -37,6 +37,7 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 {
 	struct tcf_bpf *prog = act->priv;
 	int action, filter_res;
+	bool at_ingress = G_TC_AT(skb->tc_verd) & AT_INGRESS;
 
 	if (unlikely(!skb_mac_header_was_set(skb)))
 		return TC_ACT_UNSPEC;
@@ -48,7 +49,13 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 
 	/* Needed here for accessing maps. */
 	rcu_read_lock();
-	filter_res = BPF_PROG_RUN(prog->filter, skb);
+	if (at_ingress) {
+		__skb_push(skb, skb->mac_len);
+		filter_res = BPF_PROG_RUN(prog->filter, skb);
+		__skb_pull(skb, skb->mac_len);
+	} else {
+		filter_res = BPF_PROG_RUN(prog->filter, skb);
+	}
 	rcu_read_unlock();
 
 	/* A BPF program may overwrite the default action opcode.
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 91bd9c19471d..c79ecfd36e0f 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -64,6 +64,11 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 {
 	struct cls_bpf_head *head = rcu_dereference_bh(tp->root);
 	struct cls_bpf_prog *prog;
+#ifdef CONFIG_NET_CLS_ACT
+	bool at_ingress = G_TC_AT(skb->tc_verd) & AT_INGRESS;
+#else
+	bool at_ingress = false;
+#endif
 	int ret = -1;
 
 	if (unlikely(!skb_mac_header_was_set(skb)))
@@ -72,7 +77,16 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	/* Needed here for accessing maps. */
 	rcu_read_lock();
 	list_for_each_entry_rcu(prog, &head->plist, link) {
-		int filter_res = BPF_PROG_RUN(prog->filter, skb);
+		int filter_res;
+
+		if (at_ingress) {
+			/* It is safe to push/pull even if skb_shared() */
+			__skb_push(skb, skb->mac_len);
+			filter_res = BPF_PROG_RUN(prog->filter, skb);
+			__skb_pull(skb, skb->mac_len);
+		} else {
+			filter_res = BPF_PROG_RUN(prog->filter, skb);
+		}
 
 		if (filter_res == 0)
 			continue;
diff --git a/samples/bpf/tcbpf1_kern.c b/samples/bpf/tcbpf1_kern.c
index 7c27710f8296..9bfb2eb34563 100644
--- a/samples/bpf/tcbpf1_kern.c
+++ b/samples/bpf/tcbpf1_kern.c
@@ -21,7 +21,7 @@ static inline void set_dst_mac(struct __sk_buff *skb, char *mac)
 
 static inline void set_ip_tos(struct __sk_buff *skb, __u8 new_tos)
 {
-	__u8 old_tos = load_byte(skb, BPF_LL_OFF + TOS_OFF);
+	__u8 old_tos = load_byte(skb, TOS_OFF);
 
 	bpf_l3_csum_replace(skb, IP_CSUM_OFF, htons(old_tos), htons(new_tos), 2);
 	bpf_skb_store_bytes(skb, TOS_OFF, &new_tos, sizeof(new_tos), 0);
@@ -34,7 +34,7 @@ static inline void set_ip_tos(struct __sk_buff *skb, __u8 new_tos)
 
 static inline void set_tcp_ip_src(struct __sk_buff *skb, __u32 new_ip)
 {
-	__u32 old_ip = _htonl(load_word(skb, BPF_LL_OFF + IP_SRC_OFF));
+	__u32 old_ip = _htonl(load_word(skb, IP_SRC_OFF));
 
 	bpf_l4_csum_replace(skb, TCP_CSUM_OFF, old_ip, new_ip, IS_PSEUDO | sizeof(new_ip));
 	bpf_l3_csum_replace(skb, IP_CSUM_OFF, old_ip, new_ip, sizeof(new_ip));
@@ -44,7 +44,7 @@ static inline void set_tcp_ip_src(struct __sk_buff *skb, __u32 new_ip)
 #define TCP_DPORT_OFF (ETH_HLEN + sizeof(struct iphdr) + offsetof(struct tcphdr, dest))
 static inline void set_tcp_dest_port(struct __sk_buff *skb, __u16 new_port)
 {
-	__u16 old_port = htons(load_half(skb, BPF_LL_OFF + TCP_DPORT_OFF));
+	__u16 old_port = htons(load_half(skb, TCP_DPORT_OFF));
 
 	bpf_l4_csum_replace(skb, TCP_CSUM_OFF, old_port, new_port, sizeof(new_port));
 	bpf_skb_store_bytes(skb, TCP_DPORT_OFF, &new_port, sizeof(new_port), 0);
@@ -53,7 +53,7 @@ static inline void set_tcp_dest_port(struct __sk_buff *skb, __u16 new_port)
 SEC("classifier")
 int bpf_prog1(struct __sk_buff *skb)
 {
-	__u8 proto = load_byte(skb, BPF_LL_OFF + ETH_HLEN + offsetof(struct iphdr, protocol));
+	__u8 proto = load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol));
 	long *value;
 
 	if (proto == IPPROTO_TCP) {
-- 
1.7.9.5
