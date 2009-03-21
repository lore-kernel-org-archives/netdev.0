From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 01/77] atm: convert mpc device to using netdev_ops
Date: Fri, 20 Mar 2009 22:35:28 -0700
Message-ID: <20090321053712.648437543@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36630 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760992AbZCUFsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:18 -0400
Content-Disposition: inline; filename=atm-mpc.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts the mpc device to using new netdevice_ops.
Compile tested only, needs more than usual review since
device was swaping pointers around etc.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/atm/mpc.c |   32 ++++++++++++++------------------
 net/atm/mpc.h |    5 ++++-
 2 files changed, 18 insertions(+), 19 deletions(-)

--- a/net/atm/mpc.c	2009-03-19 22:40:30.534964257 -0700
+++ b/net/atm/mpc.c	2009-03-19 22:42:40.038902168 -0700
@@ -286,33 +286,32 @@ static void start_mpc(struct mpoa_client
 {
 
 	dprintk("mpoa: (%s) start_mpc:\n", mpc->dev->name);
-	if (dev->hard_start_xmit == NULL) {
-		printk("mpoa: (%s) start_mpc: dev->hard_start_xmit == NULL, not starting\n",
-		       dev->name);
-		return;
+	if (!dev->netdev_ops)
+		printk("mpoa: (%s) start_mpc  not starting\n", dev->name);
+	else {
+		mpc->old_ops = dev->netdev_ops;
+		mpc->new_ops = *mpc->old_ops;
+		mpc->new_ops.ndo_start_xmit = mpc_send_packet;
+		dev->netdev_ops = &mpc->new_ops;
 	}
-	mpc->old_hard_start_xmit = dev->hard_start_xmit;
-	dev->hard_start_xmit = mpc_send_packet;
-
-	return;
 }
 
 static void stop_mpc(struct mpoa_client *mpc)
 {
-
+	struct net_device *dev = mpc->dev;
 	dprintk("mpoa: (%s) stop_mpc:", mpc->dev->name);
 
 	/* Lets not nullify lec device's dev->hard_start_xmit */
-	if (mpc->dev->hard_start_xmit != mpc_send_packet) {
+	if (dev->netdev_ops != &mpc->new_ops) {
 		dprintk(" mpc already stopped, not fatal\n");
 		return;
 	}
 	dprintk("\n");
-	mpc->dev->hard_start_xmit = mpc->old_hard_start_xmit;
-	mpc->old_hard_start_xmit = NULL;
-	/* close_shortcuts(mpc);    ??? FIXME */
 
-	return;
+	dev->netdev_ops = mpc->old_ops;
+	mpc->old_ops = NULL;
+
+	/* close_shortcuts(mpc);    ??? FIXME */
 }
 
 static const char *mpoa_device_type_string(char type) __attribute__ ((unused));
@@ -531,7 +530,6 @@ static int send_via_shortcut(struct sk_b
  */
 static int mpc_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	int retval;
 	struct mpoa_client *mpc;
 	struct ethhdr *eth;
 	int i = 0;
@@ -561,9 +559,7 @@ static int mpc_send_packet(struct sk_buf
 	}
 
  non_ip:
-	retval = mpc->old_hard_start_xmit(skb,dev);
-
-	return retval;
+	return mpc->old_ops->ndo_start_xmit(skb,dev);
 }
 
 static int atm_mpoa_vcc_attach(struct atm_vcc *vcc, void __user *arg)
--- a/net/atm/mpc.h	2009-03-19 22:40:30.528964315 -0700
+++ b/net/atm/mpc.h	2009-03-19 22:42:40.038902168 -0700
@@ -15,7 +15,7 @@ struct mpoa_client {
 	struct mpoa_client *next;
 	struct net_device *dev;      /* lec in question                     */
 	int dev_num;                 /* e.g. 2 for lec2                     */
-	int (*old_hard_start_xmit)(struct sk_buff *skb, struct net_device *dev);
+
 	struct atm_vcc *mpoad_vcc;   /* control channel to mpoad            */
 	uint8_t mps_ctrl_addr[ATM_ESA_LEN];  /* MPS control ATM address     */
 	uint8_t our_ctrl_addr[ATM_ESA_LEN];  /* MPC's control ATM address   */
@@ -31,6 +31,9 @@ struct mpoa_client {
 	uint8_t *mps_macs;           /* array of MPS MAC addresses, >=1     */
 	int number_of_mps_macs;      /* number of the above MAC addresses   */
 	struct mpc_parameters parameters;  /* parameters for this client    */
+
+	const struct net_device_ops *old_ops;
+	struct net_device_ops new_ops;
 };
 
 

-- 

