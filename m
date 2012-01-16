From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: [PATCH 1/1] net: race condition in ipv6 forwarding and disable_ipv6 parameters
Date: Mon, 16 Jan 2012 12:40:10 -0800
Message-ID: <CA+HUmGgLmsHsTUbKb=XB_Ow+BPajpu75B18Um0zRZRkof8rQmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francesco Ruggeri <fruggeri@aristanetworks.com>

There is a race condition in addrconf_sysctl_forward() and
addrconf_sysctl_disable().
These functions change idev->cnf.forwarding (resp. idev->cnf.disable_ipv6)
and then try to grab the rtnl lock before performing any actions.
If that fails they restore the original value and restart the syscall.
This creates race conditions if ipv6 code tries to access
these parameters, or if multiple instances try to do the same operation.
As an example of the former, if __ipv6_ifa_notify() finds a 0 in
idev->cnf.forwarding when invoked by addrconf_ifdown() it may not free
anycast addresses, ultimately resulting in the net_device not being freed.
This patch reads the user parameters into a temporary location and only
writes the actual parameters when the rtnl lock is acquired.
Tested in 2.6.38.8.
Signed-off-by: Francesco Ruggeri <fruggeri@aristanetworks.com>
---
diff -up a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2011-03-14 18:20:32.000000000 -0700
+++ b/net/ipv6/addrconf.c	2012-01-07 16:48:54.146386450 -0800
@@ -502,29 +502,31 @@ static void addrconf_forward_change(stru
 	rcu_read_unlock();
 }

-static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
+static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 {
 	struct net *net;
+	int old;
+
+	if (!rtnl_trylock())
+		return restart_syscall();

 	net = (struct net *)table->extra2;
-	if (p == &net->ipv6.devconf_dflt->forwarding)
-		return 0;
+	old = *p;
+	*p = newf;

-	if (!rtnl_trylock()) {
-		/* Restore the original values before restarting */
-		*p = old;
-		return restart_syscall();
+	if (p == &net->ipv6.devconf_dflt->forwarding) {
+		rtnl_unlock();
+		return 0;
 	}

 	if (p == &net->ipv6.devconf_all->forwarding) {
-		__s32 newf = net->ipv6.devconf_all->forwarding;
 		net->ipv6.devconf_dflt->forwarding = newf;
 		addrconf_forward_change(net, newf);
-	} else if ((!*p) ^ (!old))
+	} else if ((!newf) ^ (!old))
 		dev_forward_change((struct inet6_dev *)table->extra1);
 	rtnl_unlock();

-	if (*p)
+	if (newf)
 		rt6_purge_dflt_routers(net);
 	return 1;
 }
@@ -4257,9 +4259,17 @@ int addrconf_sysctl_forward(ctl_table *c
 	int *valp = ctl->data;
 	int val = *valp;
 	loff_t pos = *ppos;
+	ctl_table lctl;
 	int ret;

-	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+	/*
+	 * ctl->data points to idev->cnf.forwarding, we should
+	 * not modify it until we get the rtnl lock.
+	 */
+	lctl = *ctl;
+	lctl.data = &val;
+
+	ret = proc_dointvec(&lctl, write, buffer, lenp, ppos);

 	if (write)
 		ret = addrconf_fixup_forwarding(ctl, valp, val);
@@ -4297,26 +4307,27 @@ static void addrconf_disable_change(stru
 	rcu_read_unlock();
 }

-static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int old)
+static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int newf)
 {
 	struct net *net;
+	int old;
+
+	if (!rtnl_trylock())
+		return restart_syscall();

 	net = (struct net *)table->extra2;
+	old = *p;
+	*p = newf;

-	if (p == &net->ipv6.devconf_dflt->disable_ipv6)
+	if (p == &net->ipv6.devconf_dflt->disable_ipv6) {
+		rtnl_unlock();
 		return 0;
-
-	if (!rtnl_trylock()) {
-		/* Restore the original values before restarting */
-		*p = old;
-		return restart_syscall();
 	}

 	if (p == &net->ipv6.devconf_all->disable_ipv6) {
-		__s32 newf = net->ipv6.devconf_all->disable_ipv6;
 		net->ipv6.devconf_dflt->disable_ipv6 = newf;
 		addrconf_disable_change(net, newf);
-	} else if ((!*p) ^ (!old))
+	} else if ((!newf) ^ (!old))
 		dev_disable_change((struct inet6_dev *)table->extra1);

 	rtnl_unlock();
@@ -4330,9 +4341,17 @@ int addrconf_sysctl_disable(ctl_table *c
 	int *valp = ctl->data;
 	int val = *valp;
 	loff_t pos = *ppos;
+	ctl_table lctl;
 	int ret;

-	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+	/*
+	 * ctl->data points to idev->cnf.disable_ipv6, we should
+	 * not modify it until we get the rtnl lock.
+	 */
+	lctl = *ctl;
+	lctl.data = &val;
+
+	ret = proc_dointvec(&lctl, write, buffer, lenp, ppos);

 	if (write)
 		ret = addrconf_disable_ipv6(ctl, valp, val);
