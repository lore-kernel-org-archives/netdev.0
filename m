From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next  v2] Subject: net: allow configuring default qdisc
Date: Thu, 13 Apr 2017 08:40:53 -0700
Message-ID: <20170413154053.27568-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34029 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753623AbdDMPlD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 11:41:03 -0400
Received: by mail-pf0-f181.google.com with SMTP id c198so30259064pfc.1
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 08:40:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 3.12 it has been possible to configure the default queuing
discipline via sysctl. This patch adds ability to configure the
default queue discipline in kernel configuration. This is useful for
environments where configuring the value from userspace is difficult
to manage.

The default is still the same as before (pfifo_fast) and it is
possible to change after kernel init with sysctl. This is similar
to how TCP congestion control works.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
v2 -- add another level of indirection to make it easier for
      users blindly doing make oldconfig

 net/sched/Kconfig   | 45 +++++++++++++++++++++++++++++++++++++++++++++
 net/sched/sch_api.c |  9 +++++++++
 2 files changed, 54 insertions(+)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 403790cce7d2..9fb84f0de6af 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -352,6 +352,51 @@ config NET_SCH_PLUG
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_plug.
 
+menuconfig NET_SCH_DEFAULT
+	bool "Allow override default queue discipline"
+	---help---
+	  Support for selection of default queuing discipline.
+
+	  Nearly all users can safely say no here, and the default
+	  of pfifo_fast will be used. Many distributions already set
+	  the default value via /proc/sys/net/core/default_qdisc.
+
+	  If unsure, say N.
+
+if NET_SCH_DEFAULT
+
+choice
+	prompt "Default queuing discipline"
+	default DEFAULT_PFIFO_FAST
+	help
+	  Select the queueing discipline that will be used by default
+	  for all network devices.
+
+	config DEFAULT_FQ
+		bool "Fair Queue" if NET_SCH_FQ
+
+	config DEFAULT_CODEL
+		bool "Controlled Delay" if NET_SCH_CODEL
+
+	config DEFAULT_FQ_CODEL
+		bool "Fair Queue Controlled Delay" if NET_SCH_FQ_CODEL
+
+	config DEFAULT_SFQ
+		bool "Stochastic Fair Queue" if NET_SCH_SFQ
+
+	config DEFAULT_PFIFO_FAST
+		bool "Priority FIFO Fast"
+endchoice
+
+config DEFAULT_NET_SCH
+	string
+	default "pfifo_fast" if DEFAULT_PFIFO_FAST
+	default "fq" if DEFAULT_FQ
+	default "fq_codel" if DEFAULT_FQ_CODEL
+	default "sfq" if DEFAULT_SFQ
+	default "pfifo_fast"
+endif
+
 comment "Classification"
 
 config NET_CLS
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 62567bfe52c7..3ec4e77a76c7 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -251,6 +251,15 @@ int qdisc_set_default(const char *name)
 	return ops ? 0 : -ENOENT;
 }
 
+#ifdef CONFIG_NET_SCH_DEFAULT
+/* Set default value from kernel config */
+static int __init sch_default_qdisc(void)
+{
+	return qdisc_set_default(CONFIG_DEFAULT_NET_SCH);
+}
+late_initcall(sch_default_qdisc);
+#endif
+
 /* We know handle. Find qdisc among all qdisc's attached to device
  * (root qdisc, all its children, children of children etc.)
  * Note: caller either uses rtnl or rcu_read_lock()
-- 
2.11.0
