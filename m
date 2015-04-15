From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] bpf: fix bpf helpers to use skb->mac_header relative offsets
Date: Wed, 15 Apr 2015 12:55:45 -0700
Message-ID: <1429127745-5960-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35970 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607AbbDOTzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 15:55:55 -0400
Received: by pabsx10 with SMTP id sx10so61911522pab.3
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 12:55:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the short-term solution, lets fix bpf helper functions to use
skb->mac_header relative offsets instead of skb->data in order to
get the same eBPF programs with cls_bpf and act_bpf work on ingress
and egress qdisc path. We need to ensure that mac_header is set
before calling into programs. This is effectively the first option
from below referenced discussion.

More long term solution for LD_ABS|LD_IND instructions will be more
intrusive but also more beneficial than this, and implemented later
as it's too risky at this point in time.

I.e., we plan to look into the option of moving skb_pull() out of
eth_type_trans() and into netif_receive_skb() as has been suggested
as second option. Meanwhile, this solution ensures ingress can be
used with eBPF, too, and that we won't run into ABI troubles later.
For dealing with negative offsets inside eBPF helper functions,
we've implemented bpf_skb_clone_unwritable() to test for unwriteable
headers.

Reference: http://thread.gmane.org/gmane.linux.network/359129/focus=359694
Fixes: 608cd71a9c7c ("tc: bpf: generalize pedit action")
Fixes: 91bc4822c3d6 ("tc: bpf: add checksum helpers")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h    |    2 +-
 include/uapi/linux/filter.h |    7 +++++--
 net/core/filter.c           |   41 ++++++++++++++++++++++++++++++++---------
 net/sched/act_bpf.c         |    3 +++
 net/sched/cls_bpf.c         |    3 +++
 samples/bpf/tcbpf1_kern.c   |   16 ++++++----------
 6 files changed, 50 insertions(+), 22 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 5c1cee11f777..a9ebdf5701e8 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -177,7 +177,7 @@ enum bpf_func_id {
 	/**
 	 * skb_store_bytes(skb, offset, from, len, flags) - store bytes into packet
 	 * @skb: pointer to skb
-	 * @offset: offset within packet from skb->data
+	 * @offset: offset within packet from skb->mac_header
 	 * @from: pointer where to copy bytes from
 	 * @len: number of bytes to store into packet
 	 * @flags: bit 0 - if true, recompute skb->csum
diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
index 34c7936ca114..c97340e43dd6 100644
--- a/include/uapi/linux/filter.h
+++ b/include/uapi/linux/filter.h
@@ -79,8 +79,11 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define SKF_AD_RANDOM	56
 #define SKF_AD_VLAN_TPID	60
 #define SKF_AD_MAX	64
-#define SKF_NET_OFF   (-0x100000)
-#define SKF_LL_OFF    (-0x200000)
 
+#define SKF_NET_OFF	(-0x100000)
+#define SKF_LL_OFF	(-0x200000)
+
+#define BPF_NET_OFF	SKF_NET_OFF
+#define BPF_LL_OFF	SKF_LL_OFF
 
 #endif /* _UAPI__LINUX_FILTER_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index b669e75d2b36..bf831a85c315 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1175,12 +1175,27 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 	return 0;
 }
 
+/**
+ *	bpf_skb_clone_not_writable - is the header of a clone not writable
+ *	@skb: buffer to check
+ *	@len: length up to which to write, can be negative
+ *
+ *	Returns true if modifying the header part of the cloned buffer
+ *	does require the data to be copied. I.e. this version works with
+ *	negative lengths needed for eBPF case!
+ */
+static bool bpf_skb_clone_unwritable(const struct sk_buff *skb, int len)
+{
+	return skb_header_cloned(skb) ||
+	       (int) skb_headroom(skb) + len > skb->hdr_len;
+}
+
 #define BPF_RECOMPUTE_CSUM(flags)	((flags) & 1)
 
 static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
-	unsigned int offset = (unsigned int) r2;
+	int offset = (int) r2;
 	void *from = (void *) (long) r3;
 	unsigned int len = (unsigned int) r4;
 	char buf[16];
@@ -1194,10 +1209,12 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 	 *
 	 * so check for invalid 'offset' and too large 'len'
 	 */
-	if (unlikely(offset > 0xffff || len > sizeof(buf)))
+	if (unlikely((u32) offset > 0xffff || len > sizeof(buf)))
 		return -EFAULT;
 
-	if (skb_cloned(skb) && !skb_clone_writable(skb, offset + len))
+	offset -= skb->data - skb_mac_header(skb);
+	if (unlikely(skb_cloned(skb) &&
+		     bpf_skb_clone_unwritable(skb, offset + len)))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, len, buf);
@@ -1232,15 +1249,18 @@ const struct bpf_func_proto bpf_skb_store_bytes_proto = {
 #define BPF_HEADER_FIELD_SIZE(flags)	((flags) & 0x0f)
 #define BPF_IS_PSEUDO_HEADER(flags)	((flags) & 0x10)
 
-static u64 bpf_l3_csum_replace(u64 r1, u64 offset, u64 from, u64 to, u64 flags)
+static u64 bpf_l3_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+	int offset = (int) r2;
 	__sum16 sum, *ptr;
 
-	if (unlikely(offset > 0xffff))
+	if (unlikely((u32) offset > 0xffff))
 		return -EFAULT;
 
-	if (skb_cloned(skb) && !skb_clone_writable(skb, offset + sizeof(sum)))
+	offset -= skb->data - skb_mac_header(skb);
+	if (unlikely(skb_cloned(skb) &&
+		     bpf_skb_clone_unwritable(skb, offset + sizeof(sum))))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
@@ -1276,16 +1296,19 @@ const struct bpf_func_proto bpf_l3_csum_replace_proto = {
 	.arg5_type	= ARG_ANYTHING,
 };
 
-static u64 bpf_l4_csum_replace(u64 r1, u64 offset, u64 from, u64 to, u64 flags)
+static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	u32 is_pseudo = BPF_IS_PSEUDO_HEADER(flags);
+	int offset = (int) r2;
 	__sum16 sum, *ptr;
 
-	if (unlikely(offset > 0xffff))
+	if (unlikely((u32) offset > 0xffff))
 		return -EFAULT;
 
-	if (skb_cloned(skb) && !skb_clone_writable(skb, offset + sizeof(sum)))
+	offset -= skb->data - skb_mac_header(skb);
+	if (unlikely(skb_cloned(skb) &&
+		     bpf_skb_clone_unwritable(skb, offset + sizeof(sum))))
 		return -EFAULT;
 
 	ptr = skb_header_pointer(skb, offset, sizeof(sum), &sum);
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 4d2cede17468..dc6a2d324bd8 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -38,6 +38,9 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 	struct tcf_bpf *prog = act->priv;
 	int action, filter_res;
 
+	if (unlikely(!skb_mac_header_was_set(skb)))
+		return TC_ACT_UNSPEC;
+
 	spin_lock(&prog->tcf_lock);
 
 	prog->tcf_tm.lastuse = jiffies;
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 5c4171c5d2bd..91bd9c19471d 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -66,6 +66,9 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	struct cls_bpf_prog *prog;
 	int ret = -1;
 
+	if (unlikely(!skb_mac_header_was_set(skb)))
+		return -1;
+
 	/* Needed here for accessing maps. */
 	rcu_read_lock();
 	list_for_each_entry_rcu(prog, &head->plist, link) {
diff --git a/samples/bpf/tcbpf1_kern.c b/samples/bpf/tcbpf1_kern.c
index 7cf3f42a6e39..7c27710f8296 100644
--- a/samples/bpf/tcbpf1_kern.c
+++ b/samples/bpf/tcbpf1_kern.c
@@ -4,6 +4,8 @@
 #include <uapi/linux/ip.h>
 #include <uapi/linux/in.h>
 #include <uapi/linux/tcp.h>
+#include <uapi/linux/filter.h>
+
 #include "bpf_helpers.h"
 
 /* compiler workaround */
@@ -14,18 +16,12 @@ static inline void set_dst_mac(struct __sk_buff *skb, char *mac)
 	bpf_skb_store_bytes(skb, 0, mac, ETH_ALEN, 1);
 }
 
-/* use 1 below for ingress qdisc and 0 for egress */
-#if 0
-#undef ETH_HLEN
-#define ETH_HLEN 0
-#endif
-
 #define IP_CSUM_OFF (ETH_HLEN + offsetof(struct iphdr, check))
 #define TOS_OFF (ETH_HLEN + offsetof(struct iphdr, tos))
 
 static inline void set_ip_tos(struct __sk_buff *skb, __u8 new_tos)
 {
-	__u8 old_tos = load_byte(skb, TOS_OFF);
+	__u8 old_tos = load_byte(skb, BPF_LL_OFF + TOS_OFF);
 
 	bpf_l3_csum_replace(skb, IP_CSUM_OFF, htons(old_tos), htons(new_tos), 2);
 	bpf_skb_store_bytes(skb, TOS_OFF, &new_tos, sizeof(new_tos), 0);
@@ -38,7 +34,7 @@ static inline void set_ip_tos(struct __sk_buff *skb, __u8 new_tos)
 
 static inline void set_tcp_ip_src(struct __sk_buff *skb, __u32 new_ip)
 {
-	__u32 old_ip = _htonl(load_word(skb, IP_SRC_OFF));
+	__u32 old_ip = _htonl(load_word(skb, BPF_LL_OFF + IP_SRC_OFF));
 
 	bpf_l4_csum_replace(skb, TCP_CSUM_OFF, old_ip, new_ip, IS_PSEUDO | sizeof(new_ip));
 	bpf_l3_csum_replace(skb, IP_CSUM_OFF, old_ip, new_ip, sizeof(new_ip));
@@ -48,7 +44,7 @@ static inline void set_tcp_ip_src(struct __sk_buff *skb, __u32 new_ip)
 #define TCP_DPORT_OFF (ETH_HLEN + sizeof(struct iphdr) + offsetof(struct tcphdr, dest))
 static inline void set_tcp_dest_port(struct __sk_buff *skb, __u16 new_port)
 {
-	__u16 old_port = htons(load_half(skb, TCP_DPORT_OFF));
+	__u16 old_port = htons(load_half(skb, BPF_LL_OFF + TCP_DPORT_OFF));
 
 	bpf_l4_csum_replace(skb, TCP_CSUM_OFF, old_port, new_port, sizeof(new_port));
 	bpf_skb_store_bytes(skb, TCP_DPORT_OFF, &new_port, sizeof(new_port), 0);
@@ -57,7 +53,7 @@ static inline void set_tcp_dest_port(struct __sk_buff *skb, __u16 new_port)
 SEC("classifier")
 int bpf_prog1(struct __sk_buff *skb)
 {
-	__u8 proto = load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol));
+	__u8 proto = load_byte(skb, BPF_LL_OFF + ETH_HLEN + offsetof(struct iphdr, protocol));
 	long *value;
 
 	if (proto == IPPROTO_TCP) {
-- 
1.7.9.5
