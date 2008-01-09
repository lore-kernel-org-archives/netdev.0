From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-2.6.25 16/19] [NETNS] Correctly fill fib_config data.
Date: Wed,  9 Jan 2008 21:04:37 +0300
Message-ID: <1199901880-6812-16-git-send-email-den@openvz.org>
References: <47850C57.60907@openvz.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org,
        benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47850C57.60907-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

Acked-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Acked-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> 
Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/ipv4/fib_frontend.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index abe9f43..cecb660 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -305,14 +305,14 @@ static int put_rtax(struct nlattr *mx, int len, int type, u32 value)
 	return len + nla_total_size(4);
 }
 
-static int rtentry_to_fib_config(int cmd, struct rtentry *rt,
+static int rtentry_to_fib_config(struct net *net, int cmd, struct rtentry *rt,
 				 struct fib_config *cfg)
 {
 	__be32 addr;
 	int plen;
 
 	memset(cfg, 0, sizeof(*cfg));
-	cfg->fc_nlinfo.nl_net = &init_net;
+	cfg->fc_nlinfo.nl_net = net;
 
 	if (rt->rt_dst.sa_family != AF_INET)
 		return -EAFNOSUPPORT;
@@ -373,7 +373,7 @@ static int rtentry_to_fib_config(int cmd, struct rtentry *rt,
 		colon = strchr(devname, ':');
 		if (colon)
 			*colon = 0;
-		dev = __dev_get_by_name(&init_net, devname);
+		dev = __dev_get_by_name(net, devname);
 		if (!dev)
 			return -ENODEV;
 		cfg->fc_oif = dev->ifindex;
@@ -396,7 +396,7 @@ static int rtentry_to_fib_config(int cmd, struct rtentry *rt,
 	if (rt->rt_gateway.sa_family == AF_INET && addr) {
 		cfg->fc_gw = addr;
 		if (rt->rt_flags & RTF_GATEWAY &&
-		    inet_addr_type(&init_net, addr) == RTN_UNICAST)
+		    inet_addr_type(net, addr) == RTN_UNICAST)
 			cfg->fc_scope = RT_SCOPE_UNIVERSE;
 	}
 
@@ -453,7 +453,7 @@ int ip_rt_ioctl(unsigned int cmd, void __user *arg)
 			return -EFAULT;
 
 		rtnl_lock();
-		err = rtentry_to_fib_config(cmd, &rt, &cfg);
+		err = rtentry_to_fib_config(&init_net, cmd, &rt, &cfg);
 		if (err == 0) {
 			struct fib_table *tb;
 
@@ -494,8 +494,8 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX+1] = {
 	[RTA_FLOW]		= { .type = NLA_U32 },
 };
 
-static int rtm_to_fib_config(struct sk_buff *skb, struct nlmsghdr *nlh,
-			     struct fib_config *cfg)
+static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
+			    struct nlmsghdr *nlh, struct fib_config *cfg)
 {
 	struct nlattr *attr;
 	int err, remaining;
@@ -519,7 +519,7 @@ static int rtm_to_fib_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	cfg->fc_nlinfo.pid = NETLINK_CB(skb).pid;
 	cfg->fc_nlinfo.nlh = nlh;
-	cfg->fc_nlinfo.nl_net = &init_net;
+	cfg->fc_nlinfo.nl_net = net;
 
 	if (cfg->fc_type > RTN_MAX) {
 		err = -EINVAL;
@@ -575,7 +575,7 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *ar
 	if (net != &init_net)
 		return -EINVAL;
 
-	err = rtm_to_fib_config(skb, nlh, &cfg);
+	err = rtm_to_fib_config(net, skb, nlh, &cfg);
 	if (err < 0)
 		goto errout;
 
@@ -600,7 +600,7 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *ar
 	if (net != &init_net)
 		return -EINVAL;
 
-	err = rtm_to_fib_config(skb, nlh, &cfg);
+	err = rtm_to_fib_config(net, skb, nlh, &cfg);
 	if (err < 0)
 		goto errout;
 
@@ -667,6 +667,7 @@ out:
 
 static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifaddr *ifa)
 {
+	struct net *net = ifa->ifa_dev->dev->nd_net;
 	struct fib_table *tb;
 	struct fib_config cfg = {
 		.fc_protocol = RTPROT_KERNEL,
@@ -677,14 +678,14 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 		.fc_oif = ifa->ifa_dev->dev->ifindex,
 		.fc_nlflags = NLM_F_CREATE | NLM_F_APPEND,
 		.fc_nlinfo = {
-			.nl_net = &init_net,
+			.nl_net = net,
 		},
 	};
 
 	if (type == RTN_UNICAST)
-		tb = fib_new_table(&init_net, RT_TABLE_MAIN);
+		tb = fib_new_table(net, RT_TABLE_MAIN);
 	else
-		tb = fib_new_table(&init_net, RT_TABLE_LOCAL);
+		tb = fib_new_table(net, RT_TABLE_LOCAL);
 
 	if (tb == NULL)
 		return;
-- 
1.5.3.rc5
