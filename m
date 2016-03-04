From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/7] bpf: add flags to bpf_skb_store_bytes for clearing hash
Date: Fri,  4 Mar 2016 15:15:03 +0100
Message-ID: <32aebd7201011c1378e0c7023594c5a2966d8d39.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39180 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbcCDOPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 09:15:31 -0500
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When overwriting parts of the packet with bpf_skb_store_bytes() that
were fed previously into skb->hash calculation, we should clear the
current hash with skb_clear_hash(), so that a next skb_get_hash() call
can determine the correct hash related to this skb.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h | 1 +
 net/core/filter.c        | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 6928ee8..c7fad40 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -305,6 +305,7 @@ enum bpf_func_id {
 
 /* BPF_FUNC_skb_store_bytes flags. */
 #define BPF_F_RECOMPUTE_CSUM		(1ULL << 0)
+#define BPF_F_INVALIDATE_HASH		(1ULL << 1)
 
 /* BPF_FUNC_l3_csum_replace and BPF_FUNC_l4_csum_replace flags.
  * First 4 bits are for passing the header field size.
diff --git a/net/core/filter.c b/net/core/filter.c
index 356a251..a1fe246 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1353,7 +1353,7 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 	unsigned int len = (unsigned int) r4;
 	void *ptr;
 
-	if (unlikely(flags & ~(BPF_F_RECOMPUTE_CSUM)))
+	if (unlikely(flags & ~(BPF_F_RECOMPUTE_CSUM | BPF_F_INVALIDATE_HASH)))
 		return -EINVAL;
 
 	/* bpf verifier guarantees that:
@@ -1384,6 +1384,8 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 
 	if (flags & BPF_F_RECOMPUTE_CSUM)
 		skb_postpush_rcsum(skb, ptr, len);
+	if (flags & BPF_F_INVALIDATE_HASH)
+		skb_clear_hash(skb);
 
 	return 0;
 }
-- 
1.9.3
