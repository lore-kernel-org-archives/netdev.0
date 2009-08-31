From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Subject: [PATCH resend] tracing/events: convert NAPI's tracepoint via TRACE_EVENT
Date: Mon, 31 Aug 2009 14:16:07 +0800
Message-ID: <4A9B6AA7.5020508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64612 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754410AbZHaGQl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2009 02:16:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Convert NAPI's tracepoint via TRACE_EVENT macro, the output information
  like below:

   sshd-2503  [000]    71.920846: napi_poll: ifname=eth0 state=0 weigth=16 poll=pcnet32_poll
   sshd-2503  [000]    72.020291: napi_poll: ifname=eth0 state=0 weigth=16 poll=pcnet32_poll
   sshd-2503  [000]    72.020418: napi_poll: ifname=eth0 state=NAPI_STATE_SCHED weigth=16 poll=pcnet32_poll

- Remove the "DECLARE_TRACE" definiens in include/trace/define_trace.h,
  because TRACE_EVENT not use it

Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
---
 include/trace/define_trace.h |    4 ---
 include/trace/events/napi.h  |   43 +++++++++++++++++++++++++++++++++++++----
 2 files changed, 38 insertions(+), 9 deletions(-)

diff --git a/include/trace/define_trace.h b/include/trace/define_trace.h
index 2a4b3bf..6158741 100644
--- a/include/trace/define_trace.h
+++ b/include/trace/define_trace.h
@@ -31,10 +31,6 @@
 		assign, print, reg, unreg)			\
 	DEFINE_TRACE_FN(name, reg, unreg)
 
-#undef DECLARE_TRACE
-#define DECLARE_TRACE(name, proto, args)	\
-	DEFINE_TRACE(name)
-
 #undef TRACE_INCLUDE
 #undef __TRACE_INCLUDE
 
diff --git a/include/trace/events/napi.h b/include/trace/events/napi.h
index a8989c4..5c7a192 100644
--- a/include/trace/events/napi.h
+++ b/include/trace/events/napi.h
@@ -1,11 +1,44 @@
-#ifndef _TRACE_NAPI_H_
-#define _TRACE_NAPI_H_
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM napi
+
+#if !defined(_TRACE_NAPI_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_NAPI_H
 
 #include <linux/netdevice.h>
 #include <linux/tracepoint.h>
 
-DECLARE_TRACE(napi_poll,
+#define show_napi_state(state) state ? __print_flags(state, "|",	\
+	{ (1UL << NAPI_STATE_SCHED),	"NAPI_STATE_SCHED"	},	\
+	{ (1UL << NAPI_STATE_DISABLE),	"NAPI_STATE_DISABLE"	},	\
+	{ (1UL << NAPI_STATE_NPSVC),	"NAPI_STATE_NPSVC"	}) : "0"
+
+TRACE_EVENT(napi_poll,
+
 	TP_PROTO(struct napi_struct *napi),
-	TP_ARGS(napi));
 
-#endif
+	TP_ARGS(napi),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	state		)
+		__field(	int,		weight		)
+		__field(	void *,		poll		)
+		__string(	ifname,		(napi->dev ?
+				napi->dev->name : "backlog")	)
+	),
+
+	TP_fast_assign(
+		__entry->state	= napi->state;
+		__entry->weight	= napi->weight;
+		__entry->poll	= napi->poll;
+		__assign_str(ifname, napi->dev ? napi->dev->name : "backlog")
+	),
+
+	TP_printk("ifname=%s state=%s weight=%d poll=%pf",
+		  __get_str(ifname), show_napi_state(__entry->state),
+		  __entry->weight, __entry->poll)
+);
+
+#endif /* _TRACE_NAPI_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
-- 
1.6.1.2

