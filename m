From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net-next 4/5] xdp: remove net_device names from xdp_redirect
 tracepoint
Date: Tue, 22 Aug 2017 22:47:34 +0200
Message-ID: <150343485489.31091.9423090032200726744.stgit@firesoul>
References: <150343479290.31091.8019008896152616977.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52736 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752946AbdHVUrh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 16:47:37 -0400
In-Reply-To: <150343479290.31091.8019008896152616977.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is too much overhead in the current trace_xdp_redirect
tracepoint as it does strcpy and strlen on the net_device names.

Besides, exposing the ifindex/index is actually the information that
is needed in the tracepoint to diagnose issues.  When a lookup fails
(either ifindex or devmap index) then there is a need for saying which
to_index that have issues.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/trace/events/xdp.h |   17 ++++++++---------
 net/core/filter.c          |    6 +++---
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index 0e42e69f773b..7511bed80558 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -51,15 +51,14 @@ TRACE_EVENT(xdp_exception,
 
 TRACE_EVENT(xdp_redirect,
 
-	TP_PROTO(const struct net_device *from,
-		 const struct net_device *to,
+	TP_PROTO(int from_index, int to_index,
 		 const struct bpf_prog *xdp, u32 act, int err),
 
-	TP_ARGS(from, to, xdp, act, err),
+	TP_ARGS(from_index, to_index, xdp, act, err),
 
 	TP_STRUCT__entry(
-		__string(name_from, from->name)
-		__string(name_to, to->name)
+		__field(int, from_index)
+		__field(int, to_index)
 		__array(u8, prog_tag, 8)
 		__field(u32, act)
 		__field(int, err)
@@ -68,15 +67,15 @@ TRACE_EVENT(xdp_redirect,
 	TP_fast_assign(
 		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(xdp->tag));
 		memcpy(__entry->prog_tag, xdp->tag, sizeof(xdp->tag));
-		__assign_str(name_from, from->name);
-		__assign_str(name_to, to->name);
+		__entry->from_index	= from_index;
+		__entry->to_index	= to_index;
 		__entry->act = act;
 		__entry->err = err;
 	),
 
-	TP_printk("prog=%s from=%s to=%s action=%s err=%d",
+	TP_printk("prog=%s from=%d to=%d action=%s err=%d",
 		  __print_hex_str(__entry->prog_tag, 8),
-		  __get_str(name_from), __get_str(name_to),
+		  __entry->from_index, __entry->to_index,
 		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
 		  __entry->err)
 );
diff --git a/net/core/filter.c b/net/core/filter.c
index 2d7cdb2c5c66..35f0383fa2b9 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2553,7 +2553,7 @@ int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 		ri->map_to_flush = map;
 
 out:
-	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT, err);
+	trace_xdp_redirect(dev->ifindex, index, xdp_prog, XDP_REDIRECT, err);
 	return err;
 }
 
@@ -2577,7 +2577,7 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 
 	err = __bpf_tx_xdp(fwd, NULL, xdp, 0);
 out:
-	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT, err);
+	trace_xdp_redirect(dev->ifindex, index, xdp_prog, XDP_REDIRECT, err);
 	return err;
 }
 EXPORT_SYMBOL_GPL(xdp_do_redirect);
@@ -2611,7 +2611,7 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
 
 	skb->dev = fwd;
 out:
-	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT, err);
+	trace_xdp_redirect(dev->ifindex, index, xdp_prog, XDP_REDIRECT, err);
 	return err;
 }
 EXPORT_SYMBOL_GPL(xdp_do_generic_redirect);
