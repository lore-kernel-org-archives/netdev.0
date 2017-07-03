From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] mpls: route get support
Date: Mon,  3 Jul 2017 15:31:21 -0700
Message-ID: <1499121081-57905-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, dsahern@gmail.com, rshearma@brocade.com,
        nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:35923 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752781AbdGCWb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 18:31:26 -0400
Received: by mail-pg0-f46.google.com with SMTP id u62so100675623pgb.3
        for <netdev@vger.kernel.org>; Mon, 03 Jul 2017 15:31:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds RTM_GETROUTE doit handler for mpls routes.

Input:
RTA_DST - input label
RTA_NEWDST - labels in packet for multipath selection

By default the getroute handler returns matched
nexthop label, via and oif

With RTM_F_FIB_MATCH flag, full matched route is
returned.

example (with patched iproute2):
$ip -f mpls route show
101
        nexthop as to 102/103 via inet 172.16.2.2 dev virt1-2
        nexthop as to 302/303 via inet 172.16.12.2 dev virt1-12
201
        nexthop as to 202/203 via inet6 2001:db8:2::2 dev virt1-2
        nexthop as to 402/403 via inet6 2001:db8:12::2 dev virt1-12

$ip -f mpls route get 103
RTNETLINK answers: Network is unreachable

$ip -f mpls route get 101
101 as to 102/103 via inet 172.16.2.2 dev virt1-2

$ip -f mpls route get as to 302/303 101
101 as to 302/303 via inet 172.16.12.2 dev virt1-12

$ip -f mpls route get fibmatch 103
RTNETLINK answers: Network is unreachable

$ip -f mpls route get fibmatch 101
101
        nexthop as to 102/103 via inet 172.16.2.2 dev virt1-2
        nexthop as to 302/303 via inet 172.16.12.2 dev virt1-12

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 162 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 161 insertions(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 554daf3..4b6ff85 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -2110,6 +2110,166 @@ static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
 		rtnl_set_sk_err(net, RTNLGRP_MPLS_ROUTE, err);
 }
 
