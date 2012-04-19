From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 15/19] net ipv4: Convert devinet to use register_net_sysctl
Date: Thu, 19 Apr 2012 16:42:09 -0700
Message-ID: <m1wr5be1bi.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53643 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860Ab2DSXiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:38:09 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Using an ascii path to register_net_sysctl as opposed to the slightly
awkward ctl_path allows for much simpler code.

We no longer need to malloc dev_name to keep it alive the length of our
sysctl register instead we can use a small temporary buffer on the
stack.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/devinet.c |   39 +++++----------------------------------
 1 files changed, 5 insertions(+), 34 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 8a01bfb..88c9e3f 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1585,7 +1585,6 @@ static int ipv4_doint_and_flush(ctl_table *ctl, int write,
 static struct devinet_sysctl_table {
 	struct ctl_table_header *sysctl_header;
 	struct ctl_table devinet_vars[__IPV4_DEVCONF_MAX];
-	char *dev_name;
 } devinet_sysctl = {
 	.devinet_vars = {
 		DEVINET_SYSCTL_COMPLEX_ENTRY(FORWARDING, "forwarding",
@@ -1627,16 +1626,7 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 {
 	int i;
 	struct devinet_sysctl_table *t;
-
-#define DEVINET_CTL_PATH_DEV	3
-
-	struct ctl_path devinet_ctl_path[] = {
-		{ .procname = "net",  },
-		{ .procname = "ipv4", },
-		{ .procname = "conf", },
-		{ /* to be set */ },
-		{ },
-	};
+	char path[sizeof("net/ipv4/conf/") + IFNAMSIZ];
 
 	t = kmemdup(&devinet_sysctl, sizeof(*t), GFP_KERNEL);
 	if (!t)
@@ -1648,27 +1638,15 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 		t->devinet_vars[i].extra2 = net;
 	}
 
-	/*
-	 * Make a copy of dev_name, because '.procname' is regarded as const
-	 * by sysctl and we wouldn't want anyone to change it under our feet
-	 * (see SIOCSIFNAME).
-	 */
-	t->dev_name = kstrdup(dev_name, GFP_KERNEL);
-	if (!t->dev_name)
-		goto free;
-
-	devinet_ctl_path[DEVINET_CTL_PATH_DEV].procname = t->dev_name;
+	snprintf(path, sizeof(path), "net/ipv4/conf/%s", dev_name);
 
-	t->sysctl_header = register_net_sysctl_table(net, devinet_ctl_path,
-			t->devinet_vars);
+	t->sysctl_header = register_net_sysctl(net, path, t->devinet_vars);
 	if (!t->sysctl_header)
-		goto free_procname;
+		goto free;
 
 	p->sysctl = t;
 	return 0;
 
-free_procname:
-	kfree(t->dev_name);
 free:
 	kfree(t);
 out:
@@ -1684,7 +1662,6 @@ static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
 
 	cnf->sysctl = NULL;
 	unregister_net_sysctl_table(t->sysctl_header);
-	kfree(t->dev_name);
 	kfree(t);
 }
 
@@ -1714,12 +1691,6 @@ static struct ctl_table ctl_forward_entry[] = {
 	},
 	{ },
 };
-
-static __net_initdata struct ctl_path net_ipv4_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ipv4", },
-	{ },
-};
 #endif
 
 static __net_init int devinet_init_net(struct net *net)
@@ -1765,7 +1736,7 @@ static __net_init int devinet_init_net(struct net *net)
 		goto err_reg_dflt;
 
 	err = -ENOMEM;
-	forw_hdr = register_net_sysctl_table(net, net_ipv4_path, tbl);
+	forw_hdr = register_net_sysctl(net, "net/ipv4", tbl);
 	if (forw_hdr == NULL)
 		goto err_reg_ctl;
 	net->ipv4.forw_hdr = forw_hdr;
-- 
1.7.2.5
