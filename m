From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 3/3] bpf: fix checksum for vlan push/pop helper
Date: Fri,  5 Aug 2016 00:11:13 +0200
Message-ID: <395839b32d7b9b55133fbac367c6976991921ba3.1470346863.git.daniel@iogearbox.net>
References: <cover.1470346863.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38674 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966141AbcHDWLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 18:11:21 -0400
In-Reply-To: <cover.1470346863.git.daniel@iogearbox.net>
In-Reply-To: <cover.1470346863.git.daniel@iogearbox.net>
References: <cover.1470346863.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When having skbs on ingress with CHECKSUM_COMPLETE, tc BPF programs don't
push rcsum of mac header back in and after BPF run back pull out again as
opposed to some other subsystems (ovs, for example).

For cases like q-in-q, meaning when a vlan tag for offloading is already
present and we're about to push another one, then skb_vlan_push() pushes the
inner one into the skb, increasing mac header and skb_postpush_rcsum()'ing
the 4 bytes vlan header diff. Likewise, for the reverse operation in
skb_vlan_pop() for the case where vlan header needs to be pulled out of the
skb, we're decreasing the mac header and skb_postpull_rcsum()'ing the 4 bytes
rcsum of the vlan header that was removed.

However mangling the rcsum here will lead to hw csum failure for BPF case,
since we're pulling or pushing data that was not part of the current rcsum.
Changing tc BPF programs in general to push/pull rcsum around BPF_PROG_RUN()
is also not really an option since current behaviour is ABI by now, but apart
from that would also mean to do quite a bit of useless work in the sense that
usually 12 bytes need to be rcsum pushed/pulled also when we don't need to
touch this vlan related corner case. One way to fix it would be to push the
necessary rcsum fixup down into vlan helpers that are (mostly) slow-path
anyway.

Fixes: 4e10df9a60d9 ("bpf: introduce bpf_skb_vlan_push/pop() helpers")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index 5ecd5c9..b5add4e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1371,6 +1371,12 @@ static inline void bpf_push_mac_rcsum(struct sk_buff *skb)
 		skb_postpush_rcsum(skb, skb_mac_header(skb), skb->mac_len);
 }
 
+static inline void bpf_pull_mac_rcsum(struct sk_buff *skb)
+{
+	if (skb_at_tc_ingress(skb))
+		skb_postpull_rcsum(skb, skb_mac_header(skb), skb->mac_len);
+}
+
 static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 {
 	struct bpf_scratchpad *sp = this_cpu_ptr(&bpf_sp);
@@ -1763,7 +1769,10 @@ static u64 bpf_skb_vlan_push(u64 r1, u64 r2, u64 vlan_tci, u64 r4, u64 r5)
 		     vlan_proto != htons(ETH_P_8021AD)))
 		vlan_proto = htons(ETH_P_8021Q);
 
+	bpf_push_mac_rcsum(skb);
 	ret = skb_vlan_push(skb, vlan_proto, vlan_tci);
+	bpf_pull_mac_rcsum(skb);
+
 	bpf_compute_data_end(skb);
 	return ret;
 }
@@ -1783,7 +1792,10 @@ static u64 bpf_skb_vlan_pop(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	int ret;
 
+	bpf_push_mac_rcsum(skb);
 	ret = skb_vlan_pop(skb);
+	bpf_pull_mac_rcsum(skb);
+
 	bpf_compute_data_end(skb);
 	return ret;
 }
-- 
1.9.3
