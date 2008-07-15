From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 15/17] LTTng instrumentation - ipv4
Date: Tue, 15 Jul 2008 18:26:19 -0400
Message-ID: <20080715222749.309982460@polymtl.ca>
References: <20080715222604.331269462@polymtl.ca>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
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
Received: from smtp.polymtl.ca ([132.207.4.11]:47347 "EHLO smtp.polymtl.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757267AbYGOW3W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 18:29:22 -0400
Content-Disposition: inline; filename=lttng-instrumentation-ipv4.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep track of interface up/down for ipv4. Allows to keep track of interface
address changes in a trace.

Those tracepoints are used by LTTng.

About the performance impact of tracepoints (which is comparable to markers),
even without immediate values optimizations, tests done by Hideo Aoki on ia64
show no regression. His test case was using hackbench on a kernel where
scheduler instrumentation (about 5 events in code scheduler code) was added.
See the "Tracepoints" patch header for performance result detail.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: netdev@vger.kernel.org
CC: David S. Miller <davem@davemloft.net>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
CC: 
CC: Masami Hiramatsu <mhiramat@redhat.com>
CC: 'Peter Zijlstra' <peterz@infradead.org>
CC: "Frank Ch. Eigler" <fche@redhat.com>
CC: 'Ingo Molnar' <mingo@elte.hu>
CC: 'Hideo AOKI' <haoki@redhat.com>
CC: Takashi Nishiie <t-nishiie@np.css.fujitsu.com>
CC: 'Steven Rostedt' <rostedt@goodmis.org>
CC: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 include/trace/ipv4.h |   14 ++++++++++++++
 net/ipv4/devinet.c   |    3 +++
 2 files changed, 17 insertions(+)

Index: linux-2.6-lttng/net/ipv4/devinet.c
===================================================================
--- linux-2.6-lttng.orig/net/ipv4/devinet.c	2008-07-15 14:51:51.000000000 -0400
+++ linux-2.6-lttng/net/ipv4/devinet.c	2008-07-15 15:16:11.000000000 -0400
@@ -61,6 +61,7 @@
 #include <net/ip_fib.h>
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
+#include <trace/ipv4.h>
 
 static struct ipv4_devconf ipv4_devconf = {
 	.data = {
@@ -257,6 +258,7 @@ static void __inet_del_ifa(struct in_dev
 		struct in_ifaddr **ifap1 = &ifa1->ifa_next;
 
 		while ((ifa = *ifap1) != NULL) {
+			trace_ipv4_addr_del(ifa);
 			if (!(ifa->ifa_flags & IFA_F_SECONDARY) &&
 			    ifa1->ifa_scope <= ifa->ifa_scope)
 				last_prim = ifa;
@@ -363,6 +365,7 @@ static int __inet_insert_ifa(struct in_i
 			}
 			ifa->ifa_flags |= IFA_F_SECONDARY;
 		}
+		trace_ipv4_addr_add(ifa);
 	}
 
 	if (!(ifa->ifa_flags & IFA_F_SECONDARY)) {
Index: linux-2.6-lttng/include/trace/ipv4.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6-lttng/include/trace/ipv4.h	2008-07-15 15:16:11.000000000 -0400
@@ -0,0 +1,14 @@
+#ifndef _TRACE_IPV4_H
+#define _TRACE_IPV4_H
+
+#include <linux/inetdevice.h>
+#include <linux/tracepoint.h>
+
+DEFINE_TRACE(ipv4_addr_add,
+	TPPROTO(struct in_ifaddr *ifa),
+	TPARGS(ifa));
+DEFINE_TRACE(ipv4_addr_del,
+	TPPROTO(struct in_ifaddr *ifa),
+	TPARGS(ifa));
+
+#endif

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
