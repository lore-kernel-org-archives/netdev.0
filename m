From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: [RFC PATCH net-next v3 2/4] rtnl: add link netns id to interface
	messages
Date: Thu,  2 Oct 2014 15:48:08 +0200
Message-ID: <1412257690-31253-3-git-send-email-nicolas.dichtel@6wind.com>
References: <542D5726.8070308@6wind.com>
	<1412257690-31253-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org, Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1412257690-31253-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

This patch adds a new attribute (IFLA_LINK_NETNSID) which contains the 'link'
netns id when this netns is different from the netns where the interface
stands (for example for x-net interfaces like ip tunnels). When there is no id,
we put NETNSA_NSINDEX_UNKNOWN into this attribute to indicate to userland that
the link netns is different from the interface netns. Hence, userland knows that
some information like IFLA_LINK are not interpretable.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
---
 include/net/rtnetlink.h      |  2 ++
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 13 +++++++++++++
 3 files changed, 16 insertions(+)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index e21b9f9653c0..6c6d5393fc34 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -46,6 +46,7 @@ static inline int rtnl_msg_family(const struct nlmsghdr *nlh)
  *			    to create when creating a new device.
  *	@get_num_rx_queues: Function to determine number of receive queues
  *			    to create when creating a new device.
+ *	@get_link_net: Function to get the i/o netns of the device
  */
 struct rtnl_link_ops {
 	struct list_head	list;
@@ -93,6 +94,7 @@ struct rtnl_link_ops {
 	int			(*fill_slave_info)(struct sk_buff *skb,
 						   const struct net_device *dev,
 						   const struct net_device *slave_dev);
+	struct net		*(*get_link_net)(const struct net_device *dev);
 };
 
 int __rtnl_link_register(struct rtnl_link_ops *ops);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 0bdb77e16875..938c0c02ed2e 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -145,6 +145,7 @@ enum {
 	IFLA_CARRIER,
 	IFLA_PHYS_PORT_ID,
 	IFLA_CARRIER_CHANGES,
+	IFLA_LINK_NETNSID,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a6882686ca3a..1b9329512496 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -862,6 +862,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(4) /* IFLA_CARRIER_CHANGES */
+	       + nla_total_size(4) /* IFLA_LINK_NETNSID */
 	       + nla_total_size(ext_filter_mask
 			        & RTEXT_FILTER_VF ? 4 : 0) /* IFLA_NUM_VF */
 	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
@@ -1134,6 +1135,18 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			goto nla_put_failure;
 	}
 
+	if (dev->rtnl_link_ops &&
+	    dev->rtnl_link_ops->get_link_net) {
+		struct net *link_net = dev->rtnl_link_ops->get_link_net(dev);
+
+		if (!net_eq(dev_net(dev), link_net)) {
+			int id = peernet2id(dev_net(dev), link_net);
+
+			if (nla_put_s32(skb, IFLA_LINK_NETNSID, id))
+				goto nla_put_failure;
+		}
+	}
+
 	if (!(af_spec = nla_nest_start(skb, IFLA_AF_SPEC)))
 		goto nla_put_failure;
 
-- 
2.1.0
