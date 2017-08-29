From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net-next 5/7] xdp: separate xdp_redirect tracepoint in map
 case
Date: Tue, 29 Aug 2017 16:38:01 +0200
Message-ID: <150401748121.16384.7676807301169759129.stgit@firesoul>
References: <150401743083.16384.15778781741742858567.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49858 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932066AbdH2OiD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 10:38:03 -0400
In-Reply-To: <150401743083.16384.15778781741742858567.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Creating as specific xdp_redirect_map variant of the xdp tracepoints
allow users to write simpler/faster BPF progs that get attached to
these tracepoints.

Goal is to still keep the tracepoints in xdp_redirect and xdp_redirect_map
similar enough, that a tool can read the top part of the TP_STRUCT and
produce similar monitor statistics.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/trace/events/xdp.h |   46 ++++++++++++++++++++++++++++++++++++--------
 net/core/filter.c          |    4 ++--
 2 files changed, 40 insertions(+), 10 deletions(-)

diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index 1eebad55ebd4..862575ac8da9 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -77,13 +77,11 @@ DECLARE_EVENT_CLASS(xdp_redirect_template,
 		__entry->map_index	= map_index;
 	),
 
-	TP_printk("prog_id=%d action=%s ifindex=%d to_ifindex=%d err=%d"
-		  " map_id=%d map_index=%d",
+	TP_printk("prog_id=%d action=%s ifindex=%d to_ifindex=%d err=%d",
 		  __entry->prog_id,
 		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
 		  __entry->ifindex, __entry->to_ifindex,
-		  __entry->err,
-		  __entry->map_id, __entry->map_index)
+		  __entry->err)
 );
 
 DEFINE_EVENT(xdp_redirect_template, xdp_redirect,
@@ -108,11 +106,43 @@ DEFINE_EVENT(xdp_redirect_template, xdp_redirect_err,
 #define _trace_xdp_redirect_err(dev, xdp, to, err)	\
 	 trace_xdp_redirect_err(dev, xdp, to, err, NULL, 0);
 
-#define trace_xdp_redirect_map(dev, xdp, fwd, map, idx)	\
-	trace_xdp_redirect(dev, xdp, fwd ? fwd->ifindex : 0, 0, map, idx);
+DEFINE_EVENT_PRINT(xdp_redirect_template, xdp_redirect_map,
+	TP_PROTO(const struct net_device *dev,
+		 const struct bpf_prog *xdp,
+		 int to_ifindex, int err,
+		 const struct bpf_map *map, u32 map_index),
+	TP_ARGS(dev, xdp, to_ifindex, err, map, map_index),
+	TP_printk("prog_id=%d action=%s ifindex=%d to_ifindex=%d err=%d"
+		  " map_id=%d map_index=%d",
+		  __entry->prog_id,
+		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
+		  __entry->ifindex, __entry->to_ifindex,
+		  __entry->err,
+		  __entry->map_id, __entry->map_index)
+);
+
+DEFINE_EVENT_PRINT(xdp_redirect_template, xdp_redirect_map_err,
+	TP_PROTO(const struct net_device *dev,
+		 const struct bpf_prog *xdp,
+		 int to_ifindex, int err,
+		 const struct bpf_map *map, u32 map_index),
+	TP_ARGS(dev, xdp, to_ifindex, err, map, map_index),
+	TP_printk("prog_id=%d action=%s ifindex=%d to_ifindex=%d err=%d"
+		  " map_id=%d map_index=%d",
+		  __entry->prog_id,
+		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
+		  __entry->ifindex, __entry->to_ifindex,
+		  __entry->err,
+		  __entry->map_id, __entry->map_index)
+);
+
+#define _trace_xdp_redirect_map(dev, xdp, fwd, map, idx)		\
+	 trace_xdp_redirect_map(dev, xdp, fwd ? fwd->ifindex : 0,	\
+				0, map, idx);
 
-#define trace_xdp_redirect_map_err(dev, xdp, fwd, map, idx, err)	\
-	trace_xdp_redirect_err(dev, xdp, fwd ? fwd->ifindex : 0, err, map, idx);
+#define _trace_xdp_redirect_map_err(dev, xdp, fwd, map, idx, err)	\
+	 trace_xdp_redirect_map_err(dev, xdp, fwd ? fwd->ifindex : 0,	\
+				    err, map, idx);
 
 #endif /* _TRACE_XDP_H */
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 096e78de0b97..c6a37fe0285b 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2525,10 +2525,10 @@ static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 		goto err;
 
 	ri->map_to_flush = map;
-	trace_xdp_redirect_map(dev, xdp_prog, fwd, map, index);
+	_trace_xdp_redirect_map(dev, xdp_prog, fwd, map, index);
 	return 0;
 err:
-	trace_xdp_redirect_map_err(dev, xdp_prog, fwd, map, index, err);
+	_trace_xdp_redirect_map_err(dev, xdp_prog, fwd, map, index, err);
 	return err;
 }
 
