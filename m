From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 2/5] bpf: XDP_REDIRECT enable use of cpumap
Date: Thu, 28 Sep 2017 14:57:13 +0200
Message-ID: <150660343302.2808.13091201420033844465.stgit@firesoul>
References: <150660339205.2808.7084136789768233829.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7786 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753090AbdI1M5U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 08:57:20 -0400
In-Reply-To: <150660339205.2808.7084136789768233829.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch connects cpumap to the xdp_do_redirect_map infrastructure.

Still no SKB allocation are done yet.  The XDP frames are transferred
to the other CPU, but they are simply refcnt decremented on the remote
CPU.  This served as a good benchmark for measuring the overhead of
remote refcnt decrement.  If driver page recycle cache is not
efficient then this, exposes a bottleneck in the page allocator.

A shout-out to MST's ptr_ring, which is the secret behind is being so
efficient to transfer memory pointers between CPUs, without constantly
bouncing cache-lines between CPUs.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/bpf.h        |    7 +++++
 include/trace/events/xdp.h |   10 +++++--
 kernel/bpf/cpumap.c        |    5 ++-
 kernel/bpf/verifier.c      |    3 +-
 net/core/filter.c          |   65 +++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 77 insertions(+), 13 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 2b672c50f160..7f70b03e7426 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -317,6 +317,13 @@ struct net_device  *__dev_map_lookup_elem(struct bpf_map *map, u32 key);
 void __dev_map_insert_ctx(struct bpf_map *map, u32 index);
 void __dev_map_flush(struct bpf_map *map);
 
+struct bpf_cpu_map_entry *__cpu_map_lookup_elem(struct bpf_map *map, u32 key);
+void __cpu_map_insert_ctx(struct bpf_map *map, u32 index);
+void __cpu_map_flush(struct bpf_map *map);
+struct xdp_buff;
+int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp,
+		    struct net_device *dev_rx);
+
 /* Return map's numa specified by userspace */
 static inline int bpf_map_attr_numa_node(const union bpf_attr *attr)
 {
diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index 4e16c43fba10..eb2ece96c1a2 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -136,12 +136,18 @@ DEFINE_EVENT_PRINT(xdp_redirect_template, xdp_redirect_map_err,
 		  __entry->map_id, __entry->map_index)
 );
 
+#define devmap_ifindex(fwd, map)				\
+	(!fwd ? 0 :						\
+	 (!map ? 0 :						\
+	  ((map->map_type == BPF_MAP_TYPE_DEVMAP) ?		\
+	   ((struct net_device *)fwd)->ifindex : 0)))
+
 #define _trace_xdp_redirect_map(dev, xdp, fwd, map, idx)		\
-	 trace_xdp_redirect_map(dev, xdp, fwd ? fwd->ifindex : 0,	\
+	 trace_xdp_redirect_map(dev, xdp, devmap_ifindex(fwd, map),	\
 				0, map, idx)
 
 #define _trace_xdp_redirect_map_err(dev, xdp, fwd, map, idx, err)	\
-	 trace_xdp_redirect_map_err(dev, xdp, fwd ? fwd->ifindex : 0,	\
+	 trace_xdp_redirect_map_err(dev, xdp, devmap_ifindex(fwd, map),	\
 				    err, map, idx)
 
 #endif /* _TRACE_XDP_H */
diff --git a/kernel/bpf/cpumap.c b/kernel/bpf/cpumap.c
index f0948af82e65..ce2490ad860d 100644
--- a/kernel/bpf/cpumap.c
+++ b/kernel/bpf/cpumap.c
@@ -488,7 +488,8 @@ static int bq_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_pkt *xdp_pkt)
 	return 0;
 }
 
-int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp)
+int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp,
+		    struct net_device *dev_rx)
 {
 	struct xdp_pkt *xdp_pkt;
 	int headroom;
@@ -500,7 +501,7 @@ int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp)
 	xdp_pkt = xdp->data_hard_start;
 	xdp_pkt->data = xdp->data;
 	xdp_pkt->len  = xdp->data_end - xdp->data;
