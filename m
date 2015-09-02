From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] ipv6: fix multipath route replace error recovery
Date: Tue,  1 Sep 2015 22:54:00 -0700
Message-ID: <1441173240-21826-1-git-send-email-roopa@cumulusnetworks.com>
Cc: Mazziesaccount@gmail.com, hannes@stressinduktion.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33149 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbbIBFyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 01:54:05 -0400
Received: by paap5 with SMTP id p5so13495179paa.0
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 22:54:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Problem:
The ecmp route replace support for ipv6 in the kernel, deletes the
existing ecmp route too early, ie when it installs the first nexthop.
If there is an error in installing the subsequent nexthops, its too late
to recover the already deleted existing route

This patch fixes the problem with the following:
a) Changes the existing multipath route add code to a two stage process:
  build rt6_infos + insert them
	ip6_route_add rt6_info creation code is moved into
	ip6_route_info_create.
b) This ensures that all errors are caught during building rt6_infos
  and we fail early
c) Separates multipath add and del code. Because add needs the special
  two stage mode in a) and delete essentially does not care.
d) In any event if the code fails during inserting a route again, a
  warning is printed (This should be unlikely)

Before the patch:
$ip -6 route show
3000:1000:1000:1000::2 via fe80::202:ff:fe00:b dev swp49s0 metric 1024
3000:1000:1000:1000::2 via fe80::202:ff:fe00:d dev swp49s1 metric 1024
3000:1000:1000:1000::2 via fe80::202:ff:fe00:f dev swp49s2 metric 1024

/* Try replacing the route with a duplicate nexthop */
$ip -6 route change 3000:1000:1000:1000::2/128 nexthop via
fe80::202:ff:fe00:b dev swp49s0 nexthop via fe80::202:ff:fe00:d dev
swp49s1 nexthop via fe80::202:ff:fe00:d dev swp49s1
RTNETLINK answers: File exists

$ip -6 route show
/* previously added ecmp route 3000:1000:1000:1000::2 dissappears from
 * kernel */

After the patch:
$ip -6 route show
3000:1000:1000:1000::2 via fe80::202:ff:fe00:b dev swp49s0 metric 1024
3000:1000:1000:1000::2 via fe80::202:ff:fe00:d dev swp49s1 metric 1024
3000:1000:1000:1000::2 via fe80::202:ff:fe00:f dev swp49s2 metric 1024

/* Try replacing the route with a duplicate nexthop */
$ip -6 route change 3000:1000:1000:1000::2/128 nexthop via
fe80::202:ff:fe00:b dev swp49s0 nexthop via fe80::202:ff:fe00:d dev
swp49s1 nexthop via fe80::202:ff:fe00:d dev swp49s1
RTNETLINK answers: File exists

$ip -6 route show
3000:1000:1000:1000::2 via fe80::202:ff:fe00:b dev swp49s0 metric 1024
3000:1000:1000:1000::2 via fe80::202:ff:fe00:d dev swp49s1 metric 1024
3000:1000:1000:1000::2 via fe80::202:ff:fe00:f dev swp49s2 metric 1024

Fixes: 4a287eba2de3 ("IPv6 routing, NLM_F_* flag support: REPLACE and EXCL flags support, warn about missing CREATE flag")
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
This bug is present in 4.1 kernel and 4.2 too.
Since 4.2 is out or almost out, I am submitting the patch against net-next.
I can respin against net if needed. The part of the patch that I would appreciate
more eyes on is the cleanup of the rt6_infos in ip_route_multipath_add. And
I have tried to keep the changes local to route.c closer to the netlink
message handling. Most of the code changes are moving code into separate
functions.

 net/ipv6/route.c | 205 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 179 insertions(+), 26 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f45cac6..b1b8c96 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1748,7 +1748,7 @@ static int ip6_convert_metrics(struct mx6_config *mxc,
 	return -EINVAL;
 }
 
