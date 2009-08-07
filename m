From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 05/10] nl802154: add support for
	dumping WPAN interface information
Date: Fri,  7 Aug 2009 16:58:40 +0400
Message-ID: <1249649925-11996-6-git-send-email-dbaryshkov@gmail.com>
References: <1249649925-11996-1-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-2-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-3-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-4-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-5-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1249649925-11996-5-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/nl802154.h |    2 +
 net/ieee802154/netlink.c |  106 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 106 insertions(+), 2 deletions(-)

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 266dd96..9a1af5f 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -111,6 +111,8 @@ enum {
 	IEEE802154_RX_ENABLE_REQ, /* Not supported yet */
 	IEEE802154_RX_ENABLE_CONF, /* Not supported yet */
 
+	IEEE802154_LIST_IFACE,
+
 	__IEEE802154_CMD_MAX,
 };
 
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index a615b9d..6fc6d6f 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -19,6 +19,7 @@
  * Written by:
  * Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
  * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ * Maxim Osipov <maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
  */
 
 #include <linux/kernel.h>
@@ -26,6 +27,7 @@
 #include <linux/netdevice.h>
 #include <net/netlink.h>
 #include <net/genetlink.h>
+#include <net/sock.h>
 #include <linux/nl802154.h>
 #include <net/af_ieee802154.h>
 #include <net/nl802154.h>
@@ -73,7 +75,7 @@ static int ieee802154_nl_finish(struct sk_buff *msg)
 	/* XXX: nlh is right at the start of msg */
 	void *hdr = genlmsg_data(NLMSG_DATA(msg->data));
 
-	if (!genlmsg_end(msg, hdr))
+	if (genlmsg_end(msg, hdr) < 0)
 		goto out;
 
 	return genlmsg_multicast(msg, 0, ieee802154_coord_mcgrp.id,
@@ -260,6 +262,35 @@ nla_put_failure:
 }
 EXPORT_SYMBOL(ieee802154_nl_scan_confirm);
 
+static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 pid,
+	u32 seq, int flags, struct net_device *dev)
+{
+	void *hdr;
+
+	pr_debug("%s\n", __func__);
+
+	hdr = genlmsg_put(msg, 0, seq, &ieee802154_coordinator_family, flags,
+		IEEE802154_LIST_IFACE);
+	if (!hdr)
+		goto out;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+
+	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
+		dev->dev_addr);
+	NLA_PUT_U16(msg, IEEE802154_ATTR_SHORT_ADDR,
+		ieee802154_mlme_ops(dev)->get_short_addr(dev));
+	NLA_PUT_U16(msg, IEEE802154_ATTR_PAN_ID,
+		ieee802154_mlme_ops(dev)->get_pan_id(dev));
+	return genlmsg_end(msg, hdr);
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+out:
+	return -EMSGSIZE;
+}
+
 /* Requests from userspace */
 static struct net_device *ieee802154_nl_get_dev(struct genl_info *info)
 {
@@ -272,7 +303,7 @@ static struct net_device *ieee802154_nl_get_dev(struct genl_info *info)
 		dev = dev_get_by_name(&init_net, name);
 	} else if (info->attrs[IEEE802154_ATTR_DEV_INDEX])
 		dev = dev_get_by_index(&init_net,
-				nla_get_u32(info->attrs[IEEE802154_ATTR_DEV_INDEX]));
+			nla_get_u32(info->attrs[IEEE802154_ATTR_DEV_INDEX]));
 	else
 		return NULL;
 
@@ -466,6 +497,67 @@ static int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info)
 	return ret;
 }
 
+static int ieee802154_list_iface(struct sk_buff *skb,
+	struct genl_info *info)
+{
+	/* Request for interface name, index, type, IEEE address,
+	   PAN Id, short address */
+	struct sk_buff *msg;
+	struct net_device *dev = NULL;
+	int rc = -ENOBUFS;
+
+	pr_debug("%s\n", __func__);
+
+	dev = ieee802154_nl_get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg)
+		goto out_dev;
+
+	rc = ieee802154_nl_fill_iface(msg, info->snd_pid, info->snd_seq,
+			0, dev);
+	if (rc < 0)
+		goto out_free;
+
+	dev_put(dev);
+
+	return genlmsg_unicast(msg, info->snd_pid);
+out_free:
+	nlmsg_free(msg);
+out_dev:
+	dev_put(dev);
+	return rc;
+
+}
+
+static int ieee802154_dump_iface(struct sk_buff *skb,
+	struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct net_device *dev;
+	int idx;
+	int s_idx = cb->args[0];
+
+	pr_debug("%s\n", __func__);
+
+	idx = 0;
+	for_each_netdev(net, dev) {
+		if (idx < s_idx || (dev->type != ARPHRD_IEEE802154))
+			goto cont;
+
+		if (ieee802154_nl_fill_iface(skb, NETLINK_CB(cb->skb).pid,
+			cb->nlh->nlmsg_seq, NLM_F_MULTI, dev) < 0)
+			break;
+cont:
+		idx++;
+	}
+	cb->args[0] = idx;
+
+	return skb->len;
+}
+
 #define IEEE802154_OP(_cmd, _func)			\
 	{						\
 		.cmd	= _cmd,				\
@@ -475,12 +567,22 @@ static int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info)
 		.flags	= GENL_ADMIN_PERM,		\
 	}
 
+#define IEEE802154_DUMP(_cmd, _func, _dump)		\
+	{						\
+		.cmd	= _cmd,				\
+		.policy	= ieee802154_policy,		\
+		.doit	= _func,			\
+		.dumpit	= _dump,			\
+	}
+
 static struct genl_ops ieee802154_coordinator_ops[] = {
 	IEEE802154_OP(IEEE802154_ASSOCIATE_REQ, ieee802154_associate_req),
 	IEEE802154_OP(IEEE802154_ASSOCIATE_RESP, ieee802154_associate_resp),
 	IEEE802154_OP(IEEE802154_DISASSOCIATE_REQ, ieee802154_disassociate_req),
 	IEEE802154_OP(IEEE802154_SCAN_REQ, ieee802154_scan_req),
 	IEEE802154_OP(IEEE802154_START_REQ, ieee802154_start_req),
+	IEEE802154_DUMP(IEEE802154_LIST_IFACE, ieee802154_list_iface,
+							ieee802154_dump_iface),
 };
 
 static int __init ieee802154_nl_init(void)
-- 
1.6.3.3


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