+static int mpls_getroute(struct sk_buff *in_skb, struct nlmsghdr *in_nlh,
+			 struct netlink_ext_ack *extack)
+{
+	struct net *net = sock_net(in_skb->sk);
+	u32 portid = NETLINK_CB(in_skb).portid;
+	struct nlattr *tb[RTA_MAX + 1];
+	u32 labels[MAX_NEW_LABELS];
+	struct mpls_shim_hdr *hdr;
+	unsigned int hdr_size = 0;
+	struct net_device *dev;
+	struct mpls_route *rt;
+	struct rtmsg *rtm, *r;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	struct mpls_nh *nh;
+	int err = -EINVAL;
+	u32 in_label;
+	u8 n_labels;
+
+	err = nlmsg_parse(in_nlh, sizeof(*rtm), tb, RTA_MAX,
+			  rtm_ipv4_policy, extack);
+	if (err < 0)
+		goto errout;
+
+	rtm = nlmsg_data(in_nlh);
+
+	if (tb[RTA_DST]) {
+		u8 label_count;
+
+		if (nla_get_labels(tb[RTA_DST], 1, &label_count,
+				   &in_label, extack))
+			goto errout;
+
+		if (in_label < MPLS_LABEL_FIRST_UNRESERVED)
+			goto errout;
+	}
+
+	rt = mpls_route_input_rcu(net, in_label);
+	if (!rt) {
+		err = -ENETUNREACH;
+		goto errout;
+	}
+
+	if (rtm->rtm_flags & RTM_F_FIB_MATCH) {
+		skb = nlmsg_new(lfib_nlmsg_size(rt), GFP_KERNEL);
+		if (!skb) {
+			err = -ENOBUFS;
+			goto errout;
+		}
+
+		err = mpls_dump_route(skb, portid, in_nlh->nlmsg_seq,
+				      RTM_NEWROUTE, in_label, rt, 0);
+		if (err < 0) {
+			/* -EMSGSIZE implies BUG in lfib_nlmsg_size */
+			WARN_ON(err == -EMSGSIZE);
+			goto errout_free;
+		}
+
+		return rtnl_unicast(skb, net, portid);
+	}
+
+	if (tb[RTA_NEWDST]) {
+		if (nla_get_labels(tb[RTA_NEWDST], MAX_NEW_LABELS, &n_labels,
+				   labels, extack) != 0) {
+			err = -EINVAL;
+			goto errout;
+		}
+
+		hdr_size = n_labels * sizeof(struct mpls_shim_hdr);
+	}
+
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!skb) {
+		err = -ENOBUFS;
+		goto errout;
+	}
+
+	skb->protocol = htons(ETH_P_MPLS_UC);
+
+	if (hdr_size) {
+		bool bos;
+		int i;
+
+		if (skb_cow(skb, hdr_size)) {
+			err = -ENOBUFS;
+			goto errout_free;
+		}
+
+		skb_reserve(skb, hdr_size);
+		skb_push(skb, hdr_size);
+		skb_reset_network_header(skb);
+
+		/* Push new labels */
+		hdr = mpls_hdr(skb);
+		bos = true;
+		for (i = n_labels - 1; i >= 0; i--) {
+			hdr[i] = mpls_entry_encode(labels[i],
+						   1, 0, bos);
+			bos = false;
+		}
+	}
+
+	nh = mpls_select_multipath(rt, skb);
+	if (!nh) {
+		err = -ENETUNREACH;
+		goto errout_free;
+	}
+
+	if (hdr_size) {
+		skb_pull(skb, hdr_size);
+		skb_reset_network_header(skb);
+	}
+
+	nlh = nlmsg_put(skb, portid, in_nlh->nlmsg_seq,
+			RTM_NEWROUTE, sizeof(*r), 0);
+	if (!nlh) {
+		err = -EMSGSIZE;
+		goto errout_free;
+	}
+
+	r = nlmsg_data(nlh);
+	r->rtm_family	 = AF_MPLS;
+	r->rtm_dst_len	= 20;
+	r->rtm_src_len	= 0;
+	r->rtm_table	= RT_TABLE_MAIN;
+	r->rtm_type	= RTN_UNICAST;
+	r->rtm_scope	= RT_SCOPE_UNIVERSE;
+	r->rtm_protocol = rt->rt_protocol;
+	r->rtm_flags	= 0;
+
+	if (nla_put_labels(skb, RTA_DST, 1, &in_label))
+		goto nla_put_failure;
+
+	if (nh->nh_labels &&
+	    nla_put_labels(skb, RTA_NEWDST, nh->nh_labels,
+			   nh->nh_label))
+		goto nla_put_failure;
+
+	if (nh->nh_via_table != MPLS_NEIGH_TABLE_UNSPEC &&
+	    nla_put_via(skb, nh->nh_via_table, mpls_nh_via(rt, nh),
+			nh->nh_via_alen))
+		goto nla_put_failure;
+	dev = rtnl_dereference(nh->nh_dev);
+	if (dev && nla_put_u32(skb, RTA_OIF, dev->ifindex))
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+
+	err = rtnl_unicast(skb, net, portid);
+errout:
+	return err;
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	err = -EMSGSIZE;
+errout_free:
+	kfree_skb(skb);
+	return err;
+}
+
 static int resize_platform_label_table(struct net *net, size_t limit)
 {
 	size_t size = sizeof(struct mpls_route *) * limit;
@@ -2356,7 +2516,7 @@ static int __init mpls_init(void)
 
 	rtnl_register(PF_MPLS, RTM_NEWROUTE, mpls_rtm_newroute, NULL, NULL);
 	rtnl_register(PF_MPLS, RTM_DELROUTE, mpls_rtm_delroute, NULL, NULL);
-	rtnl_register(PF_MPLS, RTM_GETROUTE, NULL, mpls_dump_routes,
+	rtnl_register(PF_MPLS, RTM_GETROUTE, mpls_getroute, mpls_dump_routes,
 		      NULL);
 	rtnl_register(PF_MPLS, RTM_GETNETCONF, mpls_netconf_get_devconf,
 		      mpls_netconf_dump_devconf, NULL);
-- 
1.9.1
