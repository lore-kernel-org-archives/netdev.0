From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] bridge: respect RFC2863 operational state
Date: Thu, 27 Dec 2012 22:28:54 -0800
Message-ID: <20121227222854.6ec132dd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40101 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750826Ab2L1GaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 01:30:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridge link detection should follow the operational state
of the lower device, rather than the carrier bit. This allows devices
like tunnels that are controlled by userspace control plane to work
with bridge STP link management.


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_if.c	2012-10-25 09:11:15.627272524 -0700
+++ b/net/bridge/br_if.c	2012-12-14 08:58:14.329847361 -0800
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
+	if (netif_running(dev) && netif_oper_up(dev))
 		if (p->state == BR_STATE_DISABLED)
 			br_stp_enable_port(p);
 	} else {
--- a/net/bridge/br_notify.c	2012-10-25 09:11:15.631272484 -0700
+++ b/net/bridge/br_notify.c	2012-12-14 08:57:36.954222724 -0800
@@ -82,7 +82,7 @@ static int br_device_event(struct notifi
 		break;
 
 	case NETDEV_UP:
-		if (netif_carrier_ok(dev) && (br->dev->flags & IFF_UP)) {
+		if (netif_running(br->dev) && netif_oper_up(dev)) {
 			spin_lock_bh(&br->lock);
 			br_stp_enable_port(p);
 			spin_unlock_bh(&br->lock);
