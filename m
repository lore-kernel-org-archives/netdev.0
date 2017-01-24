From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/5] bpf: allow option for setting bpf_l4_csum_replace from scratch
Date: Tue, 24 Jan 2017 01:06:28 +0100
Message-ID: <497b7bda4f531a2044974d54dbd50b77e1eaf675.1485214851.git.daniel@iogearbox.net>
References: <cover.1485214851.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44955 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751924AbdAXAGy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:06:54 -0500
In-Reply-To: <cover.1485214851.git.daniel@iogearbox.net>
In-Reply-To: <cover.1485214851.git.daniel@iogearbox.net>
References: <cover.1485214851.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When programs need to calculate the csum from scratch for small UDP
packets and use bpf_l4_csum_replace() to feed the result from helpers
like bpf_csum_diff(), then we need a flag besides BPF_F_MARK_MANGLED_0
that would ignore the case of current csum being 0, and which would
still allow for the helper to set the csum and transform when needed
to CSUM_MANGLED_0.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h | 1 +
 net/core/filter.c        | 7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index bd30684..e07fd5a 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -522,6 +522,7 @@ enum bpf_func_id {
 /* BPF_FUNC_l4_csum_replace flags. */
 #define BPF_F_PSEUDO_HDR		(1ULL << 4)
 #define BPF_F_MARK_MANGLED_0		(1ULL << 5)
+#define BPF_F_MARK_ENFORCE		(1ULL << 6)
 
 /* BPF_FUNC_clone_redirect and BPF_FUNC_redirect flags. */
 #define BPF_F_INGRESS			(1ULL << 0)
diff --git a/net/core/filter.c b/net/core/filter.c
index e2263da..1e00737 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1522,10 +1522,11 @@ static inline void bpf_pull_mac_rcsum(struct sk_buff *skb)
 {
 	bool is_pseudo = flags & BPF_F_PSEUDO_HDR;
 	bool is_mmzero = flags & BPF_F_MARK_MANGLED_0;
+	bool do_mforce = flags & BPF_F_MARK_ENFORCE;
 	__sum16 *ptr;
 
-	if (unlikely(flags & ~(BPF_F_MARK_MANGLED_0 | BPF_F_PSEUDO_HDR |
-			       BPF_F_HDR_FIELD_MASK)))
+	if (unlikely(flags & ~(BPF_F_MARK_MANGLED_0 | BPF_F_MARK_ENFORCE |
+			       BPF_F_PSEUDO_HDR | BPF_F_HDR_FIELD_MASK)))
 		return -EINVAL;
 	if (unlikely(offset > 0xffff || offset & 1))
 		return -EFAULT;
@@ -1533,7 +1534,7 @@ static inline void bpf_pull_mac_rcsum(struct sk_buff *skb)
 		return -EFAULT;
 
 	ptr = (__sum16 *)(skb->data + offset);
-	if (is_mmzero && !*ptr)
+	if (is_mmzero && !do_mforce && !*ptr)
 		return 0;
 
 	switch (flags & BPF_F_HDR_FIELD_MASK) {
-- 
1.9.3
