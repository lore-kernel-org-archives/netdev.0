From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 16/29] net: vrf: Set default vrf
Date: Wed,  4 Feb 2015 18:34:17 -0700
Message-ID: <1423100070-31848-17-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:55136 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756324AbbBEBgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:07 -0500
Received: by mail-ie0-f178.google.com with SMTP id rd18so6685987iec.9
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:07 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set default vrf to DEFAULT_VRF for devices, neighbor table, and a few
other places.

If a device is moved from one namespace to another reset the vrf id to
DEFAULT_VRF.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/core/dev.c       | 4 ++++
 net/core/neighbour.c | 1 +
 net/ipv4/fib_rules.c | 2 +-
 net/ipv4/ipconfig.c  | 4 ++--
 net/ipv4/ipmr.c      | 2 +-
 5 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index fa92d1046eeb..0d50b2c1944e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6817,6 +6817,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	dev_uc_init(dev);
 
 	dev_net_set(dev, &init_net);
+	dev->nd_vrf = VRF_DEFAULT;
 
 	dev->gso_max_size = GSO_MAX_SIZE;
 	dev->gso_max_segs = GSO_MAX_SEGS;
@@ -7079,6 +7080,9 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
 
+	/* reset vrf id since we changed namespaces */
+	dev->nd_vrf = VRF_DEFAULT;
+
 	/* If there is an ifindex conflict assign a new one */
 	if (__dev_get_by_index(net, dev->ifindex)) {
 		int iflink = (dev->iflink == dev->ifindex);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d872ada6720a..f64e178738de 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1526,6 +1526,7 @@ void neigh_table_init(int index, struct neigh_table *tbl)
 	INIT_LIST_HEAD(&tbl->parms_list);
 	list_add(&tbl->parms.list, &tbl->parms_list);
 	write_pnet(&tbl->parms.net_ctx.net, &init_net);
+	tbl->parms.net_ctx.vrf = VRF_DEFAULT;
 	atomic_set(&tbl->parms.refcnt, 1);
 	tbl->parms.reachable_time =
 			  neigh_rand_reach_time(NEIGH_VAR(&tbl->parms, BASE_REACHABLE_TIME));
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 60b14866661b..bb9399e2c1cb 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -331,7 +331,7 @@ int __net_init fib4_rules_init(struct net *net)
 {
 	int err;
 	struct fib_rules_ops *ops;
-	struct net_ctx ctx = { .net = net };
+	struct net_ctx ctx = { .net = net, .vrf = VRF_DEFAULT };
 
 	ops = fib_rules_register(&fib4_rules_ops_template, &ctx);
 	if (IS_ERR(ops))
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index e25e3b67be76..b0a5226faaef 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -329,7 +329,7 @@ set_sockaddr(struct sockaddr_in *sin, __be32 addr, __be16 port)
 
 static int __init ic_devinet_ioctl(unsigned int cmd, struct ifreq *arg)
 {
-	struct net_ctx ctx = { .net = &init_net };
+	struct net_ctx ctx = INIT_NET_CTX;
 	int res;
 
 	mm_segment_t oldfs = get_fs();
@@ -352,7 +352,7 @@ static int __init ic_dev_ioctl(unsigned int cmd, struct ifreq *arg)
 
 static int __init ic_route_ioctl(unsigned int cmd, struct rtentry *arg)
 {
-	struct net_ctx ctx = { .net = &init_net };
+	struct net_ctx ctx = INIT_NET_CTX;
 	int res;
 
 	mm_segment_t oldfs = get_fs();
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 935f45f54862..84d6efeeb072 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -244,7 +244,7 @@ static const struct fib_rules_ops __net_initconst ipmr_rules_ops_template = {
 
 static int __net_init ipmr_rules_init(struct net *net)
 {
-	struct net_ctx ctx = { .net = net };
+	struct net_ctx ctx = { .net = net, .vrf = VRF_DEFAULT };
 	struct fib_rules_ops *ops;
 	struct mr_table *mrt;
 	int err;
-- 
1.9.3 (Apple Git-50)
