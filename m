From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 17/22] xfrm offload v2: typhoon: split out setting of offloaded tasks
Date: Mon, 10 Jan 2005 10:37:02 -0500
Message-ID: <20040110014300.26@ori.thedillows.org>
References: <20040110014300.25@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 00:57:58-05:00 dave@thedillows.org 
#   Move the setting of the currently offloaded tasks to its own
#   function, as we'll be making use of it to change the crypto
#   offload status when adding/removing xfrms.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# drivers/net/typhoon.c
#   2005/01/10 00:57:41-05:00 dave@thedillows.org +26 -15
#   Move the setting of the currently offloaded tasks to its own
#   function, as we'll be making use of it to change the crypto
#   offload status when adding/removing xfrms.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	2005-01-10 01:17:21 -05:00
+++ b/drivers/net/typhoon.c	2005-01-10 01:17:21 -05:00
@@ -303,6 +303,7 @@
 	u16			xcvr_select;
 	u16			wol_events;
 	u32			offload;
+	spinlock_t		offload_lock;
 
 	u16			tx_sa_max;
 	u16			rx_sa_max;
@@ -724,11 +725,28 @@
 	return err;
 }
 
+static int
+typhoon_set_offload(struct typhoon *tp)
+{
+	/* Caller should hold tp->offload_lock, or otherwise guarantee
+         * exclusitivity to this routine.
+         */
+	struct cmd_desc xp_cmd;
+
+	smp_rmb();
+	if(tp->card_state != Running)
+		return 0;
+
+	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_SET_OFFLOAD_TASKS);
+	xp_cmd.parm2 = tp->offload;
+	xp_cmd.parm3 = tp->offload;
+	return typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
+}
+
 static void
 typhoon_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 {
 	struct typhoon *tp = netdev_priv(dev);
-	struct cmd_desc xp_cmd;
 	int err;
 
 	spin_lock_bh(&tp->state_lock);
@@ -736,25 +754,16 @@
 		/* We've either been turned on for the first time, or we've
 		 * been turned off. Update the 3XP.
 		 */
+		spin_lock_bh(&tp->offload_lock);
 		if(grp)
 			tp->offload |= TYPHOON_OFFLOAD_VLAN;
 		else
 			tp->offload &= ~TYPHOON_OFFLOAD_VLAN;
+		err = typhoon_set_offload(tp);
+		spin_unlock_bh(&tp->offload_lock);
 
-		/* If the interface is up, the runtime is running -- and we
-		 * must be up for the vlan core to call us.
-		 *
-		 * Do the command outside of the spin lock, as it is slow.
-		 */
-		INIT_COMMAND_WITH_RESPONSE(&xp_cmd,
-					TYPHOON_CMD_SET_OFFLOAD_TASKS);
-		xp_cmd.parm2 = tp->offload;
-		xp_cmd.parm3 = tp->offload;
-		spin_unlock_bh(&tp->state_lock);
-		err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 		if(err < 0)
 			printk("%s: vlan offload error %d\n", tp->name, -err);
-		spin_lock_bh(&tp->state_lock);
 	}
 
 	/* now make the change visible */
@@ -1485,6 +1494,7 @@
 
 	spin_lock_init(&tp->command_lock);
 	spin_lock_init(&tp->state_lock);
+	spin_lock_init(&tp->offload_lock);
 }
 
 static void
@@ -2217,12 +2227,13 @@
 	if(err < 0)
 		goto error_out;
 
+	/* tp->card_state != Running, so nothing will change this out
+	 * from under us.
+	 */
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_SET_OFFLOAD_TASKS);
-	spin_lock_bh(&tp->state_lock);
 	xp_cmd.parm2 = tp->offload;
 	xp_cmd.parm3 = tp->offload;
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
-	spin_unlock_bh(&tp->state_lock);
 	if(err < 0)
 		goto error_out;
 
