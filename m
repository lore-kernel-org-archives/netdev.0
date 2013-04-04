From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] net: ipv6: add tokenized interface identifier support
Date: Thu,  4 Apr 2013 16:37:37 +0200
Message-ID: <1365086258-4512-2-git-send-email-dborkman@redhat.com>
References: <1365086258-4512-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53598 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761957Ab3DDOhp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 10:37:45 -0400
In-Reply-To: <1365086258-4512-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for tokenized IIDs, that allow for
administrators to assign well-known host-part addresses to
nodes whilst still obtaining global network prefix from
Router Advertisements. It is currently in IETF RFC draft
status [1]:

  The primary target for such support is server platforms
  where addresses are usually manually configured, rather
  than using DHCPv6 or SLAAC. By using tokenised identifiers,
  hosts can still determine their network prefix by use of
  SLAAC, but more readily be automatically renumbered should
  their network prefix change.

 [1] http://tools.ietf.org/html/draft-chown-6man-tokenised-ipv6-identifiers-02

The implementation is partially based on top of Mark K.
Thompson's proof of concept. Successfully tested by myself.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/if_inet6.h       |    2 +
 include/net/ipv6.h           |    2 +
 include/uapi/linux/if_link.h |    1 +
 net/ipv6/addrconf.c          |   87 ++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/addrconf_core.c     |    2 -
 5 files changed, 89 insertions(+), 5 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 9356322..f1063d6 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -187,6 +187,8 @@ struct inet6_dev {
 	struct list_head	tempaddr_list;
 #endif
 
+	struct in6_addr		token;
+
 	struct neigh_parms	*nd_parms;
 	struct inet6_dev	*next;
 	struct ipv6_devconf	cnf;
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 0810aa5..da8c11e 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -88,6 +88,8 @@
 #define IPV6_ADDR_SCOPE_ORGLOCAL	0x08
 #define IPV6_ADDR_SCOPE_GLOBAL		0x0e
 
+#define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
+
 /*
  *	Addr flags
  */
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index c4edfe1..6b35c42 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -201,6 +201,7 @@ enum {
 	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
 	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
 	IFLA_INET6_ICMP6STATS,	/* statistics (icmpv6)		*/
+	IFLA_INET6_TOKEN,	/* device token			*/
 	__IFLA_INET6_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a33b157..fb0e8a0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -422,6 +422,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 		ipv6_regen_rndid((unsigned long) ndev);
 	}
 #endif
+	memset(ndev->token.s6_addr, 0, sizeof(ndev->token.s6_addr));
 
 	if (netif_running(dev) && addrconf_qdisc_ok(dev))
 		ndev->if_flags |= IF_READY;
@@ -2136,8 +2137,14 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 
 		if (pinfo->prefix_len == 64) {
 			memcpy(&addr, &pinfo->prefix, 8);
-			if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
-			    ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
+
+			if (!ipv6_addr_any(&in6_dev->token)) {
+				read_lock_bh(&in6_dev->lock);
+				memcpy(addr.s6_addr + 8,
+				       in6_dev->token.s6_addr + 8, 8);
+				read_unlock_bh(&in6_dev->lock);
+			} else if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
+				   ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
 				in6_dev_put(in6_dev);
 				return;
 			}
@@ -4165,7 +4172,8 @@ static inline size_t inet6_ifla6_size(void)
 	     + nla_total_size(sizeof(struct ifla_cacheinfo))
 	     + nla_total_size(DEVCONF_MAX * 4) /* IFLA_INET6_CONF */
 	     + nla_total_size(IPSTATS_MIB_MAX * 8) /* IFLA_INET6_STATS */
-	     + nla_total_size(ICMP6_MIB_MAX * 8); /* IFLA_INET6_ICMP6STATS */
+	     + nla_total_size(ICMP6_MIB_MAX * 8) /* IFLA_INET6_ICMP6STATS */
+	     + nla_total_size(sizeof(struct in6_addr)); /* IFLA_INET6_TOKEN */
 }
 
 static inline size_t inet6_if_nlmsg_size(void)
