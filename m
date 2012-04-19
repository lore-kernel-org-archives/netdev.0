From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 14/19] net ipv6:  Convert addrconf to use register_net_sysctl
Date: Thu, 19 Apr 2012 16:41:24 -0700
Message-ID: <m1397zffx7.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59582 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860Ab2DSXhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:37:24 -0400
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
 net/ipv6/addrconf.c |   32 ++++----------------------------
 1 files changed, 4 insertions(+), 28 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4a83983..e3b3421 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4365,7 +4365,6 @@ static struct addrconf_sysctl_table
 {
 	struct ctl_table_header *sysctl_header;
 	ctl_table addrconf_vars[DEVCONF_MAX+1];
-	char *dev_name;
 } addrconf_sysctl __read_mostly = {
 	.sysctl_header = NULL,
 	.addrconf_vars = {
@@ -4594,17 +4593,7 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 {
 	int i;
 	struct addrconf_sysctl_table *t;
-
-#define ADDRCONF_CTL_PATH_DEV	3
-
-	struct ctl_path addrconf_ctl_path[] = {
-		{ .procname = "net", },
-		{ .procname = "ipv6", },
-		{ .procname = "conf", },
-		{ /* to be set */ },
-		{ },
-	};
-
+	char path[sizeof("net/ipv6/conf/") + IFNAMSIZ];
 
 	t = kmemdup(&addrconf_sysctl, sizeof(*t), GFP_KERNEL);
 	if (t == NULL)
@@ -4616,27 +4605,15 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 		t->addrconf_vars[i].extra2 = net;
 	}
 
-	/*
-	 * Make a copy of dev_name, because '.procname' is regarded as const
-	 * by sysctl and we wouldn't want anyone to change it under our feet
-	 * (see SIOCSIFNAME).
-	 */
-	t->dev_name = kstrdup(dev_name, GFP_KERNEL);
-	if (!t->dev_name)
-		goto free;
+	snprintf(path, sizeof(path), "net/ipv6/conf/%s", dev_name);
 
-	addrconf_ctl_path[ADDRCONF_CTL_PATH_DEV].procname = t->dev_name;
-
-	t->sysctl_header = register_net_sysctl_table(net, addrconf_ctl_path,
-			t->addrconf_vars);
+	t->sysctl_header = register_net_sysctl(net, path, t->addrconf_vars);
 	if (t->sysctl_header == NULL)
-		goto free_procname;
+		goto free;
 
 	p->sysctl = t;
 	return 0;
 
-free_procname:
-	kfree(t->dev_name);
 free:
 	kfree(t);
 out:
@@ -4653,7 +4630,6 @@ static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
 	t = p->sysctl;
 	p->sysctl = NULL;
 	unregister_net_sysctl_table(t->sysctl_header);
-	kfree(t->dev_name);
 	kfree(t);
 }
 
-- 
1.7.2.5
