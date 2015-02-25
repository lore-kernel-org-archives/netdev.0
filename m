From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 6/8] mpls: Netlink commands to add, remove, and dump routes
Date: Wed, 25 Feb 2015 11:17:16 -0600
Message-ID: <87r3tdvrkz.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55912 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929AbbBYRV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:21:27 -0500
In-Reply-To: <87pp8xx6ik.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 25 Feb 2015 11:09:23 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This change adds two new netlink routing attributes:
RTA_LLGATEWAY and RTA_NEWDST.

RTA_LLGATEWAY specifies the destination gateway by it's address in the
underlying address family instead of in MPLS as RTA_GATEWAY would
require.  That is RTA_LLGATEWAY allows specifying the next hop by the
next hops' mac address.

There are places where MPLS is used where the next hop address can not
be specified as an IPv4 or an IPv6 address and this allows me to avoid
figuring out how to teach the neighbour table to deal with next hops
in a different address family.  I expect at some point someone will
add suppport for next hop addresesses as IPv4 and IPv6 addresses as
that allows replacing the next hop machine without having to
reconfigure the rest of the network.

RTA_NEWDST specifies the destination address to forward the packet
with.  MPLS typically changes it's destination address at every hop.
For a swap operation RTA_NEWDST is specified with a length of one label.
For a push operation RTA_NEWDST is specified with two or more labels.
For a pop operation RTA_NEWDST is not specified or equivalently an emtpy
RTAN_NEWDST is specified.

Those new netlink attributes are used to implement handling of rt-netlink
RTM_NEWROUTE, RTM_DELROUTE, and RTM_GETROUTE messages, to maintain the
MPLS label table.

rtm_to_route_config parses a netlink RTM_NEWROUTE or RTM_DELROUTE message,
verify no unhandled attributes or unhandled values are present and sets
up the data structures for mpls_route_add and mpls_route_del.

