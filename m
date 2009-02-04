From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] netlink: change return-value logic of netlink_broadcast()
Date: Wed, 04 Feb 2009 21:13:03 +0100
Message-ID: <20090204201303.15404.76336.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43636 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756877AbZBDUNK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 15:13:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, netlink_broadcast() reports errors to the caller if no
messages at all were delivered:

1) If, at least, one message has been delivered correctly, returns 0.
2) Otherwise, if no messages at all were delivered due to skb_clone()
   failure, return -ENOBUFS.
3) Otherwise, if there are no listeners, return -ESRCH.

With this patch, the caller knows if the delivery of any of the
messages to the listeners have failed:

1) If it fails to deliver any message (for whatever reason), return
   -ENOBUFS.
2) Otherwise, if all messages were delivered OK, returns 0.
3) Otherwise, if no listeners, return -ESRCH.

In the current ctnetlink code and in Netfilter in general, we can add
reliable logging and connection tracking event delivery by dropping the
packets whose events were not successfully delivered over Netlink. Of
course, this option would be settable via /proc as this approach reduces
performance (in terms of filtered connections per seconds by a stateful
firewall) but providing reliable logging and event delivery (for
conntrackd) in return.

This patch also changes some clients of netlink_broadcast() that
may report ENOBUFS errors via printk. This error handling is not
of any help. Instead, the userspace daemons that are listening to
those netlink messages should resync themselves with the kernel-side
if they hit ENOBUFS.

BTW, netlink_broadcast() clients include those that call
cn_netlink_send(), nlmsg_multicast() and genlmsg_multicast() since they
internally call netlink_broadcast() and return its error value.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---

 drivers/acpi/event.c                |    6 +-----
 drivers/scsi/scsi_transport_fc.c    |   16 ++++------------
 drivers/scsi/scsi_transport_iscsi.c |   12 ++----------
 drivers/video/uvesafb.c             |    5 ++++-
 fs/dquot.c                          |    5 +----
 lib/kobject_uevent.c                |    3 +++
 net/netlink/af_netlink.c            |    8 ++++++--
 net/wimax/op-msg.c                  |    9 +++------
 net/wimax/stack.c                   |   12 ++++--------
 9 files changed, 28 insertions(+), 48 deletions(-)

diff --git a/drivers/acpi/event.c b/drivers/acpi/event.c
index 0c24bd4..aeb7e5f 100644
--- a/drivers/acpi/event.c
+++ b/drivers/acpi/event.c
@@ -235,11 +235,7 @@ int acpi_bus_generate_netlink_event(const char *device_class,
 		return result;
 	}
 
-	result =
-	    genlmsg_multicast(skb, 0, acpi_event_mcgrp.id, GFP_ATOMIC);
-	if (result)
-		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
-				  "Failed to send a Genetlink message!\n"));
+	genlmsg_multicast(skb, 0, acpi_event_mcgrp.id, GFP_ATOMIC);
 	return 0;
 }
 
