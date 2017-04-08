From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v2] net: allow configuring default qdisc
Date: Sat,  8 Apr 2017 15:39:46 -0400
Message-ID: <20170408193946.18469-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33090 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752741AbdDHTj5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 15:39:57 -0400
Received: by mail-io0-f182.google.com with SMTP id t68so32079280iof.0
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 12:39:57 -0700 (PDT)
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
v2 - rearrange order of menu items
     use pfifo_fast not pfifo

 net/sched/Kconfig   | 31 +++++++++++++++++++++++++++++++
 net/sched/sch_api.c |  7 +++++++
 2 files changed, 38 insertions(+)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 403790cce7d2..c1243b8e6465 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -352,6 +352,37 @@ config NET_SCH_PLUG
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_plug.
 
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
+
 comment "Classification"
 
 config NET_CLS
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 62567bfe52c7..0d82f76f622d 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -251,6 +251,13 @@ int qdisc_set_default(const char *name)
 	return ops ? 0 : -ENOENT;
 }
 
+/* Set default value from kernel config */
+static int __init sch_default_qdisc(void)
+{
+	return qdisc_set_default(CONFIG_DEFAULT_NET_SCH);
+}
+late_initcall(sch_default_qdisc);
+
 /* We know handle. Find qdisc among all qdisc's attached to device
  * (root qdisc, all its children, children of children etc.)
  * Note: caller either uses rtnl or rcu_read_lock()
-- 
2.11.0
