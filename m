From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] bpf: support ipv6 for bpf_skb_{set,get}_tunnel_key
Date: Mon, 11 Jan 2016 01:16:39 +0100
Message-ID: <cd5fc9d4b8de9a804923b3a96bbc0809473d35ff.1452385316.git.daniel@iogearbox.net>
References: <cover.1452385316.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53599 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757903AbcAKAQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 19:16:58 -0500
In-Reply-To: <cover.1452385316.git.daniel@iogearbox.net>
In-Reply-To: <cover.1452385316.git.daniel@iogearbox.net>
References: <cover.1452385316.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After IPv6 support has recently been added to metadata dst and related
encaps, add support for populating/reading it from an eBPF program.

Commit d3aa45ce6b ("bpf: add helpers to access tunnel metadata") started
with initial IPv4-only support back then (due to IPv6 metadata support
not being available yet).

To stay compatible with older programs, we need to test for the passed
structure size. Also TOS and TTL support from the ip_tunnel_info key has
been added. Tested with vxlan devs in collect meta data mode with IPv4,
IPv6 and in compat mode over different network namespaces.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h | 10 ++++++-
 net/core/filter.c        | 69 +++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 71 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index d94797c..aa6f857 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -289,6 +289,9 @@ enum bpf_func_id {
 /* BPF_FUNC_clone_redirect and BPF_FUNC_redirect flags. */
 #define BPF_F_INGRESS			(1ULL << 0)
 
+/* BPF_FUNC_skb_set_tunnel_key and BPF_FUNC_skb_get_tunnel_key flags. */
+#define BPF_F_TUNINFO_IPV6		(1ULL << 0)
+
 /* user accessible mirror of in-kernel sk_buff.
  * new fields can only be added to the end of this structure
  */
@@ -312,7 +315,12 @@ struct __sk_buff {
 
 struct bpf_tunnel_key {
 	__u32 tunnel_id;
-	__u32 remote_ipv4;
+	union {
+		__u32 remote_ipv4;
+		__u32 remote_ipv6[4];
+	};
+	__u8 tunnel_tos;
+	__u8 tunnel_ttl;
 };
 
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/net/core/filter.c b/net/core/filter.c
index 7c55cad..77cdfb4 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1680,19 +1680,49 @@ bool bpf_helper_changes_skb_data(void *func)
 	return false;
 }
 
+static unsigned short bpf_tunnel_key_af(u64 flags)
+{
+	return flags & BPF_F_TUNINFO_IPV6 ? AF_INET6 : AF_INET;
+}
+
 static u64 bpf_skb_get_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	struct bpf_tunnel_key *to = (struct bpf_tunnel_key *) (long) r2;
-	struct ip_tunnel_info *info = skb_tunnel_info(skb);
+	const struct ip_tunnel_info *info = skb_tunnel_info(skb);
+	u8 compat[sizeof(struct bpf_tunnel_key)];
 
-	if (unlikely(size != sizeof(struct bpf_tunnel_key) || flags || !info))
-		return -EINVAL;
-	if (ip_tunnel_info_af(info) != AF_INET)
+	if (unlikely(!info || (flags & ~(BPF_F_TUNINFO_IPV6))))
 		return -EINVAL;
+	if (ip_tunnel_info_af(info) != bpf_tunnel_key_af(flags))
+		return -EPROTO;
+	if (unlikely(size != sizeof(struct bpf_tunnel_key))) {
+		switch (size) {
+		case offsetof(struct bpf_tunnel_key, remote_ipv6[1]):
+			/* Fixup deprecated structure layouts here, so we have
+			 * a common path later on.
+			 */
+			if (ip_tunnel_info_af(info) != AF_INET)
+				return -EINVAL;
+			to = (struct bpf_tunnel_key *)compat;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
 
 	to->tunnel_id = be64_to_cpu(info->key.tun_id);
-	to->remote_ipv4 = be32_to_cpu(info->key.u.ipv4.src);
+	to->tunnel_tos = info->key.tos;
+	to->tunnel_ttl = info->key.ttl;
+
+	if (flags & BPF_F_TUNINFO_IPV6)
+		memcpy(to->remote_ipv6, &info->key.u.ipv6.src,
+		       sizeof(to->remote_ipv6));
+	else
+		to->remote_ipv4 = be32_to_cpu(info->key.u.ipv4.src);
+
+	if (unlikely(size != sizeof(struct bpf_tunnel_key)))
+		memcpy((void *)(long) r2, to, size);
 
 	return 0;
 }
@@ -1714,10 +1744,25 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	struct bpf_tunnel_key *from = (struct bpf_tunnel_key *) (long) r2;
 	struct metadata_dst *md = this_cpu_ptr(md_dst);
+	u8 compat[sizeof(struct bpf_tunnel_key)];
 	struct ip_tunnel_info *info;
 
-	if (unlikely(size != sizeof(struct bpf_tunnel_key) || flags))
+	if (unlikely(flags & ~(BPF_F_TUNINFO_IPV6)))
 		return -EINVAL;
+	if (unlikely(size != sizeof(struct bpf_tunnel_key))) {
+		switch (size) {
+		case offsetof(struct bpf_tunnel_key, remote_ipv6[1]):
+			/* Fixup deprecated structure layouts here, so we have
+			 * a common path later on.
+			 */
+			memcpy(compat, from, size);
+			memset(compat + size, 0, sizeof(compat) - size);
+			from = (struct bpf_tunnel_key *)compat;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
 
 	skb_dst_drop(skb);
 	dst_hold((struct dst_entry *) md);
@@ -1725,9 +1770,19 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 
 	info = &md->u.tun_info;
 	info->mode = IP_TUNNEL_INFO_TX;
+
 	info->key.tun_flags = TUNNEL_KEY;
 	info->key.tun_id = cpu_to_be64(from->tunnel_id);
-	info->key.u.ipv4.dst = cpu_to_be32(from->remote_ipv4);
+	info->key.tos = from->tunnel_tos;
+	info->key.ttl = from->tunnel_ttl;
+
+	if (flags & BPF_F_TUNINFO_IPV6) {
+		info->mode |= IP_TUNNEL_INFO_IPV6;
+		memcpy(&info->key.u.ipv6.dst, from->remote_ipv6,
+		       sizeof(from->remote_ipv6));
+	} else {
+		info->key.u.ipv4.dst = cpu_to_be32(from->remote_ipv4);
+	}
 
 	return 0;
 }
-- 
1.9.3