-int ip6_route_add(struct fib6_config *cfg)
+int ip6_route_info_create(struct fib6_config *cfg, struct rt6_info **rt_ret)
 {
 	int err;
 	struct net *net = cfg->fc_nlinfo.nl_net;
@@ -1756,7 +1756,6 @@ int ip6_route_add(struct fib6_config *cfg)
 	struct net_device *dev = NULL;
 	struct inet6_dev *idev = NULL;
 	struct fib6_table *table;
-	struct mx6_config mxc = { .mx = NULL, };
 	int addr_type;
 
 	if (cfg->fc_dst_len > 128 || cfg->fc_src_len > 128)
@@ -1981,6 +1980,32 @@ install_route:
 
 	cfg->fc_nlinfo.nl_net = dev_net(dev);
 
+	*rt_ret = rt;
+
+	return 0;
+out:
+	if (dev)
+		dev_put(dev);
+	if (idev)
+		in6_dev_put(idev);
+	if (rt)
+		dst_free(&rt->dst);
+
+	*rt_ret = NULL;
+
+	return err;
+}
+
+int ip6_route_add(struct fib6_config *cfg)
+{
+	struct mx6_config mxc = { .mx = NULL, };
+	struct rt6_info *rt = NULL;
+	int err;
+
+	err = ip6_route_info_create(cfg, &rt);
+	if (err)
+		goto out;
+
 	err = ip6_convert_metrics(&mxc, cfg);
 	if (err)
 		goto out;
@@ -1988,14 +2013,12 @@ install_route:
 	err = __ip6_ins_rt(rt, &cfg->fc_nlinfo, &mxc);
 
 	kfree(mxc.mx);
+
 	return err;
 out:
-	if (dev)
-		dev_put(dev);
-	if (idev)
-		in6_dev_put(idev);
 	if (rt)
 		dst_free(&rt->dst);
+
 	return err;
 }
 
@@ -2776,19 +2799,79 @@ errout:
 	return err;
 }
 
