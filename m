From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: bridge: add helper to call /sbin/bridge-stp
Date: Thu,  8 Sep 2016 12:50:43 -0400
Message-ID: <20160908165043.31042-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If /sbin/bridge-stp is available on the system, bridge tries to execute
it instead of the kernel implementation when starting/stopping STP.

If anything goes wrong with /sbin/bridge-stp, bridge silently falls back
to kernel STP, making hard to debug userspace STP.

This patch adds a br_stp_call_user helper to start/stop userspace STP
and debug errors from the program: abnormal exit status is stored in the
lower byte and normal exit status is stored in higher byte.

Below is a simple example on a kernel with dynamic debug enabled:

    # ln -s /bin/false /sbin/bridge-stp
    # brctl stp br0 on
    br0: failed to start userspace STP (256)
    # dmesg
    br0: /sbin/bridge-stp exited with code 1
    br0: failed to start userspace STP (256)
    br0: using kernel STP

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_stp_if.c | 43 +++++++++++++++++++++++++++++++------------
 1 file changed, 31 insertions(+), 12 deletions(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 341caa0..d8ad73b 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -134,17 +134,36 @@ void br_stp_disable_port(struct net_bridge_port *p)
 		br_become_root_bridge(br);
 }
 
+static int br_stp_call_user(struct net_bridge *br, char *arg)
+{
+	char *argv[] = { BR_STP_PROG, br->dev->name, arg, NULL };
+	char *envp[] = { NULL };
+	int rc;
+
+	/* call userspace STP and report program errors */
+	rc = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
+	if (rc > 0) {
+		if (rc & 0xff)
+			br_debug(br, BR_STP_PROG " received signal %d\n",
+				 rc & 0x7f);
+		else
+			br_debug(br, BR_STP_PROG " exited with code %d\n",
+				 (rc >> 8) & 0xff);
+	}
+
+	return rc;
+}
+
 static void br_stp_start(struct net_bridge *br)
 {
-	int r;
-	char *argv[] = { BR_STP_PROG, br->dev->name, "start", NULL };
-	char *envp[] = { NULL };
 	struct net_bridge_port *p;
+	int err = -ENOENT;
 
 	if (net_eq(dev_net(br->dev), &init_net))
-		r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
-	else
-		r = -ENOENT;
+		err = br_stp_call_user(br, "start");
+
+	if (err && err != -ENOENT)
+		br_err(br, "failed to start userspace STP (%d)\n", err);
 
 	spin_lock_bh(&br->lock);
 
@@ -153,9 +172,10 @@ static void br_stp_start(struct net_bridge *br)
 	else if (br->bridge_forward_delay > BR_MAX_FORWARD_DELAY)
 		__br_set_forward_delay(br, BR_MAX_FORWARD_DELAY);
 
-	if (r == 0) {
+	if (!err) {
 		br->stp_enabled = BR_USER_STP;
 		br_debug(br, "userspace STP started\n");
+
 		/* Stop hello and hold timers */
 		del_timer(&br->hello_timer);
 		list_for_each_entry(p, &br->port_list, list)
@@ -173,14 +193,13 @@ static void br_stp_start(struct net_bridge *br)
 
 static void br_stp_stop(struct net_bridge *br)
 {
-	int r;
-	char *argv[] = { BR_STP_PROG, br->dev->name, "stop", NULL };
-	char *envp[] = { NULL };
 	struct net_bridge_port *p;
+	int err;
 
 	if (br->stp_enabled == BR_USER_STP) {
-		r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
-		br_info(br, "userspace STP stopped, return code %d\n", r);
+		err = br_stp_call_user(br, "stop");
+		if (err)
+			br_err(br, "failed to stop userspace STP (%d)\n", err);
 
 		/* To start timers on any ports left in blocking */
 		mod_timer(&br->hello_timer, jiffies + br->hello_time);
-- 
2.9.3
