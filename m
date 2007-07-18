From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] enforce generic netlink multicast group API
Date: Thu, 19 Jul 2007 00:05:19 +0200
Message-ID: <1184796319.8125.28.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35623 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935689AbXGSKGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 06:06:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes genlmsg_multicast() to take a struct
genl_multicast_group * instead of the ID, that way users are forced to
register a group before being able to use genlmsg_multicast().

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
Just seemed like a good idea to enforce using this API so we won't get
into any trouble with somebody using the family number as the group,
nobody noticing and then being stuck with that userspace ABI. Not sure
if it's worth it, but it doesn't really make a difference code-wise, I
guess it shouldn't even generate different code.

---
 include/net/genetlink.h |    9 +++++----
 net/netlink/genetlink.c |   10 ++++++++--
 2 files changed, 13 insertions(+), 6 deletions(-)

--- wireless-dev.orig/include/net/genetlink.h	2007-07-18 23:54:48.680937160 +0200
+++ wireless-dev/include/net/genetlink.h	2007-07-18 23:55:44.330937160 +0200
@@ -7,7 +7,7 @@
 /**
  * struct genl_multicast_group - generic netlink multicast group
  * @name: name of the multicast group, names are per-family
- * @id: multicast group ID, assigned by the core, to use with
+ * @id: multicast group ID, assigned by the core, used by
  *      genlmsg_multicast().
  * @list: list entry for linking
  * @family: pointer to family, need not be set before registering
@@ -171,13 +171,14 @@ static inline int genlmsg_cancel(struct 
  * genlmsg_multicast - multicast a netlink message
  * @skb: netlink message as socket buffer
  * @pid: own netlink pid to avoid sending to yourself
- * @group: multicast group id
+ * @group: multicast group
  * @flags: allocation flags
  */
 static inline int genlmsg_multicast(struct sk_buff *skb, u32 pid,
-				    unsigned int group, gfp_t flags)
+				    struct genl_multicast_group *group,
+				    gfp_t flags)
 {
-	return nlmsg_multicast(genl_sock, skb, pid, group, flags);
+	return nlmsg_multicast(genl_sock, skb, pid, group->id, flags);
 }
 
 /**
--- wireless-dev.orig/net/netlink/genetlink.c	2007-07-18 23:54:08.210937160 +0200
+++ wireless-dev/net/netlink/genetlink.c	2007-07-18 23:59:29.470937160 +0200
@@ -730,7 +730,7 @@ static int genl_ctrl_event(int event, vo
 		if (IS_ERR(msg))
 			return PTR_ERR(msg);
 
-		genlmsg_multicast(msg, 0, GENL_ID_CTRL, GFP_KERNEL);
+		genlmsg_multicast(msg, 0, &notify_grp, GFP_KERNEL);
 		break;
 	case CTRL_CMD_NEWMCAST_GRP:
 	case CTRL_CMD_DELMCAST_GRP:
@@ -738,7 +738,7 @@ static int genl_ctrl_event(int event, vo
 		if (IS_ERR(msg))
 			return PTR_ERR(msg);
 
-		genlmsg_multicast(msg, 0, GENL_ID_CTRL, GFP_KERNEL);
+		genlmsg_multicast(msg, 0, &notify_grp, GFP_KERNEL);
 		break;
 	}
 
@@ -754,6 +754,12 @@ static struct genl_ops genl_ctrl_ops = {
 
 static struct genl_multicast_group notify_grp = {
 	.name		= "notify",
+	/*
+	 * The ID is fixed because it is userspace ABI,
+	 * pre-assign so we already have a valid one
+	 * during registration of the controller family.
+	 */
+	.id		= GENL_ID_CTRL,
 };
 
 static int __init genl_init(void)


