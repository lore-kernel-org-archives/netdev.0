From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 1/3] bpf: also call skb_postpush_rcsum on xmit occasions
Date: Thu,  4 Aug 2016 02:50:08 +0200
Message-ID: <32eed71b20fc0c988ff074d4b6631e4f8a8a48c2.1470270323.git.daniel@iogearbox.net>
References: <cover.1470270323.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48981 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933214AbcHDAuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 20:50:24 -0400
In-Reply-To: <cover.1470270323.git.daniel@iogearbox.net>
In-Reply-To: <cover.1470270323.git.daniel@iogearbox.net>
References: <cover.1470270323.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up to commit f8ffad69c9f8 ("bpf: add skb_postpush_rcsum and fix
dev_forward_skb occasions") to fix an issue for dev_queue_xmit() redirect
locations which need CHECKSUM_COMPLETE fixups on ingress.

For the same reasons as described in f8ffad69c9f8 already, we of course
also need this here, since dev_queue_xmit() on a veth device will let us
end up in the dev_forward_skb() helper again to cross namespaces.

Latter then calls into skb_postpull_rcsum() to pull out L2 header, so
that netif_rx_internal() sees CHECKSUM_COMPLETE as it is expected. That
is, CHECKSUM_COMPLETE on ingress covering L2 _payload_, not L2 headers.

Also here we have to address bpf_redirect() and bpf_clone_redirect().

Fixes: 3896d655f4d4 ("bpf: introduce bpf_clone_redirect() helper")
Fixes: 27b29f63058d ("bpf: add bpf_redirect() helper")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 5708999..c46244f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1365,6 +1365,12 @@ static inline int bpf_try_make_writable(struct sk_buff *skb,
 	return err;
 }
 
+static inline void bpf_push_mac_rcsum(struct sk_buff *skb)
+{
+	if (skb_at_tc_ingress(skb))
+		skb_postpush_rcsum(skb, skb_mac_header(skb), skb->mac_len);
+}
+
 static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 {
 	struct bpf_scratchpad *sp = this_cpu_ptr(&bpf_sp);
@@ -1607,9 +1613,6 @@ static const struct bpf_func_proto bpf_csum_diff_proto = {
 
 static inline int __bpf_rx_skb(struct net_device *dev, struct sk_buff *skb)
 {
-	if (skb_at_tc_ingress(skb))
-		skb_postpush_rcsum(skb, skb_mac_header(skb), skb->mac_len);
-
 	return dev_forward_skb(dev, skb);
 }
 
@@ -1648,6 +1651,8 @@ static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
+	bpf_push_mac_rcsum(skb);
+
 	return flags & BPF_F_INGRESS ?
 	       __bpf_rx_skb(dev, skb) : __bpf_tx_skb(dev, skb);
 }
@@ -1693,6 +1698,8 @@ int skb_do_redirect(struct sk_buff *skb)
 		return -EINVAL;
 	}
 
+	bpf_push_mac_rcsum(skb);
+
 	return ri->flags & BPF_F_INGRESS ?
 	       __bpf_rx_skb(dev, skb) : __bpf_tx_skb(dev, skb);
 }
-- 
1.9.3