diff --git a/drivers/scsi/scsi_transport_fc.c b/drivers/scsi/scsi_transport_fc.c
index 5f77417..3ee4eb4 100644
--- a/drivers/scsi/scsi_transport_fc.c
+++ b/drivers/scsi/scsi_transport_fc.c
@@ -533,12 +533,8 @@ fc_host_post_event(struct Scsi_Host *shost, u32 event_number,
 	event->event_code = event_code;
 	event->event_data = event_data;
 
-	err = nlmsg_multicast(scsi_nl_sock, skb, 0, SCSI_NL_GRP_FC_EVENTS,
-			      GFP_KERNEL);
-	if (err && (err != -ESRCH))	/* filter no recipient errors */
-		/* nlmsg_multicast already kfree_skb'd */
-		goto send_fail;
-
+	nlmsg_multicast(scsi_nl_sock, skb, 0, SCSI_NL_GRP_FC_EVENTS,
+			GFP_KERNEL);
 	return;
 
 send_fail_skb:
@@ -607,12 +603,8 @@ fc_host_post_vendor_event(struct Scsi_Host *shost, u32 event_number,
 	event->event_code = FCH_EVT_VENDOR_UNIQUE;
 	memcpy(&event->event_data, data_buf, data_len);
 
-	err = nlmsg_multicast(scsi_nl_sock, skb, 0, SCSI_NL_GRP_FC_EVENTS,
-			      GFP_KERNEL);
-	if (err && (err != -ESRCH))	/* filter no recipient errors */
-		/* nlmsg_multicast already kfree_skb'd */
-		goto send_vendor_fail;
-
+	nlmsg_multicast(scsi_nl_sock, skb, 0, SCSI_NL_GRP_FC_EVENTS,
+			GFP_KERNEL);
 	return;
 
 send_vendor_fail_skb:
diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 75c9297..2adfab8 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -966,15 +966,7 @@ iscsi_if_transport_lookup(struct iscsi_transport *tt)
 static int
 iscsi_broadcast_skb(struct sk_buff *skb, gfp_t gfp)
 {
-	int rc;
-
-	rc = netlink_broadcast(nls, skb, 0, 1, gfp);
-	if (rc < 0) {
-		printk(KERN_ERR "iscsi: can not broadcast skb (%d)\n", rc);
-		return rc;
-	}
-
-	return 0;
+	return netlink_broadcast(nls, skb, 0, 1, gfp);
 }
 
 static int
@@ -1207,7 +1199,7 @@ int iscsi_session_event(struct iscsi_cls_session *session,
 	 * the user and when the daemon is restarted it will handle it
 	 */
 	rc = iscsi_broadcast_skb(skb, GFP_KERNEL);
-	if (rc < 0)
+	if (rc == -ESRCH)
 		iscsi_cls_session_printk(KERN_ERR, session,
 					 "Cannot notify userspace of session "
 					 "event %u. Check iscsi daemon\n",
diff --git a/drivers/video/uvesafb.c b/drivers/video/uvesafb.c
index 6c2d37f..74ae758 100644
--- a/drivers/video/uvesafb.c
+++ b/drivers/video/uvesafb.c
@@ -204,8 +204,11 @@ static int uvesafb_exec(struct uvesafb_ktask *task)
 		} else {
 			v86d_started = 1;
 			err = cn_netlink_send(m, 0, gfp_any());
+			if (err == -ENOBUFS)
+				err = 0;
 		}
-	}
+	} else if (err == -ENOBUFS)
+		err = 0;
 
 	if (!err && !(task->t.flags & TF_EXIT))
 		err = !wait_for_completion_timeout(task->done,
diff --git a/fs/dquot.c b/fs/dquot.c
index bca3cac..d6add0b 100644
--- a/fs/dquot.c
+++ b/fs/dquot.c
@@ -1057,10 +1057,7 @@ static void send_warning(const struct dquot *dquot, const char warntype)
 		goto attr_err_out;
 	genlmsg_end(skb, msg_head);
 
-	ret = genlmsg_multicast(skb, 0, quota_genl_family.id, GFP_NOFS);
-	if (ret < 0 && ret != -ESRCH)
-		printk(KERN_ERR
-			"VFS: Failed to send notification message: %d\n", ret);
+	genlmsg_multicast(skb, 0, quota_genl_family.id, GFP_NOFS);
 	return;
 attr_err_out:
 	printk(KERN_ERR "VFS: Not enough space to compose quota message!\n");
diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 318328d..3813102 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -227,6 +227,9 @@ int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 			NETLINK_CB(skb).dst_group = 1;
 			retval = netlink_broadcast(uevent_sock, skb, 0, 1,
 						   GFP_KERNEL);
+			/* ENOBUFS should be handled in userspace */
+			if (retval == -ENOBUFS)
+				retval = 0;
 		} else
 			retval = -ENOMEM;
 	}
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 9eb895c..6ee69c2 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -950,6 +950,7 @@ struct netlink_broadcast_data {
 	u32 pid;
 	u32 group;
 	int failure;
+	int delivery_failure;
 	int congested;
 	int delivered;
 	gfp_t allocation;
@@ -999,6 +1000,7 @@ static inline int do_one_broadcast(struct sock *sk,
 		p->skb2 = NULL;
 	} else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
 		netlink_overrun(sk);
+		p->delivery_failure = 1;
 	} else {
 		p->congested |= val;
 		p->delivered = 1;
@@ -1025,6 +1027,7 @@ int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 	info.pid = pid;
 	info.group = group;
 	info.failure = 0;
+	info.delivery_failure = 0;
 	info.congested = 0;
 	info.delivered = 0;
 	info.allocation = allocation;
@@ -1045,13 +1048,14 @@ int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 	if (info.skb2)
 		kfree_skb(info.skb2);
 
+	if (info.delivery_failure || info.failure)
+		return -ENOBUFS;
+
 	if (info.delivered) {
 		if (info.congested && (allocation & __GFP_WAIT))
 			yield();
 		return 0;
 	}
-	if (info.failure)
-		return -ENOBUFS;
 	return -ESRCH;
 }
 EXPORT_SYMBOL(netlink_broadcast);
