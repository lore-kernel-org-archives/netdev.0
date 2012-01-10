From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 1/1] netfilter: Add sysctl nf_conntrack_enable per netns
Date: Tue, 10 Jan 2012 12:09:50 +0100
Message-ID: <1326193790-1635-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: <kaber@trash.net>, <pablo@netfilter.org>, <jengelh@medozas.de>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:63952 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387Ab2AJLJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 06:09:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases it not desirable to have auto defrag and conntrack.
Ex. in a cluster where packets can arrive on different blades.
In that case it is possible to use containers (LXC) and send
all fragments to one place where defrag is enabled.

This patch makes it possible to turn off  conntrack and defrag
per network name space, by setting net.netfilter.nf_conntrack_enable to 0.
Both IPv4 and IPv6 is effected by this sysctl.
Default is 1

Ver. 2
 Adding "NOTRACK" logic to turn off conntrack
 rename to nf_conntrack_enable

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/netns/conntrack.h             |    1 +
 net/ipv4/netfilter/nf_defrag_ipv4.c       |   16 ++++++++++++++++
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c |   14 +++++++++++++-
 net/netfilter/nf_conntrack_core.c         |    7 +++++++
 net/netfilter/nf_conntrack_standalone.c   |    9 +++++++++
 5 files changed, 46 insertions(+), 1 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 7a911ec..6ebd5d7 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -26,6 +26,7 @@ struct netns_ct {
 	int			sysctl_tstamp;
 	int			sysctl_checksum;
 	unsigned int		sysctl_log_invalid; /* Log invalid packets */
+	int			sysctl_conntrack_enable;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 	struct ctl_table_header	*acct_sysctl_header;
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 9bb1b8a..3b12ba0 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -74,6 +74,22 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 		return NF_ACCEPT;
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	{
+		const struct net_device *dev = (hooknum == NF_INET_LOCAL_OUT ?
+						out : in);
+
+		/* Conntrack and defrag disabled ? */
+		if (!dev_net(dev)->ct.sysctl_conntrack_enable) {
+			if (!skb->nfct) {
+				/* Attach fake conntrack entry as in NOTRACK */
+				skb->nfct = &nf_ct_untracked_get()->ct_general;
+				skb->nfctinfo = IP_CT_NEW;
+				nf_conntrack_get(skb->nfct);
+				return NF_ACCEPT;
+			} else
+				return NF_ACCEPT;
+		}
+	}
 #if !defined(CONFIG_NF_NAT) && !defined(CONFIG_NF_NAT_MODULE)
 	/* Previously seen (loopback)?  Ignore.  Do this before
 	   fragment check. */
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index cdd6d04..cdc8d83 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -61,7 +61,19 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
 	struct sk_buff *reasm;
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-	/* Previously seen (loopback)?	*/
+	/* Check for no defrag options */
+	const struct net_device *dev = (hooknum == NF_INET_LOCAL_OUT ?
+					out : in);
+
+	/* Conntrack and defrag disabled ? */
+	if (!dev_net(dev)->ct.sysctl_conntrack_enable && !skb->nfct) {
+		/* Attach fake conntrack entry as in NOTRACK */
+		skb->nfct = &nf_ct_untracked_get()->ct_general;
+		skb->nfctinfo = IP_CT_NEW;
+		nf_conntrack_get(skb->nfct);
+		return NF_ACCEPT;
+	}
+	/* Previously seen (loopback)? OR conntrack disabled */
 	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
 		return NF_ACCEPT;
 #endif
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index e875f89..f42880c 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -892,6 +892,13 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 			return NF_ACCEPT;
 		}
 		skb->nfct = NULL;
+	} /* Conntrack disabled ? */
+	else if (!net->ct.sysctl_conntrack_enable) {
+		/* Attach fake conntrack entry as in NOTRACK */
+		skb->nfct = &nf_ct_untracked_get()->ct_general;
+		skb->nfctinfo = IP_CT_NEW;
+		nf_conntrack_get(skb->nfct);
+		return NF_ACCEPT;
 	}
 
 	/* rcu_read_lock()ed by nf_hook_slow */
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 885f5ab..2dd058e 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -446,6 +446,13 @@ static ctl_table nf_ct_sysctl_table[] = {
 		.extra2		= &log_invalid_proto_max,
 	},
 	{
+		.procname	= "nf_conntrack_enable",
+		.data		= &init_net.ct.sysctl_conntrack_enable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "nf_conntrack_expect_max",
 		.data		= &nf_ct_expect_max,
 		.maxlen		= sizeof(int),
@@ -493,6 +500,7 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 	table[2].data = &net->ct.htable_size;
 	table[3].data = &net->ct.sysctl_checksum;
 	table[4].data = &net->ct.sysctl_log_invalid;
+	table[5].data = &net->ct.sysctl_conntrack_enable;
 
 	net->ct.sysctl_header = register_net_sysctl_table(net,
 					nf_net_netfilter_sysctl_path, table);
@@ -544,6 +552,7 @@ static int nf_conntrack_net_init(struct net *net)
 		goto out_proc;
 	net->ct.sysctl_checksum = 1;
 	net->ct.sysctl_log_invalid = 0;
+	net->ct.sysctl_conntrack_enable = 1;
 	ret = nf_conntrack_standalone_init_sysctl(net);
 	if (ret < 0)
 		goto out_sysctl;
-- 
1.7.2.3
