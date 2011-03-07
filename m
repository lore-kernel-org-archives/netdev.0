From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge:  control carrier based on ports online
Date: Mon, 7 Mar 2011 10:34:06 -0800
Message-ID: <20110307103406.27330529@nehalam>
References: <1649722795.14144.1299480074110.JavaMail.root@tahiti.vyatta.com>
 <4D748CC3.8060603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>, Adam Majer <adamm@zombino.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40176 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752526Ab1CGSeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 13:34:11 -0500
In-Reply-To: <4D748CC3.8060603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes the bridge device behave like a physical device.
In earlier releases the bridge always asserted carrier. This
changes the behavior so that bridge device carrier is on only
if one or more ports are in the forwarding state. This
should help IPv6 autoconfiguration, DHCP, and routing daemons.

I did brief testing with Network and Virt manager and they
seem fine, but since this changes behavior of bridge, it should
wait until net-next (2.6.39).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/br_device.c    |    4 ++++
 net/bridge/br_stp.c       |   35 ++++++++++++++++++++++-------------
 net/bridge/br_stp_timer.c |    1 +
 3 files changed, 27 insertions(+), 13 deletions(-)

--- a/net/bridge/br_device.c	2011-03-07 08:40:08.913599513 -0800
+++ b/net/bridge/br_device.c	2011-03-07 08:40:48.382377389 -0800
@@ -78,6 +78,8 @@ static int br_dev_open(struct net_device
 {
 	struct net_bridge *br = netdev_priv(dev);
 
+	netif_carrier_off(dev);
+
 	br_features_recompute(br);
 	netif_start_queue(dev);
 	br_stp_enable_bridge(br);
@@ -94,6 +96,8 @@ static int br_dev_stop(struct net_device
 {
 	struct net_bridge *br = netdev_priv(dev);
 
+	netif_carrier_off(dev);
+
 	br_stp_disable_bridge(br);
 	br_multicast_stop(br);
 
--- a/net/bridge/br_stp.c	2011-03-07 08:41:58.619783678 -0800
+++ b/net/bridge/br_stp.c	2011-03-07 08:53:58.953558810 -0800
@@ -397,28 +397,37 @@ static void br_make_forwarding(struct ne
 void br_port_state_selection(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
+	unsigned int liveports = 0;
 
 	/* Don't change port states if userspace is handling STP */
 	if (br->stp_enabled == BR_USER_STP)
 		return;
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (p->state != BR_STATE_DISABLED) {
-			if (p->port_no == br->root_port) {
-				p->config_pending = 0;
-				p->topology_change_ack = 0;
-				br_make_forwarding(p);
-			} else if (br_is_designated_port(p)) {
-				del_timer(&p->message_age_timer);
-				br_make_forwarding(p);
-			} else {
-				p->config_pending = 0;
-				p->topology_change_ack = 0;
-				br_make_blocking(p);
-			}
+		if (p->state == BR_STATE_DISABLED)
+			continue;
+
+		if (p->port_no == br->root_port) {
+			p->config_pending = 0;
+			p->topology_change_ack = 0;
+			br_make_forwarding(p);
+		} else if (br_is_designated_port(p)) {
+			del_timer(&p->message_age_timer);
+			br_make_forwarding(p);
+		} else {
+			p->config_pending = 0;
+			p->topology_change_ack = 0;
+			br_make_blocking(p);
 		}
 
+		if (p->state == BR_STATE_FORWARDING)
+			++liveports;
 	}
+
+	if (liveports == 0)
+		netif_carrier_off(br->dev);
+	else
+		netif_carrier_on(br->dev);
 }
 
 /* called under bridge lock */
--- a/net/bridge/br_stp_timer.c	2011-03-07 08:53:25.728770710 -0800
+++ b/net/bridge/br_stp_timer.c	2011-03-07 08:53:40.273116636 -0800
@@ -94,6 +94,7 @@ static void br_forward_delay_timer_expir
 		p->state = BR_STATE_FORWARDING;
 		if (br_is_designated_for_some_port(br))
 			br_topology_change_detection(br);
+		netif_carrier_on(br->dev);
 	}
 	br_log_state(p);
 	spin_unlock(&br->lock);
