From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 27/27] netfilter: allow logging from non-init namespaces
Date: Fri,  3 Feb 2017 13:25:38 +0100
Message-ID: <1486124738-3013-28-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58906 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753351AbdBCM27 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:59 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B749CE04B7
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A5FE8DA793
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 23495DA807
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:45 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubeček <mkubecek@suse.cz>

Commit 69b34fb996b2 ("netfilter: xt_LOG: add net namespace support for
xt_LOG") disabled logging packets using the LOG target from non-init
namespaces. The motivation was to prevent containers from flooding
kernel log of the host. The plan was to keep it that way until syslog
namespace implementation allows containers to log in a safe way.

However, the work on syslog namespace seems to have hit a dead end
somewhere in 2013 and there are users who want to use xt_LOG in all
network namespaces. This patch allows to do so by setting

  /proc/sys/net/netfilter/nf_log_all_netns

to a nonzero value. This sysctl is only accessible from init_net so that
one cannot switch the behaviour from inside a container.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 Documentation/networking/netfilter-sysctl.txt | 10 ++++++++++
 include/net/netfilter/nf_log.h                |  3 +++
 net/bridge/netfilter/ebt_log.c                |  2 +-
 net/ipv4/netfilter/nf_log_arp.c               |  2 +-
 net/ipv4/netfilter/nf_log_ipv4.c              |  2 +-
 net/ipv6/netfilter/nf_log_ipv6.c              |  2 +-
 net/netfilter/nf_log.c                        | 24 ++++++++++++++++++++++++
 7 files changed, 41 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/networking/netfilter-sysctl.txt

diff --git a/Documentation/networking/netfilter-sysctl.txt b/Documentation/networking/netfilter-sysctl.txt
new file mode 100644
index 000000000000..55791e50e169
--- /dev/null
+++ b/Documentation/networking/netfilter-sysctl.txt
@@ -0,0 +1,10 @@
+/proc/sys/net/netfilter/* Variables:
+
+nf_log_all_netns - BOOLEAN
+	0 - disabled (default)
+	not 0 - enabled
+
+	By default, only init_net namespace can log packets into kernel log
+	with LOG target; this aims to prevent containers from flooding host
+	kernel log. If enabled, this target also works in other network
+	namespaces. This variable is only accessible from init_net.
diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_log.h
index 450f87f95415..42e0696f38d8 100644
--- a/include/net/netfilter/nf_log.h
+++ b/include/net/netfilter/nf_log.h
@@ -51,6 +51,9 @@ struct nf_logger {
 	struct module		*me;
 };
 
+/* sysctl_nf_log_all_netns - allow LOG target in all network namespaces */
+extern int sysctl_nf_log_all_netns;
+
 /* Function to register/unregister log function. */
 int nf_log_register(u_int8_t pf, struct nf_logger *logger);
 void nf_log_unregister(struct nf_logger *logger);
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index e88bd4827ac1..98b9c8e8615e 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -78,7 +78,7 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
 	unsigned int bitmask;
 
 	/* FIXME: Disabled from containers until syslog ns is supported */
-	if (!net_eq(net, &init_net))
+	if (!net_eq(net, &init_net) && !sysctl_nf_log_all_netns)
 		return;
 
 	spin_lock_bh(&ebt_log_lock);
diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
index b24795e2ee6d..f6f713376e6e 100644
--- a/net/ipv4/netfilter/nf_log_arp.c
+++ b/net/ipv4/netfilter/nf_log_arp.c
@@ -87,7 +87,7 @@ static void nf_log_arp_packet(struct net *net, u_int8_t pf,
 	struct nf_log_buf *m;
 
 	/* FIXME: Disabled from containers until syslog ns is supported */
-	if (!net_eq(net, &init_net))
+	if (!net_eq(net, &init_net) && !sysctl_nf_log_all_netns)
 		return;
 
 	m = nf_log_buf_open();
diff --git a/net/ipv4/netfilter/nf_log_ipv4.c b/net/ipv4/netfilter/nf_log_ipv4.c
index 856648966f4c..c83a9963269b 100644
--- a/net/ipv4/netfilter/nf_log_ipv4.c
+++ b/net/ipv4/netfilter/nf_log_ipv4.c
@@ -319,7 +319,7 @@ static void nf_log_ip_packet(struct net *net, u_int8_t pf,
 	struct nf_log_buf *m;
 
 	/* FIXME: Disabled from containers until syslog ns is supported */
-	if (!net_eq(net, &init_net))
+	if (!net_eq(net, &init_net) && !sysctl_nf_log_all_netns)
 		return;
 
 	m = nf_log_buf_open();
diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index 57d86066a13b..055c51b80f5d 100644
--- a/net/ipv6/netfilter/nf_log_ipv6.c
+++ b/net/ipv6/netfilter/nf_log_ipv6.c
@@ -351,7 +351,7 @@ static void nf_log_ip6_packet(struct net *net, u_int8_t pf,
 	struct nf_log_buf *m;
 
 	/* FIXME: Disabled from containers until syslog ns is supported */
-	if (!net_eq(net, &init_net))
+	if (!net_eq(net, &init_net) && !sysctl_nf_log_all_netns)
 		return;
 
 	m = nf_log_buf_open();
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 3dca90dc24ad..0a034f52b912 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -16,6 +16,9 @@
 #define NF_LOG_PREFIXLEN		128
 #define NFLOGGER_NAME_LEN		64
 
+int sysctl_nf_log_all_netns __read_mostly;
+EXPORT_SYMBOL(sysctl_nf_log_all_netns);
+
 static struct nf_logger __rcu *loggers[NFPROTO_NUMPROTO][NF_LOG_TYPE_MAX] __read_mostly;
 static DEFINE_MUTEX(nf_log_mutex);
 
@@ -414,6 +417,18 @@ static const struct file_operations nflog_file_ops = {
 #ifdef CONFIG_SYSCTL
 static char nf_log_sysctl_fnames[NFPROTO_NUMPROTO-NFPROTO_UNSPEC][3];
 static struct ctl_table nf_log_sysctl_table[NFPROTO_NUMPROTO+1];
+static struct ctl_table_header *nf_log_sysctl_fhdr;
+
+static struct ctl_table nf_log_sysctl_ftable[] = {
+	{
+		.procname	= "nf_log_all_netns",
+		.data		= &sysctl_nf_log_all_netns,
+		.maxlen		= sizeof(sysctl_nf_log_all_netns),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{ }
+};
 
 static int nf_log_proc_dostring(struct ctl_table *table, int write,
 			 void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -483,6 +498,10 @@ static int netfilter_log_sysctl_init(struct net *net)
 			nf_log_sysctl_table[i].extra1 =
 				(void *)(unsigned long) i;
 		}
+		nf_log_sysctl_fhdr = register_net_sysctl(net, "net/netfilter",
+							 nf_log_sysctl_ftable);
+		if (!nf_log_sysctl_fhdr)
+			goto err_freg;
 	}
 
 	for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++)
@@ -499,6 +518,9 @@ static int netfilter_log_sysctl_init(struct net *net)
 err_reg:
 	if (!net_eq(net, &init_net))
 		kfree(table);
+	else
+		unregister_net_sysctl_table(nf_log_sysctl_fhdr);
+err_freg:
 err_alloc:
 	return -ENOMEM;
 }
@@ -511,6 +533,8 @@ static void netfilter_log_sysctl_exit(struct net *net)
 	unregister_net_sysctl_table(net->nf.nf_log_dir_header);
 	if (!net_eq(net, &init_net))
 		kfree(table);
+	else
+		unregister_net_sysctl_table(nf_log_sysctl_fhdr);
 }
 #else
 static int netfilter_log_sysctl_init(struct net *net)
-- 
2.1.4
