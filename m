From: Robert Shearman <rshearma@brocade.com>
Subject: [RFC net-next 1/3] net: infra for per-nexthop encap data
Date: Mon, 1 Jun 2015 17:46:13 +0100
Message-ID: <1433177175-16775-2-git-send-email-rshearma@brocade.com>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	roopa <roopa@cumulusnetworks.com>, Thomas Graf <tgraf@suug.ch>,
	Robert Shearman <rshearma@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:41235 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752344AbbFAQsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 12:48:46 -0400
In-Reply-To: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having to add a new interface to apply encap onto a packet is a
mechanism that works well today, allowing the setup of the encap to be
done separately from the routes out of them, meaning that routing
protocols and other user-space apps don't need to do anything special
to add routes out of a new type of interface. However, the overhead of
creating an interface is high, especially in terms of
memory. Therefore, the traditional method won't work very well for
large numbers of routes applying encap where there is a low degree of
sharing of the encap.

The solution is to introduce a way of defining encap on a per-nexthop
basis (i.e. per-route if only one nexthop) through the addition of a
new netlink attribute, RTA_ENCAP. The semantics of this attribute is
that the data is interpreted according to the output interface type
(RTA_OIF) and is opaque to the normal forwarding path. The output
interface doesn't have to be defined per-nexthop, but instead
represents the way of encapsulating the packet. There could be as few
as one per namespace, but more could be created, particularly if they
are used to define parameters which are shared by a large number of
routes. However, the split of what goes in the encap data and what
might be specified via interface attributes is entirely up to the
encap-type implementation.

New rtnetlink operations are defined to assist with the management of
this data:
- parse_encap for parsing the attribute given through rtnl and either
  sizing the in-memory version (if encap ptr is NULL) or filling in the
  in-memory version.  RTA_ENCAP work for IPv4. This operations allows
  the interface to reject invalid encap specified by user-space and the
  sizing allows the kernel to have a different in memory implementation
  to the netlink API (which might be optimised for extensibility rather
  than speed of packet forwarding).
- fill_encap for taking the in-memory version of the encap and filling
  in an RTA_ENCAP attribute in a netlink message.
- match_encap for comparing an in-memory version of encap with an
  RTA_ENCAP version, returning 0 if matching or 1 if different.

A new dst operation is also defined to allow encap-type interfaces to
retrieve the encap data from their xmit functions and use it for
encapsulating the packet and for further forwarding.

Suggested-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 include/linux/rtnetlink.h      |  7 +++++++
 include/net/dst.h              | 11 +++++++++++
 include/net/dst_ops.h          |  2 ++
 include/net/rtnetlink.h        | 11 +++++++++++
 include/uapi/linux/rtnetlink.h |  1 +
 net/core/rtnetlink.c           | 36 ++++++++++++++++++++++++++++++++++++
 6 files changed, 68 insertions(+)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index a2324fb45cf4..470d822ddd61 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -22,6 +22,13 @@ struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
 void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev,
 		       gfp_t flags);
 
+int rtnl_parse_encap(const struct net_device *dev, const struct nlattr *nla,
+		     void *encap);
+int rtnl_fill_encap(const struct net_device *dev, struct sk_buff *skb,
+		    int encap_len, const void *encap);
+int rtnl_match_encap(const struct net_device *dev, const struct nlattr *nla,
+		     int encap_len, const void *encap);
+
 
 /* RTNL is used as a global lock for all changes to network configuration  */
 extern void rtnl_lock(void);
diff --git a/include/net/dst.h b/include/net/dst.h
index 2bc73f8a00a9..df0e6ec18eca 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -506,4 +506,15 @@ static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
 }
 #endif
 
+/* Get encap data for destination */
+static inline int dst_get_encap(struct sk_buff *skb, const void **encap)
+{
+	const struct dst_entry *dst = skb_dst(skb);
+
+	if (!dst || !dst->ops->get_encap)
+		return 0;
+
+	return dst->ops->get_encap(dst, encap);
+}
+
 #endif /* _NET_DST_H */
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index d64253914a6a..97f48cf8ef7d 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -32,6 +32,8 @@ struct dst_ops {
 	struct neighbour *	(*neigh_lookup)(const struct dst_entry *dst,
 						struct sk_buff *skb,
 						const void *daddr);
+	int			(*get_encap)(const struct dst_entry *dst,
+					     const void **encap);
 
 	struct kmem_cache	*kmem_cachep;
 
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 343d922d15c2..3121ade24957 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -95,6 +95,17 @@ struct rtnl_link_ops {
 						   const struct net_device *dev,
 						   const struct net_device *slave_dev);
 	struct net		*(*get_link_net)(const struct net_device *dev);
+	int			(*parse_encap)(const struct net_device *dev,
+					       const struct nlattr *nla,
+					       void *encap);
+	int			(*fill_encap)(const struct net_device *dev,
+					      struct sk_buff *skb,
+					      int encap_len,
+					      const void *encap);
+	int			(*match_encap)(const struct net_device *dev,
+					       const struct nlattr *nla,
+					       int encap_len,
+					       const void *encap);
 };
 
 int __rtnl_link_register(struct rtnl_link_ops *ops);
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 17fb02f488da..ed4c797503f2 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -308,6 +308,7 @@ enum rtattr_type_t {
 	RTA_VIA,
 	RTA_NEWDST,
 	RTA_PREF,
+	RTA_ENCAP,
 	__RTA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 077b6d280371..3b4e40a82799 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1441,6 +1441,42 @@ static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
 	return 0;
 }
 
+int rtnl_parse_encap(const struct net_device *dev, const struct nlattr *nla,
+		     void *encap)
+{
+	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+
+	if (!ops->parse_encap)
+		return -EINVAL;
+
+	return ops->parse_encap(dev, nla, encap);
+}
+EXPORT_SYMBOL(rtnl_parse_encap);
+
+int rtnl_fill_encap(const struct net_device *dev, struct sk_buff *skb,
+		    int encap_len, const void *encap)
+{
+	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+
+	if (!ops->fill_encap)
+		return -EINVAL;
+
+	return ops->fill_encap(dev, skb, encap_len, encap);
+}
+EXPORT_SYMBOL(rtnl_fill_encap);
+
+int rtnl_match_encap(const struct net_device *dev, const struct nlattr *nla,
+		     int encap_len, const void *encap)
+{
+	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+
+	if (!ops->match_encap)
+		return -EINVAL;
+
+	return ops->match_encap(dev, nla, encap_len, encap);
+}
+EXPORT_SYMBOL(rtnl_match_encap);
+
 static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 {
 	int rem, err = -EINVAL;
-- 
2.1.4
