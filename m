From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [V3 PATCH net] xdp: implement xdp_redirect_map for generic XDP
Date: Sun, 10 Sep 2017 09:47:02 +0200
Message-ID: <150502962259.28817.7472180087690436639.stgit@firesoul>
References: <20170908.205426.624386613610674398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50302 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751126AbdIJHrH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 10 Sep 2017 03:47:07 -0400
In-Reply-To: <20170908.205426.624386613610674398.davem@davemloft.net>
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

Before commit 109980b894e9 ("bpf: don't select potentially stale
ri->map from buggy xdp progs") it could crash the kernel.  Like this
commit also check that the map_owner owner is correct before
dereferencing the map pointer.  But make sure that this API misusage
can be caught by a tracepoint. Thus, allowing userspace via
tracepoints to detect misbehaving bpf_progs.

Fixes: 6103aa96ec07 ("net: implement XDP_REDIRECT for xdp generic")
Fixes: 24251c264798 ("samples/bpf: add option for native and skb mode for redirect apps")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/trace/events/xdp.h |    4 ++--
 net/core/filter.c          |   38 ++++++++++++++++++++++++++------------
 2 files changed, 28 insertions(+), 14 deletions(-)

diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index 862575ac8da9..4e16c43fba10 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -138,11 +138,11 @@ DEFINE_EVENT_PRINT(xdp_redirect_template, xdp_redirect_map_err,
 
 #define _trace_xdp_redirect_map(dev, xdp, fwd, map, idx)		\
 	 trace_xdp_redirect_map(dev, xdp, fwd ? fwd->ifindex : 0,	\
-				0, map, idx);
+				0, map, idx)
 
 #define _trace_xdp_redirect_map_err(dev, xdp, fwd, map, idx, err)	\
 	 trace_xdp_redirect_map_err(dev, xdp, fwd ? fwd->ifindex : 0,	\
-				    err, map, idx);
+				    err, map, idx)
 
 #endif /* _TRACE_XDP_H */
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 3a50a9b021e2..24dd33dd9f04 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2506,21 +2506,19 @@ static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 	const struct bpf_prog *map_owner = ri->map_owner;
 	struct bpf_map *map = ri->map;
+	struct net_device *fwd = NULL;
 	u32 index = ri->ifindex;
-	struct net_device *fwd;
 	int err;
 
 	ri->ifindex = 0;
 	ri->map = NULL;
 	ri->map_owner = NULL;
 
-	/* This is really only caused by a deliberately crappy
-	 * BPF program, normally we would never hit that case,
-	 * so no need to inform someone via tracepoints either,
-	 * just bail out.
-	 */
-	if (unlikely(map_owner != xdp_prog))
-		return -EINVAL;
+	if (unlikely(map_owner != xdp_prog)) {
+		err = -EFAULT;
+		map = NULL;
+		goto err;
+	}
 
 	fwd = __dev_map_lookup_elem(map, index);
 	if (!fwd) {
@@ -2576,13 +2574,27 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
 			    struct bpf_prog *xdp_prog)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+	const struct bpf_prog *map_owner = ri->map_owner;
+	struct bpf_map *map = ri->map;
+	struct net_device *fwd = NULL;
 	u32 index = ri->ifindex;
-	struct net_device *fwd;
 	unsigned int len;
 	int err = 0;
 
-	fwd = dev_get_by_index_rcu(dev_net(dev), index);
 	ri->ifindex = 0;
+	ri->map = NULL;
+	ri->map_owner = NULL;
+
+	if (map) {
+		if (unlikely(map_owner != xdp_prog)) {
+			err = -EFAULT;
+			map = NULL;
+			goto err;
+		}
+		fwd = __dev_map_lookup_elem(map, index);
+	} else {
+		fwd = dev_get_by_index_rcu(dev_net(dev), index);
+	}
 	if (unlikely(!fwd)) {
 		err = -EINVAL;
 		goto err;
@@ -2600,10 +2612,12 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
 	}
 
 	skb->dev = fwd;
-	_trace_xdp_redirect(dev, xdp_prog, index);
+	map ? _trace_xdp_redirect_map(dev, xdp_prog, fwd, map, index)
+		: _trace_xdp_redirect(dev, xdp_prog, index);
 	return 0;
 err:
-	_trace_xdp_redirect_err(dev, xdp_prog, index, err);
+	map ? _trace_xdp_redirect_map_err(dev, xdp_prog, fwd, map, index, err)
+		: _trace_xdp_redirect_err(dev, xdp_prog, index, err);
 	return err;
 }
 EXPORT_SYMBOL_GPL(xdp_do_generic_redirect);
