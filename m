From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH 1/2] net/ipv6/addrconf: simplify sysctl registration
Date: Mon, 18 Apr 2016 14:41:10 +0300
Message-ID: <146097967035.15409.8235893232862124602.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Struct ctl_table_header holds pointer to sysctl table which could be used
for freeing it after unregistration. IPv4 sysctls already use that.
Remove redundant NULL assignment: ndev allocated using kzalloc.

This also saves some bytes: sysctl table could be shorter than
DEVCONF_MAX+1 if some options are disable in config.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/ipv6.h |    3 ++-
 net/ipv6/addrconf.c  |   43 +++++++++++++++++--------------------------
 2 files changed, 19 insertions(+), 27 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 7edc14fb66b6..58d6e158755f 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -63,7 +63,8 @@ struct ipv6_devconf {
 	} stable_secret;
 	__s32		use_oif_addrs_only;
 	__s32		keep_addr_on_down;
-	void		*sysctl;
+
+	struct ctl_table_header *sysctl_header;
 };
 
 struct ipv6_params {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 27aed1afcf81..8a724c7136b0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -359,7 +359,6 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 		ndev->addr_gen_mode = IN6_ADDR_GEN_MODE_EUI64;
 
 	ndev->cnf.mtu6 = dev->mtu;
-	ndev->cnf.sysctl = NULL;
 	ndev->nd_parms = neigh_parms_alloc(dev, &nd_tbl);
 	if (!ndev->nd_parms) {
 		kfree(ndev);
@@ -5618,13 +5617,7 @@ int addrconf_sysctl_ignore_routes_with_linkdown(struct ctl_table *ctl,
 	return ret;
 }
 
-static struct addrconf_sysctl_table
-{
-	struct ctl_table_header *sysctl_header;
-	struct ctl_table addrconf_vars[DEVCONF_MAX+1];
-} addrconf_sysctl __read_mostly = {
-	.sysctl_header = NULL,
-	.addrconf_vars = {
+static const struct ctl_table addrconf_sysctl[] = {
 		{
 			.procname	= "forwarding",
 			.data		= &ipv6_devconf.forwarding,
@@ -5942,52 +5935,50 @@ static struct addrconf_sysctl_table
 		{
 			/* sentinel */
 		}
-	},
 };
 
 static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 		struct inet6_dev *idev, struct ipv6_devconf *p)
 {
 	int i;
-	struct addrconf_sysctl_table *t;
+	struct ctl_table *table;
 	char path[sizeof("net/ipv6/conf/") + IFNAMSIZ];
 
-	t = kmemdup(&addrconf_sysctl, sizeof(*t), GFP_KERNEL);
-	if (!t)
+	table = kmemdup(addrconf_sysctl, sizeof(addrconf_sysctl), GFP_KERNEL);
+	if (!table)
 		goto out;
 
-	for (i = 0; t->addrconf_vars[i].data; i++) {
-		t->addrconf_vars[i].data += (char *)p - (char *)&ipv6_devconf;
-		t->addrconf_vars[i].extra1 = idev; /* embedded; no ref */
-		t->addrconf_vars[i].extra2 = net;
+	for (i = 0; table[i].data; i++) {
+		table[i].data += (char *)p - (char *)&ipv6_devconf;
+		table[i].extra1 = idev; /* embedded; no ref */
+		table[i].extra2 = net;
 	}
 
 	snprintf(path, sizeof(path), "net/ipv6/conf/%s", dev_name);
 
-	t->sysctl_header = register_net_sysctl(net, path, t->addrconf_vars);
-	if (!t->sysctl_header)
+	p->sysctl_header = register_net_sysctl(net, path, table);
+	if (!p->sysctl_header)
 		goto free;
 
-	p->sysctl = t;
 	return 0;
 
 free:
-	kfree(t);
+	kfree(table);
 out:
 	return -ENOBUFS;
 }
 
 static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
 {
-	struct addrconf_sysctl_table *t;
+	struct ctl_table *table;
 
-	if (!p->sysctl)
+	if (!p->sysctl_header)
 		return;
 
-	t = p->sysctl;
-	p->sysctl = NULL;
-	unregister_net_sysctl_table(t->sysctl_header);
-	kfree(t);
+	table = p->sysctl_header->ctl_table_arg;
+	unregister_net_sysctl_table(p->sysctl_header);
+	p->sysctl_header = NULL;
+	kfree(table);
 }
 
 static int addrconf_sysctl_register(struct inet6_dev *idev)
