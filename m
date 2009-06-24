From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 2/3] wext: optimise, comment and fix event sending
Date: Wed, 24 Jun 2009 13:34:49 +0200
Message-ID: <20090624113731.764420902@sipsolutions.net>
References: <20090624113447.441667549@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:52162 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759451AbZFXLje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 07:39:34 -0400
Content-Disposition: inline; filename=004-wext-optimise-avoid-leak.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current function for sending events first allocates the
event stream buffer, and then an skb to copy the event stream
into. This can be done in one go. Also, the current function
leaks kernel data to userspace in a 4 uninitialised bytes,
initialise those explicitly. Finally also add a few useful
comments, as opposed to the current comments.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 net/wireless/wext.c |  114 ++++++++++++++++++++++++++--------------------------
 1 file changed, 57 insertions(+), 57 deletions(-)

--- wireless-testing.orig/net/wireless/wext.c	2009-06-24 13:31:15.000000000 +0200
+++ wireless-testing/net/wireless/wext.c	2009-06-24 13:31:17.000000000 +0200
@@ -1293,22 +1293,15 @@ static void wireless_nlevent_process(str
 
 static DECLARE_WORK(wireless_nlevent_work, wireless_nlevent_process);
 
-/* ---------------------------------------------------------------- */
-/*
- * Fill a rtnetlink message with our event data.
- * Note that we propage only the specified event and don't dump the
- * current wireless config. Dumping the wireless config is far too
- * expensive (for each parameter, the driver need to query the hardware).
- */
-static int rtnetlink_fill_iwinfo(struct sk_buff *skb, struct net_device *dev,
-				 int type, char *event, int event_len)
+static struct nlmsghdr *rtnetlink_ifinfo_prep(struct net_device *dev,
+					      struct sk_buff *skb)
 {
 	struct ifinfomsg *r;
 	struct nlmsghdr  *nlh;
 
-	nlh = nlmsg_put(skb, 0, 0, type, sizeof(*r), 0);
-	if (nlh == NULL)
-		return -EMSGSIZE;
+	nlh = nlmsg_put(skb, 0, 0, RTM_NEWLINK, sizeof(*r), 0);
+	if (!nlh)
+		return NULL;
 
 	r = nlmsg_data(nlh);
 	r->ifi_family = AF_UNSPEC;
@@ -1319,45 +1312,14 @@ static int rtnetlink_fill_iwinfo(struct 
 	r->ifi_change = 0;	/* Wireless changes don't affect those flags */
 
 	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
-	/* Add the wireless events in the netlink packet */
-	NLA_PUT(skb, IFLA_WIRELESS, event_len, event);
-
-	return nlmsg_end(skb, nlh);
 
-nla_put_failure:
+	return nlh;
+ nla_put_failure:
 	nlmsg_cancel(skb, nlh);
-	return -EMSGSIZE;
+	return NULL;
 }
 
-/* ---------------------------------------------------------------- */
-/*
- * Create and broadcast and send it on the standard rtnetlink socket
- * This is a pure clone rtmsg_ifinfo() in net/core/rtnetlink.c
- * Andrzej Krzysztofowicz mandated that I used a IFLA_XXX field
- * within a RTM_NEWLINK event.
- */
-static void rtmsg_iwinfo(struct net_device *dev, char *event, int event_len)
-{
-	struct sk_buff *skb;
-	int err;
-
-	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
-	if (!skb)
-		return;
-
-	err = rtnetlink_fill_iwinfo(skb, dev, RTM_NEWLINK, event, event_len);
-	if (err < 0) {
-		WARN_ON(err == -EMSGSIZE);
-		kfree_skb(skb);
-		return;
-	}
-
-	NETLINK_CB(skb).dst_group = RTNLGRP_LINK;
-	skb_queue_tail(&dev_net(dev)->wext_nlevents, skb);
-	schedule_work(&wireless_nlevent_work);
-}
 
-/* ---------------------------------------------------------------- */
 /*
  * Main event dispatcher. Called from other parts and drivers.
  * Send the event on the appropriate channels.
@@ -1376,6 +1338,9 @@ void wireless_send_event(struct net_devi
 	int wrqu_off = 0;			/* Offset in wrqu */
 	/* Don't "optimise" the following variable, it will crash */
 	unsigned	cmd_index;		/* *MUST* be unsigned */
+	struct sk_buff *skb;
+	struct nlmsghdr *nlh;
+	struct nlattr *nla;
 
 	/* Get the description of the Event */
 	if (cmd <= SIOCIWLAST) {
@@ -1423,25 +1388,60 @@ void wireless_send_event(struct net_devi
 	hdr_len = event_type_size[descr->header_type];
 	event_len = hdr_len + extra_len;
 
-	/* Create temporary buffer to hold the event */
-	event = kmalloc(event_len, GFP_ATOMIC);
-	if (event == NULL)
+	/*
+	 * The problem for 64/32 bit.
+	 *
+	 * On 64-bit, a regular event is laid out as follows:
+	 *      |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
+	 *      | event.len | event.cmd |     p a d d i n g     |
+	 *      | wrqu data ... (with the correct size)         |
+	 *
+	 * This padding exists because we manipulate event->u,
+	 * and 'event' is not packed.
+	 *
+	 * An iw_point event is laid out like this instead:
+	 *      |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
+	 *      | event.len | event.cmd |     p a d d i n g     |
+	 *      | iwpnt.len | iwpnt.flg |     p a d d i n g     |
+	 *      | extra data  ...
+	 *
+	 * The second padding exists because struct iw_point is extended,
+	 * but this depends on the platform...
+	 *
+	 * On 32-bit, all the padding shouldn't be there.
+	 */
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
+	if (!skb)
 		return;
 
-	/* Fill event */
+	/* Send via the RtNetlink event channel */
+	nlh = rtnetlink_ifinfo_prep(dev, skb);
+	if (WARN_ON(!nlh)) {
+		kfree_skb(skb);
+		return;
+	}
+
+	/* Add the wireless events in the netlink packet */
+	nla = nla_reserve(skb, IFLA_WIRELESS, event_len);
+	if (!nla) {
+		kfree_skb(skb);
+		return;
+	}
+	event = nla_data(nla);
+
+	/* Fill event - first clear to avoid data leaking */
+	memset(event, 0, hdr_len);
 	event->len = event_len;
 	event->cmd = cmd;
 	memcpy(&event->u, ((char *) wrqu) + wrqu_off, hdr_len - IW_EV_LCP_LEN);
-	if (extra)
+	if (extra_len)
 		memcpy(((char *) event) + hdr_len, extra, extra_len);
 
-	/* Send via the RtNetlink event channel */
-	rtmsg_iwinfo(dev, (char *) event, event_len);
-
-	/* Cleanup */
-	kfree(event);
+	nlmsg_end(skb, nlh);
 
-	return;		/* Always success, I guess ;-) */
+	skb_queue_tail(&dev_net(dev)->wext_nlevents, skb);
+	schedule_work(&wireless_nlevent_work);
 }
 EXPORT_SYMBOL(wireless_send_event);
 

-- 

