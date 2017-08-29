From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net-next 1/7] xdp: remove redundant argument to
 trace_xdp_redirect
Date: Tue, 29 Aug 2017 16:37:40 +0200
Message-ID: <150401746079.16384.6082507760415730494.stgit@firesoul>
References: <150401743083.16384.15778781741742858567.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33836 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752746AbdH2Oho (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 10:37:44 -0400
In-Reply-To: <150401743083.16384.15778781741742858567.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Supplying the action argument XDP_REDIRECT to the tracepoint xdp_redirect
is redundant as it is only called in-case this action was specified.

Remove the argument, but keep "act" member of the tracepoint struct and
populate it with XDP_REDIRECT.  This makes it easier to write a common bpf_prog
processing events.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/trace/events/xdp.h |    6 +++---
 net/core/filter.c          |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index 27cf2ef35f5f..f684f3b36bca 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -52,10 +52,10 @@ TRACE_EVENT(xdp_exception,
 TRACE_EVENT(xdp_redirect,
 
 	TP_PROTO(const struct net_device *dev,
-		 const struct bpf_prog *xdp, u32 act,
+		 const struct bpf_prog *xdp,
 		 int to_index, int err),
 
-	TP_ARGS(dev, xdp, act, to_index, err),
+	TP_ARGS(dev, xdp, to_index, err),
 
 	TP_STRUCT__entry(
 		__array(u8, prog_tag, 8)
@@ -68,7 +68,7 @@ TRACE_EVENT(xdp_redirect,
 	TP_fast_assign(
 		BUILD_BUG_ON(sizeof(__entry->prog_tag) != sizeof(xdp->tag));
 		memcpy(__entry->prog_tag, xdp->tag, sizeof(xdp->tag));
-		__entry->act		= act;
+		__entry->act		= XDP_REDIRECT;
 		__entry->ifindex	= dev->ifindex;
 		__entry->to_index	= to_index;
 		__entry->err		= err;
diff --git a/net/core/filter.c b/net/core/filter.c
index 4bcd6baa80c9..de31fb684ad4 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2524,7 +2524,7 @@ static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 	if (likely(!err))
 		ri->map_to_flush = map;
 out:
-	trace_xdp_redirect(dev, xdp_prog, XDP_REDIRECT, index, err);
+	trace_xdp_redirect(dev, xdp_prog, index, err);
 	return err;
 }
 
@@ -2548,7 +2548,7 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 
 	err = __bpf_tx_xdp(fwd, NULL, xdp, 0);
 out:
-	trace_xdp_redirect(dev, xdp_prog, XDP_REDIRECT, index, err);
+	trace_xdp_redirect(dev, xdp_prog, index, err);
 	return err;
 }
 EXPORT_SYMBOL_GPL(xdp_do_redirect);
@@ -2582,7 +2582,7 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
 
 	skb->dev = fwd;
 out:
-	trace_xdp_redirect(dev, xdp_prog, XDP_REDIRECT, index, err);
+	trace_xdp_redirect(dev, xdp_prog, index, err);
 	return err;
 }
 EXPORT_SYMBOL_GPL(xdp_do_generic_redirect);
