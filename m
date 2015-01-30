From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v4 4/7] bridge: offload bridge port attributes to switch asic if feature flag set
Date: Thu, 29 Jan 2015 22:40:14 -0800
Message-ID: <1422600017-42393-5-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:38569 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbbA3Gk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 01:40:27 -0500
Received: by mail-pa0-f47.google.com with SMTP id lj1so48615411pab.6
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 22:40:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support to set/del bridge port attributes in hardware from
the bridge driver.

With this, when the user sends a bridge setlink message with no flags or
master flags set,
   - the bridge driver ndo_bridge_setlink handler sets settings in the kernel
   - calls the swicthdev api to propagate the attrs to the switchdev
	hardware

   You can still use the self flag to go to the switch hw or switch port
   driver directly.

With this, it also makes sure a notification goes out only after the
attributes are set both in the kernel and hw.

The patch calls switchdev api only if BRIDGE_FLAGS_SELF is not set.
This is because the offload cases with BRIDGE_FLAGS_SELF are handled in
the caller (in rtnetlink.c).

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |   26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 5b38221..a180706 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -16,6 +16,7 @@
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
+#include <net/switchdev.h>
 #include <uapi/linux/if_bridge.h>
 
 #include "br_private.h"
@@ -500,7 +501,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
 	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
-	int err = 0;
+	int err = 0, ret_offload = 0;
 
 	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_PROTINFO);
 	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
@@ -542,9 +543,18 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 				afspec, RTM_SETLINK);
 	}
 
+	if (!(flags & BRIDGE_FLAGS_SELF)) {
+		/* set bridge attributes in hardware if supported
+		 */
+		ret_offload = netdev_switch_port_bridge_setlink(dev, nlh,
+								flags);
+		if (ret_offload && ret_offload != -EOPNOTSUPP)
+			br_warn(p->br, "error setting attrs on port %u(%s)\n",
+				(unsigned int)p->port_no, p->dev->name);
+	}
+
 	if (err == 0)
 		br_ifinfo_notify(RTM_NEWLINK, p);
-
 out:
 	return err;
 }
@@ -554,7 +564,7 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 {
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
-	int err;
+	int err = 0, ret_offload = 0;
 
 	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
 	if (!afspec)
@@ -573,6 +583,16 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 		 */
 		br_ifinfo_notify(RTM_NEWLINK, p);
 
+	if (!(flags & BRIDGE_FLAGS_SELF)) {
+		/* del bridge attributes in hardware
+		 */
+		ret_offload = netdev_switch_port_bridge_dellink(dev, nlh,
+								flags);
+		if (ret_offload && ret_offload != -EOPNOTSUPP)
+			br_warn(p->br, "error deleting attrs on port %u (%s)\n",
+				(unsigned int)p->port_no, p->dev->name);
+	}
+
 	return err;
 }
 static int br_validate(struct nlattr *tb[], struct nlattr *data[])
-- 
1.7.10.4
