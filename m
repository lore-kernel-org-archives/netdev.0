From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] bridge: fix br_stp_set_bridge_priority race conditions
Date: Mon, 15 Jun 2015 20:28:51 +0300
Message-ID: <1434389331-2376-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	joerg@higgsboson.tk, Nikolay Aleksandrov <razor@blackwall.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35414 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754109AbbFOR2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 13:28:55 -0400
Received: by wiga1 with SMTP id a1so85098589wig.0
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 10:28:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the ->set() spinlocks were removed br_stp_set_bridge_priority
was left running without any protection when used via sysfs. It can
race with port add/del and could result in use-after-free cases and
corrupted lists. Tested by running port add/del in a loop with stp
enabled while setting priority in a loop, crashes are easily
reproducible.
The spinlocks around sysfs ->set() were removed in commit:
14f98f258f19 ("bridge: range check STP parameters")
There's also a race condition in the netlink priority support that is
fixed by this change, but it was introduced recently and the fixes tag
covers it, just in case it's needed the commit is:
af615762e972 ("bridge: add ageing_time, stp_state, priority over netlink")

Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
Fixes: 14f98f258f19 ("bridge: range check STP parameters")
---
 net/bridge/br_ioctl.c  | 2 --
 net/bridge/br_stp_if.c | 4 +++-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index a9a4a1b7863d..8d423bc649b9 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -247,9 +247,7 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
-		spin_lock_bh(&br->lock);
 		br_stp_set_bridge_priority(br, args[1]);
-		spin_unlock_bh(&br->lock);
 		return 0;
 
 	case BRCTL_SET_PORT_PRIORITY:
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 41146872c1b4..7832d07f48f6 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -243,12 +243,13 @@ bool br_stp_recalculate_bridge_id(struct net_bridge *br)
 	return true;
 }
 
-/* called under bridge lock */
+/* Acquires and releases bridge lock */
 void br_stp_set_bridge_priority(struct net_bridge *br, u16 newprio)
 {
 	struct net_bridge_port *p;
 	int wasroot;
 
+	spin_lock_bh(&br->lock);
 	wasroot = br_is_root_bridge(br);
 
 	list_for_each_entry(p, &br->port_list, list) {
@@ -266,6 +267,7 @@ void br_stp_set_bridge_priority(struct net_bridge *br, u16 newprio)
 	br_port_state_selection(br);
 	if (br_is_root_bridge(br) && !wasroot)
 		br_become_root_bridge(br);
+	spin_unlock_bh(&br->lock);
 }
 
 /* called under bridge lock */
-- 
2.4.3
