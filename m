From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next 16/19] RDMa/netlink: Add nldev device doit implementation
Date: Wed, 21 Jun 2017 09:05:25 +0300
Message-ID: <20170621060528.3752-17-leon@kernel.org>
References: <20170621060528.3752-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57730 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751071AbdFUGF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 02:05:57 -0400
In-Reply-To: <20170621060528.3752-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Provide ability to query specific device.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/nldev.c | 40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index 219b52166c46..8d3fd9b58cc1 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -50,6 +50,45 @@ static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
 	return 0;
 }
 
+static int nldev_get_doit(struct sk_buff *skb, struct nlmsghdr *nlh,
+			  struct netlink_ext_ack *extack)
+{
+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX];
+	char name[IB_DEVICE_NAME_MAX];
+	struct ib_device *device;
+	struct sk_buff *msg;
+	int err;
+
+	err = nlmsg_parse(nlh, 0, tb, RDMA_NLDEV_ATTR_MAX,
+			  nldev_policy, extack);
+	if (err || !tb[RDMA_NLDEV_ATTR_DEV_NAME])
+		return -EINVAL;
+
+	nla_strlcpy(name, tb[RDMA_NLDEV_ATTR_DEV_NAME], IB_DEVICE_NAME_MAX);
+
+	device = __ib_device_get_by_name(name);
+	if (!device)
+		return -EINVAL;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	nlh = nlmsg_put(msg, NETLINK_CB(skb).portid, nlh->nlmsg_seq,
+			RDMA_NL_GET_TYPE(RDMA_NL_NLDEV, RDMA_NLDEV_CMD_GET),
+			0, 0);
+
+	err = fill_dev_info(msg, device);
+	if (err) {
+		nlmsg_free(msg);
+		return err;
+	}
+
+	nlmsg_end(msg, nlh);
+
+	return rdma_nl_unicast(msg, NETLINK_CB(skb).portid);
+}
+
 static int _nldev_get_dumpit(struct ib_device *device,
 			     struct sk_buff *skb,
 			     struct netlink_callback *cb,
@@ -89,6 +128,7 @@ static int nldev_get_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 
 static const struct rdma_nl_cbs nldev_cb_table[] = {
 	[RDMA_NLDEV_CMD_GET] = {
+		.doit = nldev_get_doit,
 		.dump = nldev_get_dumpit,
 	},
 };
-- 
2.13.1
