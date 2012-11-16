From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 05/17] net: Push capable(CAP_NET_ADMIN) into the rtnl
	methods
Date: Fri, 16 Nov 2012 05:03:00 -0800
Message-ID: <1353070992-5552-5-git-send-email-ebiederm@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
	<1353070992-5552-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353070992-5552-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- In rtnetlink_rcv_msg convert the capable(CAP_NET_ADMIN) check
  to ns_capable(net->user-ns, CAP_NET_ADMIN).  Allowing unprivileged
  users to make netlink calls to modify their local network
  namespace.

- In the rtnetlink doit methods add capable(CAP_NET_ADMIN) so
  that calls that are not safe for unprivileged users are still
  protected.

Later patches will remove the extra capable calls from methods
that are safe for unprivilged users.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/bridge/br_netlink.c |    3 +++
 net/can/gw.c            |    6 ++++++
 net/core/fib_rules.c    |    6 ++++++
 net/core/neighbour.c    |    9 +++++++++
 net/core/rtnetlink.c    |   17 ++++++++++++++++-
 net/dcb/dcbnl.c         |    3 +++
 net/decnet/dn_dev.c     |    6 ++++++
 net/decnet/dn_fib.c     |    6 ++++++
 net/ipv4/devinet.c      |    6 ++++++
 net/ipv4/fib_frontend.c |    6 ++++++
 net/ipv6/addrconf.c     |    6 ++++++
 net/ipv6/addrlabel.c    |    3 +++
 net/ipv6/route.c        |    6 ++++++
 net/phonet/pn_netlink.c |    6 ++++++
 net/sched/act_api.c     |    3 +++
 net/sched/cls_api.c     |    2 ++
 net/sched/sch_api.c     |    9 +++++++++
 17 files changed, 102 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 093f527..251d558 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -153,6 +153,9 @@ static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 	struct net_bridge_port *p;
 	u8 new_state;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (nlmsg_len(nlh) < sizeof(*ifm))
 		return -EINVAL;
 
diff --git a/net/can/gw.c b/net/can/gw.c
index 1f5c978..574dda7 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -751,6 +751,9 @@ static int cgw_create_job(struct sk_buff *skb,  struct nlmsghdr *nlh,
 	struct cgw_job *gwj;
 	int err = 0;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (nlmsg_len(nlh) < sizeof(*r))
 		return -EINVAL;
 
@@ -839,6 +842,9 @@ static int cgw_remove_job(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 	struct can_can_gw ccgw;
 	int err = 0;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (nlmsg_len(nlh) < sizeof(*r))
 		return -EINVAL;
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 58a4ba2..bf5b5b8 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -275,6 +275,9 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	struct nlattr *tb[FRA_MAX+1];
 	int err = -EINVAL, unresolved = 0;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frh)))
 		goto errout;
 
@@ -424,6 +427,9 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	struct nlattr *tb[FRA_MAX+1];
 	int err = -EINVAL;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frh)))
 		goto errout;
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f1c0c2e..7adcdaf 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1620,6 +1620,9 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct net_device *dev = NULL;
 	int err = -EINVAL;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	ASSERT_RTNL();
 	if (nlmsg_len(nlh) < sizeof(*ndm))
 		goto out;
@@ -1684,6 +1687,9 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct net_device *dev = NULL;
 	int err;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	ASSERT_RTNL();
 	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
 	if (err < 0)
@@ -1962,6 +1968,9 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct nlattr *tb[NDTA_MAX+1];
 	int err;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	err = nlmsg_parse(nlh, sizeof(*ndtmsg), tb, NDTA_MAX,
 			  nl_neightbl_policy);
 	if (err < 0)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 76d4c2c..5d55c30 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1547,6 +1547,9 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct nlattr *tb[IFLA_MAX+1];
 	char ifname[IFNAMSIZ];
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
 	if (err < 0)
 		goto errout;
@@ -1590,6 +1593,9 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	int err;
 	LIST_HEAD(list_kill);
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
 	if (err < 0)
 		return err;
@@ -1720,6 +1726,9 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct nlattr *linkinfo[IFLA_INFO_MAX+1];
 	int err;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 #ifdef CONFIG_MODULES
 replay:
 #endif
@@ -2057,6 +2066,9 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	u8 *addr;
 	int err;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
 	if (err < 0)
 		return err;
@@ -2123,6 +2135,9 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	int err = -EINVAL;
 	__u8 *addr;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (nlmsg_len(nlh) < sizeof(*ndm))
 		return -EINVAL;
 