-	xdp_pkt->headroom = headroom;
+	xdp_pkt->headroom = headroom - sizeof(*xdp_pkt);
 	/* For now this is just used as a void pointer to data_hard_start */
 
 	bq_enqueue(rcpu, xdp_pkt);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index f849eca36052..a712c7431c2d 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1589,7 +1589,8 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 			goto error;
 		break;
 	case BPF_FUNC_redirect_map:
-		if (map->map_type != BPF_MAP_TYPE_DEVMAP)
+		if (map->map_type != BPF_MAP_TYPE_DEVMAP &&
+		    map->map_type != BPF_MAP_TYPE_CPUMAP)
 			goto error;
 		break;
 	case BPF_FUNC_sk_redirect_map:
diff --git a/net/core/filter.c b/net/core/filter.c
index 9b6e7e84aafd..37fe9e631ee4 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2521,10 +2521,37 @@ static int __bpf_tx_xdp(struct net_device *dev,
 	err = dev->netdev_ops->ndo_xdp_xmit(dev, xdp);
 	if (err)
 		return err;
-	if (map)
+	dev->netdev_ops->ndo_xdp_flush(dev);
+	return 0;
+}
+
+static int __bpf_tx_xdp_map(struct net_device *dev_rx, void *fwd,
+			    struct bpf_map *map,
+			    struct xdp_buff *xdp,
+			    u32 index)
+{
+	int err;
+
+	if (map->map_type == BPF_MAP_TYPE_DEVMAP) {
+		struct net_device *dev = fwd;
+
+		if (!dev->netdev_ops->ndo_xdp_xmit) {
+			return -EOPNOTSUPP;
+		}
+
+		err = dev->netdev_ops->ndo_xdp_xmit(dev, xdp);
+		if (err)
+			return err;
 		__dev_map_insert_ctx(map, index);
-	else
-		dev->netdev_ops->ndo_xdp_flush(dev);
+
+	} else if (map->map_type == BPF_MAP_TYPE_CPUMAP) {
+		struct bpf_cpu_map_entry *rcpu = fwd;
+
+		err = cpu_map_enqueue(rcpu, xdp, dev_rx);
+		if (err)
+			return err;
+		__cpu_map_insert_ctx(map, index);
+	}
 	return 0;
 }
 
@@ -2534,11 +2561,33 @@ void xdp_do_flush_map(void)
 	struct bpf_map *map = ri->map_to_flush;
 
 	ri->map_to_flush = NULL;
-	if (map)
-		__dev_map_flush(map);
+	if (map) {
+		switch (map->map_type) {
+		case BPF_MAP_TYPE_DEVMAP:
+			__dev_map_flush(map);
+			break;
+		case BPF_MAP_TYPE_CPUMAP:
+			__cpu_map_flush(map);
+			break;
+		default:
+			break;
+		}
+	}
 }
 EXPORT_SYMBOL_GPL(xdp_do_flush_map);
 
+static void *__xdp_map_lookup_elem(struct bpf_map *map, u32 index)
+{
+	switch (map->map_type) {
+	case BPF_MAP_TYPE_DEVMAP:
+		return __dev_map_lookup_elem(map, index);
+	case BPF_MAP_TYPE_CPUMAP:
+		return __cpu_map_lookup_elem(map, index);
+	default:
+		return NULL;
+	}
+}
+
 static inline bool xdp_map_invalid(const struct bpf_prog *xdp_prog,
 				   unsigned long aux)
 {
@@ -2551,8 +2600,8 @@ static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 	unsigned long map_owner = ri->map_owner;
 	struct bpf_map *map = ri->map;
-	struct net_device *fwd = NULL;
 	u32 index = ri->ifindex;
+	void *fwd = NULL;
 	int err;
 
 	ri->ifindex = 0;
@@ -2565,7 +2614,7 @@ static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 		goto err;
 	}
 
-	fwd = __dev_map_lookup_elem(map, index);
+	fwd = __xdp_map_lookup_elem(map, index);
 	if (!fwd) {
 		err = -EINVAL;
 		goto err;
@@ -2573,7 +2622,7 @@ static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 	if (ri->map_to_flush && ri->map_to_flush != map)
 		xdp_do_flush_map();
 
-	err = __bpf_tx_xdp(fwd, map, xdp, index);
+	err = __bpf_tx_xdp_map(dev, fwd, map, xdp, index);
 	if (unlikely(err))
 		goto err;
 
