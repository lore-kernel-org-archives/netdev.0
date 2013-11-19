From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v2 1/2] ipv6 addrconf: extend ifa_flags to u32
Date: Tue, 19 Nov 2013 11:43:28 +0100
Message-ID: <1384857809-6573-2-git-send-email-jiri@resnulli.us>
References: <1384857809-6573-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:55207 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab3KSKnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 05:43:35 -0500
Received: by mail-ee0-f45.google.com with SMTP id d49so3159951eek.4
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 02:43:34 -0800 (PST)
In-Reply-To: <1384857809-6573-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no more space in u8 ifa_flags. So do what davem suffested and
add another netlink attr called IFA_FLAGS for carry more flags.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Thomas Haller <thaller@redhat.com>
---
v1->v2:
- reordered struct inet6_ifaddr as suggested by David Laight
- changed flags type to u32 on couple of places as suggested by Thomas Haller
- changed output of if6_seq_show as suggested by Thomas Haller

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
index 542d095..c94da31 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1393,7 +1393,7 @@ try_nextdev:
 EXPORT_SYMBOL(ipv6_dev_get_saddr);
 
 int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
-		      unsigned char banned_flags)
+		      u32 banned_flags)
 {
 	struct inet6_ifaddr *ifp;
 	int err = -EADDRNOTAVAIL;
@@ -1410,7 +1410,7 @@ int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
 }
 
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
-		    unsigned char banned_flags)
+		    u32 banned_flags)
 {
 	struct inet6_dev *idev;
 	int err = -EADDRNOTAVAIL;
@@ -2181,7 +2181,7 @@ ok:
 		}
 
 		if (ifp) {
-			int flags;
+			u32 flags;
 			unsigned long now;
 			struct inet6_ifaddr *ift;
 			u32 stored_lft;
@@ -2366,10 +2366,11 @@ err_exit:
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
@@ -3357,7 +3358,7 @@ static void if6_seq_stop(struct seq_file *seq, void *v)
 static int if6_seq_show(struct seq_file *seq, void *v)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *)v;
-	seq_printf(seq, "%pi6 %02x %02x %02x %02x %8s\n",
+	seq_printf(seq, "%pi6 %02x %02x %02x %03x %8s\n",
 		   &ifp->addr,
 		   ifp->idev->dev->ifindex,
 		   ifp->prefix_len,
@@ -3578,6 +3579,7 @@ static const struct nla_policy ifa_ipv6_policy[IFA_MAX+1] = {
 	[IFA_ADDRESS]		= { .len = sizeof(struct in6_addr) },
 	[IFA_LOCAL]		= { .len = sizeof(struct in6_addr) },
 	[IFA_CACHEINFO]		= { .len = sizeof(struct ifa_cacheinfo) },
+	[IFA_FLAGS]		= { .len = sizeof(u32) },
 };
 
 static int
@@ -3601,7 +3603,7 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return inet6_addr_del(net, ifm->ifa_index, pfx, ifm->ifa_prefixlen);
 }
 
-static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
+static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 			     u32 prefered_lft, u32 valid_lft)
 {
 	u32 flags;
@@ -3656,7 +3658,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct inet6_ifaddr *ifa;
 	struct net_device *dev;
 	u32 valid_lft = INFINITY_LIFE_TIME, preferred_lft = INFINITY_LIFE_TIME;
-	u8 ifa_flags;
+	u32 ifa_flags;
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
@@ -3683,8 +3685,10 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (dev == NULL)
 		return -ENODEV;
 
+	ifa_flags = tb[IFA_FLAGS] ? nla_get_u32(tb[IFA_FLAGS]) : ifm->ifa_flags;
+
 	/* We ignore other flags so far. */
-	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
+	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS;
 
 	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
 	if (ifa == NULL) {
@@ -3708,7 +3712,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return err;
 }
 
-static void put_ifaddrmsg(struct nlmsghdr *nlh, u8 prefixlen, u8 flags,
+static void put_ifaddrmsg(struct nlmsghdr *nlh, u8 prefixlen, u32 flags,
 			  u8 scope, int ifindex)
 {
 	struct ifaddrmsg *ifm;
@@ -3751,7 +3755,8 @@ static inline int inet6_ifaddr_msgsize(void)
 	return NLMSG_ALIGN(sizeof(struct ifaddrmsg))
 	       + nla_total_size(16) /* IFA_LOCAL */
 	       + nla_total_size(16) /* IFA_ADDRESS */
-	       + nla_total_size(sizeof(struct ifa_cacheinfo));
+	       + nla_total_size(sizeof(struct ifa_cacheinfo))
+	       + nla_total_size(4)  /* IFA_FLAGS */;
 }
 
 static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
@@ -3799,6 +3804,9 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 	if (put_cacheinfo(skb, ifa->cstamp, ifa->tstamp, preferred, valid) < 0)
 		goto error;
 
+	if (nla_put_u32(skb, IFA_FLAGS, ifa->flags) < 0)
+		goto error;
+
 	return nlmsg_end(skb, nlh);
 
 error:
-- 
1.8.3.1
