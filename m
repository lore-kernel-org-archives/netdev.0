From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next V4 PATCH 2/5] bpf: XDP_REDIRECT enable use of cpumap
Date: Wed, 04 Oct 2017 14:03:50 +0200
Message-ID: <150711863012.9499.383645968070658124.stgit@firesoul>
References: <150711858281.9499.7767364427831352921.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34686 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752181AbdJDMDz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 08:03:55 -0400
In-Reply-To: <150711858281.9499.7767364427831352921.stgit@firesoul>
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

V3: Handle !CONFIG_BPF_SYSCALL pointed out by kbuild test robot.

V4: Make Generic-XDP aware of cpumap type, but don't allow redirect yet,
 as implementation require a separate upstream discussion.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/bpf.h        |   31 +++++++++-
 include/trace/events/xdp.h |   10 ++-
 kernel/bpf/cpumap.c        |    5 +-
 kernel/bpf/verifier.c      |    3 +
 net/core/filter.c          |  142 +++++++++++++++++++++++++++++++++++---------
 5 files changed, 155 insertions(+), 36 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 252f4bc9eb25..36ec83343c82 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -320,6 +320,13 @@ struct net_device  *__dev_map_lookup_elem(struct bpf_map *map, u32 key);
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
@@ -327,7 +334,7 @@ static inline int bpf_map_attr_numa_node(const union bpf_attr *attr)
 		attr->numa_node : NUMA_NO_NODE;
 }
 
-#else
+#else /* !CONFIG_BPF_SYSCALL */
 static inline struct bpf_prog *bpf_prog_get(u32 ufd)
 {
 	return ERR_PTR(-EOPNOTSUPP);
@@ -385,6 +392,28 @@ static inline void __dev_map_insert_ctx(struct bpf_map *map, u32 index)
 static inline void __dev_map_flush(struct bpf_map *map)
 {
 }
+
+static inline
+struct bpf_cpu_map_entry *__cpu_map_lookup_elem(struct bpf_map *map, u32 key)
+{
+	return NULL;
+}
+
+static inline void __cpu_map_insert_ctx(struct bpf_map *map, u32 index)
+{
+}
+
+static inline void __cpu_map_flush(struct bpf_map *map)
+{
+}
+
+struct xdp_buff;
+static inline int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu,
+				  struct xdp_buff *xdp,
+				  struct net_device *dev_rx)
+{
+	return 0;
+}
 #endif /* CONFIG_BPF_SYSCALL */
 
 #if defined(CONFIG_STREAM_PARSER) && defined(CONFIG_BPF_SYSCALL)
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
index ae8e29352261..4926a9971f90 100644
--- a/kernel/bpf/cpumap.c
+++ b/kernel/bpf/cpumap.c
@@ -493,7 +493,8 @@ static int bq_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_pkt *xdp_pkt)
 	return 0;
 }
 
-int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp)
+int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp,
+		    struct net_device *dev_rx)
 {
 	struct xdp_pkt *xdp_pkt;
 	int headroom;
@@ -505,7 +506,7 @@ int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp)
 	xdp_pkt = xdp->data_hard_start;
 	xdp_pkt->data = xdp->data;
 	xdp_pkt->len  = xdp->data_end - xdp->data;
-	xdp_pkt->headroom = headroom;
+	xdp_pkt->headroom = headroom - sizeof(*xdp_pkt);
 	/* For now this is just used as a void pointer to data_hard_start */
 
 	bq_enqueue(rcpu, xdp_pkt);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 4cf9b72c59a0..670868f1b017 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1608,7 +1608,8 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
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
index 9b6e7e84aafd..dbf2ae071108 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2521,10 +2521,36 @@ static int __bpf_tx_xdp(struct net_device *dev,
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
+		if (!dev->netdev_ops->ndo_xdp_xmit)
+			return -EOPNOTSUPP;
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
 
@@ -2534,11 +2560,33 @@ void xdp_do_flush_map(void)
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
@@ -2551,8 +2599,8 @@ static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 	unsigned long map_owner = ri->map_owner;
 	struct bpf_map *map = ri->map;
-	struct net_device *fwd = NULL;
 	u32 index = ri->ifindex;
+	void *fwd = NULL;
 	int err;
 
 	ri->ifindex = 0;
@@ -2565,7 +2613,7 @@ static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 		goto err;
 	}
 
