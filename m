From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/4] bpf: support flow label for bpf_skb_{set,get}_tunnel_key
Date: Wed,  9 Mar 2016 03:00:05 +0100
Message-ID: <a1d02a81fb4811648e278440ffe4fb6096f26c5c.1457488298.git.daniel@iogearbox.net>
References: <cover.1457488298.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45232 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbcCICAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 21:00:10 -0500
In-Reply-To: <cover.1457488298.git.daniel@iogearbox.net>
In-Reply-To: <cover.1457488298.git.daniel@iogearbox.net>
References: <cover.1457488298.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extends bpf_tunnel_key with a tunnel_label member, that maps
to ip_tunnel_key's label so underlying backends like vxlan and geneve
can propagate the label to udp_tunnel6_xmit_skb(), where it's being set
in the IPv6 header. It allows for having 20 more bits to encode/decode
flow related meta information programmatically. Tested with vxlan and
geneve.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h |  1 +
 net/core/filter.c        | 14 ++++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0e30b19..924f537 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -375,6 +375,7 @@ struct bpf_tunnel_key {
 	};
 	__u8 tunnel_tos;
 	__u8 tunnel_ttl;
+	__u32 tunnel_label;
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index a66dc03..6fc3893 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1770,12 +1770,15 @@ static u64 bpf_skb_get_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 		return -EPROTO;
 	if (unlikely(size != sizeof(struct bpf_tunnel_key))) {
 		switch (size) {
+		case offsetof(struct bpf_tunnel_key, tunnel_label):
+			goto set_compat;
 		case offsetof(struct bpf_tunnel_key, remote_ipv6[1]):
 			/* Fixup deprecated structure layouts here, so we have
 			 * a common path later on.
 			 */
 			if (ip_tunnel_info_af(info) != AF_INET)
 				return -EINVAL;
+set_compat:
 			to = (struct bpf_tunnel_key *)compat;
 			break;
 		default:
@@ -1787,11 +1790,13 @@ static u64 bpf_skb_get_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	to->tunnel_tos = info->key.tos;
 	to->tunnel_ttl = info->key.ttl;
 
-	if (flags & BPF_F_TUNINFO_IPV6)
+	if (flags & BPF_F_TUNINFO_IPV6) {
 		memcpy(to->remote_ipv6, &info->key.u.ipv6.src,
 		       sizeof(to->remote_ipv6));
-	else
+		to->tunnel_label = be32_to_cpu(info->key.label);
+	} else {
 		to->remote_ipv4 = be32_to_cpu(info->key.u.ipv4.src);
+	}
 
 	if (unlikely(size != sizeof(struct bpf_tunnel_key)))
 		memcpy((void *)(long) r2, to, size);
@@ -1850,6 +1855,7 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 		return -EINVAL;
 	if (unlikely(size != sizeof(struct bpf_tunnel_key))) {
 		switch (size) {
+		case offsetof(struct bpf_tunnel_key, tunnel_label):
 		case offsetof(struct bpf_tunnel_key, remote_ipv6[1]):
 			/* Fixup deprecated structure layouts here, so we have
 			 * a common path later on.
@@ -1862,6 +1868,8 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 			return -EINVAL;
 		}
 	}
+	if (unlikely(!(flags & BPF_F_TUNINFO_IPV6) && from->tunnel_label))
+		return -EINVAL;
 
 	skb_dst_drop(skb);
 	dst_hold((struct dst_entry *) md);
@@ -1882,6 +1890,8 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 		info->mode |= IP_TUNNEL_INFO_IPV6;
 		memcpy(&info->key.u.ipv6.dst, from->remote_ipv6,
 		       sizeof(from->remote_ipv6));
+		info->key.label = cpu_to_be32(from->tunnel_label) &
+				  IPV6_FLOWLABEL_MASK;
 	} else {
 		info->key.u.ipv4.dst = cpu_to_be32(from->remote_ipv4);
 		if (flags & BPF_F_ZERO_CSUM_TX)
-- 
1.9.3