-static int ip6_route_multipath(struct fib6_config *cfg, int add)
+struct rt6_nh {
+	struct rt6_info *rt6_info;
+	struct fib6_config r_cfg;
+	struct mx6_config mxc;
+	struct list_head next;
+};
+
+static void ip6_print_replace_route_err(struct list_head *rt6_nh_list)
+{
+	struct rt6_nh *nh;
+	char *errstr = "IPV6: unexpected error replacing route";
+
+	list_for_each_entry(nh, rt6_nh_list, next) {
+		printk(KERN_WARNING "%s: %pI6 nexthop %pI6 ifi %d\n",
+		       errstr, &nh->r_cfg.fc_dst, &nh->r_cfg.fc_gateway,
+		       nh->r_cfg.fc_ifindex);
+	}
+}
+
+static int ip6_route_info_append(struct list_head *rt6_nh_list,
+				 struct rt6_info *rt, struct fib6_config *r_cfg)
+{
+	struct rt6_nh *nh;
+	struct rt6_info *rtnh;
+	int err = -EEXIST;
+
+	list_for_each_entry(nh, rt6_nh_list, next) {
+		/* check if rt6_info already exists */
+		rtnh = nh->rt6_info;
+
+		if (rtnh->dst.dev == rt->dst.dev &&
+		    rtnh->rt6i_idev == rt->rt6i_idev &&
+		    ipv6_addr_equal(&rtnh->rt6i_gateway,
+				    &rt->rt6i_gateway))
+			return err;
+	}
+
+	nh = kzalloc(sizeof(*nh), GFP_KERNEL);
+	if (!nh)
+		return -ENOMEM;
+	nh->rt6_info = rt;
+	err = ip6_convert_metrics(&nh->mxc, r_cfg);
+	if (err) {
+		kfree(nh);
+		return err;
+	}
+	memcpy(&nh->r_cfg, r_cfg, sizeof(*r_cfg));
+	list_add_tail(&nh->next, rt6_nh_list);
+
+	return 0;
+}
+
+static int ip6_route_multipath_add(struct fib6_config *cfg)
 {
 	struct fib6_config r_cfg;
 	struct rtnexthop *rtnh;
+	struct rt6_info *rt;
+	struct rt6_nh *err_nh;
+	struct rt6_nh *nh, *nh_safe;
 	int remaining;
 	int attrlen;
-	int err = 0, last_err = 0;
+	int err = 1;
+	int nhn = 0;
+	int replace = (cfg->fc_nlinfo.nlh &&
+		       (cfg->fc_nlinfo.nlh->nlmsg_flags & NLM_F_REPLACE));
+	LIST_HEAD(rt6_nh_list);
 
 	remaining = cfg->fc_mp_len;
-beginning:
 	rtnh = (struct rtnexthop *)cfg->fc_mp;
 
-	/* Parse a Multipath Entry */
+	/* Parse a Multipath Entry and build a list (rt6_nh_list) of
+	 * rt6_info structs per nexthop
+	 */
 	while (rtnh_ok(rtnh, remaining)) {
 		memcpy(&r_cfg, cfg, sizeof(*cfg));
 		if (rtnh->rtnh_ifindex)
@@ -2808,22 +2891,30 @@ beginning:
 			if (nla)
 				r_cfg.fc_encap_type = nla_get_u16(nla);
 		}
-		err = add ? ip6_route_add(&r_cfg) : ip6_route_del(&r_cfg);
+
+		err = ip6_route_info_create(&r_cfg, &rt);
+		if (err)
+			goto cleanup;
+
+		err = ip6_route_info_append(&rt6_nh_list, rt, &r_cfg);
+		if (err)
+			goto cleanup;
+
+		rtnh = rtnh_next(rtnh, &remaining);
+	}
+
+	err_nh = NULL;
+	list_for_each_entry(nh, &rt6_nh_list, next) {
+		err = __ip6_ins_rt(nh->rt6_info, &cfg->fc_nlinfo, &nh->mxc);
+		/* nh->rt6_info is used or freed at this point, reset to NULL*/
+		nh->rt6_info = NULL;
 		if (err) {
-			last_err = err;
-			/* If we are trying to remove a route, do not stop the
-			 * loop when ip6_route_del() fails (because next hop is
-			 * already gone), we should try to remove all next hops.
-			 */
-			if (add) {
-				/* If add fails, we should try to delete all
-				 * next hops that have been already added.
-				 */
-				add = 0;
-				remaining = cfg->fc_mp_len - remaining;
-				goto beginning;
-			}
+			if (replace && nhn)
+				ip6_print_replace_route_err(&rt6_nh_list);
+			err_nh = nh;
+			goto add_errout;
 		}
+
 		/* Because each route is added like a single route we remove
 		 * these flags after the first nexthop: if there is a collision,
 		 * we have already failed to add the first nexthop:
@@ -2833,6 +2924,68 @@ beginning:
 		 */
 		cfg->fc_nlinfo.nlh->nlmsg_flags &= ~(NLM_F_EXCL |
 						     NLM_F_REPLACE);
+		nhn++;
+	}
+
+	goto cleanup;
+
+add_errout:
+	/* Delete routes that were already added */
+	list_for_each_entry(nh, &rt6_nh_list, next) {
+		if (err_nh == nh)
+			break;
+		ip6_route_del(&nh->r_cfg);
+	}
+
+cleanup:
+	list_for_each_entry_safe(nh, nh_safe, &rt6_nh_list, next) {
+		if (nh->rt6_info) {
+			struct rt6_info *r = nh->rt6_info;
+
+			if (r->rt6i_idev)
+				in6_dev_put(r->rt6i_idev);
+			dst_free(&r->dst);
+		}
+		if (nh->mxc.mx)
+			kfree(nh->mxc.mx);
+		list_del(&nh->next);
+		kfree(nh);
+	}
+
+	return err;
+}
+
+static int ip6_route_multipath_del(struct fib6_config *cfg)
+{
+	struct fib6_config r_cfg;
+	struct rtnexthop *rtnh;
+	int remaining;
+	int attrlen;
+	int err = 1, last_err = 0;
+
+	remaining = cfg->fc_mp_len;
+	rtnh = (struct rtnexthop *)cfg->fc_mp;
+
+	/* Parse a Multipath Entry */
+	while (rtnh_ok(rtnh, remaining)) {
+		memcpy(&r_cfg, cfg, sizeof(*cfg));
+		if (rtnh->rtnh_ifindex)
+			r_cfg.fc_ifindex = rtnh->rtnh_ifindex;
+
+		attrlen = rtnh_attrlen(rtnh);
+		if (attrlen > 0) {
+			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
+
+			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
+			if (nla) {
+				nla_memcpy(&r_cfg.fc_gateway, nla, 16);
+				r_cfg.fc_flags |= RTF_GATEWAY;
+			}
+		}
+		err = ip6_route_del(&r_cfg);
+		if (err)
+			last_err = err;
+
 		rtnh = rtnh_next(rtnh, &remaining);
 	}
 
@@ -2849,7 +3002,7 @@ static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return err;
 
 	if (cfg.fc_mp)
-		return ip6_route_multipath(&cfg, 0);
+		return ip6_route_multipath_del(&cfg);
 	else
 		return ip6_route_del(&cfg);
 }
@@ -2864,7 +3017,7 @@ static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return err;
 
 	if (cfg.fc_mp)
-		return ip6_route_multipath(&cfg, 1);
+		return ip6_route_multipath_add(&cfg);
 	else
 		return ip6_route_add(&cfg);
 }
-- 
1.9.1
