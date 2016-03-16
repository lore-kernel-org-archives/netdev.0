From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/3] ip_tunnels, bpf: define IP_TUNNEL_OPTS_MAX and use it
Date: Wed, 16 Mar 2016 01:42:51 +0100
Message-ID: <cb343dbf218e922b28efc7e051a58bbf0881703a.1458085814.git.daniel@iogearbox.net>
References: <cover.1458085814.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38434 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754365AbcCPAnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 20:43:06 -0400
In-Reply-To: <cover.1458085814.git.daniel@iogearbox.net>
In-Reply-To: <cover.1458085814.git.daniel@iogearbox.net>
References: <cover.1458085814.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eBPF defines this as BPF_TUNLEN_MAX and OVS just uses the hard-coded
value inside struct sw_flow_key. Thus, add and use IP_TUNNEL_OPTS_MAX
for this, which makes the code a bit more generic and allows to remove
BPF_TUNLEN_MAX from eBPF code.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/ip_tunnels.h  | 7 +++++++
 net/core/filter.c         | 9 ++-------
 net/ipv4/ip_tunnel_core.c | 6 ++++++
 net/openvswitch/flow.h    | 2 +-
 4 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 5dc2e45..c35dda9 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -7,6 +7,8 @@
 #include <linux/socket.h>
 #include <linux/types.h>
 #include <linux/u64_stats_sync.h>
+#include <linux/bitops.h>
+
 #include <net/dsfield.h>
 #include <net/gro_cells.h>
 #include <net/inet_ecn.h>
@@ -57,6 +59,11 @@ struct ip_tunnel_key {
 #define IP_TUNNEL_INFO_TX	0x01	/* represents tx tunnel parameters */
 #define IP_TUNNEL_INFO_IPV6	0x02	/* key contains IPv6 addresses */
 
+/* Maximum tunnel options length. */
+#define IP_TUNNEL_OPTS_MAX					\
+	GENMASK((FIELD_SIZEOF(struct ip_tunnel_info,		\
+			      options_len) * BITS_PER_BYTE) - 1, 0)
+
 struct ip_tunnel_info {
 	struct ip_tunnel_key	key;
 #ifdef CONFIG_DST_CACHE
diff --git a/net/core/filter.c b/net/core/filter.c
index 4c35d83..b7177d0 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1904,8 +1904,6 @@ static const struct bpf_func_proto bpf_skb_set_tunnel_key_proto = {
 	.arg4_type	= ARG_ANYTHING,
 };
 
-#define BPF_TUNLEN_MAX	255
-
 static u64 bpf_skb_set_tunnel_opt(u64 r1, u64 r2, u64 size, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
@@ -1915,7 +1913,7 @@ static u64 bpf_skb_set_tunnel_opt(u64 r1, u64 r2, u64 size, u64 r4, u64 r5)
 
 	if (unlikely(info != &md->u.tun_info || (size & (sizeof(u32) - 1))))
 		return -EINVAL;
-	if (unlikely(size > BPF_TUNLEN_MAX))
+	if (unlikely(size > IP_TUNNEL_OPTS_MAX))
 		return -ENOMEM;
 
 	ip_tunnel_info_opts_set(info, from, size);
@@ -1936,13 +1934,10 @@ static const struct bpf_func_proto *
 bpf_get_skb_set_tunnel_proto(enum bpf_func_id which)
 {
 	if (!md_dst) {
-		BUILD_BUG_ON(FIELD_SIZEOF(struct ip_tunnel_info,
-					  options_len) != 1);
-
 		/* Race is not possible, since it's called from verifier
 		 * that is holding verifier mutex.
 		 */
-		md_dst = metadata_dst_alloc_percpu(BPF_TUNLEN_MAX,
+		md_dst = metadata_dst_alloc_percpu(IP_TUNNEL_OPTS_MAX,
 						   GFP_KERNEL);
 		if (!md_dst)
 			return NULL;
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index eaca244..d27276f 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -398,6 +398,12 @@ static const struct lwtunnel_encap_ops ip6_tun_lwt_ops = {
 
 void __init ip_tunnel_core_init(void)
 {
+	/* If you land here, make sure whether increasing ip_tunnel_info's
+	 * options_len is a reasonable choice with its usage in front ends
+	 * (f.e., it's part of flow keys, etc).
+	 */
+	BUILD_BUG_ON(IP_TUNNEL_OPTS_MAX != 255);
+
 	lwtunnel_encap_add_ops(&ip_tun_lwt_ops, LWTUNNEL_ENCAP_IP);
 	lwtunnel_encap_add_ops(&ip6_tun_lwt_ops, LWTUNNEL_ENCAP_IP6);
 }
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 1d055c5..03378e7 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -55,7 +55,7 @@ struct ovs_tunnel_info {
 	FIELD_SIZEOF(struct sw_flow_key, recirc_id))
 
 struct sw_flow_key {
-	u8 tun_opts[255];
+	u8 tun_opts[IP_TUNNEL_OPTS_MAX];
 	u8 tun_opts_len;
 	struct ip_tunnel_key tun_key;	/* Encapsulating tunnel key. */
 	struct {
-- 
1.9.3
