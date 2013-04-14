From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] bridge: make user modified path cost sticky
Date: Sat, 13 Apr 2013 17:06:07 -0700
Message-ID: <20130413170607.2a9294f6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:41447 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955Ab3DNAGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 20:06:32 -0400
Received: by mail-da0-f53.google.com with SMTP id n34so1586534dal.26
        for <netdev@vger.kernel.org>; Sat, 13 Apr 2013 17:06:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep a STP port path cost value if it was set by a user.
Don't replace it with the link-speed based path cost
whenever the link goes down and comes back up.

Reported-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 net/bridge/br_if.c      |    3 ++-
 net/bridge/br_private.h |    1 +
 net/bridge/br_stp_if.c  |    1 +
 3 files changed, 4 insertions(+), 1 deletion(-)

--- a/net/bridge/br_private.h	2013-03-14 14:22:58.155958025 -0700
+++ b/net/bridge/br_private.h	2013-04-13 09:16:41.712531648 -0700
@@ -156,6 +156,7 @@ struct net_bridge_port
 #define BR_BPDU_GUARD           0x00000002
 #define BR_ROOT_BLOCK		0x00000004
 #define BR_MULTICAST_FAST_LEAVE	0x00000008
+#define BR_ADMIN_COST		0x00000010
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	u32				multicast_startup_queries_sent;
--- a/net/bridge/br_stp_if.c	2013-03-07 18:12:53.885287247 -0800
+++ b/net/bridge/br_stp_if.c	2013-04-13 09:19:58.437979528 -0700
@@ -288,6 +288,7 @@ int br_stp_set_path_cost(struct net_brid
 	    path_cost > BR_MAX_PATH_COST)
 		return -ERANGE;
 
+	p->flags |= BR_ADMIN_COST;
 	p->path_cost = path_cost;
 	br_configuration_update(p->br);
 	br_port_state_selection(p->br);
--- a/net/bridge/br_if.c	2013-04-09 16:10:57.553418004 -0700
+++ b/net/bridge/br_if.c	2013-04-13 09:24:07.274751368 -0700
@@ -67,7 +67,8 @@ void br_port_carrier_check(struct net_br
 	struct net_device *dev = p->dev;
 	struct net_bridge *br = p->br;
 
-	if (netif_running(dev) && netif_oper_up(dev))
+	if (!(p->flags & BR_ADMIN_COST) &&
+	    netif_running(dev) && netif_oper_up(dev))
 		p->path_cost = port_cost(dev);
 
 	if (!netif_running(br->dev))
