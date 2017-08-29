From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net-next 4/7] xdp: separate xdp_redirect tracepoint in error
 case
Date: Tue, 29 Aug 2017 16:37:56 +0200
Message-ID: <150401747611.16384.8021135230122395742.stgit@firesoul>
References: <150401743083.16384.15778781741742858567.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57914 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752746AbdH2Oh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 10:37:58 -0400
In-Reply-To: <150401743083.16384.15778781741742858567.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a need to separate the xdp_redirect tracepoint into two
tracepoints, for separating the error case from the normal forward
case.

Due to the extreme speeds XDP is operating at, loading a tracepoint
have a measurable impact.  Single core XDP REDIRECT (ethtool tuned
rx-usecs 25) can do 13.7 Mpps forwarding, but loading a simple
bpf_prog at the tracepoint (with a return 0) reduce perf to 10.2 Mpps
(CPU E5-1650 v4 @ 3.60GHz, driver: ixgbe)

The overhead of loading a bpf-based tracepoint can be calculated to
cost 25 nanosec ((1/13782002-1/10267937)*10^9 = -24.83 ns).

Using perf record on the tracepoint event, with a non-matching --filter
expression, the overhead is much larger. Performance drops to 8.3 Mpps,
cost 48 nanosec ((1/13782002-1/8312497)*10^9 = -47.74))

Having a separate tracepoint for err cases, which should be less
frequent, allow running a continuous monitor for errors while not
affecting the redirect forward performance (this have also been
verified by measurements).

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/trace/events/xdp.h |   22 ++++++++++++++++++----
 net/core/filter.c          |   37 ++++++++++++++++++++++++-------------
 2 files changed, 42 insertions(+), 17 deletions(-)

diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index 89eba564e199..1eebad55ebd4 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -94,11 +94,25 @@ DEFINE_EVENT(xdp_redirect_template, xdp_redirect,
 	TP_ARGS(dev, xdp, to_ifindex, err, map, map_index)
 );
 
-#define _trace_xdp_redirect(dev, xdp, to, err)	\
-	 trace_xdp_redirect(dev, xdp, to, err, NULL, 0);
+DEFINE_EVENT(xdp_redirect_template, xdp_redirect_err,
+	TP_PROTO(const struct net_device *dev,
+		 const struct bpf_prog *xdp,
+		 int to_ifindex, int err,
+		 const struct bpf_map *map, u32 map_index),
+	TP_ARGS(dev, xdp, to_ifindex, err, map, map_index)
+);
+
+#define _trace_xdp_redirect(dev, xdp, to)		\
+	 trace_xdp_redirect(dev, xdp, to, 0, NULL, 0);
+
+#define _trace_xdp_redirect_err(dev, xdp, to, err)	\
+	 trace_xdp_redirect_err(dev, xdp, to, err, NULL, 0);
+
+#define trace_xdp_redirect_map(dev, xdp, fwd, map, idx)	\
+	trace_xdp_redirect(dev, xdp, fwd ? fwd->ifindex : 0, 0, map, idx);
 
-#define trace_xdp_redirect_map(dev, xdp, fwd, err, map, idx)	\
-	trace_xdp_redirect(dev, xdp, fwd ? fwd->ifindex : 0, err, map, idx);
+#define trace_xdp_redirect_map_err(dev, xdp, fwd, map, idx, err)	\
+	trace_xdp_redirect_err(dev, xdp, fwd ? fwd->ifindex : 0, err, map, idx);
 
 #endif /* _TRACE_XDP_H */
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 31eab77cc842..096e78de0b97 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2515,16 +2515,20 @@ static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 	fwd = __dev_map_lookup_elem(map, index);
 	if (!fwd) {
 		err = -EINVAL;
-		goto out;
+		goto err;
 	}
 	if (ri->map_to_flush && ri->map_to_flush != map)
 		xdp_do_flush_map();
 
 	err = __bpf_tx_xdp(fwd, map, xdp, index);
-	if (likely(!err))
-		ri->map_to_flush = map;
-out:
-	trace_xdp_redirect_map(dev, xdp_prog, fwd, err, map, index);
+	if (unlikely(err))
+		goto err;
+
+	ri->map_to_flush = map;
+	trace_xdp_redirect_map(dev, xdp_prog, fwd, map, index);
+	return 0;
+err:
+	trace_xdp_redirect_map_err(dev, xdp_prog, fwd, map, index, err);
 	return err;
 }
 
@@ -2543,12 +2547,17 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 	ri->ifindex = 0;
 	if (unlikely(!fwd)) {
 		err = -EINVAL;
-		goto out;
+		goto err;
 	}
 
 	err = __bpf_tx_xdp(fwd, NULL, xdp, 0);
-out:
-	_trace_xdp_redirect(dev, xdp_prog, index, err);
+	if (unlikely(err))
+		goto err;
+
+	_trace_xdp_redirect(dev, xdp_prog, index);
+	return 0;
+err:
+	_trace_xdp_redirect_err(dev, xdp_prog, index, err);
 	return err;
 }
 EXPORT_SYMBOL_GPL(xdp_do_redirect);
@@ -2566,23 +2575,25 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
 	ri->ifindex = 0;
 	if (unlikely(!fwd)) {
 		err = -EINVAL;
-		goto out;
+		goto err;
 	}
 
 	if (unlikely(!(fwd->flags & IFF_UP))) {
 		err = -ENETDOWN;
-		goto out;
+		goto err;
 	}
 
 	len = fwd->mtu + fwd->hard_header_len + VLAN_HLEN;
 	if (skb->len > len) {
 		err = -EMSGSIZE;
-		goto out;
+		goto err;
 	}
 
 	skb->dev = fwd;
-out:
-	_trace_xdp_redirect(dev, xdp_prog, index, err);
+	_trace_xdp_redirect(dev, xdp_prog, index);
+	return 0;
+err:
+	_trace_xdp_redirect_err(dev, xdp_prog, index, err);
 	return err;
 }
 EXPORT_SYMBOL_GPL(xdp_do_generic_redirect);