-	fwd = __dev_map_lookup_elem(map, index);
+	fwd = __xdp_map_lookup_elem(map, index);
 	if (!fwd) {
 		err = -EINVAL;
 		goto err;
@@ -2573,7 +2621,7 @@ static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 	if (ri->map_to_flush && ri->map_to_flush != map)
 		xdp_do_flush_map();
 
-	err = __bpf_tx_xdp(fwd, map, xdp, index);
+	err = __bpf_tx_xdp_map(dev, fwd, map, xdp, index);
 	if (unlikely(err))
 		goto err;
 
@@ -2615,54 +2663,88 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 }
 EXPORT_SYMBOL_GPL(xdp_do_redirect);
 
-int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
-			    struct bpf_prog *xdp_prog)
+static int __xdp_generic_ok_fwd_dev(struct sk_buff *skb, struct net_device *fwd)
+{
+	unsigned int len;
+
+	if (unlikely(!(fwd->flags & IFF_UP)))
+		return -ENETDOWN;
+
+	len = fwd->mtu + fwd->hard_header_len + VLAN_HLEN;
+	if (skb->len > len)
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+int xdp_do_generic_redirect_map(struct net_device *dev, struct sk_buff *skb,
+				struct bpf_prog *xdp_prog)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 	unsigned long map_owner = ri->map_owner;
 	struct bpf_map *map = ri->map;
-	struct net_device *fwd = NULL;
 	u32 index = ri->ifindex;
-	unsigned int len;
+	struct net_device *fwd;
 	int err = 0;
 
 	ri->ifindex = 0;
 	ri->map = NULL;
 	ri->map_owner = 0;
 
-	if (map) {
-		if (unlikely(xdp_map_invalid(xdp_prog, map_owner))) {
-			err = -EFAULT;
-			map = NULL;
-			goto err;
-		}
-		fwd = __dev_map_lookup_elem(map, index);
-	} else {
-		fwd = dev_get_by_index_rcu(dev_net(dev), index);
+	if (unlikely(xdp_map_invalid(xdp_prog, map_owner))) {
+		err = -EFAULT;
+		map = NULL;
+		goto err;
 	}
+	fwd = __xdp_map_lookup_elem(map, index);
 	if (unlikely(!fwd)) {
 		err = -EINVAL;
 		goto err;
 	}
 
-	if (unlikely(!(fwd->flags & IFF_UP))) {
-		err = -ENETDOWN;
+	if (map->map_type == BPF_MAP_TYPE_DEVMAP) {
+		if (unlikely((err = __xdp_generic_ok_fwd_dev(skb, fwd))))
+			goto err;
+		skb->dev = fwd;
+	} else {
+		/* TODO: Handle BPF_MAP_TYPE_CPUMAP */
+		err = -EBADRQC;
 		goto err;
 	}
 
-	len = fwd->mtu + fwd->hard_header_len + VLAN_HLEN;
-	if (skb->len > len) {
-		err = -EMSGSIZE;
+	_trace_xdp_redirect_map(dev, xdp_prog, fwd, map, index);
+	return 0;
+err:
+	_trace_xdp_redirect_map_err(dev, xdp_prog, fwd, map, index, err);
+	return err;
+}
+
+int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
+			    struct bpf_prog *xdp_prog)
+{
+	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+	u32 index = ri->ifindex;
+	struct net_device *fwd;
+	int err = 0;
+
+	if (ri->map)
+		return xdp_do_generic_redirect_map(dev, skb, xdp_prog);
+
+	ri->ifindex = 0;
+	fwd = dev_get_by_index_rcu(dev_net(dev), index);
+	if (unlikely(!fwd)) {
+		err = -EINVAL;
 		goto err;
 	}
 
+	if (unlikely((err = __xdp_generic_ok_fwd_dev(skb, fwd))))
+		goto err;
+
 	skb->dev = fwd;
-	map ? _trace_xdp_redirect_map(dev, xdp_prog, fwd, map, index)
-		: _trace_xdp_redirect(dev, xdp_prog, index);
+	_trace_xdp_redirect(dev, xdp_prog, index);
 	return 0;
 err:
-	map ? _trace_xdp_redirect_map_err(dev, xdp_prog, fwd, map, index, err)
-		: _trace_xdp_redirect_err(dev, xdp_prog, index, err);
+	_trace_xdp_redirect_err(dev, xdp_prog, index, err);
 	return err;
 }
 EXPORT_SYMBOL_GPL(xdp_do_generic_redirect);