@@ -2282,7 +2297,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	sz_idx = type>>2;
 	kind = type&3;
 
-	if (kind != 2 && !capable(CAP_NET_ADMIN))
+	if (kind != 2 && !ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 70989e6..b07c75d 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1662,6 +1662,9 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct nlmsghdr *reply_nlh = NULL;
 	const struct reply_func *fn;
 
+	if ((nlh->nlmsg_type == RTM_SETDCB) && !capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 7b7e561..e47ba9f 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -573,6 +573,9 @@ static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct dn_ifaddr __rcu **ifap;
 	int err = -EINVAL;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (!net_eq(net, &init_net))
 		goto errout;
 
@@ -614,6 +617,9 @@ static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct dn_ifaddr *ifa;
 	int err;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 102d610..e36614e 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -520,6 +520,9 @@ static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *
 	struct rtattr **rta = arg;
 	struct rtmsg *r = NLMSG_DATA(nlh);
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
@@ -540,6 +543,9 @@ static int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *
 	struct rtattr **rta = arg;
 	struct rtmsg *r = NLMSG_DATA(nlh);
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 66df8d1..ae95f64 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -538,6 +538,9 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
 
 	ASSERT_RTNL();
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv4_policy);
 	if (err < 0)
 		goto errout;
@@ -645,6 +648,9 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
 
 	ASSERT_RTNL();
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	ifa = rtm_to_ifaddr(net, nlh);
 	if (IS_ERR(ifa))
 		return PTR_ERR(ifa);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 825c608..bce4541 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -613,6 +613,9 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *ar
 	struct fib_table *tb;
 	int err;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	err = rtm_to_fib_config(net, skb, nlh, &cfg);
 	if (err < 0)
 		goto errout;
@@ -635,6 +638,9 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *ar
 	struct fib_table *tb;
 	int err;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	err = rtm_to_fib_config(net, skb, nlh, &cfg);
 	if (err < 0)
 		goto errout;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6378be4..47c591d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3369,6 +3369,9 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct in6_addr *pfx;
 	int err;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
 	if (err < 0)
 		return err;
@@ -3439,6 +3442,9 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	u8 ifa_flags;
 	int err;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
 	if (err < 0)
 		return err;
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index ff76eec..b106f80 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -425,6 +425,9 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u32 label;
 	int err = 0;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
 	if (err < 0)
 		return err;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 551fb82..2a98397 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2336,6 +2336,9 @@ static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *a
 	struct fib6_config cfg;
 	int err;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	err = rtm_to_fib6_config(skb, nlh, &cfg);
 	if (err < 0)
 		return err;
@@ -2348,6 +2351,9 @@ static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *a
 	struct fib6_config cfg;
 	int err;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	err = rtm_to_fib6_config(skb, nlh, &cfg);
 	if (err < 0)
 		return err;
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index 83a8389..0193630 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -70,6 +70,9 @@ static int addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *attr)
 	int err;
 	u8 pnaddr;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
@@ -230,6 +233,9 @@ static int route_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *attr)
 	int err;
 	u8 dst;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 102761d..65d240c 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -987,6 +987,9 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
 	int ret = 0, ovr = 0;
 
+	if ((n->nlmsg_type != RTM_GETACTION) && !capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL);
 	if (ret < 0)
 		return ret;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 7ae0289..ff55ed6 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -139,6 +139,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	int err;
 	int tp_created = 0;
 
+	if ((n->nlmsg_type != RTM_GETTFILTER) && !capable(CAP_NET_ADMIN))
+		return -EPERM;
 replay:
 	t = nlmsg_data(n);
 	protocol = TC_H_MIN(t->tcm_info);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a18d975..7dae9d0 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -981,6 +981,9 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	struct Qdisc *p = NULL;
 	int err;
 
+	if ((n->nlmsg_type != RTM_GETQDISC) && !capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
 	if (!dev)
 		return -ENODEV;
@@ -1044,6 +1047,9 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	struct Qdisc *q, *p;
 	int err;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 replay:
 	/* Reinit, just in case something touches this. */
 	tcm = nlmsg_data(n);
@@ -1380,6 +1386,9 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	u32 qid = TC_H_MAJ(clid);
 	int err;
 
+	if ((n->nlmsg_type != RTM_GETTCLASS) && !capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
 	if (!dev)
 		return -ENODEV;
-- 
1.7.5.4
