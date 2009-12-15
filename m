From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 1/4] net: port mirroring: add tracepoints to
	appropriate network paths
Date: Tue, 15 Dec 2009 11:36:04 -0500
Message-ID: <20091215163604.GC18710@hmsreliant.think-freely.org>
References: <20091215162956.GB18710@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56853 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759624AbZLOQgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 11:36:06 -0500
Content-Disposition: inline
In-Reply-To: <20091215162956.GB18710@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add net_dev_xmit & net_dev_receive tracepoints

Add tracepoints at the end of the network stack xmit path and the start of the
stack receive path.  Among other uses, these tracepoints can be used to tap the
raw input and output streams for any given network device for the purposes of
mirroring that traffic to other ports.

I should note that this patch relies on the patch here:
http://lkml.org/lkml/2009/12/7/403
As it fixes a bug in the tracing infrastructure that doesn't allow for the
definition of tracepoints from multiple header files in a single C file.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/trace/events/net.h |   59 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c             |   10 +++++++
 net/core/net-traces.c      |    4 ++-
 3 files changed, 72 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/net.h b/include/trace/events/net.h
new file mode 100644
index 0000000..09d26cf
--- /dev/null
+++ b/include/trace/events/net.h
@@ -0,0 +1,59 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM net 
+
+#if !defined(_TRACE_NET_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_NET_H
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(net_dev_xmit,
+
+	TP_PROTO(struct sk_buff *skb, int rc),
+
+	TP_ARGS(skb, rc),
+
+	TP_STRUCT__entry(
+		__field(	void *,	skbaddr		)
+		__field(	int, 	rc		)
+	),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->rc = rc;
+	),
+
+	TP_printk("skbaddr=%p transmitted with rc=%d",
+		__entry->skbaddr, __entry->rc)
+);
+
+TRACE_EVENT(net_dev_receive,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__field(	void *, skbaddr 		)
+		__field(	struct net_device *, dev	)
+	),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		if (skb->dev) {
+			__entry->dev = skb->dev;
+		} else {
+			__entry->dev = NULL;
+		}
+	),
+
+	TP_printk("skbaddr=%p received on interface %s",
+		__entry->skbaddr, (__entry->dev) ? __entry->dev->name : "Unknown")
+);
+
+		
+#endif
+
+#include <trace/define_trace.h>
+
diff --git a/net/core/dev.c b/net/core/dev.c
index c36a17a..303d56f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -129,6 +129,7 @@
 #include <linux/jhash.h>
 #include <linux/random.h>
 #include <trace/events/napi.h>
+#include <trace/events/net.h>
 
 #include "net-sysfs.h"
 
@@ -1828,6 +1829,9 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			skb_dst_drop(skb);
 
 		rc = ops->ndo_start_xmit(skb, dev);
+
+		trace_net_dev_xmit(skb, rc);
+
 		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);
 		/*
@@ -1853,7 +1857,11 @@ gso:
 
 		skb->next = nskb->next;
 		nskb->next = NULL;
+
 		rc = ops->ndo_start_xmit(nskb, dev);
+
+		trace_net_dev_xmit(nskb, rc);
+
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
 				goto out_kfree_gso_skb;
@@ -2428,6 +2436,8 @@ int netif_receive_skb(struct sk_buff *skb)
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
 
+	trace_net_dev_receive(skb);
+
 	if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
 		return NET_RX_SUCCESS;
 
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index f1e982c..da23ec8 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -25,8 +25,10 @@
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/skb.h>
+#include <trace/events/net.h>
 #include <trace/events/napi.h>
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
-
 EXPORT_TRACEPOINT_SYMBOL_GPL(napi_poll);
+EXPORT_TRACEPOINT_SYMBOL_GPL(net_dev_xmit);
+EXPORT_TRACEPOINT_SYMBOL_GPL(net_dev_receive);
