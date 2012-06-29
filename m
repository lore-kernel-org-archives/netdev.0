From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Subject: [PATCH net-next 11/15] netlink: connector: implement cn_netlink_reply
Date: Fri, 29 Jun 2012 17:45:50 +0100
Message-ID: <1340988354-26981-12-git-send-email-vincent.sanders@collabora.co.uk>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Cc: Alban Crequy <alban.crequy@collabora.co.uk>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban.crequy@collabora.co.uk>

In a connector callback, it was not possible to reply to a message only to a
sender. This patch implements cn_netlink_reply(). It uses the connector socket
to send an unicast netlink message back to the sender.

The following pseudo-code can be used from a connector callback:

        struct cn_msg *cn_reply;
        cn_reply = kzalloc(sizeof(struct cn_msg)
                + sizeof(struct ..._nl_cfg_reply), GFP_KERNEL);

        cn_reply->id = msg->id;
        cn_reply->seq = msg->seq;
        cn_reply->ack = msg->ack  + 1;
        cn_reply->len = sizeof(struct ..._nl_cfg_reply);
        cn_reply->flags = 0;

        rr = cn_netlink_reply(cn_reply, nsp->pid, GFP_KERNEL);

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 drivers/connector/connector.c |   32 ++++++++++++++++++++++++++++++++
 include/linux/connector.h     |    1 +
 2 files changed, 33 insertions(+)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 34e0e9e..a728d33 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -118,6 +118,38 @@ int cn_netlink_send(struct cn_msg *msg, u32 __group, gfp_t gfp_mask)
 EXPORT_SYMBOL_GPL(cn_netlink_send);
 
 /*
+ * Send an unicast reply from a connector callback
+ *
+ */
+int cn_netlink_reply(struct cn_msg *msg, u32 pid, gfp_t gfp_mask)
+{
+	unsigned int size;
+	struct sk_buff *skb;
+	struct nlmsghdr *nlh;
+	struct cn_msg *data;
+	struct cn_dev *dev = &cdev;
+
+	size = NLMSG_SPACE(sizeof(*msg) + msg->len);
+
+	skb = alloc_skb(size, gfp_mask);
+	if (!skb)
+		return -ENOMEM;
+
+	nlh = nlmsg_put(skb, 0, msg->seq, NLMSG_DONE, size - sizeof(*nlh), 0);
+	if (nlh == NULL) {
+		kfree_skb(skb);
+		return -EMSGSIZE;
+	}
+
+	data = nlmsg_data(nlh);
+
+	memcpy(data, msg, sizeof(*data) + msg->len);
+
+	return netlink_unicast(dev->nls, skb, pid, 1);
+}
+EXPORT_SYMBOL_GPL(cn_netlink_reply);
+
+/*
  * Callback helper - queues work and setup destructor for given data.
  */
 static int cn_call_callback(struct sk_buff *skb)
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 7638407..c27be60 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -125,6 +125,7 @@ int cn_add_callback(struct cb_id *id, const char *name,
 		    void (*callback)(struct cn_msg *, struct netlink_skb_parms *));
 void cn_del_callback(struct cb_id *);
 int cn_netlink_send(struct cn_msg *, u32, gfp_t);
+int cn_netlink_reply(struct cn_msg *, u32, gfp_t);
 
 int cn_queue_add_callback(struct cn_queue_dev *dev, const char *name,
 			  struct cb_id *id,
-- 
1.7.10
