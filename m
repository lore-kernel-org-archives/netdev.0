From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH net-next-2.6] net: use net_eq to compare nets
Date: Thu, 26 Nov 2009 00:51:17 +0200
Message-ID: <200911260051.17430.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Julia Lawall <julia@diku.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:3242 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933079AbZKYWyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 17:54:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Generated with the following semantic patch

@@
struct net *n1;
struct net *n2;
@@
- n1 == n2
+ net_eq(n1, n2)

@@
struct net *n1;
struct net *n2;
@@
- n1 != n2
+ !net_eq(n1, n2)

applied over {include,net,drivers/net}.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 drivers/net/hamradio/bpqether.c |    4 ++--
 drivers/net/loopback.c          |    2 +-
 drivers/net/wan/hdlc.c          |    4 ++--
 net/appletalk/ddp.c             |    2 +-
 net/atm/svc.c                   |    2 +-
 net/ax25/af_ax25.c              |    2 +-
 net/can/af_can.c                |    2 +-
 net/core/dev.c                  |    4 ++--
 net/core/neighbour.c            |    2 +-
 net/core/net-sysfs.c            |    4 ++--
 net/core/net_namespace.c        |    2 +-
 net/core/sysctl_net_core.c      |    2 +-
 net/dcb/dcbnl.c                 |    2 +-
 net/decnet/af_decnet.c          |    2 +-
 net/decnet/dn_dev.c             |    6 +++---
 net/decnet/dn_fib.c             |    4 ++--
 net/decnet/dn_route.c           |    4 ++--
 net/decnet/dn_table.c           |    2 +-
 net/econet/af_econet.c          |    2 +-
 net/ieee802154/af_ieee802154.c  |    2 +-
 net/ipv4/devinet.c              |    2 +-
 net/ipv4/fib_semantics.c        |    4 ++--
 net/ipv4/inet_connection_sock.c |    4 ++--
 net/ipv4/inet_hashtables.c      |    3 ++-
 net/ipv4/ip_fragment.c          |    4 ++--
 net/ipv4/ip_input.c             |    2 +-
 net/ipv4/netfilter/ip_queue.c   |    2 +-
 net/ipv4/route.c                |    4 ++--
 net/ipv4/sysctl_net_ipv4.c      |    4 ++--
 net/ipv6/addrconf.c             |    4 ++--
 net/ipv6/ip6_flowlabel.c        |    9 +++++----
 net/ipv6/netfilter/ip6_queue.c  |    2 +-
 net/ipv6/reassembly.c           |    4 ++--
 net/ipx/af_ipx.c                |    2 +-
 net/llc/af_llc.c                |    2 +-
 net/netfilter/nfnetlink_log.c   |    2 +-
 net/netlink/af_netlink.c        |    2 +-
 net/netrom/af_netrom.c          |    2 +-
 net/packet/af_packet.c          |    6 +++---
 net/rose/af_rose.c              |    2 +-
 net/rxrpc/af_rxrpc.c            |    2 +-
 net/sched/act_api.c             |    4 ++--
 net/sched/cls_api.c             |    4 ++--
 net/sched/sch_api.c             |   10 +++++-----
 net/tipc/socket.c               |    2 +-
 net/x25/af_x25.c                |    2 +-
 46 files changed, 74 insertions(+), 72 deletions(-)

diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index fe893c9..76abed9 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -186,7 +186,7 @@ static int bpq_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_ty
 	struct ethhdr *eth;
 	struct bpqdev *bpq;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto drop;
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
@@ -552,7 +552,7 @@ static int bpq_device_event(struct notifier_block *this,unsigned long event, voi
 {
 	struct net_device *dev = (struct net_device *)ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (!dev_is_ethdev(dev))
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 1bc654a..c9f6557 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -207,7 +207,7 @@ static __net_init int loopback_net_init(struct net *net)
 out_free_netdev:
 	free_netdev(dev);
 out:
-	if (net == &init_net)
+	if (net_eq(net, &init_net))
 		panic("loopback: Failed to register netdevice: %d\n", err);
 	return err;
 }
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index cc07236..9937bba 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -57,7 +57,7 @@ static int hdlc_rcv(struct sk_buff *skb, struct net_device *dev,
 {
 	struct hdlc_device *hdlc = dev_to_hdlc(dev);
 
-	if (dev_net(dev) != &init_net) {
+	if (!net_eq(dev_net(dev), &init_net)) {
 		kfree_skb(skb);
 		return 0;
 	}
@@ -102,7 +102,7 @@ static int hdlc_device_event(struct notifier_block *this, unsigned long event,
 	unsigned long flags;
 	int on;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (!(dev->priv_flags & IFF_WAN_HDLC))
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 73ca4d5..9fc4da5 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1023,7 +1023,7 @@ static int atalk_create(struct net *net, struct socket *sock, int protocol,
 	struct sock *sk;
 	int rc = -ESOCKTNOSUPPORT;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	/*
diff --git a/net/atm/svc.c b/net/atm/svc.c
index c739507..66e1d9b 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -655,7 +655,7 @@ static int svc_create(struct net *net, struct socket *sock, int protocol,
 {
 	int error;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	sock->ops = &svc_proto_ops;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index d6ddfa4..5588ba6 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -805,7 +805,7 @@ static int ax25_create(struct net *net, struct socket *sock, int protocol,
 	struct sock *sk;
 	ax25_cb *ax25;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	switch (sock->type) {
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 833bd83..f306717 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -126,7 +126,7 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
 	if (protocol < 0 || protocol >= CAN_NPROTO)
 		return -EINVAL;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 #ifdef CONFIG_MODULES
diff --git a/net/core/dev.c b/net/core/dev.c
index ccefa24..e65af60 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -985,7 +985,7 @@ rollback:
 	/* For now only devices in the initial network namespace
 	 * are in sysfs.
 	 */
-	if (net == &init_net) {
+	if (net_eq(net, &init_net)) {
 		ret = device_rename(&dev->dev, dev->name);
 		if (ret) {
 			memcpy(dev->name, oldname, IFNAMSIZ);
@@ -4792,7 +4792,7 @@ static void rollback_registered_many(struct list_head *head)
 	list_for_each_entry_safe(dev, aux, head, unreg_list) {
 		int new_net = 1;
 		list_for_each_entry(fdev, &pernet_list, unreg_list) {
-			if (dev_net(dev) == dev_net(fdev)) {
+			if (net_eq(dev_net(dev), dev_net(fdev))) {
 				new_net = 0;
 				dev_put(dev);
 				break;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index e587e68..a08a35b 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2092,7 +2092,7 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 		if (h > s_h)
 			s_idx = 0;
 		for (n = tbl->hash_buckets[h], idx = 0; n; n = n->next) {
-			if (dev_net(n->dev) != net)
+			if (!net_eq(dev_net(n->dev), net))
 				continue;
 			if (idx < s_idx)
 				goto next;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 157645c..fbc1c74 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -525,7 +525,7 @@ void netdev_unregister_kobject(struct net_device * net)
 
 	kobject_get(&dev->kobj);
 
-	if (dev_net(net) != &init_net)
+	if (!net_eq(dev_net(net), &init_net))
 		return;
 
 	device_del(dev);
@@ -559,7 +559,7 @@ int netdev_register_kobject(struct net_device *net)
 #endif
 #endif /* CONFIG_SYSFS */
 
-	if (dev_net(net) != &init_net)
+	if (!net_eq(dev_net(net), &init_net))
 		return 0;
 
 	return device_add(dev);
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 1c1af27..86ed7f4 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -280,7 +280,7 @@ out_undo:
 	list_del(&ops->list);
 	if (ops->exit) {
 		for_each_net(undo_net) {
-			if (undo_net == net)
+			if (net_eq(undo_net, net))
 				goto undone;
 			ops->exit(undo_net);
 		}
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 7db1de0..fcfc545 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -134,7 +134,7 @@ static __net_init int sysctl_core_net_init(struct net *net)
 	net->core.sysctl_somaxconn = SOMAXCONN;
 
 	tbl = netns_core_table;
-	if (net != &init_net) {
+	if (!net_eq(net, &init_net)) {
 		tbl = kmemdup(tbl, sizeof(netns_core_table), GFP_KERNEL);
 		if (tbl == NULL)
 			goto err_dup;
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index ac1205d..2afd617 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1126,7 +1126,7 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
 	int ret = -EINVAL;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
 	ret = nlmsg_parse(nlh, sizeof(*dcb), tb, DCB_ATTR_MAX,
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 9ade3a6..2b494fa 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -680,7 +680,7 @@ static int dn_create(struct net *net, struct socket *sock, int protocol,
 {
 	struct sock *sk;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	switch(sock->type) {
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 6c916e2..f20dec9 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -636,7 +636,7 @@ static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct dn_ifaddr *ifa, **ifap;
 	int err = -EINVAL;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		goto errout;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy);
@@ -675,7 +675,7 @@ static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct dn_ifaddr *ifa;
 	int err;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy);
@@ -789,7 +789,7 @@ static int dn_nl_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 	struct dn_dev *dn_db;
 	struct dn_ifaddr *ifa;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return 0;
 
 	skip_ndevs = cb->args[0];
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index fd641f6..e9d4870 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -509,7 +509,7 @@ static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *
 	struct rtattr **rta = arg;
 	struct rtmsg *r = NLMSG_DATA(nlh);
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
 	if (dn_fib_check_attr(r, rta))
@@ -529,7 +529,7 @@ static int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *
 	struct rtattr **rta = arg;
 	struct rtmsg *r = NLMSG_DATA(nlh);
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
 	if (dn_fib_check_attr(r, rta))
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 860286a..a032840 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1517,7 +1517,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 	struct sk_buff *skb;
 	struct flowi fl;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
 	memset(&fl, 0, sizeof(fl));
@@ -1602,7 +1602,7 @@ int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int h, s_h;
 	int idx, s_idx;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return 0;
 
 	if (NLMSG_PAYLOAD(cb->nlh, 0) < sizeof(struct rtmsg))
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 67054b0..f281e0f 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -471,7 +471,7 @@ int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct hlist_node *node;
 	int dumped = 0;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return 0;
 
 	if (NLMSG_PAYLOAD(cb->nlh, 0) >= sizeof(struct rtmsg) &&
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 5966798..29b4931 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -612,7 +612,7 @@ static int econet_create(struct net *net, struct socket *sock, int protocol,
 	struct econet_sock *eo;
 	int err;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	/* Econet only provides datagram services. */
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index de6e34d..bad1c49 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -241,7 +241,7 @@ static int ieee802154_create(struct net *net, struct socket *sock,
 	struct proto *proto;
 	const struct proto_ops *ops;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	switch (sock->type) {
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7620382..c100709 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1605,7 +1605,7 @@ static __net_init int devinet_init_net(struct net *net)
 	all = &ipv4_devconf;
 	dflt = &ipv4_devconf_dflt;
 
-	if (net != &init_net) {
+	if (!net_eq(net, &init_net)) {
 		all = kmemdup(all, sizeof(ipv4_devconf), GFP_KERNEL);
 		if (all == NULL)
 			goto err_alloc_all;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 9b096d6..ed19aa6 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -228,7 +228,7 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
 	head = &fib_info_hash[hash];
 
 	hlist_for_each_entry(fi, node, head, fib_hash) {
-		if (fi->fib_net != nfi->fib_net)
+		if (!net_eq(fi->fib_net, nfi->fib_net))
 			continue;
 		if (fi->fib_nhs != nfi->fib_nhs)
 			continue;
@@ -1047,7 +1047,7 @@ int fib_sync_down_addr(struct net *net, __be32 local)
 		return 0;
 
 	hlist_for_each_entry(fi, node, head, fib_lhash) {
-		if (fi->fib_net != net)
+		if (!net_eq(fi->fib_net, net))
 			continue;
 		if (fi->fib_prefsrc == local) {
 			fi->fib_flags |= RTNH_F_DEAD;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 26fb50e..9b35c56 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -112,7 +112,7 @@ again:
 					hashinfo->bhash_size)];
 			spin_lock(&head->lock);
 			inet_bind_bucket_for_each(tb, node, &head->chain)
-				if (ib_net(tb) == net && tb->port == rover) {
+				if (net_eq(ib_net(tb), net) && tb->port == rover) {
 					if (tb->fastreuse > 0 &&
 					    sk->sk_reuse &&
 					    sk->sk_state != TCP_LISTEN &&
@@ -158,7 +158,7 @@ have_snum:
 				hashinfo->bhash_size)];
 		spin_lock(&head->lock);
 		inet_bind_bucket_for_each(tb, node, &head->chain)
-			if (ib_net(tb) == net && tb->port == snum)
+			if (net_eq(ib_net(tb), net) && tb->port == snum)
 				goto tb_found;
 	}
 	tb = NULL;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 47ad7aa..94ef51a 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -454,7 +454,8 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			 * unique enough.
 			 */
 			inet_bind_bucket_for_each(tb, node, &head->chain) {
-				if (ib_net(tb) == net && tb->port == port) {
+				if (net_eq(ib_net(tb), net) &&
+				    tb->port == port) {
 					if (tb->fastreuse >= 0)
 						goto next_port;
 					WARN_ON(hlist_empty(&tb->owners));
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b007f8a..1472d8e 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -658,7 +658,7 @@ static int ip4_frags_ns_ctl_register(struct net *net)
 	struct ctl_table_header *hdr;
 
 	table = ip4_frags_ns_ctl_table;
-	if (net != &init_net) {
+	if (!net_eq(net, &init_net)) {
 		table = kmemdup(table, sizeof(ip4_frags_ns_ctl_table), GFP_KERNEL);
 		if (table == NULL)
 			goto err_alloc;
@@ -676,7 +676,7 @@ static int ip4_frags_ns_ctl_register(struct net *net)
 	return 0;
 
 err_reg:
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		kfree(table);
 err_alloc:
 	return -ENOMEM;
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index fdf51ba..c29de98 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -164,7 +164,7 @@ int ip_call_ra_chain(struct sk_buff *skb)
 		if (sk && inet_sk(sk)->inet_num == protocol &&
 		    (!sk->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == dev->ifindex) &&
-		    sock_net(sk) == dev_net(dev)) {
+		    net_eq(sock_net(sk), dev_net(dev))) {
 			if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
 				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN)) {
 					read_unlock(&ip_ra_lock);
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index c156db2..884f085 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -500,7 +500,7 @@ ipq_rcv_nl_event(struct notifier_block *this,
 	if (event == NETLINK_URELEASE &&
 	    n->protocol == NETLINK_FIREWALL && n->pid) {
 		write_lock_bh(&queue_lock);
-		if ((n->net == &init_net) && (n->pid == peer_pid))
+		if ((net_eq(n->net, &init_net)) && (n->pid == peer_pid))
 			__ipq_reset();
 		write_unlock_bh(&queue_lock);
 	}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7547944..aea7bb3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -703,7 +703,7 @@ static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 
 static inline int compare_netns(struct rtable *rt1, struct rtable *rt2)
 {
-	return dev_net(rt1->u.dst.dev) == dev_net(rt2->u.dst.dev);
+	return net_eq(dev_net(rt1->u.dst.dev), dev_net(rt2->u.dst.dev));
 }
 
 static inline int rt_is_expired(struct rtable *rth)
@@ -3310,7 +3310,7 @@ static __net_init int sysctl_route_net_init(struct net *net)
 	struct ctl_table *tbl;
 
 	tbl = ipv4_route_flush_table;
-	if (net != &init_net) {
+	if (!net_eq(net, &init_net)) {
 		tbl = kmemdup(tbl, sizeof(ipv4_route_flush_table), GFP_KERNEL);
 		if (tbl == NULL)
 			goto err_dup;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 2dcf04d..c00323b 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -818,7 +818,7 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 	struct ctl_table *table;
 
 	table = ipv4_net_table;
-	if (net != &init_net) {
+	if (!net_eq(net, &init_net)) {
 		table = kmemdup(table, sizeof(ipv4_net_table), GFP_KERNEL);
 		if (table == NULL)
 			goto err_alloc;
@@ -849,7 +849,7 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 	return 0;
 
 err_reg:
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		kfree(table);
 err_alloc:
 	return -ENOMEM;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 522bdc7..b1ce8fc 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4498,7 +4498,7 @@ static int addrconf_init_net(struct net *net)
 	all = &ipv6_devconf;
 	dflt = &ipv6_devconf_dflt;
 
-	if (net != &init_net) {
+	if (!net_eq(net, &init_net)) {
 		all = kmemdup(all, sizeof(ipv6_devconf), GFP_KERNEL);
 		if (all == NULL)
 			goto err_alloc_all;
@@ -4546,7 +4546,7 @@ static void addrconf_exit_net(struct net *net)
 	__addrconf_sysctl_unregister(net->ipv6.devconf_dflt);
 	__addrconf_sysctl_unregister(net->ipv6.devconf_all);
 #endif
-	if (net != &init_net) {
+	if (!net_eq(net, &init_net)) {
 		kfree(net->ipv6.devconf_dflt);
 		kfree(net->ipv6.devconf_all);
 	}
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 593a67e..6e7bffa 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -67,7 +67,7 @@ static inline struct ip6_flowlabel *__fl_lookup(struct net *net, __be32 label)
 	struct ip6_flowlabel *fl;
 
 	for (fl=fl_ht[FL_HASH(label)]; fl; fl = fl->next) {
-		if (fl->label == label && fl->fl_net == net)
+		if (fl->label == label && net_eq(fl->fl_net, net))
 			return fl;
 	}
 	return NULL;
@@ -163,7 +163,8 @@ static void ip6_fl_purge(struct net *net)
 		struct ip6_flowlabel *fl, **flp;
 		flp = &fl_ht[i];
 		while ((fl = *flp) != NULL) {
-			if (fl->fl_net == net && atomic_read(&fl->users) == 0) {
+			if (net_eq(fl->fl_net, net) &&
+			    atomic_read(&fl->users) == 0) {
 				*flp = fl->next;
 				fl_free(fl);
 				atomic_dec(&fl_size);
@@ -630,7 +631,7 @@ static struct ip6_flowlabel *ip6fl_get_first(struct seq_file *seq)
 	for (state->bucket = 0; state->bucket <= FL_HASH_MASK; ++state->bucket) {
 		fl = fl_ht[state->bucket];
 
-		while (fl && fl->fl_net != net)
+		while (fl && !net_eq(fl->fl_net, net))
 			fl = fl->next;
 		if (fl)
 			break;
@@ -645,7 +646,7 @@ static struct ip6_flowlabel *ip6fl_get_next(struct seq_file *seq, struct ip6_flo
 
 	fl = fl->next;
 try_again:
-	while (fl && fl->fl_net != net)
+	while (fl && !net_eq(fl->fl_net, net))
 		fl = fl->next;
 
 	while (!fl) {
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 1cf3f0c..4c7a18a 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -502,7 +502,7 @@ ipq_rcv_nl_event(struct notifier_block *this,
 	if (event == NETLINK_URELEASE &&
 	    n->protocol == NETLINK_IP6_FW && n->pid) {
 		write_lock_bh(&queue_lock);
-		if ((n->net == &init_net) && (n->pid == peer_pid))
+		if ((net_eq(n->net, &init_net)) && (n->pid == peer_pid))
 			__ipq_reset();
 		write_unlock_bh(&queue_lock);
 	}
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index dce699f..45efc39 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -681,7 +681,7 @@ static int ip6_frags_ns_sysctl_register(struct net *net)
 	struct ctl_table_header *hdr;
 
 	table = ip6_frags_ns_ctl_table;
-	if (net != &init_net) {
+	if (!net_eq(net, &init_net)) {
 		table = kmemdup(table, sizeof(ip6_frags_ns_ctl_table), GFP_KERNEL);
 		if (table == NULL)
 			goto err_alloc;
@@ -699,7 +699,7 @@ static int ip6_frags_ns_sysctl_register(struct net *net)
 	return 0;
 
 err_reg:
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		kfree(table);
 err_alloc:
 	return -ENOMEM;
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 975c5a3..f9759b5 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1362,7 +1362,7 @@ static int ipx_create(struct net *net, struct socket *sock, int protocol,
 	int rc = -ESOCKTNOSUPPORT;
 	struct sock *sk;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	/*
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 5266c28..3a66546 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -158,7 +158,7 @@ static int llc_ui_create(struct net *net, struct socket *sock, int protocol,
 	if (!capable(CAP_NET_RAW))
 		return -EPERM;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	if (likely(sock->type == SOCK_DGRAM || sock->type == SOCK_STREAM)) {
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index f900dc3..4900548 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -678,7 +678,7 @@ nfulnl_rcv_nl_event(struct notifier_block *this,
 			struct hlist_head *head = &instance_table[i];
 
 			hlist_for_each_entry_safe(inst, tmp, t2, head, hlist) {
-				if ((n->net == &init_net) &&
+				if ((net_eq(n->net, &init_net)) &&
 				    (n->pid == inst->peer_pid))
 					__instance_destroy(inst);
 			}
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index eff5b0d..a4957bf 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1092,7 +1092,7 @@ static inline int do_one_set_err(struct sock *sk,
 	if (sk == p->exclude_sk)
 		goto out;
 
-	if (sock_net(sk) != sock_net(p->exclude_sk))
+	if (!net_eq(sock_net(sk), sock_net(p->exclude_sk)))
 		goto out;
 
 	if (nlk->pid == p->pid || p->group - 1 >= nlk->ngroups ||
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 4bdd569..71604c6 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -431,7 +431,7 @@ static int nr_create(struct net *net, struct socket *sock, int protocol,
 	struct sock *sk;
 	struct nr_sock *nr;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	if (sock->type != SOCK_SEQPACKET || protocol != 0)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c620bd9..940fc20 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -365,7 +365,7 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto out;
 
-	if (dev_net(dev) != sock_net(sk))
+	if (!net_eq(dev_net(dev), sock_net(sk)))
 		goto out;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
@@ -553,7 +553,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	sk = pt->af_packet_priv;
 	po = pkt_sk(sk);
 
-	if (dev_net(dev) != sock_net(sk))
+	if (!net_eq(dev_net(dev), sock_net(sk)))
 		goto drop;
 
 	skb->dev = dev;
@@ -674,7 +674,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	sk = pt->af_packet_priv;
 	po = pkt_sk(sk);
 
-	if (dev_net(dev) != sock_net(sk))
+	if (!net_eq(dev_net(dev), sock_net(sk)))
 		goto drop;
 
 	if (dev->header_ops) {
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 4de4287..8feb9e5 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -518,7 +518,7 @@ static int rose_create(struct net *net, struct socket *sock, int protocol,
 	struct sock *sk;
 	struct rose_sock *rose;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	if (sock->type != SOCK_SEQPACKET || protocol != 0)
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index f978d02..287b141 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -616,7 +616,7 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 
 	_enter("%p,%d", sock, protocol);
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	/* we support transport protocol UDP only */
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index ca2e1fd..2a74003 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -969,7 +969,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
 	int ret = 0, ovr = 0;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
 	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL);
@@ -1052,7 +1052,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	struct tcamsg *t = (struct tcamsg *) NLMSG_DATA(cb->nlh);
 	struct nlattr *kind = find_dump_kind(cb->nlh);
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return 0;
 
 	if (kind == NULL) {
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index c024da7..3725d8f 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -137,7 +137,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	int err;
 	int tp_created = 0;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
 replay:
@@ -418,7 +418,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	const struct Qdisc_class_ops *cops;
 	struct tcf_dump_args arg;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return 0;
 
 	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 876ba4b..75fd1c6 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -947,7 +947,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	struct Qdisc *p = NULL;
 	int err;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
 	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
@@ -1009,7 +1009,7 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	struct Qdisc *q, *p;
 	int err;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
 replay:
@@ -1274,7 +1274,7 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 	int s_idx, s_q_idx;
 	struct net_device *dev;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return 0;
 
 	s_idx = cb->args[0];
@@ -1334,7 +1334,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	u32 qid = TC_H_MAJ(clid);
 	int err;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
 	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
@@ -1576,7 +1576,7 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net_device *dev;
 	int t, s_t;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return 0;
 
 	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index d00c211..eca5eb0 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -195,7 +195,7 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
 
 	/* Validate arguments */
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	if (unlikely(protocol != 0))
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index ac7dba4..2a3a513 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -514,7 +514,7 @@ static int x25_create(struct net *net, struct socket *sock, int protocol,
 	struct x25_sock *x25;
 	int rc = -ESOCKTNOSUPPORT;
 
-	if (net != &init_net)
+	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
 	if (sock->type != SOCK_SEQPACKET || protocol)
-- 
1.5.6.5

