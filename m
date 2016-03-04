From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/7] bpf: allow to propagate df in bpf_skb_set_tunnel_key
Date: Fri,  4 Mar 2016 15:15:05 +0100
Message-ID: <4459137a9fbaf7956e0408bfa36fbc54da722c20.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39197 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbcCDOPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 09:15:33 -0500
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added by 9a628224a61b ("ip_tunnel: Add dont fragment flag."), allow to
feed df flag into tunneling facilities (currently supported on TX by
vxlan, geneve and gre) as a hint from eBPF's bpf_skb_set_tunnel_key()
helper.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h | 1 +
 net/core/filter.c        | 6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index c7fad40..06287bb 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -324,6 +324,7 @@ enum bpf_func_id {
 
 /* BPF_FUNC_skb_set_tunnel_key flags. */
 #define BPF_F_ZERO_CSUM_TX		(1ULL << 1)
+#define BPF_F_DONT_FRAGMENT		(1ULL << 2)
 
 /* BPF_FUNC_get_stackid flags. */
 #define BPF_F_SKIP_FIELD_MASK		0xffULL
diff --git a/net/core/filter.c b/net/core/filter.c
index ce4e18d..6c9d155 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1819,7 +1819,8 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	u8 compat[sizeof(struct bpf_tunnel_key)];
 	struct ip_tunnel_info *info;
 
-	if (unlikely(flags & ~(BPF_F_TUNINFO_IPV6 | BPF_F_ZERO_CSUM_TX)))
+	if (unlikely(flags & ~(BPF_F_TUNINFO_IPV6 | BPF_F_ZERO_CSUM_TX |
+			       BPF_F_DONT_FRAGMENT)))
 		return -EINVAL;
 	if (unlikely(size != sizeof(struct bpf_tunnel_key))) {
 		switch (size) {
@@ -1844,6 +1845,9 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	info->mode = IP_TUNNEL_INFO_TX;
 
 	info->key.tun_flags = TUNNEL_KEY | TUNNEL_CSUM;
+	if (flags & BPF_F_DONT_FRAGMENT)
+		info->key.tun_flags |= TUNNEL_DONT_FRAGMENT;
+
 	info->key.tun_id = cpu_to_be64(from->tunnel_id);
 	info->key.tos = from->tunnel_tos;
 	info->key.ttl = from->tunnel_ttl;
-- 
1.9.3
