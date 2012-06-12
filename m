From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: =?utf-8?Q?net=2Fnetfilter=2Fnf=5Fconnt?=
	=?utf-8?B?cmFja19wcm90b190Y3AuYzoxNjA2Ojk6IGVycm9yOiDigJhzdHJ1Y3QgbmZf?=
	=?utf-8?B?cHJvdG9fbmV04oCZIGhhcyBubyBtZW1iZXIgbmFtZWQg4oCYdXNlcuKAmQ==?=
Date: Tue, 12 Jun 2012 02:26:55 +0200
Message-ID: <20120612002655.GA28155@1984>
References: <4fd664de.oQN9NTKjdledtla0%wfg@linux.intel.com>
 <20120611221521.GA27239@1984>
 <20120611.152344.1072167705198124284.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="XsQoSWH+UP9D9v3l"
Cc: wfg@linux.intel.com, gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50581 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762Ab2FLA1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 20:27:00 -0400
Content-Disposition: inline
In-Reply-To: <20120611.152344.1072167705198124284.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi again David,

On Mon, Jun 11, 2012 at 03:23:44PM -0700, David Miller wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Tue, 12 Jun 2012 00:15:21 +0200
> 
> > Could you please apply the following patch to net-next to resolve
> > this? Thanks.
> 
> Applied, but you have to be kidding me with those ifdefs.
> 
> This is exactly the same kind of thing Gao suggested for
> the inetpeer code recently and which I flat out rejected.
> 
> You can't pepper foo.c files with ifdefs all over the place.

Would you be OK if I send you patches to move all sysctl part of
nf_conntrack_proto_*.c to nf_conntrack_proto_*_sysctl.c

I can also do the same for nf_conntrack_proto.c.

This means more files under the net/netfilter directory, but less
ifdef kludges in the code.

Please, have a look at the patch enclosed to this email in case you
want to see how it would look like in the end with my proposal.

--XsQoSWH+UP9D9v3l
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-nf_ct_tcp-move-sysctl-code-to-nf_conntrack.patch"

>From ed8a7d2812b0c490b67ea44d9745db86bd7927ee Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 12 Jun 2012 02:14:38 +0200
Subject: [PATCH] netfilter: nf_ct_tcp: move sysctl code to
 nf_conntrack_proto_tcp_sysctl.c

This patch moves all the sysctl part of the TCP tracker to the
nf_conntrack_proto_tcp_sysctl.c file.

This code split reduces pollution due to lots of CONFIG_SYSCTL
ifdef checks.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_tcp.h      |    8 +
 net/netfilter/Makefile                        |    1 +
 net/netfilter/nf_conntrack_proto_tcp.c        |  249 +------------------------
 net/netfilter/nf_conntrack_proto_tcp_sysctl.c |  247 ++++++++++++++++++++++++
 4 files changed, 260 insertions(+), 245 deletions(-)
 create mode 100644 include/net/netfilter/nf_conntrack_tcp.h
 create mode 100644 net/netfilter/nf_conntrack_proto_tcp_sysctl.c

diff --git a/include/net/netfilter/nf_conntrack_tcp.h b/include/net/netfilter/nf_conntrack_tcp.h
new file mode 100644
index 0000000..8d16ebe
--- /dev/null
+++ b/include/net/netfilter/nf_conntrack_tcp.h
@@ -0,0 +1,8 @@
+#ifndef _NF_CONNTRACK_TCP_H_
+#define _NF_CONNTRACK_TCP_H_
+
+int nf_ct_tcp_kmemdup_sysctl_table(struct nf_proto_net *pn);
+int nf_ct_tcp_compat_kmemdup_sysctl_table(struct nf_proto_net *pn);
+void nf_ct_tcp_compat_kfree_sysctl_table(struct nf_proto_net *pn);
+
+#endif
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 2f3bc0f..8815f4b 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -1,6 +1,7 @@
 netfilter-objs := core.o nf_log.o nf_queue.o nf_sockopt.o
 
 nf_conntrack-y	:= nf_conntrack_core.o nf_conntrack_standalone.o nf_conntrack_expect.o nf_conntrack_helper.o nf_conntrack_proto.o nf_conntrack_l3proto_generic.o nf_conntrack_proto_generic.o nf_conntrack_proto_tcp.o nf_conntrack_proto_udp.o nf_conntrack_extend.o nf_conntrack_acct.o
