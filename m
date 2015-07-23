From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] bridge: stp: when using userspace stp stop kernel hello and hold timers
Date: Thu, 23 Jul 2015 09:07:37 -0700
Message-ID: <1437667657-16954-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	stephen@networkplumber.org,
	Satish Ashok <sashok@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36700 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbbGWQHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 12:07:50 -0400
Received: by pdjr16 with SMTP id r16so162134507pdj.3
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 09:07:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Ashok <sashok@cumulusnetworks.com>

Stop the kernel STP hello and hold timers when user-space STP is being
used to stop generating both packets. These should be handled only by
the respective STP which is in control. Also ensure that when the bridge
is up these timers are started only when running with kernel STP.
The kernel STP should function as before.

Test done using user-space RSTP.
Before patch:
14:55:35.043194 52:54:00:28:9d:4c > 01:80:c2:00:00:00, 802.3, length 52:
LLC, dsap STP (0x42) Individual, ssap STP (0x42) Command, ctrl 0x03: STP
802.1d, Config, Flags [none], bridge-id 8000.52:54:00:28:9d:4c.8001,
length 35
	message-age 0.00s, max-age 20.00s, hello-time 2.00s,
forwarding-delay 15.00s
	root-id 8000.52:54:00:28:9d:4c, root-pathcost 0
^^^^^^^
Kernel STP.

14:55:35.333807 52:54:00:28:9d:4c > 01:80:c2:00:00:00, 802.3, length 53:
LLC, dsap STP (0x42) Individual, ssap STP (0x42) Command, ctrl 0x03: STP
802.1w, Rapid STP, Flags [Learn, Forward], bridge-id
8000.52:54:00:28:9d:4c.8001, length 36
	message-age 0.00s, max-age 20.00s, hello-time 3.00s,
forwarding-delay 15.00s
	root-id 8000.52:54:00:28:9d:4c, root-pathcost 0, port-role
Designated
^^^^^^^
User-space STP (rstpd, configured with 3s hello-time)

After patch:
15:02:31.821511 52:54:00:28:9d:4c > 01:80:c2:00:00:00, 802.3, length 52:
LLC, dsap STP (0x42) Individual, ssap STP (0x42) Command, ctrl 0x03: STP
802.1d, Config, Flags [Topology change], bridge-id
8000.52:54:00:28:9d:4c.8002, length 35
	message-age 0.00s, max-age 20.00s, hello-time 3.00s,
forwarding-delay 15.00s
	root-id 8000.52:54:00:28:9d:4c, root-pathcost 0

15:02:34.821819 52:54:00:28:9d:4c > 01:80:c2:00:00:00, 802.3, length 52:
LLC, dsap STP (0x42) Individual, ssap STP (0x42) Command, ctrl 0x03: STP
802.1d, Config, Flags [Topology change], bridge-id
8000.52:54:00:28:9d:4c.8002, length 35
	message-age 0.00s, max-age 20.00s, hello-time 3.00s,
forwarding-delay 15.00s
	root-id 8000.52:54:00:28:9d:4c, root-pathcost 0
^^^^^
Only user-space STP.

Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_stp.c       |  5 +++--
 net/bridge/br_stp_if.c    | 15 ++++++++++++++-
 net/bridge/br_stp_timer.c |  4 +++-
 3 files changed, 20 insertions(+), 4 deletions(-)

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
index a2730e7196cd..962a149b117a 100644
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
 
@@ -140,6 +142,12 @@ static void br_stp_start(struct net_bridge *br)
 	if (r == 0) {
 		br->stp_enabled = BR_USER_STP;
 		br_debug(br, "userspace STP started\n");
+		/* Stop hello and hold timer */
+		spin_lock_bh(&br->lock);
+		del_timer(&br->hello_timer);
+		list_for_each_entry(p, &br->port_list, list)
+			del_timer(&p->hold_timer);
+		spin_unlock_bh(&br->lock);
 	} else {
 		br->stp_enabled = BR_KERNEL_STP;
 		br_debug(br, "using kernel STP\n");
@@ -156,12 +164,17 @@ static void br_stp_stop(struct net_bridge *br)
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
