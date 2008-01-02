From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch 0/9][NETNS][IPV6] make sysctl per namespace
Date: Wed, 2 Jan 2008 14:54:34 +0100
Message-ID: <20080102145434.8bdba06d.dada1@cosmosbay.com>
References: <20080102122548.629622062@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:55823 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211AbYABNyl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jan 2008 08:54:41 -0500
In-Reply-To: <20080102122548.629622062@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Jan 2008 13:25:48 +0100
Daniel Lezcano <dlezcano@fr.ibm.com> wrote:

> The following patchset makes the ipv6 sysctl to handle multiple
> network namespaces. Each instance of a network namespace as its own
> set of sysctl values, that means the behavior of the ipv6 stack can be
> different depending on the sysctl values setup in the different
> network namespaces.

Hi Daniel

Did you tested your patches with CONFIG_SYSCTL=n ?

For example, I had to apply this patch on current git.

Thank you

[PATCH] IPV4 : Should build with CONFIG_SYSCTL=n

Previous NETNS patches broke CONFIG_SYSCTL=n case

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index e06d7cf..61a28ff 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -8,7 +8,9 @@ struct ctl_table_header;
 struct ipv4_devconf;
 
 struct netns_ipv4 {
+#ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*forw_hdr;
+#endif
 	struct ipv4_devconf	*devconf_all;
 	struct ipv4_devconf	*devconf_dflt;
 };
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 252ce01..98a0079 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1542,7 +1542,6 @@ static void devinet_sysctl_unregister(struct in_device *idev)
 	__devinet_sysctl_unregister(&idev->cnf);
 	neigh_sysctl_unregister(idev->arp_parms);
 }
-#endif
 
 static struct ctl_table ctl_forward_entry[] = {
 	{
@@ -1565,18 +1564,20 @@ static __net_initdata struct ctl_path net_ipv4_path[] = {
 	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
 	{ },
 };
+#endif
 
 static __net_init int devinet_init_net(struct net *net)
 {
 	int err;
-	struct ctl_table *tbl;
-	struct ipv4_devconf *all, *dflt;
+#ifdef CONFIG_SYSCTL
+	struct ctl_table *tbl = ctl_forward_entry;
 	struct ctl_table_header *forw_hdr;
+#endif
+	struct ipv4_devconf *all, *dflt;
 
 	err = -ENOMEM;
 	all = &ipv4_devconf;
 	dflt = &ipv4_devconf_dflt;
-	tbl = ctl_forward_entry;
 
 	if (net != &init_net) {
 		all = kmemdup(all, sizeof(ipv4_devconf), GFP_KERNEL);
@@ -1587,6 +1588,7 @@ static __net_init int devinet_init_net(struct net *net)
 		if (dflt == NULL)
 			goto err_alloc_dflt;
 
+#ifdef CONFIG_SYSCTL
 		tbl = kmemdup(tbl, sizeof(ctl_forward_entry), GFP_KERNEL);
 		if (tbl == NULL)
 			goto err_alloc_ctl;
@@ -1594,6 +1596,7 @@ static __net_init int devinet_init_net(struct net *net)
 		tbl[0].data = &all->data[NET_IPV4_CONF_FORWARDING - 1];
 		tbl[0].extra1 = all;
 		tbl[0].extra2 = net;
+#endif
 	}
 
 #ifdef CONFIG_SYSCTL
@@ -1611,9 +1614,9 @@ static __net_init int devinet_init_net(struct net *net)
 	forw_hdr = register_net_sysctl_table(net, net_ipv4_path, tbl);
 	if (forw_hdr == NULL)
 		goto err_reg_ctl;
+	net->ipv4.forw_hdr = forw_hdr;
 #endif
 
-	net->ipv4.forw_hdr = forw_hdr;
 	net->ipv4.devconf_all = all;
 	net->ipv4.devconf_dflt = dflt;
 	return 0;
@@ -1626,8 +1629,8 @@ err_reg_dflt:
 err_reg_all:
 	if (tbl != ctl_forward_entry)
 		kfree(tbl);
-#endif
 err_alloc_ctl:
+#endif
 	if (dflt != &ipv4_devconf_dflt)
 		kfree(dflt);
 err_alloc_dflt:
@@ -1639,15 +1642,15 @@ err_alloc_all:
 
 static __net_exit void devinet_exit_net(struct net *net)
 {
+#ifdef CONFIG_SYSCTL
 	struct ctl_table *tbl;
 
 	tbl = net->ipv4.forw_hdr->ctl_table_arg;
-#ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(net->ipv4.forw_hdr);
 	__devinet_sysctl_unregister(net->ipv4.devconf_dflt);
 	__devinet_sysctl_unregister(net->ipv4.devconf_all);
-#endif
 	kfree(tbl);
+#endif
 	kfree(net->ipv4.devconf_dflt);
 	kfree(net->ipv4.devconf_all);
 }

