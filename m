From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [RFC] UAPI for 6lowpan
Date: Wed, 22 Jun 2016 20:35:59 +0200
Message-ID: <1c97594b-a4b3-23ef-6d18-75a8e51c3b26@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
To: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

I currently want to search nice solution to adding an UAPI for 6LoWPAN.
The current 6LoWPAN UAPI is some dev-hacking stuff in debugfs [0].

Marcel told me before I tried to send upstream patches for radvd [1] I
definitely should introduce a stable UAPI concept.

The question is here, what would be the right UAPI? Maybe extends
existing ones e.g. RTNL?

I would declare the following three cases where we need an UAPI in
different 6LoWPAN handling layers, for all cases we want to use netlink
of course:

 - 6LoWPAN specific only:

This is 6LoWPAN specific only and has nothing to do with L2 (e.g.
802.15.4 or BTLE) and L3 (IPv6).

As example this would be a per interface context table for stateful
compression. This context table contains IPv6 prefix and 6LoWPAN can
compress L3 address information by some context table lookup.

This context table need to be accessible from userspace.

Question:
What should here the right netlink UAPI?

In this case I think I cannot use RTNL because, RTNL is bound also to
PF_* which is in our case PF_INET6. RTNL is also very generic UAPI and
adding "ipv6 prefixes for some compression algorithm" isn't something
which can be found also in some other PF_* or existing RTNL commands.

I would here use an own netlink implementation, "nl6lowpan" or does RTNL
have some mechanism to provide such exotic settings per device type?

 - 6LoWPAN link-layer specific:

Sometimes we need for 6LoWPAN interface L2 information, e.g. short
address for 802.15.4 6LoWPAN.

In case of 802.15.4 6LoWPAN we create the 6LoWPAN interface like the
following ip command:

ip link add link wpan0 name lowpan0 type lowpan

Where wpan0 is the L2 device which doesn't has the capability to run IPv6
on it.

So theoretically we could get from the lowpan0 interface (6LoWPAN
interface) the ifindex of wpan0 interface and get the necessary L2
information from another netlink API (nl802154).

But this would only work for 802.15.4 case, BTLE works different and use
different L2 UAPI.

I think we should simple ignore such theoretically handling of L2
netlink API from upper 6LoWPAN interface and provide the L2 information
simple in "6LoWPAN netlink UAPI", e.g. short address netlink attribute will
be NULL for BTLE 6LoWPAN interfaces.

 - IPv6 Layer but 6LoWPAN specific:

These are settings which are 6LoWPAN specific but sitting in L3 layer
(IPv6).

As example this would be "6LoWPAN neighbour entry parameters" which
could also be L2 specific (e.g. short address on 802.15.4) or not.

In this case I would use existing neighbour cache UAPI. I tried to
implement such UAPI already by introduce a NDA_PRIVATE nested attribute
which depends on device type. Here is the draft (dumping functionality
only):

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 890158e..650b558 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1222,6 +1222,8 @@ struct net_device_ops {
 						    netdev_features_t features);
 	int			(*ndo_neigh_construct)(struct neighbour *n);
 	void			(*ndo_neigh_destroy)(struct neighbour *n);
