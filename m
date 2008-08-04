From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Eliminate unnecessary forward delay
Date: Tue, 5 Aug 2008 01:04:39 +0800
Message-ID: <20080804170439.GA13546@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36952 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753273AbYHDREq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 13:04:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

bridge: Eliminate unnecessary forward delay

When the forward delay is set to zero, we still delay the setting
of the forwarding state by one or possibly two timers depending
on whether STP is enabled.  This could either turn out to be
instantaneous, or horribly slow depending on the load of the
machine.

As there is nothing preventing us from enabling forwarding straight
away, this patch eliminates this potential delay by executing the
code directly if the forward delay is zero.

The effect of this problem is that immediately after the carrier
comes on a port, the bridge will drop all packets received from
that port until it enters forwarding mode, thus causing unnecessary
packet loss.

Note that this patch doesn't fully remove the delay due to the
link watcher.  We should also check the carrier state when we
are about to drop an incoming packet because the port is disabled.
But that's for another patch.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_private_stp.h b/net/bridge/br_private_stp.h
index 8b650f7..c612c02 100644
--- a/net/bridge/br_private_stp.h
+++ b/net/bridge/br_private_stp.h
@@ -53,4 +53,7 @@ extern void br_topology_change_detection(struct net_bridge *br);
 extern void br_send_config_bpdu(struct net_bridge_port *, struct br_config_bpdu *);
 extern void br_send_tcn_bpdu(struct net_bridge_port *);
 
+/* br_stp_timer.c */
+void __br_forward_delay_timer_expired(struct net_bridge_port *p);
+
 #endif
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 921bbe5..70e0890 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -375,7 +375,12 @@ static void br_make_forwarding(struct net_bridge_port *p)
 			p->state = BR_STATE_LEARNING;
 
 		br_log_state(p);
-		mod_timer(&p->forward_delay_timer, jiffies + p->br->forward_delay);	}
+		if (p->br->forward_delay)
+			mod_timer(&p->forward_delay_timer,
+				  jiffies + p->br->forward_delay);
+		else
+			__br_forward_delay_timer_expired(p);
+	}
 }
 
 /* called under bridge lock */
diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 772a140..c061907 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -82,24 +82,41 @@ static void br_message_age_timer_expired(unsigned long arg)
 	spin_unlock(&br->lock);
 }
 
-static void br_forward_delay_timer_expired(unsigned long arg)
+/* called under bridge lock */
+void __br_forward_delay_timer_expired(struct net_bridge_port *p)
 {
-	struct net_bridge_port *p = (struct net_bridge_port *) arg;
 	struct net_bridge *br = p->br;
 
 	pr_debug("%s: %d(%s) forward delay timer\n",
 		 br->dev->name, p->port_no, p->dev->name);
-	spin_lock(&br->lock);
+
 	if (p->state == BR_STATE_LISTENING) {
 		p->state = BR_STATE_LEARNING;
-		mod_timer(&p->forward_delay_timer,
-			  jiffies + br->forward_delay);
-	} else if (p->state == BR_STATE_LEARNING) {
+		if (br->forward_delay) {
+			mod_timer(&p->forward_delay_timer,
+				  jiffies + br->forward_delay);
+			goto out;
+		}
+		br_log_state(p);
+	}
+
+	if (p->state == BR_STATE_LEARNING) {
 		p->state = BR_STATE_FORWARDING;
 		if (br_is_designated_for_some_port(br))
 			br_topology_change_detection(br);
 	}
+
+out:
 	br_log_state(p);
+}
+
+static void br_forward_delay_timer_expired(unsigned long arg)
+{
+	struct net_bridge_port *p = (struct net_bridge_port *) arg;
+	struct net_bridge *br = p->br;
+
+	spin_lock(&br->lock);
+	__br_forward_delay_timer_expired(p);
 	spin_unlock(&br->lock);
 }
 

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
