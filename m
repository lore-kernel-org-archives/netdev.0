From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] drop_monitor: Update netlink protocol to include netlink
	attribute header in alert message
Date: Thu, 23 Apr 2009 16:05:48 -0400
Message-ID: <20090423200548.GE30405@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33166 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbZDWUFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 16:05:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I initially implemented this protocol, I disregarded the use of netlink
attribute headers, thinking for my purposes they weren't needed.  I've come to
find out that, as I'm starting to work with sending down messages with
associated data (like config messages), the kernel code spits out warnings about
trailing data in a netlink skb that doesn't have an associated header on it.  As
such, I'm going to start including attribute headers in my netlink transaction,
and so for completeness, I should likely include them on messages bound from the
kernel to user space.  This patch adds that header to the kernel, and bumps the
protocol version accordingly

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 drop_monitor.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)


diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 9fd0dc3..2797b71 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -51,7 +51,7 @@ static struct genl_family net_drop_monitor_family = {
 	.id             = GENL_ID_GENERATE,
 	.hdrsize        = 0,
 	.name           = "NET_DM",
-	.version        = 1,
+	.version        = 2,
 	.maxattr        = NET_DM_CMD_MAX,
 };
 
@@ -65,13 +65,17 @@ static void reset_per_cpu_data(struct per_cpu_dm_data *data)
 {
 	size_t al;
 	struct net_dm_alert_msg *msg;
+	struct nlattr *nla;
 
 	al = sizeof(struct net_dm_alert_msg);
 	al += dm_hit_limit * sizeof(struct net_dm_drop_point);
+	al += sizeof(struct nlattr);
+
 	data->skb = genlmsg_new(al, GFP_KERNEL);
 	genlmsg_put(data->skb, 0, 0, &net_drop_monitor_family,
 			0, NET_DM_CMD_ALERT);
-	msg = __nla_reserve_nohdr(data->skb, sizeof(struct net_dm_alert_msg));
+	nla = nla_reserve(data->skb, NLA_UNSPEC, sizeof(struct net_dm_alert_msg));
+	msg = nla_data(nla);
 	memset(msg, 0, al);
 	atomic_set(&data->dm_hit_count, dm_hit_limit);
 }
@@ -115,6 +119,7 @@ static void trace_kfree_skb_hit(struct sk_buff *skb, void *location)
 {
 	struct net_dm_alert_msg *msg;
 	struct nlmsghdr *nlh;
+	struct nlattr *nla;
 	int i;
 	struct per_cpu_dm_data *data = &__get_cpu_var(dm_cpu_data);
 
@@ -127,7 +132,8 @@ static void trace_kfree_skb_hit(struct sk_buff *skb, void *location)
 	}
 
 	nlh = (struct nlmsghdr *)data->skb->data;
-	msg = genlmsg_data(nlmsg_data(nlh));
+	nla = genlmsg_data(nlmsg_data(nlh));
+	msg = nla_data(nla);
 	for (i = 0; i < msg->entries; i++) {
 		if (!memcmp(&location, msg->points[i].pc, sizeof(void *))) {
 			msg->points[i].count++;
@@ -139,6 +145,7 @@ static void trace_kfree_skb_hit(struct sk_buff *skb, void *location)
 	 * We need to create a new entry
 	 */
 	__nla_reserve_nohdr(data->skb, sizeof(struct net_dm_drop_point));
+	nla->nla_len += NLA_ALIGN(sizeof(struct net_dm_drop_point));
 	memcpy(msg->points[msg->entries].pc, &location, sizeof(void *));
 	msg->points[msg->entries].count = 1;
 	msg->entries++;
