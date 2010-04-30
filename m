From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] [RFC] C/R: inet4 and inet6 unicast routes (v2)
Date: Fri, 30 Apr 2010 10:00:55 -0700
Message-ID: <1272646855-17327-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich-VXdhtT5mjnY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds support for checkpointing and restoring route information.
It keeps enough information to restore basic routes at the level of detail
of /proc/net/route.  It uses RTNETLINK to extract the information during
checkpoint and also to insert it back during restore.  This gives us a
nice layer of isolation between us and the various "fib" implementations.

Changes in v2:

This version of the patch actually moves the current task into the
desired network namespace temporarily, for the purposes of examining and
restoring the route information.  This is a instead of creating a cross-
namespace socket to do the job, as was done in v1.

This is just an RFC to see if this is an acceptable method.  For a final
version, adding a helper to nsproxy.c would allow us to create a new
nsproxy with the desired netns instead of creating one with
copy_namespaces() just to kill it off and use the target one.

I still think the previous method is cleaner, but this way may violate
fewer namespace boundaries (I'm still undecided :)

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Vlad Yasevich <vladislav.yasevich-VXdhtT5mjnY@public.gmane.org>
Cc: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |   31 +++
 net/checkpoint_dev.c           |  463 +++++++++++++++++++++++++++++++++++++++-
 2 files changed, 493 insertions(+), 1 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 790214f..28b268a 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -20,6 +20,7 @@
 #ifndef CONFIG_CHECKPOINT
 #warn linux/checkpoint_hdr.h included directly (without CONFIG_CHECKPOINT)
 #endif
+#include <linux/if.h>
 
 #else /* __KERNEL__ */
 
@@ -782,6 +783,7 @@ struct ckpt_hdr_file_socket {
 struct ckpt_hdr_netns {
 	struct ckpt_hdr h;
 	__s32 this_ref;
+	__u32 routes;
 } __attribute__((aligned(8)));
 
 enum ckpt_netdev_types {
@@ -826,6 +828,35 @@ struct ckpt_netdev_addr {
 	} __attribute__((aligned(8)));
 } __attribute__((aligned(8)));
 
+enum ckpt_route_types {
+	CKPT_ROUTE_IPV4,
+	CKPT_ROUTE_IPV6,
+	CKPT_ROUTE_MAX
+};
+
+#define CKPT_ROUTE_FLAG_GW 1
+
+struct ckpt_route {
+	__u16 type;
+	__u16 flags;
+
+	union {
+		struct {
+			__be32 inet4_len;          /* mask length (bits) */
+			__u32  inet4_met;          /* metric             */
+			__be32 inet4_dst;          /* route address      */
+			__be32 inet4_gwy;          /* gateway address    */
+		};
+		struct {
+			__u32 inet6_len;           /* mask length (bits) */
+			__u32 inet6_met;           /* metric             */
+			struct in6_addr inet6_dst; /* route address      */
+			struct in6_addr inet6_gwy; /* gateway address    */
+		};
+	} __attribute__((aligned(8)));
+	char dev[IFNAMSIZ+1];
+} __attribute__((aligned(8)));
+
 struct ckpt_hdr_eventpoll_items {
 	struct ckpt_hdr h;
 	__s32  epfile_objref;
diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
index a8e3341..cc5f0ac 100644
--- a/net/checkpoint_dev.c
+++ b/net/checkpoint_dev.c
@@ -16,9 +16,11 @@
 #include <linux/veth.h>
 #include <linux/checkpoint.h>
 #include <linux/deferqueue.h>
+#include <linux/fib_rules.h>
 
 #include <net/net_namespace.h>
 #include <net/sch_generic.h>
+#include <net/ipv6.h>
 
 struct veth_newlink {
 	char *peer;
@@ -59,6 +61,22 @@ static int __kern_dev_ioctl(struct net *net, unsigned int cmd, void *arg)
 	return ret;
 }
 
+static void debug_route(struct ckpt_route *route)
+{
+       if (route->type == CKPT_ROUTE_IPV4)
+               ckpt_debug("inet4 route %pI4/%i gw %pI4 metric %i dev %s\n",
+                          &route->inet4_dst, route->inet4_len,
+                          &route->inet4_gwy, route->inet4_met,
+                          route->dev);
+       else if (route->type == CKPT_ROUTE_IPV6)
+               ckpt_debug("inet6 route %pI6/%i gw %pI6 metric %i dev %s\n",
+                          &route->inet6_dst, route->inet6_len,
+                          &route->inet6_gwy, route->inet6_met,
+                          route->dev);
+       else
+               ckpt_debug("unknown route type %i\n", route->type);
+}
+
 static struct socket *rtnl_open(void)
 {
 	struct socket *sock;
@@ -250,11 +268,280 @@ int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr)
 	return ret;
 }
 
+static int rtnl_do_dump_routes(struct socket *rtnl, int family)
+{
+	struct sk_buff *skb = NULL;
+	struct rtmsg *rtm;
+	int flags = NLM_F_ROOT | NLM_F_REQUEST;
+	struct msghdr msg;
+	struct kvec kvec;
+	struct nlmsghdr *nlh;
+	int ret = -ENOMEM;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	nlh = nlmsg_put(skb, 0, 0, RTM_GETROUTE, sizeof(*rtm), flags);
+	if (!nlh)
+		goto out;
+
+	rtm = nlmsg_data(nlh);
+	memset(rtm, 0, sizeof(*rtm));
+	rtm->rtm_family = family;
+
+	nlmsg_end(skb, nlh);
+
+	memset(&msg, 0, sizeof(msg));
+	kvec.iov_len = skb->len;
+	kvec.iov_base = skb->head;
+
+	ret = kernel_sendmsg(rtnl, &msg, &kvec, 1, kvec.iov_len);
+	if ((ret >= 0) && (ret != skb->len))
+		ret = -EIO;
+ out:
+	kfree_skb(skb);
+
+	return ret;
+}
+
+static int rtnl_dump_routes(struct socket *rtnl, int family,
+			    struct sk_buff **skb)
+{
+	int ret = -ENOMEM;
+	long timeo = MAX_SCHEDULE_TIMEOUT;
+
+	*skb = NULL;
+
+	ret = rtnl_do_dump_routes(rtnl, family);
+	if (ret < 0)
+		return ret;
+
+	lock_sock(rtnl->sk);
+	ret = sk_wait_data(rtnl->sk, &timeo);
+	if (ret)
+		*skb = skb_dequeue(&rtnl->sk->sk_receive_queue);
+	release_sock(rtnl->sk);
+	if (!*skb)
+		ret = -EIO;
+
+	return ret;
+}
+
+static int rtnl_process_inet4_route(struct net *net,
+				    struct rtmsg *rtm,
+				    struct nlattr **tb,
+				    struct ckpt_route *route)
+{
+	if (rtm->rtm_type != RTN_UNICAST)
+		return 0; /* skip non-unicast routes */
+
+	route->type = CKPT_ROUTE_IPV4;
+	route->inet4_len = rtm->rtm_dst_len;
+
+	if (tb[RTA_DST])
+		route->inet4_dst = htonl(nla_get_u32(tb[RTA_DST]));
+	if (tb[RTA_GATEWAY]) {
+		route->flags |= CKPT_ROUTE_FLAG_GW;
+		route->inet4_gwy = htonl(nla_get_u32(tb[RTA_GATEWAY]));
+	}
+	if (tb[RTA_PRIORITY])
+		route->inet4_met = nla_get_u32(tb[RTA_PRIORITY]);
+
+	if (tb[RTA_OIF]) {
+		struct net_device *dev;
+
+		dev = dev_get_by_index(net, nla_get_u32(tb[RTA_OIF]));
+		if (dev) {
+			strncpy(route->dev, dev->name, IFNAMSIZ);
+			dev_put(dev);
+		}
+	}
+
+	debug_route(route);
+
+	return 1; /* save this route */
+}
+
+static int rtnl_process_inet6_route(struct net *net,
+				    struct rtmsg *rtm,
+				    struct nlattr **tb,
+				    struct ckpt_route *route)
+{
+	if (rtm->rtm_type != RTN_UNICAST)
+		return 0; /* skip non-unicast routes */
+
+	route->type = CKPT_ROUTE_IPV6;
+	route->inet6_len = rtm->rtm_dst_len;
+
+	if (tb[RTA_DST])
+		ipv6_addr_copy(&route->inet6_dst, nla_data(tb[RTA_DST]));
+	if (tb[RTA_GATEWAY]) {
+		route->flags |= CKPT_ROUTE_FLAG_GW;
+		ipv6_addr_copy(&route->inet6_gwy, nla_data(tb[RTA_GATEWAY]));
+	}
+	if (tb[RTA_PRIORITY])
+		route->inet6_met = nla_get_u32(tb[RTA_PRIORITY]);
+
+	if (tb[RTA_OIF]) {
+		struct net_device *dev;
+
+		dev = dev_get_by_index(net, nla_get_u32(tb[RTA_OIF]));
+		if (dev) {
+			strncpy(route->dev, dev->name, IFNAMSIZ);
+			dev_put(dev);
+		}
+	}
+
+	debug_route(route);
+
+	return 1;
+}
+
+static int rtnl_process_routes(struct net *net,
+			       struct nlmsghdr *nlh, int len,
+			       struct ckpt_route *routes,
+			       int idx, int max)
+{
+	struct nlmsghdr *i;
+
+	for (i = nlh; NLMSG_OK(i, len); i = NLMSG_NEXT(i, len)) {
+		struct ckpt_route *route = &routes[idx];
+		struct rtmsg *rtm = NLMSG_DATA(i);
+		struct nlattr *tb[FRA_MAX+1];
+		int ret;
+
+		if (idx >= max)
+			return -E2BIG;
+
+		if (i->nlmsg_type == NLMSG_DONE)
+			break;
+		else if (nlh->nlmsg_type != RTM_NEWROUTE) {
+			struct nlmsgerr *errmsg = nlmsg_data(nlh);
+			return errmsg->error;
+		}
+
+		ret = nlmsg_parse(i, sizeof(*rtm), tb, FRA_MAX, NULL);
+		if (ret < 0)
+			return ret;
+
+		memset(route, 0, sizeof(*route));
+
+		if (rtm->rtm_family == AF_INET)
+			ret = rtnl_process_inet4_route(net, rtm, tb, route);
+		else if (rtm->rtm_family == AF_INET6)
+			ret = rtnl_process_inet6_route(net, rtm, tb, route);
+		else
+			ret = 0; /* skip */
+		if (ret < 0)
+			return ret;
+		else if (ret)
+			idx += 1;
+	}
+
+	return idx;
+}
+
+static int temp_netns_enter(struct net *net)
+{
+	int ret;
+	struct net *tmp_netns;
+
+	ret = copy_namespaces(CLONE_NEWNET, current);
+	if (ret)
+		return ret;
+
+	tmp_netns = current->nsproxy->net_ns;
+	get_net(net);
+	current->nsproxy->net_ns = net;
+	put_net(tmp_netns);
+
+	return 0;
+}
+
+static void temp_netns_exit(struct nsproxy *prev)
+{
+	switch_task_namespaces(current, prev);
+}
+
+static int rtnl_get_routes(struct net *net, int family,
+			   struct ckpt_route *routes, int idx, int max)
+{
+	int ret;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb = NULL;
+	struct socket *rtnl = NULL;
+	struct nsproxy *prev = current->nsproxy;
+
+	ret = temp_netns_enter(net);
+	if (ret)
+		return ret;
+
+	rtnl = rtnl_open();
+	if (IS_ERR(rtnl)) {
+		ret = PTR_ERR(rtnl);
+		goto out;
+	}
+
+	ret = rtnl_dump_routes(rtnl, family, &skb);
+	if (ret < 0)
+		goto out;
+
+	nlh = nlmsg_hdr(skb);
+	if (!nlh) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = rtnl_process_routes(net, nlh, skb->len, routes, idx, max);
+ out:
+	kfree_skb(skb);
+	rtnl_close(rtnl);
+	temp_netns_exit(prev);
+
+	return ret;
+}
+
+int checkpoint_netns_routes(struct ckpt_ctx *ctx, struct net *net,
+			    struct ckpt_route **_routes)
+{
+	struct ckpt_route *routes = NULL;
+	int max = 32;
+	int idx;
+	int families[] = {AF_INET, AF_INET6, 0};
+	int family;
+ retry:
+	idx = 0;
+	kfree(routes);
+	routes = kmalloc(max * sizeof(*routes), GFP_KERNEL);
+	if (!routes)
+		return -ENOMEM;
+
+	for (family = 0; families[family]; family++) {
+		idx = rtnl_get_routes(net, families[family], routes, idx, max);
+		if (idx == -E2BIG) {
+			max *= 2;
+			goto retry;
+		} else if (idx < 0)
+			break;
+	}
+
+	if (idx < 0) {
+		kfree(routes);
+		routes = NULL;
+		ckpt_err(ctx, idx, "error saving routes\n");
+	}
+	*_routes = routes;
+
+	return idx;
+}
+
 int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr)
 {
 	struct net *net = ptr;
 	struct net_device *dev;
 	struct ckpt_hdr_netns *h;
+	struct ckpt_route *routes = NULL;
 	int ret;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NET_NS);
@@ -264,10 +551,19 @@ int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr)
 	h->this_ref = ckpt_obj_lookup(ctx, net, CKPT_OBJ_NET_NS);
 	BUG_ON(h->this_ref <= 0);
 
