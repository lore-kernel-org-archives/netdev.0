From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] ipv6 addrconf: extend ifa_flags to u32
Date: Fri,  6 Dec 2013 09:45:21 +0100
Message-ID: <1386319522-2102-2-git-send-email-jiri@resnulli.us>
References: <1386319522-2102-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:37752 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756894Ab3LFIp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 03:45:29 -0500
Received: by mail-ee0-f54.google.com with SMTP id e51so143718eek.27
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 00:45:28 -0800 (PST)
In-Reply-To: <1386319522-2102-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no more space in u8 ifa_flags. So do what davem suffested and
add another netlink attr called IFA_FLAGS for carry more flags.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Thomas Haller <thaller@redhat.com>
---
 include/net/addrconf.h       |  4 ++--
 include/net/if_inet6.h       |  2 +-
 include/uapi/linux/if_addr.h |  4 ++++
 net/ipv6/addrconf.c          | 32 ++++++++++++++++++++------------
 4 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 86505bf..e70278e 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -81,9 +81,9 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dev,
 		       const struct in6_addr *daddr, unsigned int srcprefs,
 		       struct in6_addr *saddr);
 int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
-		      unsigned char banned_flags);
+		      u32 banned_flags);
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
-		    unsigned char banned_flags);
+		    u32 banned_flags);
 int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2);
 void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr);
 void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr);
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 76d5427..b58c36c 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -50,8 +50,8 @@ struct inet6_ifaddr {
 
 	int			state;
 
+	__u32			flags;
 	__u8			dad_probes;
-	__u8			flags;
 
 	__u16			scope;
 
diff --git a/include/uapi/linux/if_addr.h b/include/uapi/linux/if_addr.h
index 23357ab..8ab0c2c 100644
--- a/include/uapi/linux/if_addr.h
+++ b/include/uapi/linux/if_addr.h
@@ -18,6 +18,9 @@ struct ifaddrmsg {
  * It makes no difference for normally configured broadcast interfaces,
  * but for point-to-point IFA_ADDRESS is DESTINATION address,
  * local address is supplied in IFA_LOCAL attribute.
+ *
+ * IFA_FLAGS is a u32 attribute that extends the u8 field ifa_flags.
+ * If present, the value from struct ifaddrmsg will be ignored.
  */
 enum {
 	IFA_UNSPEC,
@@ -28,6 +31,7 @@ enum {
 	IFA_ANYCAST,
 	IFA_CACHEINFO,
 	IFA_MULTICAST,
+	IFA_FLAGS,
 	__IFA_MAX,
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d5fa5b8..334a7e1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1407,7 +1407,7 @@ try_nextdev:
 EXPORT_SYMBOL(ipv6_dev_get_saddr);
 
 int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
-		      unsigned char banned_flags)
+		      u32 banned_flags)
 {
 	struct inet6_ifaddr *ifp;
 	int err = -EADDRNOTAVAIL;
@@ -1424,7 +1424,7 @@ int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
 }
 
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
-		    unsigned char banned_flags)
+		    u32 banned_flags)
 {
 	struct inet6_dev *idev;
 	int err = -EADDRNOTAVAIL;
@@ -2178,7 +2178,7 @@ ok:
 		}
 
 		if (ifp) {
-			int flags;
+			u32 flags;
 			unsigned long now;
 			struct inet6_ifaddr *ift;
 			u32 stored_lft;
@@ -2363,10 +2363,11 @@ err_exit:
 /*
  *	Manual configuration of address on an interface
  */
-static int inet6_addr_add(struct net *net, int ifindex, const struct in6_addr *pfx,
+static int inet6_addr_add(struct net *net, int ifindex,
+			  const struct in6_addr *pfx,
 			  const struct in6_addr *peer_pfx,
-			  unsigned int plen, __u8 ifa_flags, __u32 prefered_lft,
-			  __u32 valid_lft)
+			  unsigned int plen, __u32 ifa_flags,
+			  __u32 prefered_lft, __u32 valid_lft)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
@@ -3351,7 +3352,7 @@ static void if6_seq_stop(struct seq_file *seq, void *v)
 static int if6_seq_show(struct seq_file *seq, void *v)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *)v;
-	seq_printf(seq, "%pi6 %02x %02x %02x %02x %8s\n",
+	seq_printf(seq, "%pi6 %02x %02x %02x %03x %8s\n",
 		   &ifp->addr,
 		   ifp->idev->dev->ifindex,
 		   ifp->prefix_len,
@@ -3572,6 +3573,7 @@ static const struct nla_policy ifa_ipv6_policy[IFA_MAX+1] = {
 	[IFA_ADDRESS]		= { .len = sizeof(struct in6_addr) },
 	[IFA_LOCAL]		= { .len = sizeof(struct in6_addr) },
 	[IFA_CACHEINFO]		= { .len = sizeof(struct ifa_cacheinfo) },
+	[IFA_FLAGS]		= { .len = sizeof(u32) },
 };
 
 static int
@@ -3595,7 +3597,7 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return inet6_addr_del(net, ifm->ifa_index, pfx, ifm->ifa_prefixlen);
 }
 
-static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
+static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 			     u32 prefered_lft, u32 valid_lft)
 {
 	u32 flags;
@@ -3650,7 +3652,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct inet6_ifaddr *ifa;
 	struct net_device *dev;
 	u32 valid_lft = INFINITY_LIFE_TIME, preferred_lft = INFINITY_LIFE_TIME;
-	u8 ifa_flags;
+	u32 ifa_flags;
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
@@ -3677,8 +3679,10 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (dev == NULL)
 		return -ENODEV;
 
+	ifa_flags = tb[IFA_FLAGS] ? nla_get_u32(tb[IFA_FLAGS]) : ifm->ifa_flags;
+
 	/* We ignore other flags so far. */
-	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
+	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS;
 
 	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
 	if (ifa == NULL) {
@@ -3702,7 +3706,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return err;
 }
 
-static void put_ifaddrmsg(struct nlmsghdr *nlh, u8 prefixlen, u8 flags,
+static void put_ifaddrmsg(struct nlmsghdr *nlh, u8 prefixlen, u32 flags,
 			  u8 scope, int ifindex)
 {
 	struct ifaddrmsg *ifm;
@@ -3745,7 +3749,8 @@ static inline int inet6_ifaddr_msgsize(void)
 	return NLMSG_ALIGN(sizeof(struct ifaddrmsg))
 	       + nla_total_size(16) /* IFA_LOCAL */
 	       + nla_total_size(16) /* IFA_ADDRESS */
-	       + nla_total_size(sizeof(struct ifa_cacheinfo));
+	       + nla_total_size(sizeof(struct ifa_cacheinfo))
+	       + nla_total_size(4)  /* IFA_FLAGS */;
 }
 
 static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
@@ -3793,6 +3798,9 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 	if (put_cacheinfo(skb, ifa->cstamp, ifa->tstamp, preferred, valid) < 0)
 		goto error;
 
+	if (nla_put_u32(skb, IFA_FLAGS, ifa->flags) < 0)
+		goto error;
+
 	return nlmsg_end(skb, nlh);
 
 error:
-- 
1.8.3.1