I did my best to match up with the existing conventions with the caveats
that MPLS addresses are all destination-specific-addresses, and so
don't properly have a scope.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/uapi/linux/rtnetlink.h |   2 +
 net/mpls/af_mpls.c             | 192 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 194 insertions(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 5cc5d66bf519..da9889a4dec0 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -303,6 +303,8 @@ enum rtattr_type_t {
 	RTA_TABLE,
 	RTA_MARK,
 	RTA_MFC_STATS,
+	RTA_LLGATEWAY,
+	RTA_NEWDST,
 	__RTA_MAX
 };
 
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 75f24609f297..5cf9aa68c32f 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -206,6 +206,11 @@ static struct packet_type mpls_packet_type __read_mostly = {
 	.func = mpls_forward,
 };
 
+const struct nla_policy rtm_mpls_policy[RTA_MAX+1] = {
+	[RTA_DST]		= { .type = NLA_U32 },
+	[RTA_OIF]		= { .type = NLA_U32 },
+};
+
 struct mpls_route_config {
 	u32		rc_protocol;
 	u32		rc_ifindex;
@@ -455,6 +460,189 @@ int nla_get_labels(const struct nlattr *nla,
 	return 0;
 }
 
+static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
+			       struct mpls_route_config *cfg)
+{
+	struct rtmsg *rtm;
+	struct nlattr *tb[RTA_MAX+1];
+	int index;
+	int err;
+
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_mpls_policy);
+	if (err < 0)
+		goto errout;
+
+	err = -EINVAL;
+	rtm = nlmsg_data(nlh);
+	memset(cfg, 0, sizeof(*cfg));
+
+	if (rtm->rtm_family != AF_MPLS)
+		goto errout;
+	if (rtm->rtm_dst_len != 20)
+		goto errout;
+	if (rtm->rtm_src_len != 0)
+		goto errout;
+	if (rtm->rtm_tos != 0)
+		goto errout;
+	if (rtm->rtm_table != RT_TABLE_MAIN)
+		goto errout;
+	/* Any value is acceptable for rtm_protocol */
+
+	/* As mpls uses destination specific addresses
+	 * (or source specific address in the case of multicast)
+	 * all addresses have universal scope.
+	 */
+	if (rtm->rtm_scope != RT_SCOPE_UNIVERSE)
+		goto errout;
+	if (rtm->rtm_type != RTN_UNICAST)
+		goto errout;
+	if (rtm->rtm_flags != 0)
+		goto errout;
+
+	cfg->rc_label		= LABEL_NOT_SPECIFIED;
+	cfg->rc_protocol	= rtm->rtm_protocol;
+	cfg->rc_nlflags		= nlh->nlmsg_flags;
+	cfg->rc_nlinfo.portid	= NETLINK_CB(skb).portid;
+	cfg->rc_nlinfo.nlh	= nlh;
+	cfg->rc_nlinfo.nl_net	= sock_net(skb->sk);
+
+	for (index = 0; index <= RTA_MAX; index++) {
+		struct nlattr *nla = tb[index];
+		if (!nla)
+			continue;
+
+		switch(index) {
+		case RTA_OIF:
+			cfg->rc_ifindex = nla_get_u32(nla);
+			break;
+		case RTA_NEWDST:
+			if (nla_get_labels(nla, MAX_NEW_LABELS,
+					   &cfg->rc_output_labels,
+					   cfg->rc_output_label))
+				goto errout;
+			break;
+		case RTA_DST:
+		{
+			u32 label_count;
+			if (nla_get_labels(nla, 1, &label_count,
+					   &cfg->rc_label))
+				goto errout;
+
+			/* The first 16 labels are reserved, and may not be set */
+			if (cfg->rc_label < 16)
+				goto errout;
+
+			break;
+		}
+		case RTA_LLGATEWAY:
+			cfg->rc_ha_len = nla_len(nla);
+			if (cfg->rc_ha_len > MAX_HA_LEN)
+				goto errout;
+
+			memcpy(cfg->rc_ha, nla_data(nla), cfg->rc_ha_len);
+			break;
+		default:
+			/* Unsupported attribute */
+			goto errout;
+		}
+	}
+
+	err = 0;
+errout:
+	return err;
+}
+
+static int mpls_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	struct mpls_route_config cfg;
+	int err;
+
+	err = rtm_to_route_config(skb, nlh, &cfg);
+	if (err < 0)
+		return err;
+
+	return mpls_route_del(&cfg);
+}
+
+
+static int mpls_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	struct mpls_route_config cfg;
+	int err;
+
+	err = rtm_to_route_config(skb, nlh, &cfg);
+	if (err < 0)
+		return err;
+
+	return mpls_route_add(&cfg);
+}
+
+static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
+			   u32 label, struct mpls_route *rt, int flags)
+{
+	struct nlmsghdr *nlh;
+	struct rtmsg *rtm;
+
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*rtm), flags);
+	if (nlh == NULL)
+		return -EMSGSIZE;
+
+	rtm = nlmsg_data(nlh);
+	rtm->rtm_family = AF_MPLS;
+	rtm->rtm_dst_len = 20;
+	rtm->rtm_src_len = 0;
+	rtm->rtm_tos = 0;
+	rtm->rtm_table = RT_TABLE_MAIN;
+	rtm->rtm_protocol = rt->rt_protocol;
+	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
+	rtm->rtm_type = RTN_UNICAST;
+	rtm->rtm_flags = 0;
+
+	if (rt->rt_labels &&
+	    nla_put_labels(skb, RTA_NEWDST, rt->rt_labels, rt->rt_label))
+		goto nla_put_failure;
+	if (nla_put(skb, RTA_LLGATEWAY, rt->rt_dev->addr_len, rt->rt_ha))
+		goto nla_put_failure;
+	if (nla_put_u32(skb, RTA_OIF, rt->rt_dev->ifindex))
+		goto nla_put_failure;
+	if (nla_put_labels(skb, RTA_DST, 1, &label))
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+	return 0;
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static int mpls_dump_routes(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	unsigned int index;
+
+	ASSERT_RTNL();
+
+	index = cb->args[0];
+	if (index < 16)
+		index = 16;
+
+	for (; index < net->mpls.platform_labels; index++) {
+		struct mpls_route *rt;
+		rt = net->mpls.platform_label[index];
+		if (!rt)
+			continue;
+
+		if (mpls_dump_route(skb, NETLINK_CB(cb->skb).portid,
+				    cb->nlh->nlmsg_seq, RTM_NEWROUTE,
+				    index, rt, NLM_F_MULTI) < 0)
+			break;
+	}
+	cb->args[0] = index;
+
+	return skb->len;
+}
+
 static int resize_platform_label_table(struct net *net, size_t limit)
 {
 	size_t size = sizeof(struct mpls_route *) * limit;
@@ -644,6 +832,9 @@ static int __init mpls_init(void)
 
 	dev_add_pack(&mpls_packet_type);
 
+	rtnl_register(PF_MPLS, RTM_NEWROUTE, mpls_rtm_newroute, NULL, NULL);
+	rtnl_register(PF_MPLS, RTM_DELROUTE, mpls_rtm_delroute, NULL, NULL);
+	rtnl_register(PF_MPLS, RTM_GETROUTE, NULL, mpls_dump_routes, NULL);
 	err = 0;
 out:
 	return err;
@@ -656,6 +847,7 @@ module_init(mpls_init);
 
 static void __exit mpls_exit(void)
 {
+	rtnl_unregister_all(PF_MPLS);
 	dev_remove_pack(&mpls_packet_type);
 	unregister_netdevice_notifier(&mpls_dev_notifier);
 	unregister_pernet_subsys(&mpls_net_ops);
-- 
2.2.1
