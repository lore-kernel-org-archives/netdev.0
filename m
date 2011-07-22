From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/5] [PATCH] bridge: add notification over netlink when STP changes state
Date: Fri, 22 Jul 2011 10:47:09 -0700
Message-ID: <20110722174758.196506941@vyatta.com>
References: <20110722174705.144993799@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davmeloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46802 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754149Ab1GVRus (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 13:50:48 -0400
Content-Disposition: inline; filename=bridge-notify-on-stp-change.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When STP changes state of interface need to send a new link
message to reflect that change.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
This is a revised version of earlier patch.

 net/bridge/br_netlink.c   |    2 ++
 net/bridge/br_stp.c       |    4 +++-
 net/bridge/br_stp_if.c    |    3 +++
 net/bridge/br_stp_timer.c |    1 +
 4 files changed, 9 insertions(+), 1 deletion(-)

--- a/net/bridge/br_stp.c	2011-07-21 20:13:31.651989371 -0700
+++ b/net/bridge/br_stp.c	2011-07-21 20:23:14.123989044 -0700
@@ -363,6 +363,8 @@ static void br_make_blocking(struct net_
 
 		p->state = BR_STATE_BLOCKING;
 		br_log_state(p);
+		br_ifinfo_notify(RTM_NEWLINK, p);
+
 		del_timer(&p->forward_delay_timer);
 	}
 }
@@ -386,8 +388,8 @@ static void br_make_forwarding(struct ne
 		p->state = BR_STATE_LEARNING;
 
 	br_multicast_enable_port(p);
-
 	br_log_state(p);
+	br_ifinfo_notify(RTM_NEWLINK, p);
 
 	if (br->forward_delay != 0)
 		mod_timer(&p->forward_delay_timer, jiffies + br->forward_delay);
--- a/net/bridge/br_stp_if.c	2011-07-20 09:06:24.491997816 -0700
+++ b/net/bridge/br_stp_if.c	2011-07-21 20:23:14.123989044 -0700
@@ -88,6 +88,7 @@ void br_stp_enable_port(struct net_bridg
 	br_init_port(p);
 	br_port_state_selection(p->br);
 	br_log_state(p);
+	br_ifinfo_notify(RTM_NEWLINK, p);
 }
 
 /* called under bridge lock */
@@ -104,6 +105,8 @@ void br_stp_disable_port(struct net_brid
 	p->topology_change_ack = 0;
 	p->config_pending = 0;
 
+	br_ifinfo_notify(RTM_NEWLINK, p);
+
 	del_timer(&p->message_age_timer);
 	del_timer(&p->forward_delay_timer);
 	del_timer(&p->hold_timer);
--- a/net/bridge/br_stp_timer.c	2011-07-20 09:06:24.507997816 -0700
+++ b/net/bridge/br_stp_timer.c	2011-07-21 20:23:14.123989044 -0700
@@ -97,6 +97,7 @@ static void br_forward_delay_timer_expir
 		netif_carrier_on(br->dev);
 	}
 	br_log_state(p);
+	br_ifinfo_notify(RTM_NEWLINK, p);
 	spin_unlock(&br->lock);
 }
 
--- a/net/bridge/br_netlink.c	2011-07-20 09:06:24.499997816 -0700
+++ b/net/bridge/br_netlink.c	2011-07-21 20:23:14.123989044 -0700
@@ -188,6 +188,8 @@ static int br_rtm_setlink(struct sk_buff
 
 	p->state = new_state;
 	br_log_state(p);
+	br_ifinfo_notify(RTM_NEWLINK, p);
+
 	return 0;
 }
 


