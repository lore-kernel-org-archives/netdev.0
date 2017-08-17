From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 2/2] xdp: adjust xdp redirect tracepoint to include return
 error code
Date: Thu, 17 Aug 2017 18:22:37 +0200
Message-ID: <150298695758.6608.7128764985631537683.stgit@firesoul>
References: <150298692691.6608.11908184719252996949.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49432 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753005AbdHQQWl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 12:22:41 -0400
In-Reply-To: <150298692691.6608.11908184719252996949.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The return error code need to be included in the tracepoint
xdp:xdp_redirect, else its not possible to distinguish successful or
failed XDP_REDIRECT transmits.

XDP have no queuing mechanism. Thus, it is fairly easily to overrun a
NIC transmit queue.  The eBPF program invoking helpers (bpf_redirect
or bpf_redirect_map) to redirect a packet doesn't get any feedback
whether the packet was actually transmitted.

Info on failed transmits in the tracepoint xdp:xdp_redirect, is
interesting as this opens for providing a feedback-loop to the
receiving XDP program.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/trace/events/xdp.h |   11 +++++++----
 net/core/filter.c          |   19 ++++++++++++-------
 2 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index 7b1eb7b4be41..0e42e69f773b 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -53,15 +53,16 @@ TRACE_EVENT(xdp_redirect,
 
 	TP_PROTO(const struct net_device *from,
 		 const struct net_device *to,
-		 const struct bpf_prog *xdp, u32 act),
+		 const struct bpf_prog *xdp, u32 act, int err),
 
-	TP_ARGS(from, to, xdp, act),
+	TP_ARGS(from, to, xdp, act, err),
 
 	TP_STRUCT__entry(
 		__string(name_from, from->name)
 		__string(name_to, to->name)
 		__array(u8, prog_tag, 8)
 		__field(u32, act)
+		__field(int, err)
 	),
 
 	TP_fast_assign(
@@ -70,12 +71,14 @@ TRACE_EVENT(xdp_redirect,
 		__assign_str(name_from, from->name);
 		__assign_str(name_to, to->name);
 		__entry->act = act;
+		__entry->err = err;
 	),
 
-	TP_printk("prog=%s from=%s to=%s action=%s",
+	TP_printk("prog=%s from=%s to=%s action=%s err=%d",
 		  __print_hex_str(__entry->prog_tag, 8),
 		  __get_str(name_from), __get_str(name_to),
-		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB))
+		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
+		  __entry->err)
 );
 #endif /* _TRACE_XDP_H */
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 5afe3ac191ec..70c9631da7f2 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2496,14 +2496,16 @@ int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 	struct bpf_map *map = ri->map;
 	u32 index = ri->ifindex;
 	struct net_device *fwd;
-	int err = -EINVAL;
+	int err;
 
 	ri->ifindex = 0;
 	ri->map = NULL;
 
 	fwd = __dev_map_lookup_elem(map, index);
-	if (!fwd)
+	if (!fwd) {
+		err = -EINVAL;
 		goto out;
+	}
 
 	if (ri->map_to_flush && (ri->map_to_flush != map))
 		xdp_do_flush_map();
@@ -2513,7 +2515,7 @@ int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 		ri->map_to_flush = map;
 
 out:
-	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
+	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT, err);
 	return err;
 }
 
@@ -2523,6 +2525,7 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 	struct net_device *fwd;
 	u32 index = ri->ifindex;
+	int err;
 
 	if (ri->map)
 		return xdp_do_redirect_map(dev, xdp, xdp_prog);
@@ -2532,12 +2535,14 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 	ri->map = NULL;
 	if (unlikely(!fwd)) {
 		bpf_warn_invalid_xdp_redirect(index);
-		return -EINVAL;
+		err = -EINVAL;
+		goto out;
 	}
 
-	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
-
-	return __bpf_tx_xdp(fwd, NULL, xdp, 0);
+	err = __bpf_tx_xdp(fwd, NULL, xdp, 0);
+out:
+	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT, err);
+	return err;
 }
 EXPORT_SYMBOL_GPL(xdp_do_redirect);
 
