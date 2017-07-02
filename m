From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/7] bpf, net: add skb_mac_header_len helper
Date: Sun,  2 Jul 2017 02:13:25 +0200
Message-ID: <ab270cfdd14f75cefc3b425d07508f73a18759b8.1498952486.git.daniel@iogearbox.net>
References: <cover.1498952486.git.daniel@iogearbox.net>
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57524 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752174AbdGBANn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 20:13:43 -0400
In-Reply-To: <cover.1498952486.git.daniel@iogearbox.net>
In-Reply-To: <cover.1498952486.git.daniel@iogearbox.net>
References: <cover.1498952486.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a small skb_mac_header_len() helper similarly as the
skb_network_header_len() we have and replace open coded
places in BPF's bpf_skb_change_proto() helper. Will also
be used in upcoming work.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/skbuff.h | 5 +++++
 net/core/filter.c      | 4 ++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d0b9f38..3d3ceaa 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2206,6 +2206,11 @@ static inline int skb_mac_offset(const struct sk_buff *skb)
 	return skb_mac_header(skb) - skb->data;
 }
 
+static inline u32 skb_mac_header_len(const struct sk_buff *skb)
+{
+	return skb->network_header - skb->mac_header;
+}
+
 static inline int skb_mac_header_was_set(const struct sk_buff *skb)
 {
 	return skb->mac_header != (typeof(skb->mac_header))~0U;
diff --git a/net/core/filter.c b/net/core/filter.c
index 523b91d..0cadbc6 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2012,7 +2012,7 @@ static int bpf_skb_net_hdr_pop(struct sk_buff *skb, u32 off, u32 len)
 static int bpf_skb_proto_4_to_6(struct sk_buff *skb)
 {
 	const u32 len_diff = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
-	u32 off = skb->network_header - skb->mac_header;
+	u32 off = skb_mac_header_len(skb);
 	int ret;
 
 	ret = skb_cow(skb, len_diff);
@@ -2048,7 +2048,7 @@ static int bpf_skb_proto_4_to_6(struct sk_buff *skb)
 static int bpf_skb_proto_6_to_4(struct sk_buff *skb)
 {
 	const u32 len_diff = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
-	u32 off = skb->network_header - skb->mac_header;
+	u32 off = skb_mac_header_len(skb);
 	int ret;
 
 	ret = skb_unclone(skb, GFP_ATOMIC);
-- 
1.9.3
