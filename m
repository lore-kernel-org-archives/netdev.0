From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] ebpf: add skb->hash to offset map for usage in {cls,act}_bpf or filters
Date: Sat,  1 Aug 2015 00:46:29 +0200
Message-ID: <4b25d0b28e9c366a8a307d855d1690038956e6bd.1438382433.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50451 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbbGaWqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:46:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add skb->hash to the __sk_buff offset map, so it can be accessed from
an eBPF program. We currently already do this for classic BPF filters,
but not yet on eBPF, it might be useful as a demuxer in combination with
helpers like bpf_clone_redirect(), toy example:

  __section("cls-lb") int ingress_main(struct __sk_buff *skb)
  {
    unsigned int which = 3 + (skb->hash & 7);
    /* bpf_skb_store_bytes(skb, ...); */
    /* bpf_l{3,4}_csum_replace(skb, ...); */
    bpf_clone_redirect(skb, which, 0);
    return -1;
  }

I was thinking whether to add skb_get_hash(), but then concluded the
raw skb->hash seems fine in this case: we can directly access the hash
w/o extra eBPF helper function call, it's filled out by many NICs on
ingress, and in case the entropy level would not be sufficient, people
can still implement their own specific sw fallback hash mix anyway.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/bpf.h | 1 +
 net/core/filter.c        | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index bc0d27d..2ce13c1 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -290,6 +290,7 @@ struct __sk_buff {
 	__u32 ifindex;
 	__u32 tc_index;
 	__u32 cb[5];
+	__u32 hash;
 };
 
 struct bpf_tunnel_key {
diff --git a/net/core/filter.c b/net/core/filter.c
index 1b72264..a50dbfa 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1711,6 +1711,13 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 				      offsetof(struct net_device, ifindex));
 		break;
 
+	case offsetof(struct __sk_buff, hash):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, hash) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+				      offsetof(struct sk_buff, hash));
+		break;
+
 	case offsetof(struct __sk_buff, mark):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
 
-- 
1.9.3
