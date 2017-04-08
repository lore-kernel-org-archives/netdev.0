From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] net_sched: allow configuring default qdisc
Date: Sat,  8 Apr 2017 14:50:25 -0400
Message-ID: <20170408185025.2104-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:32773 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751626AbdDHSug (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 14:50:36 -0400
Received: by mail-io0-f169.google.com with SMTP id t68so31799048iof.0
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 11:50:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 3.12 it has been possible to configure the default queuing discipline
via sysctl. This patch adds ability to configure the default queue discipline
in kernel configuration. This is useful for environments where configuring
the value from userspace is difficult to manage.

The default is still the same as before (pfifo_fast) and it is possible
to change after kernel init with sysctl.  This is analagous to how
TCP congestion control is configured.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/sched/Kconfig   | 31 +++++++++++++++++++++++++++++++
 net/sched/sch_api.c |  7 +++++++
 2 files changed, 38 insertions(+)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 403790cce7d2..8fb45655e59b 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -820,6 +820,37 @@ config NET_CLS_IND
 	  classification based on the incoming device. This option is
 	  likely to disappear in favour of the metadata ematch.
 
+choice
+	prompt "Default queuing discipline"
+	default DEFAULT_PFIFO
+	help
+	  Select the queueing discipline that will be used by default
+	  for all network devices.
+
+	config DEFAULT_FQ
+		bool "Fair Queue" if NET_SCH_FQ
+
+	config DEFAULT_FQ_CODEL
+		bool "Fair Queue Controlled Delay (FQ_CODEL)" if NET_SCH_FQ_CODEL
+
+	config DEFAULT_CODEL
+		bool "Controlled Delay (CODEL)" if NET_SCH_CODEL
+
+	config DEFAULT_SFQ
+		bool "Stochastic Fair Queue (SFQ)" if NET_SCH_SFQ
+
+	config DEFAULT_PFIFO
+		bool "Priority FIFO"
+endchoice
+
+config DEFAULT_NET_SCH
+	string
+	default "pfifo" if DEFAULT_PFIFO
+	default "fq" if DEFAULT_FQ
+	default "fq_codel" if DEFAULT_FQ_CODEL
+	default "sfq" if DEFAULT_SFQ
+	default "pfifo"
+
 endif # NET_SCHED
 
 config NET_SCH_FIFO
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
