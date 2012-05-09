From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH] netlink: connector: implement cn_netlink_reply
Date: Wed,  9 May 2012 15:37:23 +0100
Message-ID: <1336574243-12063-1-git-send-email-alban.crequy@collabora.co.uk>
Cc: netdev@vger.kernel.org,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Alban Crequy <alban.crequy@collabora.co.uk>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:49302 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754187Ab2EIOuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 10:50:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
Acked-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
CC: Rodrigo Moya <rodrigo.moya@collabora.co.uk>
CC: Evgeniy Polyakov <zbr@ioremap.net>
---
 drivers/connector/connector.c |   32 ++++++++++++++++++++++++++++++++
 include/linux/connector.h     |    1 +
 2 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index dde6a0f..1cb488d 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -118,6 +118,38 @@ nlmsg_failure:
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
+	nlh = NLMSG_PUT(skb, 0, msg->seq, NLMSG_DONE, size - sizeof(*nlh));
+
+	data = NLMSG_DATA(nlh);
+
+	memcpy(data, msg, sizeof(*data) + msg->len);
+
+	return netlink_unicast(dev->nls, skb, pid, 1);
+
+nlmsg_failure:
+	kfree_skb(skb);
+	return -EINVAL;
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
1.7.2.5
