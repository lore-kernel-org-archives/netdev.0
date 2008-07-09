From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 13/15] LTTng instrumentation - net
Date: Wed, 09 Jul 2008 10:59:42 -0400
Message-ID: <20080709150047.809621885@polymtl.ca>
References: <20080709145929.352201601@polymtl.ca>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"Frank Ch. Eigler" <fche@redhat.com>,
	Hideo AOKI <haoki@redhat.com>,
	Takashi Nishiie <t-nishiie@np.css.fujitsu.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
To: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.polymtl.ca ([132.207.4.11]:41170 "EHLO smtp.polymtl.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758583AbYGIPC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 11:02:59 -0400
Content-Disposition: inline; filename=lttng-instrumentation-net.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network device activity instrumentation (xmit/receive). Allows to detect when a
packet had arrived on the network card or when it is going to be sent. This is
the instrumentation point outside of the drivers that is the closest to the
hardware. It allows to detect the amount of time taken by a packet to go through
the kernel between the system call and the actual delivery to the network card
(given that system calls are instrumented).

Those tracepoints are used by LTTng.

About the performance impact of tracepoints (which is comparable to markers),
even without immediate values optimizations, tests done by Hideo Aoki on ia64
show no regression. His test case was using hackbench on a kernel where
scheduler instrumentation (about 5 events in code scheduler code) was added.
See the "Tracepoints" patch header for performance result detail.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: netdev@vger.kernel.org
CC: Jeff Garzik <jgarzik@pobox.com>
CC: Masami Hiramatsu <mhiramat@redhat.com>
CC: 'Peter Zijlstra' <peterz@infradead.org>
CC: "Frank Ch. Eigler" <fche@redhat.com>
CC: 'Ingo Molnar' <mingo@elte.hu>
CC: 'Hideo AOKI' <haoki@redhat.com>
CC: Takashi Nishiie <t-nishiie@np.css.fujitsu.com>
CC: 'Steven Rostedt' <rostedt@goodmis.org>
CC: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 net/core/dev.c       |    4 ++++
 net/core/net-trace.h |   14 ++++++++++++++
 2 files changed, 18 insertions(+)

Index: linux-2.6-lttng/net/core/dev.c
===================================================================
--- linux-2.6-lttng.orig/net/core/dev.c	2008-07-09 10:55:46.000000000 -0400
+++ linux-2.6-lttng/net/core/dev.c	2008-07-09 10:58:38.000000000 -0400
@@ -122,6 +122,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_vlan.h>
 
+#include "net-trace.h"
 #include "net-sysfs.h"
 
 /*
@@ -1699,6 +1700,8 @@ int dev_queue_xmit(struct sk_buff *skb)
 	}
 
 gso:
+	trace_net_dev_xmit(skb);
+
 	spin_lock_prefetch(&dev->queue_lock);
 
 	/* Disable soft irqs for various locks below. Also
@@ -2099,6 +2102,7 @@ int netif_receive_skb(struct sk_buff *sk
 
 	__get_cpu_var(netdev_rx_stat).total++;
 
+	trace_net_dev_receive(skb);
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 	skb->mac_len = skb->network_header - skb->mac_header;
Index: linux-2.6-lttng/net/core/net-trace.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6-lttng/net/core/net-trace.h	2008-07-09 10:58:38.000000000 -0400
@@ -0,0 +1,14 @@
+#ifndef _NET_TRACE_H
+#define _NET_TRACE_H
+
+#include <net/sock.h>
+#include <linux/tracepoint.h>
+
+DEFINE_TRACE(net_dev_xmit,
+	TPPROTO(struct sk_buff *skb),
+	TPARGS(skb));
+DEFINE_TRACE(net_dev_receive,
+	TPPROTO(struct sk_buff *skb),
+	TPARGS(skb));
+
+#endif

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