+	int			(*ndo_neigh_fill_info)(struct sk_buff *skb,
+						       struct neighbour *n);
 
 	int			(*ndo_fdb_add)(struct ndmsg *ndm,
 					       struct nlattr *tb[],
@@ -1704,6 +1706,7 @@ struct net_device {
 	unsigned char		addr_assign_type;
 	unsigned char		addr_len;
 	unsigned short		neigh_priv_len;
+	unsigned short		neigh_priv_nlmsg_len;
 	unsigned short          dev_id;
 	unsigned short          dev_port;
 	spinlock_t		addr_list_lock;
diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index bd99a8d..0072008 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -15,6 +15,13 @@ struct ndmsg {
 };
 
 enum {
+	NDA_6LOWPAN_802154_SHORT_ADDR,
+	__NDA_6LOWPAN_MAX
+};
+
+#define NDA_6LOWPAN_MAX (__NDA_6LOWPAN_MAX - 1)
+
+enum {
 	NDA_UNSPEC,
 	NDA_DST,
 	NDA_LLADDR,
@@ -26,6 +33,7 @@ enum {
 	NDA_IFINDEX,
 	NDA_MASTER,
 	NDA_LINK_NETNSID,
+	NDA_PRIVATE,
 	__NDA_MAX
 };
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 29dd8cc..b6b3abb 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2153,6 +2153,7 @@ static int neigh_fill_info(struct sk_buff *skb, struct neighbour *neigh,
 	unsigned long now = jiffies;
 	struct nda_cacheinfo ci;
 	struct nlmsghdr *nlh;
+	struct nlattr *nest;
 	struct ndmsg *ndm;
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndm), flags);
@@ -2182,6 +2183,17 @@ static int neigh_fill_info(struct sk_buff *skb, struct neighbour *neigh,
 		}
 	}
 
+	if (neigh->dev->netdev_ops->ndo_neigh_fill_info) {
+		nest = nla_nest_start(skb, NDA_PRIVATE);
+		if (nest == NULL)
+			return -ENOBUFS;
+
+		if (neigh->dev->netdev_ops->ndo_neigh_fill_info(skb, neigh))
+			goto nla_put_failure;
+
+		nla_nest_end(skb, nest);
+	}
+
 	ci.ndm_used	 = jiffies_to_clock_t(now - neigh->used);
 	ci.ndm_confirmed = jiffies_to_clock_t(now - neigh->confirmed);
 	ci.ndm_updated	 = jiffies_to_clock_t(now - neigh->updated);
@@ -2824,13 +2836,14 @@ static const struct file_operations neigh_stat_seq_fops = {
 
 #endif /* CONFIG_PROC_FS */
 
-static inline size_t neigh_nlmsg_size(void)
+static inline size_t neigh_nlmsg_size(const struct net_device *dev)
 {
 	return NLMSG_ALIGN(sizeof(struct ndmsg))
 	       + nla_total_size(MAX_ADDR_LEN) /* NDA_DST */
 	       + nla_total_size(MAX_ADDR_LEN) /* NDA_LLADDR */
 	       + nla_total_size(sizeof(struct nda_cacheinfo))
-	       + nla_total_size(4); /* NDA_PROBES */
+	       + nla_total_size(4) /* NDA_PROBES */
+	       + nla_total_size(dev->neigh_priv_nlmsg_len);
 }
 
 static void __neigh_notify(struct neighbour *n, int type, int flags)
@@ -2839,7 +2852,7 @@ static void __neigh_notify(struct neighbour *n, int type, int flags)
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(neigh_nlmsg_size(), GFP_ATOMIC);
+	skb = nlmsg_new(neigh_nlmsg_size(n->dev), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;

--

In callback "*ndo_neigh_fill_info" which is device type specific, each
device can setup the device specific neighbour parameters for dumping
them in userspace.

In userspace the nested attribute NDA_PRIVATE depends on the device type
then and need to be evaluated before. I saw some similar handling for
NDA_DST which requires to evaluate the AF_* value before.

My question is:

Goes this into the right direction? I also want to dump my special
6LoWPAN parameters with iproute2 by running "ip -6 neigh".
Parameters which are L2 specific e.g. 802.15.4 parameters are NULL for
BTLE 6LoWPAN interfaces and will not be set.

-------

It would be nice to get some suggestions about RTNL vs "own 6lowpan
netlink", if I could add my 6LoWPAN use-cases to the RTNL API.
Also is it fine to introduce NDA_PRIVATE which depends on device type?

Thanks in advance.

- Alex

[0] http://lxr.free-electrons.com/source/net/6lowpan/debugfs.c
[1] https://github.com/linux-wpan/radvd/tree/6lowpan
