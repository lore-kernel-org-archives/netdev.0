From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 6/7] Switch users of ipv4_devconf_dflt to use the
 pernet one
Date: Tue, 11 Dec 2007 20:59:58 +0300
Message-ID: <475ED01E.5020505@openvz.org>
References: <475ECC69.1040809@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51194 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755104AbXLKSAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 13:00:13 -0500
In-Reply-To: <475ECC69.1040809@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are all collected in the net/ipv4/devinet.c file and
mostly use the IPV4_DEVCONF_DFLT macro.

So I add the net parameter to it and patch users accordingly.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 996f07e..cd957f4 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -83,7 +83,8 @@ static struct ipv4_devconf ipv4_devconf_dflt = {
 	},
 };
 
-#define IPV4_DEVCONF_DFLT(attr) IPV4_DEVCONF(ipv4_devconf_dflt, attr)
+#define IPV4_DEVCONF_DFLT(net, attr) \
+	IPV4_DEVCONF((*net->ipv4.devconf_dflt), attr)
 
 static const struct nla_policy ifa_ipv4_policy[IFA_MAX+1] = {
 	[IFA_LOCAL]     	= { .type = NLA_U32 },
@@ -164,7 +165,8 @@ static struct in_device *inetdev_init(struct net_device *dev)
 	if (!in_dev)
 		goto out;
 	INIT_RCU_HEAD(&in_dev->rcu_head);
-	memcpy(&in_dev->cnf, &ipv4_devconf_dflt, sizeof(in_dev->cnf));
+	memcpy(&in_dev->cnf, dev->nd_net->ipv4.devconf_dflt,
+			sizeof(in_dev->cnf));
 	in_dev->cnf.sysctl = NULL;
 	in_dev->dev = dev;
 	if ((in_dev->arp_parms = neigh_parms_alloc(dev, &arp_tbl)) == NULL)
@@ -1248,7 +1250,7 @@ static void devinet_copy_dflt_conf(struct net *net, int i)
 		rcu_read_lock();
 		in_dev = __in_dev_get_rcu(dev);
 		if (in_dev && !test_bit(i, in_dev->cnf.state))
-			in_dev->cnf.data[i] = ipv4_devconf_dflt.data[i];
+			in_dev->cnf.data[i] = net->ipv4.devconf_dflt->data[i];
 		rcu_read_unlock();
 	}
 	read_unlock(&dev_base_lock);
@@ -1260,7 +1262,7 @@ static void inet_forward_change(struct net *net)
 	int on = IPV4_DEVCONF_ALL(FORWARDING);
 
 	IPV4_DEVCONF_ALL(ACCEPT_REDIRECTS) = !on;
-	IPV4_DEVCONF_DFLT(FORWARDING) = on;
+	IPV4_DEVCONF_DFLT(net, FORWARDING) = on;
 
 	read_lock(&dev_base_lock);
 	for_each_netdev(net, dev) {
@@ -1289,7 +1291,7 @@ static int devinet_conf_proc(ctl_table *ctl, int write,
 
 		set_bit(i, cnf->state);
 
-		if (cnf == &ipv4_devconf_dflt)
+		if (cnf == net->ipv4.devconf_dflt)
 			devinet_copy_dflt_conf(net, i);
 	}
 
@@ -1342,7 +1344,7 @@ static int devinet_conf_sysctl(ctl_table *table, int __user *name, int nlen,
 
 	set_bit(i, cnf->state);
 
-	if (cnf == &ipv4_devconf_dflt)
+	if (cnf == net->ipv4.devconf_dflt)
 		devinet_copy_dflt_conf(net, i);
 
 	return 1;
@@ -1361,7 +1363,7 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
 
 		if (valp == &IPV4_DEVCONF_ALL(FORWARDING))
 			inet_forward_change(net);
-		else if (valp != &IPV4_DEVCONF_DFLT(FORWARDING))
+		else if (valp != &IPV4_DEVCONF_DFLT(net, FORWARDING))
 			rt_cache_flush(0);
 	}
 
-- 
1.5.3.4

