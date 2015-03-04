From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 6/7] mpls: Netlink commands to add, remove, and dump routes
Date: Tue, 03 Mar 2015 19:13:56 -0600
Message-ID: <87wq2xsgx7.fsf_-_@x220.int.ebiederm.org>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<87vbihtvts.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60448 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbbCDBRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 20:17:31 -0500
In-Reply-To: <87vbihtvts.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Tue, 03 Mar 2015 19:06:39 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This change adds two new netlink routing attributes:
RTA_VIA and RTA_NEWDST.

RTA_VIA specifies the specifies the next machine to send a packet to
like RTA_GATEWAY.  RTA_VIA differs from RTA_GATEWAY in that it
includes the address family of the address of the next machine to send
a packet to.  Currently the MPLS code supports addresses in AF_INET,
AF_INET6 and AF_PACKET.  For AF_INET and AF_INET6 the destination mac
address is acquired from the neighbour table.  For AF_PACKET the
destination mac_address is specified in the netlink configuration.

I think raw destination mac address support with the family AF_PACKET
will prove useful.  There is MPLS-TP which is defined to operate
on machines that do not support internet packets of any flavor.  Further
seem to be corner cases where it can be useful.  At this point
I don't care much either way.

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
 include/uapi/linux/rtnetlink.h |   8 ++
 net/mpls/af_mpls.c             | 229 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 237 insertions(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 5cc5d66bf519..bad65550ae3e 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -303,6 +303,8 @@ enum rtattr_type_t {
 	RTA_TABLE,
 	RTA_MARK,
 	RTA_MFC_STATS,
+	RTA_VIA,
+	RTA_NEWDST,
 	__RTA_MAX
 };
 
@@ -344,6 +346,12 @@ struct rtnexthop {
 #define RTNH_SPACE(len)	RTNH_ALIGN(RTNH_LENGTH(len))
 #define RTNH_DATA(rtnh)   ((struct rtattr*)(((char*)(rtnh)) + RTNH_LENGTH(0)))
 
+/* RTA_VIA */
+struct rtvia {
+	__kernel_sa_family_t	rtvia_family;
+	__u8			rtvia_addr[0];
+};
+
 /* RTM_CACHEINFO */
 
 struct rta_cacheinfo {
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 2d6612a10e30..b4d7cec398d2 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -212,6 +212,11 @@ static struct packet_type mpls_packet_type __read_mostly = {
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
@@ -410,6 +415,22 @@ static struct notifier_block mpls_dev_notifier = {
 	.notifier_call = mpls_dev_notify,
 };
 
+static int nla_put_via(struct sk_buff *skb,
+		       u16 family, const void *addr, int alen)
+{
+	struct nlattr *nla;
+	struct rtvia *via;
+
+	nla = nla_reserve(skb, RTA_VIA, alen + 2);
+	if (!nla)
+		return -EMSGSIZE;
+
+	via = nla_data(nla);
+	via->rtvia_family = family;
+	memcpy(via->rtvia_addr, addr, alen);
+	return 0;
+}
+
 int nla_put_labels(struct sk_buff *skb, int attrtype,
 		   u8 labels, const u32 label[])
 {
@@ -467,6 +488,210 @@ int nla_get_labels(const struct nlattr *nla,
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
+		case RTA_VIA:
+		{
+			struct rtvia *via = nla_data(nla);
+			cfg->rc_via_family = via->rtvia_family;
+			cfg->rc_via_alen   = nla_len(nla) - 2;
+			if (cfg->rc_via_alen > MAX_VIA_ALEN)
+				goto errout;
+
+			/* Validate the address family */
+			switch(cfg->rc_via_family) {
+			case AF_PACKET:
+				break;
+			case AF_INET:
+				if (cfg->rc_via_alen != 4)
+					goto errout;
+				break;
+			case AF_INET6:
+				if (cfg->rc_via_alen != 16)
+					goto errout;
+				break;
+			default:
+				/* Unsupported address family */
+				goto errout;
+			}
+
+			memcpy(cfg->rc_via, via->rtvia_addr, cfg->rc_via_alen);
+			break;
+		}
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
+	if (nla_put_via(skb, rt->rt_via_family, rt->rt_via, rt->rt_via_alen))
+		goto nla_put_failure;
+	if (rt->rt_dev && nla_put_u32(skb, RTA_OIF, rt->rt_dev->ifindex))
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
@@ -662,6 +887,9 @@ static int __init mpls_init(void)
 
 	dev_add_pack(&mpls_packet_type);
 
+	rtnl_register(PF_MPLS, RTM_NEWROUTE, mpls_rtm_newroute, NULL, NULL);
+	rtnl_register(PF_MPLS, RTM_DELROUTE, mpls_rtm_delroute, NULL, NULL);
+	rtnl_register(PF_MPLS, RTM_GETROUTE, NULL, mpls_dump_routes, NULL);
 	err = 0;
 out:
 	return err;
@@ -674,6 +902,7 @@ module_init(mpls_init);
 
 static void __exit mpls_exit(void)
 {
+	rtnl_unregister_all(PF_MPLS);
 	dev_remove_pack(&mpls_packet_type);
 	unregister_netdevice_notifier(&mpls_dev_notifier);
 	unregister_pernet_subsys(&mpls_net_ops);
-- 
2.2.1
