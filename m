From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net v2] bridge: stp: when using userspace stp stop
	kernel hello and hold timers
Date: Thu, 23 Jul 2015 11:01:05 -0700
Message-ID: <1437674465-4388-1-git-send-email-nikolay@cumulusnetworks.com>
References: <1437667657-16954-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1437667657-16954-1-git-send-email-nikolay@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <razor@blackwall.org>

These should be handled only by the respective STP which is in control.
They become problematic for devices with limited resources with many
ports because the hold_timer is per port and fires each second and the
hello timer fires each 2 seconds even though it's global. While in
user-space STP mode these timers are completely unnecessary so it's better
to keep them off.
Also ensure that when the bridge is up these timers are started only when
running with kernel STP.

Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: fixed a locking issue and the commit message which was wrong
Stephen: I didn't use the del_timer_sync() because br->lock is acquired
         in br_stp_start() and we shouldn't block.

 net/bridge/br_stp.c       |  5 +++--
 net/bridge/br_stp_if.c    | 13 ++++++++++++-
 net/bridge/br_stp_timer.c |  4 +++-
 3 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index b4b6dab9c285..ed74ffaa851f 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -209,8 +209,9 @@ void br_transmit_config(struct net_bridge_port *p)
 		br_send_config_bpdu(p, &bpdu);
 		p->topology_change_ack = 0;
 		p->config_pending = 0;
-		mod_timer(&p->hold_timer,
-			  round_jiffies(jiffies + BR_HOLD_TIME));
+		if (p->br->stp_enabled == BR_KERNEL_STP)
+			mod_timer(&p->hold_timer,
+				  round_jiffies(jiffies + BR_HOLD_TIME));
 	}
 }
 
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index a2730e7196cd..4ca449a16132 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -48,7 +48,8 @@ void br_stp_enable_bridge(struct net_bridge *br)
 	struct net_bridge_port *p;
 
 	spin_lock_bh(&br->lock);
-	mod_timer(&br->hello_timer, jiffies + br->hello_time);
+	if (br->stp_enabled == BR_KERNEL_STP)
+		mod_timer(&br->hello_timer, jiffies + br->hello_time);
 	mod_timer(&br->gc_timer, jiffies + HZ/10);
 
 	br_config_bpdu_generation(br);
@@ -127,6 +128,7 @@ static void br_stp_start(struct net_bridge *br)
 	int r;
 	char *argv[] = { BR_STP_PROG, br->dev->name, "start", NULL };
 	char *envp[] = { NULL };
+	struct net_bridge_port *p;
 
 	r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
 
@@ -140,6 +142,10 @@ static void br_stp_start(struct net_bridge *br)
 	if (r == 0) {
 		br->stp_enabled = BR_USER_STP;
 		br_debug(br, "userspace STP started\n");
+		/* Stop hello and hold timers */
+		del_timer(&br->hello_timer);
+		list_for_each_entry(p, &br->port_list, list)
+			del_timer(&p->hold_timer);
 	} else {
 		br->stp_enabled = BR_KERNEL_STP;
 		br_debug(br, "using kernel STP\n");
@@ -156,12 +162,17 @@ static void br_stp_stop(struct net_bridge *br)
 	int r;
 	char *argv[] = { BR_STP_PROG, br->dev->name, "stop", NULL };
 	char *envp[] = { NULL };
+	struct net_bridge_port *p;
 
 	if (br->stp_enabled == BR_USER_STP) {
 		r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
 		br_info(br, "userspace STP stopped, return code %d\n", r);
 
 		/* To start timers on any ports left in blocking */
+		mod_timer(&br->hello_timer, jiffies + br->hello_time);
+		list_for_each_entry(p, &br->port_list, list)
+			mod_timer(&p->hold_timer,
+				  round_jiffies(jiffies + BR_HOLD_TIME));
 		spin_lock_bh(&br->lock);
 		br_port_state_selection(br);
 		spin_unlock_bh(&br->lock);
diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 7caf7fae2d5b..5f0f5af0ec35 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -40,7 +40,9 @@ static void br_hello_timer_expired(unsigned long arg)
 	if (br->dev->flags & IFF_UP) {
 		br_config_bpdu_generation(br);
 
-		mod_timer(&br->hello_timer, round_jiffies(jiffies + br->hello_time));
+		if (br->stp_enabled != BR_USER_STP)
+			mod_timer(&br->hello_timer,
+				  round_jiffies(jiffies + br->hello_time));
 	}
 	spin_unlock(&br->lock);
 }
-- 
2.4.3