+nf_conntrack-$(CONFIG_SYSCTL) += nf_conntrack_proto_tcp_sysctl.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMEOUT) += nf_conntrack_timeout.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMESTAMP) += nf_conntrack_timestamp.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_EVENTS) += nf_conntrack_ecache.o
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 99caa13..cdf8b93 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -28,6 +28,7 @@
 #include <net/netfilter/nf_log.h>
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
+#include <net/netfilter/nf_conntrack_tcp.h>
 
 /* "Be conservative in what you do,
     be liberal in what you accept from others."
@@ -1365,234 +1366,6 @@ static const struct nla_policy tcp_timeout_nla_policy[CTA_TIMEOUT_TCP_MAX+1] = {
 };
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
-#ifdef CONFIG_SYSCTL
-static struct ctl_table tcp_sysctl_table[] = {
-	{
-		.procname	= "nf_conntrack_tcp_timeout_syn_sent",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "nf_conntrack_tcp_timeout_syn_recv",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "nf_conntrack_tcp_timeout_established",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "nf_conntrack_tcp_timeout_fin_wait",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "nf_conntrack_tcp_timeout_close_wait",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "nf_conntrack_tcp_timeout_last_ack",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "nf_conntrack_tcp_timeout_time_wait",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "nf_conntrack_tcp_timeout_close",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "nf_conntrack_tcp_timeout_max_retrans",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "nf_conntrack_tcp_timeout_unacknowledged",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "nf_conntrack_tcp_loose",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname       = "nf_conntrack_tcp_be_liberal",
-		.maxlen         = sizeof(unsigned int),
-		.mode           = 0644,
-		.proc_handler   = proc_dointvec,
-	},
-	{
-		.procname	= "nf_conntrack_tcp_max_retrans",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{ }
-};
-
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-static struct ctl_table tcp_compat_sysctl_table[] = {
-	{
-		.procname	= "ip_conntrack_tcp_timeout_syn_sent",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_syn_sent2",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_syn_recv",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_established",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_fin_wait",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_close_wait",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_last_ack",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_time_wait",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_close",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_timeout_max_retrans",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_loose",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_be_liberal",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "ip_conntrack_tcp_max_retrans",
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{ }
-};
-#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
-#endif /* CONFIG_SYSCTL */
-
-static int tcp_kmemdup_sysctl_table(struct nf_proto_net *pn)
-{
-#ifdef CONFIG_SYSCTL
-	struct nf_tcp_net *tn = (struct nf_tcp_net *)pn;
-
-	if (pn->ctl_table)
-		return 0;
-
-	pn->ctl_table = kmemdup(tcp_sysctl_table,
-				sizeof(tcp_sysctl_table),
-				GFP_KERNEL);
-	if (!pn->ctl_table)
-		return -ENOMEM;
-
-	pn->ctl_table[0].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT];
-	pn->ctl_table[1].data = &tn->timeouts[TCP_CONNTRACK_SYN_RECV];
-	pn->ctl_table[2].data = &tn->timeouts[TCP_CONNTRACK_ESTABLISHED];
-	pn->ctl_table[3].data = &tn->timeouts[TCP_CONNTRACK_FIN_WAIT];
-	pn->ctl_table[4].data = &tn->timeouts[TCP_CONNTRACK_CLOSE_WAIT];
-	pn->ctl_table[5].data = &tn->timeouts[TCP_CONNTRACK_LAST_ACK];
-	pn->ctl_table[6].data = &tn->timeouts[TCP_CONNTRACK_TIME_WAIT];
-	pn->ctl_table[7].data = &tn->timeouts[TCP_CONNTRACK_CLOSE];
-	pn->ctl_table[8].data = &tn->timeouts[TCP_CONNTRACK_RETRANS];
-	pn->ctl_table[9].data = &tn->timeouts[TCP_CONNTRACK_UNACK];
-	pn->ctl_table[10].data = &tn->tcp_loose;
-	pn->ctl_table[11].data = &tn->tcp_be_liberal;
-	pn->ctl_table[12].data = &tn->tcp_max_retrans;
-#endif
-	return 0;
-}
-
-static int tcp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
-{
-#ifdef CONFIG_SYSCTL
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	struct nf_tcp_net *tn = (struct nf_tcp_net *)pn;
-	pn->ctl_compat_table = kmemdup(tcp_compat_sysctl_table,
-				       sizeof(tcp_compat_sysctl_table),
-				       GFP_KERNEL);
-	if (!pn->ctl_compat_table)
-		return -ENOMEM;
-
-	pn->ctl_compat_table[0].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT];
-	pn->ctl_compat_table[1].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT2];
-	pn->ctl_compat_table[2].data = &tn->timeouts[TCP_CONNTRACK_SYN_RECV];
-	pn->ctl_compat_table[3].data = &tn->timeouts[TCP_CONNTRACK_ESTABLISHED];
-	pn->ctl_compat_table[4].data = &tn->timeouts[TCP_CONNTRACK_FIN_WAIT];
-	pn->ctl_compat_table[5].data = &tn->timeouts[TCP_CONNTRACK_CLOSE_WAIT];
-	pn->ctl_compat_table[6].data = &tn->timeouts[TCP_CONNTRACK_LAST_ACK];
-	pn->ctl_compat_table[7].data = &tn->timeouts[TCP_CONNTRACK_TIME_WAIT];
-	pn->ctl_compat_table[8].data = &tn->timeouts[TCP_CONNTRACK_CLOSE];
-	pn->ctl_compat_table[9].data = &tn->timeouts[TCP_CONNTRACK_RETRANS];
-	pn->ctl_compat_table[10].data = &tn->tcp_loose;
-	pn->ctl_compat_table[11].data = &tn->tcp_be_liberal;
-	pn->ctl_compat_table[12].data = &tn->tcp_max_retrans;
-#endif
-#endif
-	return 0;
-}
-
 static int tcpv4_init_net(struct net *net)
 {
 	int i;
@@ -1600,11 +1373,7 @@ static int tcpv4_init_net(struct net *net)
 	struct nf_tcp_net *tn = tcp_pernet(net);
 	struct nf_proto_net *pn = (struct nf_proto_net *)tn;
 
-#ifdef CONFIG_SYSCTL
-	if (!pn->ctl_table) {
-#else
 	if (!pn->users++) {
-#endif
 		for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
 			tn->timeouts[i] = tcp_timeouts[i];
 
@@ -1613,21 +1382,15 @@ static int tcpv4_init_net(struct net *net)
 		tn->tcp_max_retrans = nf_ct_tcp_max_retrans;
 	}
 
-	ret = tcp_kmemdup_compat_sysctl_table(pn);
-
+	ret = nf_ct_tcp_compat_kmemdup_sysctl_table(pn);
 	if (ret < 0)
 		return ret;
 
-	ret = tcp_kmemdup_sysctl_table(pn);
-
-#ifdef CONFIG_SYSCTL
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	ret = nf_ct_tcp_kmemdup_sysctl_table(pn);
 	if (ret < 0) {
 		kfree(pn->ctl_compat_table);
 		pn->ctl_compat_table = NULL;
 	}
-#endif
-#endif
 	return ret;
 }
 
@@ -1637,11 +1400,7 @@ static int tcpv6_init_net(struct net *net)
 	struct nf_tcp_net *tn = tcp_pernet(net);
 	struct nf_proto_net *pn = (struct nf_proto_net *)tn;
 
-#ifdef CONFIG_SYSCTL
-	if (!pn->ctl_table) {
-#else
 	if (!pn->users++) {
-#endif
 		for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
 			tn->timeouts[i] = tcp_timeouts[i];
 		tn->tcp_loose = nf_ct_tcp_loose;
@@ -1649,7 +1408,7 @@ static int tcpv6_init_net(struct net *net)
 		tn->tcp_max_retrans = nf_ct_tcp_max_retrans;
 	}
 
-	return tcp_kmemdup_sysctl_table(pn);
+	return nf_ct_tcp_kmemdup_sysctl_table(pn);
 }
 
 struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
diff --git a/net/netfilter/nf_conntrack_proto_tcp_sysctl.c b/net/netfilter/nf_conntrack_proto_tcp_sysctl.c
new file mode 100644
index 0000000..b9e027f
--- /dev/null
+++ b/net/netfilter/nf_conntrack_proto_tcp_sysctl.c
@@ -0,0 +1,247 @@
+/*
+ * (C) 1999-2001 Paul `Rusty' Russell
+ * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv6.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_l4proto.h>
+#include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
+#include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
+
+static struct ctl_table tcp_sysctl_table[] = {
+	{
+		.procname	= "nf_conntrack_tcp_timeout_syn_sent",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "nf_conntrack_tcp_timeout_syn_recv",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "nf_conntrack_tcp_timeout_established",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "nf_conntrack_tcp_timeout_fin_wait",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "nf_conntrack_tcp_timeout_close_wait",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "nf_conntrack_tcp_timeout_last_ack",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "nf_conntrack_tcp_timeout_time_wait",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "nf_conntrack_tcp_timeout_close",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "nf_conntrack_tcp_timeout_max_retrans",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "nf_conntrack_tcp_timeout_unacknowledged",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "nf_conntrack_tcp_loose",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname       = "nf_conntrack_tcp_be_liberal",
+		.maxlen         = sizeof(unsigned int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec,
+	},
+	{
+		.procname	= "nf_conntrack_tcp_max_retrans",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{ }
+};
+
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+static struct ctl_table tcp_compat_sysctl_table[] = {
+	{
+		.procname	= "ip_conntrack_tcp_timeout_syn_sent",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "ip_conntrack_tcp_timeout_syn_sent2",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "ip_conntrack_tcp_timeout_syn_recv",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "ip_conntrack_tcp_timeout_established",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "ip_conntrack_tcp_timeout_fin_wait",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "ip_conntrack_tcp_timeout_close_wait",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "ip_conntrack_tcp_timeout_last_ack",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "ip_conntrack_tcp_timeout_time_wait",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "ip_conntrack_tcp_timeout_close",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "ip_conntrack_tcp_timeout_max_retrans",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "ip_conntrack_tcp_loose",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "ip_conntrack_tcp_be_liberal",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "ip_conntrack_tcp_max_retrans",
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{ }
+};
+#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
+
+int nf_ct_tcp_kmemdup_sysctl_table(struct nf_proto_net *pn)
+{
+	struct nf_tcp_net *tn = (struct nf_tcp_net *)pn;
+
+	if (pn->ctl_table)
+		return 0;
+
+	pn->ctl_table = kmemdup(tcp_sysctl_table, sizeof(tcp_sysctl_table),
+				GFP_KERNEL);
+	if (!pn->ctl_table)
+		return -ENOMEM;
+
+	pn->ctl_table[0].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT];
+	pn->ctl_table[1].data = &tn->timeouts[TCP_CONNTRACK_SYN_RECV];
+	pn->ctl_table[2].data = &tn->timeouts[TCP_CONNTRACK_ESTABLISHED];
+	pn->ctl_table[3].data = &tn->timeouts[TCP_CONNTRACK_FIN_WAIT];
+	pn->ctl_table[4].data = &tn->timeouts[TCP_CONNTRACK_CLOSE_WAIT];
+	pn->ctl_table[5].data = &tn->timeouts[TCP_CONNTRACK_LAST_ACK];
+	pn->ctl_table[6].data = &tn->timeouts[TCP_CONNTRACK_TIME_WAIT];
+	pn->ctl_table[7].data = &tn->timeouts[TCP_CONNTRACK_CLOSE];
+	pn->ctl_table[8].data = &tn->timeouts[TCP_CONNTRACK_RETRANS];
+	pn->ctl_table[9].data = &tn->timeouts[TCP_CONNTRACK_UNACK];
+	pn->ctl_table[10].data = &tn->tcp_loose;
+	pn->ctl_table[11].data = &tn->tcp_be_liberal;
+	pn->ctl_table[12].data = &tn->tcp_max_retrans;
+
+	return 0;
+}
+
+int nf_ct_tcp_compat_kmemdup_sysctl_table(struct nf_proto_net *pn)
+{
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct nf_tcp_net *tn = (struct nf_tcp_net *)pn;
+	pn->ctl_compat_table = kmemdup(tcp_compat_sysctl_table,
+				       sizeof(tcp_compat_sysctl_table),
+				       GFP_KERNEL);
+	if (!pn->ctl_compat_table)
+		return -ENOMEM;
+
+	pn->ctl_compat_table[0].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT];
+	pn->ctl_compat_table[1].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT2];
+	pn->ctl_compat_table[2].data = &tn->timeouts[TCP_CONNTRACK_SYN_RECV];
+	pn->ctl_compat_table[3].data = &tn->timeouts[TCP_CONNTRACK_ESTABLISHED];
+	pn->ctl_compat_table[4].data = &tn->timeouts[TCP_CONNTRACK_FIN_WAIT];
+	pn->ctl_compat_table[5].data = &tn->timeouts[TCP_CONNTRACK_CLOSE_WAIT];
+	pn->ctl_compat_table[6].data = &tn->timeouts[TCP_CONNTRACK_LAST_ACK];
+	pn->ctl_compat_table[7].data = &tn->timeouts[TCP_CONNTRACK_TIME_WAIT];
+	pn->ctl_compat_table[8].data = &tn->timeouts[TCP_CONNTRACK_CLOSE];
+	pn->ctl_compat_table[9].data = &tn->timeouts[TCP_CONNTRACK_RETRANS];
+	pn->ctl_compat_table[10].data = &tn->tcp_loose;
+	pn->ctl_compat_table[11].data = &tn->tcp_be_liberal;
+	pn->ctl_compat_table[12].data = &tn->tcp_max_retrans;
+#endif
+	return 0;
+}
+
+void nf_ct_tcp_compat_kfree_sysctl_table(struct nf_proto_net *pn)
+{
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	kfree(pn->ctl_compat_table);
+	pn->ctl_compat_table = NULL;
+#endif
+}
-- 
1.7.10


--XsQoSWH+UP9D9v3l--
