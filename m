From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Clamp forward_delay when enabling STP
Date: Thu, 12 Sep 2013 17:12:05 +1000
Message-ID: <20130912071204.GA16548@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:46622 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751475Ab3ILHMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 03:12:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At some point limits were added to forward_delay.  However, the
limits are only enforced when STP is enabled.  This created a
scenario where you could have a value outside the allowed range
while STP is disabled, which then stuck around even after STP
is enabled.

This patch fixes this by clamping the value when we enable STP.

I had to move the locking around a bit to ensure that there is
no window where someone could insert a value outside the range
while we're in the middle of enabling STP.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 598cb0b..cda8315 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -746,6 +746,7 @@ extern struct net_bridge_port *br_get_port(struct net_bridge *br,
 extern void br_init_port(struct net_bridge_port *p);
 extern void br_become_designated_port(struct net_bridge_port *p);
 
+extern void __br_set_forward_delay(struct net_bridge *br, unsigned long t);
 extern int br_set_forward_delay(struct net_bridge *br, unsigned long x);
 extern int br_set_hello_time(struct net_bridge *br, unsigned long x);
 extern int br_set_max_age(struct net_bridge *br, unsigned long x);
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 1c0a50f..e651211 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -544,18 +544,27 @@ int br_set_max_age(struct net_bridge *br, unsigned long val)
 
 }
 
+void __br_set_forward_delay(struct net_bridge *br, unsigned long t)
+{
+	br->bridge_forward_delay = t;
+	if (br_is_root_bridge(br))
+		br->forward_delay = br->bridge_forward_delay;
+}
+
 int br_set_forward_delay(struct net_bridge *br, unsigned long val)
 {
 	unsigned long t = clock_t_to_jiffies(val);
+	int err = -ERANGE;
 
+	spin_lock_bh(&br->lock);
 	if (br->stp_enabled != BR_NO_STP &&
 	    (t < BR_MIN_FORWARD_DELAY || t > BR_MAX_FORWARD_DELAY))
-		return -ERANGE;
+		goto unlock;
 
-	spin_lock_bh(&br->lock);
-	br->bridge_forward_delay = t;
-	if (br_is_root_bridge(br))
-		br->forward_delay = br->bridge_forward_delay;
+	__br_set_forward_delay(br, t);
+	err = 0;
+
+unlock:
 	spin_unlock_bh(&br->lock);
-	return 0;
+	return err;
 }
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index d45e760..108084a 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -129,6 +129,14 @@ static void br_stp_start(struct net_bridge *br)
 	char *envp[] = { NULL };
 
 	r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
+
+	spin_lock_bh(&br->lock);
+
+	if (br->bridge_forward_delay < BR_MIN_FORWARD_DELAY)
+		__br_set_forward_delay(br, BR_MIN_FORWARD_DELAY);
+	else if (br->bridge_forward_delay < BR_MAX_FORWARD_DELAY)
+		__br_set_forward_delay(br, BR_MAX_FORWARD_DELAY);
+
 	if (r == 0) {
 		br->stp_enabled = BR_USER_STP;
 		br_debug(br, "userspace STP started\n");
@@ -137,10 +145,10 @@ static void br_stp_start(struct net_bridge *br)
 		br_debug(br, "using kernel STP\n");
 
 		/* To start timers on any ports left in blocking */
-		spin_lock_bh(&br->lock);
 		br_port_state_selection(br);
-		spin_unlock_bh(&br->lock);
 	}
+
+	spin_unlock_bh(&br->lock);
 }
 
 static void br_stp_stop(struct net_bridge *br)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