diff --git a/net/wimax/op-msg.c b/net/wimax/op-msg.c
index cb3b4ad..5d149c1 100644
--- a/net/wimax/op-msg.c
+++ b/net/wimax/op-msg.c
@@ -258,7 +258,6 @@ EXPORT_SYMBOL_GPL(wimax_msg_len);
  */
 int wimax_msg_send(struct wimax_dev *wimax_dev, struct sk_buff *skb)
 {
-	int result;
 	struct device *dev = wimax_dev->net_dev->dev.parent;
 	void *msg = skb->data;
 	size_t size = skb->len;
@@ -266,11 +265,9 @@ int wimax_msg_send(struct wimax_dev *wimax_dev, struct sk_buff *skb)
 
 	d_printf(1, dev, "CTX: wimax msg, %zu bytes\n", size);
 	d_dump(2, dev, msg, size);
-	result = genlmsg_multicast(skb, 0, wimax_gnl_mcg.id, GFP_KERNEL);
-	d_printf(1, dev, "CTX: genl multicast result %d\n", result);
-	if (result == -ESRCH)	/* Nobody connected, ignore it */
-		result = 0;	/* btw, the skb is freed already */
-	return result;
+	genlmsg_multicast(skb, 0, wimax_gnl_mcg.id, GFP_KERNEL);
+	d_printf(1, dev, "CTX: genl multicast done\n");
+	return 0;
 }
 EXPORT_SYMBOL_GPL(wimax_msg_send);
 
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 3869c03..a0ee76b 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -163,16 +163,12 @@ int wimax_gnl_re_state_change_send(
 	struct device *dev = wimax_dev_to_dev(wimax_dev);
 	d_fnstart(3, dev, "(wimax_dev %p report_skb %p)\n",
 		  wimax_dev, report_skb);
-	if (report_skb == NULL)
+	if (report_skb == NULL) {
+		result = -ENOMEM;
 		goto out;
-	genlmsg_end(report_skb, header);
-	result = genlmsg_multicast(report_skb, 0, wimax_gnl_mcg.id, GFP_KERNEL);
-	if (result == -ESRCH)	/* Nobody connected, ignore it */
-		result = 0;	/* btw, the skb is freed already */
-	if (result < 0) {
-		dev_err(dev, "RE_STCH: Error sending: %d\n", result);
-		nlmsg_free(report_skb);
 	}
+	genlmsg_end(report_skb, header);
+	genlmsg_multicast(report_skb, 0, wimax_gnl_mcg.id, GFP_KERNEL);
 out:
 	d_fnend(3, dev, "(wimax_dev %p report_skb %p) = %d\n",
 		wimax_dev, report_skb, result);