+	ret = checkpoint_netns_routes(ctx, net, &routes);
+	if (ret < 0)
+		goto out;
+	h->routes = ret;
+
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 	if (ret < 0)
 		goto out;
 
+	ret = ckpt_write_buffer(ctx, routes, h->routes * sizeof(*routes));
+	if (ret < 0)
+		goto out;
+
 	for_each_netdev(net, dev) {
 		if (dev->netdev_ops->ndo_checkpoint)
 			ret = checkpoint_obj(ctx, dev, CKPT_OBJ_NETDEV);
@@ -284,6 +580,7 @@ int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr)
 	}
  out:
 	ckpt_hdr_put(ctx, h);
+	kfree(routes);
 
 	return ret;
 }
@@ -825,10 +1122,152 @@ void *restore_netdev(struct ckpt_ctx *ctx)
 	return dev;
 }
 
+static int rtnl_restore_route(struct net *net, struct ckpt_route *route)
+{
+	struct sk_buff *skb;
+	struct rtmsg *rtm;
+	int flags = NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
+	struct nlmsghdr *nlh;
+	int ret = 0;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	nlh = nlmsg_put(skb, 0, 0, RTM_NEWROUTE, sizeof(*rtm), flags);
+	if (!nlh) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	rtm = nlmsg_data(nlh);
+	memset(rtm, 0, sizeof(*rtm));
+
+	rtm->rtm_table = RT_TABLE_MAIN;
+	rtm->rtm_protocol = RTPROT_BOOT;
+	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
+	rtm->rtm_type = RTN_UNICAST;
+
+	if (route->dev[0]) {
+		struct net_device *dev;
+
+		dev = dev_get_by_name(net, route->dev);
+		if (!dev) {
+			ckpt_debug("unable to find dev %s for route\n",
+				   route->dev);
+			ret = -EINVAL;
+			goto out;
+		}
+		nla_put_u32(skb, RTA_OIF, dev->ifindex);
+		dev_put(dev);
+	}
+
+	if (route->type == CKPT_ROUTE_IPV4) {
+		rtm->rtm_family = AF_INET;
+		rtm->rtm_dst_len = route->inet4_len;
+
+		nla_put_u32(skb, RTA_DST, ntohl(route->inet4_dst));
+		if (route->flags & CKPT_ROUTE_FLAG_GW)
+			nla_put_u32(skb, RTA_GATEWAY, ntohl(route->inet4_gwy));
+		nla_put_u32(skb, RTA_PRIORITY, route->inet4_met);
+	} else if (route->type == CKPT_ROUTE_IPV6) {
+		int len = sizeof(route->inet6_dst);
+
+		if (ipv6_addr_scope(&route->inet6_dst))
+			goto out; /* Skip non-global scope routes */
+
+		rtm->rtm_family = AF_INET6;
+		rtm->rtm_dst_len = route->inet6_len;
+
+		nla_put(skb, RTA_DST, len, &route->inet6_dst);
+		if (route->flags & CKPT_ROUTE_FLAG_GW)
+			nla_put(skb, RTA_GATEWAY, len, &route->inet6_gwy);
+		nla_put_u32(skb, RTA_PRIORITY, route->inet6_met);
+	} else {
+		ckpt_debug("unsupported route type %i\n", route->type);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	nlmsg_end(skb, nlh);
+
+	debug_route(route);
+
+	ret = rtnl_do(skb);
+ out:
+	kfree_skb(skb);
+	return ret;
+}
+
+static int restore_routes(struct net *net, struct ckpt_route *routes, int count)
+{
+	int i;
+	int ret = 0;
+	struct nsproxy *prev = current->nsproxy;
+
+	ret = temp_netns_enter(net);
+	if (ret)
+		return ret;
+
+	for (i = 0; i < count; i++) {
+		struct ckpt_route *route = &routes[i];
+
+		ret = rtnl_restore_route(net, route);
+		if (ret == -EEXIST)
+			/* Some routes have been implied by device addresses */
+			continue;
+		else if (ret < 0)
+			break;
+	}
+
+	temp_netns_exit(prev);
+
+	return ret;
+}
+
+struct dq_routes {
+	struct ckpt_ctx *ctx;
+	struct net *net;
+	struct ckpt_route *routes;
+	int count;
+};
+
+static int deferred_restore_routes(void *data)
+{
+	struct dq_routes *dq = data;
+	int ret;
+
+	ret = restore_routes(dq->net, dq->routes, dq->count);
+	if (ret < 0)
+		ckpt_err(dq->ctx, ret, "failed to restore routes\n");
+
+	kfree(dq->routes);
+
+	return ret;
+}
+
+static int defer_restore_routes(struct ckpt_ctx *ctx,
+				struct net *net,
+				struct ckpt_route *routes,
+				int count)
+{
+	struct dq_routes dq;
+
+	dq.ctx = ctx;
+	dq.net = net;
+	dq.routes = routes;
+	dq.count = count;
+
+	return deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
+			      deferred_restore_routes, NULL);
+}
+
 void *restore_netns(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_netns *h;
 	struct net *net;
+	struct ckpt_route *routes = NULL;
+	int ret;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_NET_NS);
 	if (IS_ERR(h)) {
@@ -836,12 +1275,34 @@ void *restore_netns(struct ckpt_ctx *ctx)
 		return h;
 	}
 
+	ret = ckpt_read_payload(ctx, (void **)&routes,
+				h->routes * sizeof(*routes), CKPT_HDR_BUFFER);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "Unable to read routes buffer\n");
+		net = ERR_PTR(ret);
+		goto out;
+	}
+
 	if (h->this_ref != 0) {
 		net = copy_net_ns(CLONE_NEWNET, current->nsproxy->net_ns);
 		if (IS_ERR(net))
 			goto out;
-	} else
+
+		ret = defer_restore_routes(ctx, net, routes, h->routes);
+		if (ret < 0) {
+			kfree(routes);
+			put_net(net);
+			net = ERR_PTR(ret);
+		}
+	} else {
+		if (h->routes) {
+			net = ERR_PTR(-EINVAL);
+			ckpt_err(ctx, -EINVAL,
+				 "Parent netns claims to have routes\n");
+			goto out;
+		}
 		net = current->nsproxy->net_ns;
+	}
  out:
 	ckpt_hdr_put(ctx, h);
 
-- 
1.6.2.5
