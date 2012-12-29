From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCHv2 net-next] bridge: respect RFC2863 operational state
Date: Fri, 28 Dec 2012 20:15:22 -0800
Message-ID: <20121228201522.62a48370@nehalam.linuxnetplumber.net>
References: <20121227222854.6ec132dd@nehalam.linuxnetplumber.net>
	<20121228.152754.707370216340290808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33780 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142Ab2L2Eg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 23:36:56 -0500
In-Reply-To: <20121228.152754.707370216340290808.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridge link detection should follow the operational state
of the lower device, rather than the carrier bit. This allows devices
like tunnels that are controlled by userspace control plane to work
with bridge STP link management.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - add more places and fix typo

 net/bridge/br_if.c      |    6 +++---
 net/bridge/br_netlink.c |    5 ++++-
 net/bridge/br_notify.c  |    2 +-
 net/bridge/br_stp_if.c  |    2 +-
 4 files changed, 9 insertions(+), 6 deletions(-)

--- a/net/bridge/br_if.c	2012-12-27 22:30:53.634796003 -0800
+++ b/net/bridge/br_if.c	2012-12-28 19:54:14.198973683 -0800
@@ -66,14 +66,14 @@ void br_port_carrier_check(struct net_br
 	struct net_device *dev = p->dev;
 	struct net_bridge *br = p->br;
 
-	if (netif_running(dev) && netif_carrier_ok(dev))
+	if (netif_running(dev) && netif_oper_up(dev))
 		p->path_cost = port_cost(dev);
 
 	if (!netif_running(br->dev))
 		return;
 
 	spin_lock_bh(&br->lock);
-	if (netif_running(dev) && netif_carrier_ok(dev)) {
+	if (netif_running(dev) && netif_oper_up(dev)) {
 		if (p->state == BR_STATE_DISABLED)
 			br_stp_enable_port(p);
 	} else {
@@ -383,7 +383,7 @@ int br_add_if(struct net_bridge *br, str
 	spin_lock_bh(&br->lock);
 	changed_addr = br_stp_recalculate_bridge_id(br);
 
-	if ((dev->flags & IFF_UP) && netif_carrier_ok(dev) &&
+	if (netif_running(dev) && netif_oper_up(dev) &&
 	    (br->dev->flags & IFF_UP))
 		br_stp_enable_port(p);
 	spin_unlock_bh(&br->lock);
--- a/net/bridge/br_notify.c	2012-12-27 22:30:23.547098173 -0800
+++ b/net/bridge/br_notify.c	2012-12-28 19:47:57.022761664 -0800
@@ -82,7 +82,7 @@ static int br_device_event(struct notifi
 		break;
 
 	case NETDEV_UP:
-		if (netif_carrier_ok(dev) && (br->dev->flags & IFF_UP)) {
+		if (netif_running(br->dev) && netif_oper_up(dev)) {
 			spin_lock_bh(&br->lock);
 			br_stp_enable_port(p);
 			spin_unlock_bh(&br->lock);
--- a/net/bridge/br_netlink.c	2012-12-27 11:36:34.813072288 -0800
+++ b/net/bridge/br_netlink.c	2012-12-28 19:52:24.180078602 -0800
@@ -181,8 +181,11 @@ static int br_set_port_state(struct net_
 	if (p->br->stp_enabled == BR_KERNEL_STP)
 		return -EBUSY;
 
+	/* if device is not up, change is not allowed
+	 * if link is not present, only allowable state is disabled
+	 */
 	if (!netif_running(p->dev) ||
-	    (!netif_carrier_ok(p->dev) && state != BR_STATE_DISABLED))
+	    (!netif_oper_up(p->dev) && state != BR_STATE_DISABLED))
 		return -ENETDOWN;
 
 	p->state = state;
--- a/net/bridge/br_stp_if.c	2012-10-29 09:07:36.618530493 -0700
+++ b/net/bridge/br_stp_if.c	2012-12-28 19:53:37.207345191 -0800
@@ -54,7 +54,7 @@ void br_stp_enable_bridge(struct net_bri
 	br_config_bpdu_generation(br);
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if ((p->dev->flags & IFF_UP) && netif_carrier_ok(p->dev))
+		if (netif_running(p->dev) && netif_oper_up(p->dev))
 			br_stp_enable_port(p);
 
 	}
