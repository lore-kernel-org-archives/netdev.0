From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next V1 17/19] RDMA/netlink: Add nldev port dumpit implementation
Date: Thu, 22 Jun 2017 16:24:32 +0300
Message-ID: <20170622132434.1327-18-leon@kernel.org>
References: <20170622132434.1327-1-leon@kernel.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Chien Tin Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170622132434.1327-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

This patch implements the query interface to get all
ports data for the specific device.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/core/nldev.c | 61 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 61 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index 666940f2b49a..4413eda8c435 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -53,6 +53,18 @@ static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
 	return 0;
 }
 
+static int fill_port_info(struct sk_buff *msg,
+			  struct ib_device *device, u32 port)
+{
+	if (nla_put_u32(msg, RDMA_NLDEV_ATTR_DEV_INDEX, device->index))
+		return -EMSGSIZE;
+	if (nla_put_string(msg, RDMA_NLDEV_ATTR_DEV_NAME, device->name))
+		return -EMSGSIZE;
+	if (nla_put_u32(msg, RDMA_NLDEV_ATTR_PORT_INDEX, port))
+		return -EMSGSIZE;
+	return 0;
+}
+
 static int nldev_get_doit(struct sk_buff *skb, struct nlmsghdr *nlh,
 			  struct netlink_ext_ack *extack)
 {
@@ -129,11 +141,60 @@ static int nldev_get_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 	return ib_enum_all_devs(_nldev_get_dumpit, skb, cb);
 }
 
+static int nldev_port_get_dumpit(struct sk_buff *skb,
+				 struct netlink_callback *cb)
+{
+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX];
+	struct ib_device *device;
+	int start = cb->args[0];
+	struct nlmsghdr *nlh;
+	u32 idx = 0;
+	u32 ifindex;
+	int err;
+	u32 p;
+
+	err = nlmsg_parse(cb->nlh, 0, tb, RDMA_NLDEV_ATTR_MAX - 1,
+			  nldev_policy, NULL);
+	if (err || !tb[RDMA_NLDEV_ATTR_DEV_INDEX])
+		return -EINVAL;
+
+	ifindex = nla_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
+	device = __ib_device_get_by_index(ifindex);
+	if (!device)
+		return -EINVAL;
+
+	for (p = rdma_start_port(device); p <= rdma_end_port(device); ++p) {
+		if (idx < start) {
+			idx++;
+			continue;
+		}
+
+		nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid,
+				cb->nlh->nlmsg_seq,
+				RDMA_NL_GET_TYPE(RDMA_NL_NLDEV,
+						 RDMA_NLDEV_CMD_PORT_GET),
+				0, NLM_F_MULTI);
+
+		if (fill_port_info(skb, device, p)) {
+			nlmsg_cancel(skb, nlh);
+			goto out;
+		}
+		idx++;
+		nlmsg_end(skb, nlh);
+	}
+
+out:	cb->args[0] = idx;
+	return skb->len;
+}
+
 static const struct rdma_nl_cbs nldev_cb_table[] = {
 	[RDMA_NLDEV_CMD_GET] = {
 		.doit = nldev_get_doit,
 		.dump = nldev_get_dumpit,
 	},
+	[RDMA_NLDEV_CMD_PORT_GET] = {
+		.dump = nldev_port_get_dumpit,
+	},
 };
 
 void __init nldev_init(void)
-- 
2.13.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
