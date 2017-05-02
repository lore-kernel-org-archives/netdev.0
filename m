From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] bpf: Align packet data properly in program testing
 framework.
Date: Tue, 02 May 2017 11:36:45 -0400 (EDT)
Message-ID: <20170502.113645.551424261592586390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50098 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbdEBPgr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:36:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Make sure we apply NET_IP_ALIGN when reserving headroom for SKB
and XDP test runs, just like a real driver would.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/bpf/test_run.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/bpf/test_run.c b/net/bpf/test_run.c
index f946912..6be41a4 100644
--- a/net/bpf/test_run.c
+++ b/net/bpf/test_run.c
@@ -100,7 +100,7 @@ int bpf_prog_test_run_skb(struct bpf_prog *prog, const union bpf_attr *kattr,
 	void *data;
 	int ret;
 
-	data = bpf_test_init(kattr, size, NET_SKB_PAD,
+	data = bpf_test_init(kattr, size, NET_SKB_PAD + NET_IP_ALIGN,
 			     SKB_DATA_ALIGN(sizeof(struct skb_shared_info)));
 	if (IS_ERR(data))
 		return PTR_ERR(data);
@@ -125,7 +125,7 @@ int bpf_prog_test_run_skb(struct bpf_prog *prog, const union bpf_attr *kattr,
 		return -ENOMEM;
 	}
 
-	skb_reserve(skb, NET_SKB_PAD);
+	skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
 	__skb_put(skb, size);
 	skb->protocol = eth_type_trans(skb, current->nsproxy->net_ns->loopback_dev);
 	skb_reset_network_header(skb);
@@ -156,16 +156,16 @@ int bpf_prog_test_run_xdp(struct bpf_prog *prog, const union bpf_attr *kattr,
 	void *data;
 	int ret;
 
-	data = bpf_test_init(kattr, size, XDP_PACKET_HEADROOM, 0);
+	data = bpf_test_init(kattr, size, XDP_PACKET_HEADROOM + NET_IP_ALIGN, 0);
 	if (IS_ERR(data))
 		return PTR_ERR(data);
 
 	xdp.data_hard_start = data;
-	xdp.data = data + XDP_PACKET_HEADROOM;
+	xdp.data = data + XDP_PACKET_HEADROOM + NET_IP_ALIGN;
 	xdp.data_end = xdp.data + size;
 
 	retval = bpf_test_run(prog, &xdp, repeat, &duration);
-	if (xdp.data != data + XDP_PACKET_HEADROOM)
+	if (xdp.data != data + XDP_PACKET_HEADROOM + NET_IP_ALIGN)
 		size = xdp.data_end - xdp.data;
 	ret = bpf_test_finish(kattr, uattr, xdp.data, size, retval, duration);
 	kfree(data);
-- 
2.1.2.532.g19b5d50
