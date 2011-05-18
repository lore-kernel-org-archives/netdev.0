From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] bridge: add notification over netlink when STP
 changes state
Date: Wed, 18 May 2011 08:17:18 -0700
Message-ID: <20110518081718.0b1fc390@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47719 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932851Ab1ERPRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2011 11:17:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first netlink code in the bridge module was to notify
user space implementations of Spanning Tree Protocol about
new ports. It did not handle the case of kernel mode STP 
changing states which could be useful for monitoring.

This patch causes RTM_NEWLINK message to occur on kernel
transitions. It does not send message if request was from user
space STP, since that would cause reflection and break existing
API.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 net/bridge/br_stp.c       |    4 +++-
 net/bridge/br_stp_if.c    |    3 +++
 net/bridge/br_stp_timer.c |    1 +
 3 files changed, 7 insertions(+), 1 deletion(-)

--- a/net/bridge/br_stp.c	2011-04-15 14:09:10.700851052 -0700
+++ b/net/bridge/br_stp.c	2011-05-17 10:06:09.006014826 -0700
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
--- a/net/bridge/br_stp_if.c	2011-04-15 14:09:10.700851052 -0700
+++ b/net/bridge/br_stp_if.c	2011-05-17 10:06:09.006014826 -0700
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
--- a/net/bridge/br_stp_timer.c	2011-04-04 09:21:25.963009153 -0700
+++ b/net/bridge/br_stp_timer.c	2011-05-17 10:06:09.018014957 -0700
@@ -97,6 +97,7 @@ static void br_forward_delay_timer_expir
 		netif_carrier_on(br->dev);
 	}
 	br_log_state(p);
+	br_ifinfo_notify(RTM_NEWLINK, p);
 	spin_unlock(&br->lock);
 }
 
