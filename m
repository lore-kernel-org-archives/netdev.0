From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net-next] xdp: implement xdp_redirect_map for generic XDP
Date: Wed, 06 Sep 2017 17:26:25 +0200
Message-ID: <150471158528.3727.12324542627400287360.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52908 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932263AbdIFP0h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 11:26:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using bpf_redirect_map is allowed for generic XDP programs, but the
appropriate map lookup was never performed in xdp_do_generic_redirect().

Instead the map-index is directly used as the ifindex.  For the
xdp_redirect_map sample in SKB-mode '-S', this resulted in trying
sending on ifindex 0 which isn't valid, resulting in getting SKB
packets dropped.  Thus, the reported performance numbers are wrong in
commit 24251c264798 ("samples/bpf: add option for native and skb mode
for redirect apps") for the 'xdp_redirect_map -S' case.

It might seem innocent this was lacking, but it can actually crash the
kernel.  The potential crash is caused by not consuming redirect_info->map.
The bpf_redirect_map helper will set this_cpu_ptr(&redirect_info)->map
pointer, which will survive even after unloading the xdp bpf_prog and
deallocating the devmap data-structure.  This leaves a dead map
pointer around.  The kernel will crash when loading the xdp_redirect
sample (in native XDP mode) as it doesn't reset map (via bpf_redirect)
and returns XDP_REDIRECT, which will cause it to dereference the map
pointer.

Fixes: 6103aa96ec07 ("net: implement XDP_REDIRECT for xdp generic")
Fixes: 24251c264798 ("samples/bpf: add option for native and skb mode for redirect apps")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/core/filter.c |   29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index 5912c738a7b2..6a4745bf2c9f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2562,6 +2562,32 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 }
 EXPORT_SYMBOL_GPL(xdp_do_redirect);
 
+static int xdp_do_generic_redirect_map(struct net_device *dev,
+				       struct sk_buff *skb,
+				       struct bpf_prog *xdp_prog)
+{
+	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+	struct bpf_map *map = ri->map;
+	u32 index = ri->ifindex;
+	struct net_device *fwd;
+	int err;
+
+	ri->ifindex = 0;
+	ri->map = NULL;
+
+	fwd = __dev_map_lookup_elem(map, index);
+	if (!fwd) {
+		err = -EINVAL;
+		goto err;
+	}
+	skb->dev = fwd;
+	_trace_xdp_redirect_map(dev, xdp_prog, fwd, map, index);
+	return 0;
+err:
+	_trace_xdp_redirect_map_err(dev, xdp_prog, fwd, map, index, err);
+	return err;
+}
+
 int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
 			    struct bpf_prog *xdp_prog)
 {
@@ -2571,6 +2597,9 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
 	unsigned int len;
 	int err = 0;
 
+	if (ri->map)
+		return xdp_do_generic_redirect_map(dev, skb, xdp_prog);
+
 	fwd = dev_get_by_index_rcu(dev_net(dev), index);
 	ri->ifindex = 0;
 	if (unlikely(!fwd)) {