@@ -4252,6 +4260,13 @@ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev)
 		goto nla_put_failure;
 	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_ICMP6STATS, nla_len(nla));
 
+	nla = nla_reserve(skb, IFLA_INET6_TOKEN, sizeof(struct in6_addr));
+	if (nla == NULL)
+		goto nla_put_failure;
+	read_lock_bh(&idev->lock);
+	memcpy(nla_data(nla), idev->token.s6_addr, nla_len(nla));
+	read_unlock_bh(&idev->lock);
+
 	return 0;
 
 nla_put_failure:
@@ -4279,6 +4294,71 @@ static int inet6_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
 	return 0;
 }
 
+static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
+{
+	struct in6_addr ll_addr;
+	struct inet6_ifaddr *ifp;
+	struct net_device *dev = idev->dev;
+
+	if (token == NULL)
+		return -EINVAL;
+	if (ipv6_addr_any(token))
+		return -EINVAL;
+	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP))
+		return -EINVAL;
+	if (idev->dead || !(idev->if_flags & IF_READY))
+		return -EINVAL;
+	if (!ipv6_accept_ra(idev))
+		return -EINVAL;
+	if (idev->cnf.rtr_solicits <= 0)
+		return -EINVAL;
+
+	write_lock_bh(&idev->lock);
+
+	BUILD_BUG_ON(sizeof(token->s6_addr) != 16);
+	memcpy(idev->token.s6_addr + 8, token->s6_addr + 8, 8);
+
+	write_unlock_bh(&idev->lock);
+
+	ipv6_get_lladdr(dev, &ll_addr, IFA_F_TENTATIVE | IFA_F_OPTIMISTIC);
+	ndisc_send_rs(dev, &ll_addr, &in6addr_linklocal_allrouters);
+
+	write_lock_bh(&idev->lock);
+	idev->if_flags |= IF_RS_SENT;
+
+	/* Well, that's kinda nasty ... */
+	list_for_each_entry(ifp, &idev->addr_list, if_list) {
+		spin_lock(&ifp->lock);
+		if (__ipv6_addr_type(&ifp->addr) &
+		    IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL)) {
+			ifp->valid_lft = 0;
+			ifp->prefered_lft = 0;
+		}
+		spin_unlock(&ifp->lock);
+	}
+
+	write_unlock_bh(&idev->lock);
+	return 0;
+}
+
+static int inet6_set_link_af(struct net_device *dev, const struct nlattr *nla)
+{
+	int err = -EINVAL;
+	struct inet6_dev *idev = __in6_dev_get(dev);
+	struct nlattr *tb[IFLA_INET6_MAX + 1];
+
+	if (!idev)
+		return -EAFNOSUPPORT;
+
+	if (nla_parse_nested(tb, IFLA_INET6_MAX, nla, NULL) < 0)
+		BUG();
+
+	if (tb[IFLA_INET6_TOKEN])
+		err = inet6_set_iftoken(idev, nla_data(tb[IFLA_INET6_TOKEN]));
+
+	return err;
+}
+
 static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 			     u32 portid, u32 seq, int event, unsigned int flags)
 {
@@ -4981,6 +5061,7 @@ static struct rtnl_af_ops inet6_ops = {
 	.family		  = AF_INET6,
 	.fill_link_af	  = inet6_fill_link_af,
 	.get_link_af_size = inet6_get_link_af_size,
+	.set_link_af	  = inet6_set_link_af,
 };
 
 /*
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index d051e5f..8b723de 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -6,8 +6,6 @@
 #include <linux/export.h>
 #include <net/ipv6.h>
 
-#define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
-
 static inline unsigned int ipv6_addr_scope2type(unsigned int scope)
 {
 	switch (scope) {
-- 
1.7.1
