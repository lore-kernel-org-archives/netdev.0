From: roopa@cumulusnetworks.com
Subject: [PATCH net-next] bridge: add missing bridge port check for offloads
Date: Thu,  5 Feb 2015 22:24:45 -0800
Message-ID: <1423203885-45657-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net
To: bridge@lists.linux-foundation.org, dan.carpenter@oracle.com,
	stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:36814 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754557AbbBFGYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 01:24:50 -0500
Received: by pdjp10 with SMTP id p10so2733451pdj.3
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 22:24:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch fixes a missing bridge port check caught by smatch.

setlink/dellink of attributes like vlans can come for a bridge device
and there is no need to offload those today. So, this patch adds a bridge
port check. (In these cases however, the BRIDGE_SELF flags will always be set
and we may not hit a problem with the current code).

smatch complaint:

The patch 68e331c785b8: "bridge: offload bridge port attributes to
switch asic if feature flag set" from Jan 29, 2015, leads to the
following Smatch complaint:

net/bridge/br_netlink.c:552 br_setlink()
	 error: we previously assumed 'p' could be null (see line 518)

net/bridge/br_netlink.c
   517
   518		if (p && protinfo) {
                    ^
Check for NULL.

Reported-By: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index b93f42c..4fbcea0 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -543,7 +543,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 				afspec, RTM_SETLINK);
 	}
 
-	if (!(flags & BRIDGE_FLAGS_SELF)) {
+	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
 		/* set bridge attributes in hardware if supported
 		 */
 		ret_offload = netdev_switch_port_bridge_setlink(dev, nlh,
@@ -583,7 +583,7 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 		 */
 		br_ifinfo_notify(RTM_NEWLINK, p);
 
-	if (!(flags & BRIDGE_FLAGS_SELF)) {
+	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
 		/* del bridge attributes in hardware
 		 */
 		ret_offload = netdev_switch_port_bridge_dellink(dev, nlh,
-- 
1.7.10.4
