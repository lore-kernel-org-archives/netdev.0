From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: fix csum setting for bpf_set_tunnel_key
Date: Tue, 23 Feb 2016 02:05:26 +0100
Message-ID: <cb92edae7e6cb23d349d714736362535e56a1c75.1456188678.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, jesse@kernel.org,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:32869 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756262AbcBWBFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 20:05:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fix in 35e2d1152b22 ("tunnels: Allow IPv6 UDP checksums to be correctly
controlled.") changed behavior for bpf_set_tunnel_key() when in use with
IPv6 and thus uncovered a bug that TUNNEL_CSUM needed to be set but wasn't.
As a result, the stack dropped ingress vxlan IPv6 packets, that have been
sent via eBPF through collect meta data mode due to checksum now being zero.

Since after LCO, we enable IPv4 checksum by default, so make that analogous
and only provide a flag BPF_F_ZERO_CSUM_TX for the user to turn it off in
IPv4 case.

Fixes: 35e2d1152b22 ("tunnels: Allow IPv6 UDP checksums to be correctly controlled.")
Fixes: c6c33454072f ("bpf: support ipv6 for bpf_skb_{set,get}_tunnel_key")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 Since the tunnel key IPv6 support sits in Linus' tree, would be good to
 fix it before it goes out. The patch is small and probably not worth
 splitting into two parts, I've tested that IPv6 and IPv4 (csum on/off)
 is working fine with it. Thanks!

 include/uapi/linux/bpf.h | 3 +++
 net/core/filter.c        | 6 ++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index aa6f857..5df4881 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -292,6 +292,9 @@ enum bpf_func_id {
 /* BPF_FUNC_skb_set_tunnel_key and BPF_FUNC_skb_get_tunnel_key flags. */
 #define BPF_F_TUNINFO_IPV6		(1ULL << 0)
 
+/* BPF_FUNC_skb_set_tunnel_key flags. */
+#define BPF_F_ZERO_CSUM_TX		(1ULL << 1)
+
 /* user accessible mirror of in-kernel sk_buff.
  * new fields can only be added to the end of this structure
  */
diff --git a/net/core/filter.c b/net/core/filter.c
index 94d2620..bba502f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1752,7 +1752,7 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	u8 compat[sizeof(struct bpf_tunnel_key)];
 	struct ip_tunnel_info *info;
 
-	if (unlikely(flags & ~(BPF_F_TUNINFO_IPV6)))
+	if (unlikely(flags & ~(BPF_F_TUNINFO_IPV6 | BPF_F_ZERO_CSUM_TX)))
 		return -EINVAL;
 	if (unlikely(size != sizeof(struct bpf_tunnel_key))) {
 		switch (size) {
@@ -1776,7 +1776,7 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	info = &md->u.tun_info;
 	info->mode = IP_TUNNEL_INFO_TX;
 
-	info->key.tun_flags = TUNNEL_KEY;
+	info->key.tun_flags = TUNNEL_KEY | TUNNEL_CSUM;
 	info->key.tun_id = cpu_to_be64(from->tunnel_id);
 	info->key.tos = from->tunnel_tos;
 	info->key.ttl = from->tunnel_ttl;
@@ -1787,6 +1787,8 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 		       sizeof(from->remote_ipv6));
 	} else {
 		info->key.u.ipv4.dst = cpu_to_be32(from->remote_ipv4);
+		if (flags & BPF_F_ZERO_CSUM_TX)
+			info->key.tun_flags &= ~TUNNEL_CSUM;
 	}
 
 	return 0;
-- 
1.9.3
