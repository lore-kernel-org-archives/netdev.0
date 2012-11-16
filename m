From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 16/17] net: Enable a userns root rtnl calls that are
	safe for unprivilged users
Date: Fri, 16 Nov 2012 05:03:11 -0800
Message-ID: <1353070992-5552-16-git-send-email-ebiederm@xmission.com>
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

- Only allow moving network devices to network namespaces you have
  CAP_NET_ADMIN privileges over.

- Enable creating/deleting/modifying interfaces
- Enable adding/deleting addresses
- Enable adding/setting/deleting neighbour entries
- Enable adding/removing routes
- Enable adding/removing fib rules
- Enable setting the forwarding state
- Enable adding/removing ipv6 address labels
- Enable setting bridge parameter

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/bridge/br_netlink.c |    3 ---
 net/core/fib_rules.c    |    6 ------
 net/core/neighbour.c    |    9 ---------
 net/core/rtnetlink.c    |   13 ++++---------
 net/ipv4/devinet.c      |    6 ------
 net/ipv4/fib_frontend.c |    6 ------
 net/ipv6/addrconf.c     |    6 ------
 net/ipv6/addrlabel.c    |    3 ---
 net/ipv6/route.c        |    6 ------
 9 files changed, 4 insertions(+), 54 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 251d558..093f527 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -153,9 +153,6 @@ static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 	struct net_bridge_port *p;
 	u8 new_state;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	if (nlmsg_len(nlh) < sizeof(*ifm))
 		return -EINVAL;
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index bf5b5b8..58a4ba2 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -275,9 +275,6 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	struct nlattr *tb[FRA_MAX+1];
 	int err = -EINVAL, unresolved = 0;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frh)))
 		goto errout;
 
@@ -427,9 +424,6 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	struct nlattr *tb[FRA_MAX+1];
 	int err = -EINVAL;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frh)))
 		goto errout;
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 7adcdaf..f1c0c2e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1620,9 +1620,6 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct net_device *dev = NULL;
 	int err = -EINVAL;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	ASSERT_RTNL();
 	if (nlmsg_len(nlh) < sizeof(*ndm))
 		goto out;
@@ -1687,9 +1684,6 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct net_device *dev = NULL;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	ASSERT_RTNL();
 	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
 	if (err < 0)
@@ -1968,9 +1962,6 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct nlattr *tb[NDTA_MAX+1];
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	err = nlmsg_parse(nlh, sizeof(*ndtmsg), tb, NDTA_MAX,
 			  nl_neightbl_policy);
 	if (err < 0)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5d55c30..06dcf44 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1316,6 +1316,10 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 			err = PTR_ERR(net);
 			goto errout;
 		}
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN)) {
+			err = -EPERM;
+			goto errout;
+		}
 		err = dev_change_net_namespace(dev, net, ifname);
 		put_net(net);
 		if (err)
@@ -1547,9 +1551,6 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct nlattr *tb[IFLA_MAX+1];
 	char ifname[IFNAMSIZ];
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
 	if (err < 0)
 		goto errout;
@@ -1593,9 +1594,6 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	int err;
 	LIST_HEAD(list_kill);
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
 	if (err < 0)
 		return err;
@@ -1726,9 +1724,6 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct nlattr *linkinfo[IFLA_INFO_MAX+1];
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 #ifdef CONFIG_MODULES
 replay:
 #endif
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 446b1b9..7059d6f 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -538,9 +538,6 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
 
 	ASSERT_RTNL();
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv4_policy);
 	if (err < 0)
 		goto errout;
@@ -648,9 +645,6 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
 
 	ASSERT_RTNL();
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	ifa = rtm_to_ifaddr(net, nlh);
 	if (IS_ERR(ifa))
 		return PTR_ERR(ifa);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 784716a..5cd75e2 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -613,9 +613,6 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *ar
 	struct fib_table *tb;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	err = rtm_to_fib_config(net, skb, nlh, &cfg);
 	if (err < 0)
 		goto errout;
@@ -638,9 +635,6 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *ar
 	struct fib_table *tb;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	err = rtm_to_fib_config(net, skb, nlh, &cfg);
 	if (err < 0)
 		goto errout;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5f1967b..27b1e8f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3369,9 +3369,6 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct in6_addr *pfx;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
 	if (err < 0)
 		return err;
@@ -3442,9 +3439,6 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	u8 ifa_flags;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
 	if (err < 0)
 		return err;
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index b106f80..ff76eec 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -425,9 +425,6 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u32 label;
 	int err = 0;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
 	if (err < 0)
 		return err;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index be2c173..c7f7fda 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2336,9 +2336,6 @@ static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *a
 	struct fib6_config cfg;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	err = rtm_to_fib6_config(skb, nlh, &cfg);
 	if (err < 0)
 		return err;
@@ -2351,9 +2348,6 @@ static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *a
 	struct fib6_config cfg;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	err = rtm_to_fib6_config(skb, nlh, &cfg);
 	if (err < 0)
 		return err;
-- 
1.7.5.4
