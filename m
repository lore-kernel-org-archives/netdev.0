From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: ipv6: add tokenized interface identifier support
Date: Mon,  8 Apr 2013 16:01:30 +0200
Message-ID: <1365429690-17342-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62688 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936162Ab3DHOBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 10:01:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for IPv6 tokenized IIDs, that allow
for administrators to assign well-known host-part addresses
to nodes whilst still obtaining global network prefix from
Router Advertisements. It is currently in draft status.

  The primary target for such support is server platforms
  where addresses are usually manually configured, rather
  than using DHCPv6 or SLAAC. By using tokenised identifiers,
  hosts can still determine their network prefix by use of
  SLAAC, but more readily be automatically renumbered should
  their network prefix change. [...]

  The disadvantage with static addresses is that they are
  likely to require manual editing should the network prefix
  in use change.  If instead there were a method to only
  manually configure the static identifier part of the IPv6
  address, then the address could be automatically updated
  when a new prefix was introduced, as described in [RFC4192]
  for example.  In such cases a DNS server might be
  configured with such a tokenised interface identifier of
  ::53, and SLAAC would use the token in constructing the
  interface address, using the advertised prefix. [...]

  http://tools.ietf.org/html/draft-chown-6man-tokenised-ipv6-identifiers-02

The implementation is partially based on top of Mark K.
Thompson's proof of concept. However, it uses the Netlink
interface for configuration resp. data retrival, so that
it can be easily extended in future. Successfully tested
by myself.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 RFC -> v1:
   - Applied Hannes' feedback from the RFC
   - Dropped the RFC from the subject

 The iproute2 part of this patch was previously posted at
 http://thread.gmane.org/gmane.linux.network/264553/focus=264555
 and will be re-submitted during the 3.10 merge window as
 Stephen requested.

 include/net/if_inet6.h       |    2 +
 include/uapi/linux/if_link.h |    1 +
 net/ipv6/addrconf.c          |   87 ++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 87 insertions(+), 3 deletions(-)

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
index a33b157..65d8139 100644
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
+		if (ipv6_addr_src_scope(&ifp->addr) ==
+		    IPV6_ADDR_SCOPE_GLOBAL) {
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
-- 
1.7.1
