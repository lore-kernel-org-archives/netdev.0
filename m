From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 16/17] LTTng instrumentation - ipv6
Date: Tue, 15 Jul 2008 18:26:20 -0400
Message-ID: <20080715222749.533476549@polymtl.ca>
References: <20080715222604.331269462@polymtl.ca>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Pekka Savola <pekkas@netcore.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Frank Ch. Eigler" <fche@redhat.com>,
	Hideo AOKI <haoki@redhat.com>,
	Takashi Nishiie <t-nishiie@np.css.fujitsu.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
To: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Masami Hiramatsu <mhiramat@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.polymtl.ca ([132.207.4.11]:47386 "EHLO smtp.polymtl.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762628AbYGOW3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 18:29:32 -0400
Content-Disposition: inline; filename=lttng-instrumentation-ipv6.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instrument addr_add and del of network interfaces. Lets a tracer know the
interface address changes.

Those tracepoints are used by LTTng.

About the performance impact of tracepoints (which is comparable to markers),
even without immediate values optimizations, tests done by Hideo Aoki on ia64
show no regression. His test case was using hackbench on a kernel where
scheduler instrumentation (about 5 events in code scheduler code) was added.
See the "Tracepoints" patch header for performance result detail.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: Pekka Savola <pekkas@netcore.fi>
CC: netdev@vger.kernel.org
CC: David S. Miller <davem@davemloft.net>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
CC: Masami Hiramatsu <mhiramat@redhat.com>
CC: 'Peter Zijlstra' <peterz@infradead.org>
CC: "Frank Ch. Eigler" <fche@redhat.com>
CC: 'Ingo Molnar' <mingo@elte.hu>
CC: 'Hideo AOKI' <haoki@redhat.com>
CC: Takashi Nishiie <t-nishiie@np.css.fujitsu.com>
CC: 'Steven Rostedt' <rostedt@goodmis.org>
CC: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 include/trace/ipv6.h |   14 ++++++++++++++
 net/ipv6/addrconf.c  |    4 ++++
 2 files changed, 18 insertions(+)

Index: linux-2.6-lttng/net/ipv6/addrconf.c
===================================================================
--- linux-2.6-lttng.orig/net/ipv6/addrconf.c	2008-07-15 14:51:51.000000000 -0400
+++ linux-2.6-lttng/net/ipv6/addrconf.c	2008-07-15 15:16:14.000000000 -0400
@@ -85,6 +85,7 @@
 
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <trace/ipv6.h>
 
 /* Set to 3 to get tracing... */
 #define ACONF_DEBUG 2
@@ -650,6 +651,8 @@ ipv6_add_addr(struct inet6_dev *idev, co
 	/* For caller */
 	in6_ifa_hold(ifa);
 
+	trace_ipv6_addr_add(ifa);
+
 	/* Add to big hash table */
 	hash = ipv6_addr_hash(addr);
 
@@ -2163,6 +2166,7 @@ static int inet6_addr_del(struct net *ne
 			in6_ifa_hold(ifp);
 			read_unlock_bh(&idev->lock);
 
+			trace_ipv6_addr_del(ifp);
 			ipv6_del_addr(ifp);
 
 			/* If the last address is deleted administratively,
Index: linux-2.6-lttng/include/trace/ipv6.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6-lttng/include/trace/ipv6.h	2008-07-15 15:16:14.000000000 -0400
@@ -0,0 +1,14 @@
+#ifndef _TRACE_IPV6_H
+#define _TRACE_IPV6_H
+
+#include <net/if_inet6.h>
+#include <linux/tracepoint.h>
+
+DEFINE_TRACE(ipv6_addr_add,
+	TPPROTO(struct inet6_ifaddr *ifa),
+	TPARGS(ifa));
+DEFINE_TRACE(ipv6_addr_del,
+	TPPROTO(struct inet6_ifaddr *ifa),
+	TPARGS(ifa));
+
+#endif

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
