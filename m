From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] lapb: Neaten debugging
Date: Thu, 17 May 2012 13:25:49 -0700
Message-ID: <1337286349.17726.58.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-x25@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable dynamic debugging and remove a bunch of #ifdef/#endifs.

Add a lapb_dbg(level, fmt, ...) macro and replace the
printk(KERN_DEBUG uses.
Add pr_fmt and remove embedded prefixes.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/lapb.h    |    6 +
 net/lapb/lapb_iface.c |   22 +---
 net/lapb/lapb_in.c    |  320 ++++++++++++++-----------------------------------
 net/lapb/lapb_out.c   |   38 ++----
 net/lapb/lapb_subr.c  |   28 ++---
 net/lapb/lapb_timer.c |   32 ++----
 6 files changed, 140 insertions(+), 306 deletions(-)

diff --git a/include/net/lapb.h b/include/net/lapb.h
index fd2bf57..df892a9 100644
--- a/include/net/lapb.h
+++ b/include/net/lapb.h
@@ -149,4 +149,10 @@ extern int  lapb_t1timer_running(struct lapb_cb *lapb);
  */
 #define	LAPB_DEBUG	0
 
+#define lapb_dbg(level, fmt, ...)			\
+do {							\
+	if (level < LAPB_DEBUG)				\
+		pr_debug(fmt, ##__VA_ARGS__);		\
+} while (0)
+
 #endif
diff --git a/net/lapb/lapb_iface.c b/net/lapb/lapb_iface.c
index ab3d35f..3cdaa04 100644
--- a/net/lapb/lapb_iface.c
+++ b/net/lapb/lapb_iface.c
@@ -15,6 +15,8 @@
  *	2000-10-29	Henner Eisen	lapb_data_indication() return status.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -279,9 +281,7 @@ int lapb_connect_request(struct net_device *dev)
 
 	lapb_establish_data_link(lapb);
 
-#if LAPB_DEBUG > 0
-	printk(KERN_DEBUG "lapb: (%p) S0 -> S1\n", lapb->dev);
-#endif
+	lapb_dbg(0, "(%p) S0 -> S1\n", lapb->dev);
 	lapb->state = LAPB_STATE_1;
 
 	rc = LAPB_OK;
@@ -305,12 +305,8 @@ int lapb_disconnect_request(struct net_device *dev)
 		goto out_put;
 
 	case LAPB_STATE_1:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S1 TX DISC(1)\n", lapb->dev);
-#endif
-#if LAPB_DEBUG > 0
-		printk(KERN_DEBUG "lapb: (%p) S1 -> S0\n", lapb->dev);
-#endif
+		lapb_dbg(1, "(%p) S1 TX DISC(1)\n", lapb->dev);
+		lapb_dbg(0, "(%p) S1 -> S0\n", lapb->dev);
 		lapb_send_control(lapb, LAPB_DISC, LAPB_POLLON, LAPB_COMMAND);
 		lapb->state = LAPB_STATE_0;
 		lapb_start_t1timer(lapb);
@@ -329,12 +325,8 @@ int lapb_disconnect_request(struct net_device *dev)
 	lapb_stop_t2timer(lapb);
 	lapb->state = LAPB_STATE_2;
 
-#if LAPB_DEBUG > 1
-	printk(KERN_DEBUG "lapb: (%p) S3 DISC(1)\n", lapb->dev);
-#endif
-#if LAPB_DEBUG > 0
-	printk(KERN_DEBUG "lapb: (%p) S3 -> S2\n", lapb->dev);
-#endif
+	lapb_dbg(1, "(%p) S3 DISC(1)\n", lapb->dev);
+	lapb_dbg(0, "(%p) S3 -> S2\n", lapb->dev);
 
 	rc = LAPB_OK;
 out_put:
diff --git a/net/lapb/lapb_in.c b/net/lapb/lapb_in.c
index f4e3c1a..5dba899 100644
--- a/net/lapb/lapb_in.c
+++ b/net/lapb/lapb_in.c
@@ -15,6 +15,8 @@
  *	2000-10-29	Henner Eisen	lapb_data_indication() return status.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/socket.h>
@@ -44,25 +46,16 @@ static void lapb_state0_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 {
 	switch (frame->type) {
 	case LAPB_SABM:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S0 RX SABM(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S0 RX SABM(%d)\n", lapb->dev, frame->pf);
 		if (lapb->mode & LAPB_EXTENDED) {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S0 TX DM(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
+			lapb_dbg(1, "(%p) S0 TX DM(%d)\n",
+				 lapb->dev, frame->pf);
 			lapb_send_control(lapb, LAPB_DM, frame->pf,
 					  LAPB_RESPONSE);
 		} else {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S0 TX UA(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
-#if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S0 -> S3\n", lapb->dev);
-#endif
+			lapb_dbg(1, "(%p) S0 TX UA(%d)\n",
+				 lapb->dev, frame->pf);
+			lapb_dbg(0, "(%p) S0 -> S3\n", lapb->dev);
 			lapb_send_control(lapb, LAPB_UA, frame->pf,
 					  LAPB_RESPONSE);
 			lapb_stop_t1timer(lapb);
@@ -78,18 +71,11 @@ static void lapb_state0_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 		break;
 
 	case LAPB_SABME:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S0 RX SABME(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S0 RX SABME(%d)\n", lapb->dev, frame->pf);
 		if (lapb->mode & LAPB_EXTENDED) {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S0 TX UA(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
-#if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S0 -> S3\n", lapb->dev);
-#endif
+			lapb_dbg(1, "(%p) S0 TX UA(%d)\n",
+				 lapb->dev, frame->pf);
+			lapb_dbg(0, "(%p) S0 -> S3\n", lapb->dev);
 			lapb_send_control(lapb, LAPB_UA, frame->pf,
 					  LAPB_RESPONSE);
 			lapb_stop_t1timer(lapb);
@@ -102,22 +88,16 @@ static void lapb_state0_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 			lapb->va        = 0;
 			lapb_connect_indication(lapb, LAPB_OK);
 		} else {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S0 TX DM(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
+			lapb_dbg(1, "(%p) S0 TX DM(%d)\n",
+				 lapb->dev, frame->pf);
 			lapb_send_control(lapb, LAPB_DM, frame->pf,
 					  LAPB_RESPONSE);
 		}
 		break;
 
 	case LAPB_DISC:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S0 RX DISC(%d)\n",
-		       lapb->dev, frame->pf);
-		printk(KERN_DEBUG "lapb: (%p) S0 TX UA(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S0 RX DISC(%d)\n", lapb->dev, frame->pf);
+		lapb_dbg(1, "(%p) S0 TX UA(%d)\n", lapb->dev, frame->pf);
 		lapb_send_control(lapb, LAPB_UA, frame->pf, LAPB_RESPONSE);
 		break;
 
@@ -137,68 +117,45 @@ static void lapb_state1_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 {
 	switch (frame->type) {
 	case LAPB_SABM:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S1 RX SABM(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S1 RX SABM(%d)\n", lapb->dev, frame->pf);
 		if (lapb->mode & LAPB_EXTENDED) {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S1 TX DM(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
+			lapb_dbg(1, "(%p) S1 TX DM(%d)\n",
+				 lapb->dev, frame->pf);
 			lapb_send_control(lapb, LAPB_DM, frame->pf,
 					  LAPB_RESPONSE);
 		} else {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S1 TX UA(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
+			lapb_dbg(1, "(%p) S1 TX UA(%d)\n",
+				 lapb->dev, frame->pf);
 			lapb_send_control(lapb, LAPB_UA, frame->pf,
 					  LAPB_RESPONSE);
 		}
 		break;
 
 	case LAPB_SABME:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S1 RX SABME(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S1 RX SABME(%d)\n", lapb->dev, frame->pf);
 		if (lapb->mode & LAPB_EXTENDED) {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S1 TX UA(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
+			lapb_dbg(1, "(%p) S1 TX UA(%d)\n",
+				 lapb->dev, frame->pf);
 			lapb_send_control(lapb, LAPB_UA, frame->pf,
 					  LAPB_RESPONSE);
 		} else {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S1 TX DM(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
+			lapb_dbg(1, "(%p) S1 TX DM(%d)\n",
+				 lapb->dev, frame->pf);
 			lapb_send_control(lapb, LAPB_DM, frame->pf,
 					  LAPB_RESPONSE);
 		}
 		break;
 
 	case LAPB_DISC:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S1 RX DISC(%d)\n",
-		       lapb->dev, frame->pf);
-		printk(KERN_DEBUG "lapb: (%p) S1 TX DM(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S1 RX DISC(%d)\n", lapb->dev, frame->pf);
+		lapb_dbg(1, "(%p) S1 TX DM(%d)\n", lapb->dev, frame->pf);
 		lapb_send_control(lapb, LAPB_DM, frame->pf, LAPB_RESPONSE);
 		break;
 
 	case LAPB_UA:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S1 RX UA(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S1 RX UA(%d)\n", lapb->dev, frame->pf);
 		if (frame->pf) {
-#if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S1 -> S3\n", lapb->dev);
-#endif
+			lapb_dbg(0, "(%p) S1 -> S3\n", lapb->dev);
 			lapb_stop_t1timer(lapb);
 			lapb_stop_t2timer(lapb);
 			lapb->state     = LAPB_STATE_3;
@@ -212,14 +169,9 @@ static void lapb_state1_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 		break;
 
 	case LAPB_DM:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S1 RX DM(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S1 RX DM(%d)\n", lapb->dev, frame->pf);
 		if (frame->pf) {
-#if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S1 -> S0\n", lapb->dev);
-#endif
+			lapb_dbg(0, "(%p) S1 -> S0\n", lapb->dev);
 			lapb_clear_queues(lapb);
 			lapb->state = LAPB_STATE_0;
 			lapb_start_t1timer(lapb);
@@ -242,34 +194,22 @@ static void lapb_state2_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 	switch (frame->type) {
 	case LAPB_SABM:
 	case LAPB_SABME:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S2 RX {SABM,SABME}(%d)\n",
-		       lapb->dev, frame->pf);
-		printk(KERN_DEBUG "lapb: (%p) S2 TX DM(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S2 RX {SABM,SABME}(%d)\n",
+			 lapb->dev, frame->pf);
+		lapb_dbg(1, "(%p) S2 TX DM(%d)\n", lapb->dev, frame->pf);
 		lapb_send_control(lapb, LAPB_DM, frame->pf, LAPB_RESPONSE);
 		break;
 
 	case LAPB_DISC:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S2 RX DISC(%d)\n",
-		       lapb->dev, frame->pf);
-		printk(KERN_DEBUG "lapb: (%p) S2 TX UA(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S2 RX DISC(%d)\n", lapb->dev, frame->pf);
+		lapb_dbg(1, "(%p) S2 TX UA(%d)\n", lapb->dev, frame->pf);
 		lapb_send_control(lapb, LAPB_UA, frame->pf, LAPB_RESPONSE);
 		break;
 
 	case LAPB_UA:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S2 RX UA(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S2 RX UA(%d)\n", lapb->dev, frame->pf);
 		if (frame->pf) {
-#if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S2 -> S0\n", lapb->dev);
-#endif
+			lapb_dbg(0, "(%p) S2 -> S0\n", lapb->dev);
 			lapb->state = LAPB_STATE_0;
 			lapb_start_t1timer(lapb);
 			lapb_stop_t2timer(lapb);
@@ -278,14 +218,9 @@ static void lapb_state2_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 		break;
 
 	case LAPB_DM:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S2 RX DM(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S2 RX DM(%d)\n", lapb->dev, frame->pf);
 		if (frame->pf) {
-#if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S2 -> S0\n", lapb->dev);
-#endif
+			lapb_dbg(0, "(%p) S2 -> S0\n", lapb->dev);
 			lapb->state = LAPB_STATE_0;
 			lapb_start_t1timer(lapb);
 			lapb_stop_t2timer(lapb);
@@ -297,12 +232,9 @@ static void lapb_state2_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 	case LAPB_REJ:
 	case LAPB_RNR:
 	case LAPB_RR:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S2 RX {I,REJ,RNR,RR}(%d)\n",
-		       lapb->dev, frame->pf);
-		printk(KERN_DEBUG "lapb: (%p) S2 RX DM(%d)\n",
+		lapb_dbg(1, "(%p) S2 RX {I,REJ,RNR,RR}(%d)\n",
 		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S2 RX DM(%d)\n", lapb->dev, frame->pf);
 		if (frame->pf)
 			lapb_send_control(lapb, LAPB_DM, frame->pf,
 					  LAPB_RESPONSE);
@@ -325,22 +257,15 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 
 	switch (frame->type) {
 	case LAPB_SABM:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S3 RX SABM(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S3 RX SABM(%d)\n", lapb->dev, frame->pf);
 		if (lapb->mode & LAPB_EXTENDED) {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 TX DM(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
+			lapb_dbg(1, "(%p) S3 TX DM(%d)\n",
+				 lapb->dev, frame->pf);
 			lapb_send_control(lapb, LAPB_DM, frame->pf,
 					  LAPB_RESPONSE);
 		} else {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 TX UA(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
+			lapb_dbg(1, "(%p) S3 TX UA(%d)\n",
+				 lapb->dev, frame->pf);
 			lapb_send_control(lapb, LAPB_UA, frame->pf,
 					  LAPB_RESPONSE);
 			lapb_stop_t1timer(lapb);
@@ -355,15 +280,10 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 		break;
 
 	case LAPB_SABME:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S3 RX SABME(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S3 RX SABME(%d)\n", lapb->dev, frame->pf);
 		if (lapb->mode & LAPB_EXTENDED) {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 TX UA(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
+			lapb_dbg(1, "(%p) S3 TX UA(%d)\n",
+				 lapb->dev, frame->pf);
 			lapb_send_control(lapb, LAPB_UA, frame->pf,
 					  LAPB_RESPONSE);
 			lapb_stop_t1timer(lapb);
@@ -375,23 +295,16 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 			lapb->va        = 0;
 			lapb_requeue_frames(lapb);
 		} else {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S3 TX DM(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
+			lapb_dbg(1, "(%p) S3 TX DM(%d)\n",
+				 lapb->dev, frame->pf);
 			lapb_send_control(lapb, LAPB_DM, frame->pf,
 					  LAPB_RESPONSE);
 		}
 		break;
 
 	case LAPB_DISC:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S3 RX DISC(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
-#if LAPB_DEBUG > 0
-		printk(KERN_DEBUG "lapb: (%p) S3 -> S0\n", lapb->dev);
-#endif
+		lapb_dbg(1, "(%p) S3 RX DISC(%d)\n", lapb->dev, frame->pf);
+		lapb_dbg(0, "(%p) S3 -> S0\n", lapb->dev);
 		lapb_clear_queues(lapb);
 		lapb_send_control(lapb, LAPB_UA, frame->pf, LAPB_RESPONSE);
 		lapb_start_t1timer(lapb);
@@ -401,13 +314,8 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 		break;
 
 	case LAPB_DM:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S3 RX DM(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
-#if LAPB_DEBUG > 0
-		printk(KERN_DEBUG "lapb: (%p) S3 -> S0\n", lapb->dev);
-#endif
+		lapb_dbg(1, "(%p) S3 RX DM(%d)\n", lapb->dev, frame->pf);
+		lapb_dbg(0, "(%p) S3 -> S0\n", lapb->dev);
 		lapb_clear_queues(lapb);
 		lapb->state = LAPB_STATE_0;
 		lapb_start_t1timer(lapb);
@@ -416,10 +324,8 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 		break;
 
 	case LAPB_RNR:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S3 RX RNR(%d) R%d\n",
-		       lapb->dev, frame->pf, frame->nr);
-#endif
+		lapb_dbg(1, "(%p) S3 RX RNR(%d) R%d\n",
+			 lapb->dev, frame->pf, frame->nr);
 		lapb->condition |= LAPB_PEER_RX_BUSY_CONDITION;
 		lapb_check_need_response(lapb, frame->cr, frame->pf);
 		if (lapb_validate_nr(lapb, frame->nr)) {
@@ -428,9 +334,7 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 			lapb->frmr_data = *frame;
 			lapb->frmr_type = LAPB_FRMR_Z;
 			lapb_transmit_frmr(lapb);
-#if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n", lapb->dev);
-#endif
+			lapb_dbg(0, "(%p) S3 -> S4\n", lapb->dev);
 			lapb_start_t1timer(lapb);
 			lapb_stop_t2timer(lapb);
 			lapb->state   = LAPB_STATE_4;
@@ -439,10 +343,8 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 		break;
 
 	case LAPB_RR:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S3 RX RR(%d) R%d\n",
-		       lapb->dev, frame->pf, frame->nr);
-#endif
+		lapb_dbg(1, "(%p) S3 RX RR(%d) R%d\n",
+			 lapb->dev, frame->pf, frame->nr);
 		lapb->condition &= ~LAPB_PEER_RX_BUSY_CONDITION;
 		lapb_check_need_response(lapb, frame->cr, frame->pf);
 		if (lapb_validate_nr(lapb, frame->nr)) {
@@ -451,9 +353,7 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 			lapb->frmr_data = *frame;
 			lapb->frmr_type = LAPB_FRMR_Z;
 			lapb_transmit_frmr(lapb);
-#if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n", lapb->dev);
-#endif
+			lapb_dbg(0, "(%p) S3 -> S4\n", lapb->dev);
 			lapb_start_t1timer(lapb);
 			lapb_stop_t2timer(lapb);
 			lapb->state   = LAPB_STATE_4;
@@ -462,10 +362,8 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 		break;
 
 	case LAPB_REJ:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S3 RX REJ(%d) R%d\n",
-		       lapb->dev, frame->pf, frame->nr);
-#endif
+		lapb_dbg(1, "(%p) S3 RX REJ(%d) R%d\n",
+			 lapb->dev, frame->pf, frame->nr);
 		lapb->condition &= ~LAPB_PEER_RX_BUSY_CONDITION;
 		lapb_check_need_response(lapb, frame->cr, frame->pf);
 		if (lapb_validate_nr(lapb, frame->nr)) {
@@ -477,9 +375,7 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 			lapb->frmr_data = *frame;
 			lapb->frmr_type = LAPB_FRMR_Z;
 			lapb_transmit_frmr(lapb);
-#if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n", lapb->dev);
-#endif
+			lapb_dbg(0, "(%p) S3 -> S4\n", lapb->dev);
 			lapb_start_t1timer(lapb);
 			lapb_stop_t2timer(lapb);
 			lapb->state   = LAPB_STATE_4;
@@ -488,17 +384,13 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 		break;
 
 	case LAPB_I:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S3 RX I(%d) S%d R%d\n",
-		       lapb->dev, frame->pf, frame->ns, frame->nr);
-#endif
+		lapb_dbg(1, "(%p) S3 RX I(%d) S%d R%d\n",
+			 lapb->dev, frame->pf, frame->ns, frame->nr);
 		if (!lapb_validate_nr(lapb, frame->nr)) {
 			lapb->frmr_data = *frame;
 			lapb->frmr_type = LAPB_FRMR_Z;
 			lapb_transmit_frmr(lapb);
-#if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n", lapb->dev);
-#endif
+			lapb_dbg(0, "(%p) S3 -> S4\n", lapb->dev);
 			lapb_start_t1timer(lapb);
 			lapb_stop_t2timer(lapb);
 			lapb->state   = LAPB_STATE_4;
@@ -522,7 +414,7 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 			 * a frame lost on the wire.
 			 */
 			if (cn == NET_RX_DROP) {
-				printk(KERN_DEBUG "LAPB: rx congestion\n");
+				pr_debug("rx congestion\n");
 				break;
 			}
 			lapb->vr = (lapb->vr + 1) % modulus;
@@ -541,11 +433,8 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 				if (frame->pf)
 					lapb_enquiry_response(lapb);
 			} else {
-#if LAPB_DEBUG > 1
-				printk(KERN_DEBUG
-				       "lapb: (%p) S3 TX REJ(%d) R%d\n",
-				       lapb->dev, frame->pf, lapb->vr);
-#endif
+				lapb_dbg(1, "(%p) S3 TX REJ(%d) R%d\n",
+					 lapb->dev, frame->pf, lapb->vr);
 				lapb->condition |= LAPB_REJECT_CONDITION;
 				lapb_send_control(lapb, LAPB_REJ, frame->pf,
 						  LAPB_RESPONSE);
@@ -555,31 +444,22 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 		break;
 
 	case LAPB_FRMR:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S3 RX FRMR(%d) %02X "
-		       "%02X %02X %02X %02X\n", lapb->dev, frame->pf,
-		       skb->data[0], skb->data[1], skb->data[2],
-		       skb->data[3], skb->data[4]);
-#endif
+		lapb_dbg(1, "(%p) S3 RX FRMR(%d) %02X %02X %02X %02X %02X\n",
+			 lapb->dev, frame->pf,
+			 skb->data[0], skb->data[1], skb->data[2],
+			 skb->data[3], skb->data[4]);
 		lapb_establish_data_link(lapb);
-#if LAPB_DEBUG > 0
-		printk(KERN_DEBUG "lapb: (%p) S3 -> S1\n", lapb->dev);
-#endif
+		lapb_dbg(0, "(%p) S3 -> S1\n", lapb->dev);
 		lapb_requeue_frames(lapb);
 		lapb->state = LAPB_STATE_1;
 		break;
 
 	case LAPB_ILLEGAL:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S3 RX ILLEGAL(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S3 RX ILLEGAL(%d)\n", lapb->dev, frame->pf);
 		lapb->frmr_data = *frame;
 		lapb->frmr_type = LAPB_FRMR_W;
 		lapb_transmit_frmr(lapb);
-#if LAPB_DEBUG > 0
-		printk(KERN_DEBUG "lapb: (%p) S3 -> S4\n", lapb->dev);
-#endif
+		lapb_dbg(0, "(%p) S3 -> S4\n", lapb->dev);
 		lapb_start_t1timer(lapb);
 		lapb_stop_t2timer(lapb);
 		lapb->state   = LAPB_STATE_4;
@@ -600,25 +480,16 @@ static void lapb_state4_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 {
 	switch (frame->type) {
 	case LAPB_SABM:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S4 RX SABM(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S4 RX SABM(%d)\n", lapb->dev, frame->pf);
 		if (lapb->mode & LAPB_EXTENDED) {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S4 TX DM(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
+			lapb_dbg(1, "(%p) S4 TX DM(%d)\n",
+				 lapb->dev, frame->pf);
 			lapb_send_control(lapb, LAPB_DM, frame->pf,
 					  LAPB_RESPONSE);
 		} else {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S4 TX UA(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
-#if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S4 -> S3\n", lapb->dev);
-#endif
+			lapb_dbg(1, "(%p) S4 TX UA(%d)\n",
+				 lapb->dev, frame->pf);
+			lapb_dbg(0, "(%p) S4 -> S3\n", lapb->dev);
 			lapb_send_control(lapb, LAPB_UA, frame->pf,
 					  LAPB_RESPONSE);
 			lapb_stop_t1timer(lapb);
@@ -634,18 +505,11 @@ static void lapb_state4_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 		break;
 
 	case LAPB_SABME:
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S4 RX SABME(%d)\n",
-		       lapb->dev, frame->pf);
-#endif
+		lapb_dbg(1, "(%p) S4 RX SABME(%d)\n", lapb->dev, frame->pf);
 		if (lapb->mode & LAPB_EXTENDED) {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S4 TX UA(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
-#if LAPB_DEBUG > 0
-			printk(KERN_DEBUG "lapb: (%p) S4 -> S3\n", lapb->dev);
-#endif
+			lapb_dbg(1, "(%p) S4 TX UA(%d)\n",
+				 lapb->dev, frame->pf);
+			lapb_dbg(0, "(%p) S4 -> S3\n", lapb->dev);
 			lapb_send_control(lapb, LAPB_UA, frame->pf,
 					  LAPB_RESPONSE);
 			lapb_stop_t1timer(lapb);
@@ -658,10 +522,8 @@ static void lapb_state4_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 			lapb->va        = 0;
 			lapb_connect_indication(lapb, LAPB_OK);
 		} else {
-#if LAPB_DEBUG > 1
-			printk(KERN_DEBUG "lapb: (%p) S4 TX DM(%d)\n",
-			       lapb->dev, frame->pf);
-#endif
+			lapb_dbg(1, "(%p) S4 TX DM(%d)\n",
+				 lapb->dev, frame->pf);
 			lapb_send_control(lapb, LAPB_DM, frame->pf,
 					  LAPB_RESPONSE);
 		}
diff --git a/net/lapb/lapb_out.c b/net/lapb/lapb_out.c
index baab276..ba4d015 100644
--- a/net/lapb/lapb_out.c
+++ b/net/lapb/lapb_out.c
@@ -14,6 +14,8 @@
  *	LAPB 002	Jonathan Naylor	New timer architecture.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/socket.h>
@@ -60,10 +62,8 @@ static void lapb_send_iframe(struct lapb_cb *lapb, struct sk_buff *skb, int poll
 		*frame |= lapb->vs << 1;
 	}
 
-#if LAPB_DEBUG > 1
-	printk(KERN_DEBUG "lapb: (%p) S%d TX I(%d) S%d R%d\n",
-	       lapb->dev, lapb->state, poll_bit, lapb->vs, lapb->vr);
-#endif
+	lapb_dbg(1, "(%p) S%d TX I(%d) S%d R%d\n",
+		 lapb->dev, lapb->state, poll_bit, lapb->vs, lapb->vr);
 
 	lapb_transmit_buffer(lapb, skb, LAPB_COMMAND);
 }
@@ -148,11 +148,9 @@ void lapb_transmit_buffer(struct lapb_cb *lapb, struct sk_buff *skb, int type)
 		}
 	}
 
-#if LAPB_DEBUG > 2
-	printk(KERN_DEBUG "lapb: (%p) S%d TX %02X %02X %02X\n",
-	       lapb->dev, lapb->state,
-	       skb->data[0], skb->data[1], skb->data[2]);
-#endif
+	lapb_dbg(2, "(%p) S%d TX %02X %02X %02X\n",
+		 lapb->dev, lapb->state,
+		 skb->data[0], skb->data[1], skb->data[2]);
 
 	if (!lapb_data_transmit(lapb, skb))
 		kfree_skb(skb);
@@ -164,16 +162,10 @@ void lapb_establish_data_link(struct lapb_cb *lapb)
 	lapb->n2count   = 0;
 
 	if (lapb->mode & LAPB_EXTENDED) {
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S%d TX SABME(1)\n",
-		       lapb->dev, lapb->state);
-#endif
+		lapb_dbg(1, "(%p) S%d TX SABME(1)\n", lapb->dev, lapb->state);
 		lapb_send_control(lapb, LAPB_SABME, LAPB_POLLON, LAPB_COMMAND);
 	} else {
-#if LAPB_DEBUG > 1
-		printk(KERN_DEBUG "lapb: (%p) S%d TX SABM(1)\n",
-		       lapb->dev, lapb->state);
-#endif
+		lapb_dbg(1, "(%p) S%d TX SABM(1)\n", lapb->dev, lapb->state);
 		lapb_send_control(lapb, LAPB_SABM, LAPB_POLLON, LAPB_COMMAND);
 	}
 
@@ -183,10 +175,8 @@ void lapb_establish_data_link(struct lapb_cb *lapb)
 
 void lapb_enquiry_response(struct lapb_cb *lapb)
 {
-#if LAPB_DEBUG > 1
-	printk(KERN_DEBUG "lapb: (%p) S%d TX RR(1) R%d\n",
-	       lapb->dev, lapb->state, lapb->vr);
-#endif
+	lapb_dbg(1, "(%p) S%d TX RR(1) R%d\n",
+		 lapb->dev, lapb->state, lapb->vr);
 
 	lapb_send_control(lapb, LAPB_RR, LAPB_POLLON, LAPB_RESPONSE);
 
@@ -195,10 +185,8 @@ void lapb_enquiry_response(struct lapb_cb *lapb)
 
 void lapb_timeout_response(struct lapb_cb *lapb)
 {
-#if LAPB_DEBUG > 1
-	printk(KERN_DEBUG "lapb: (%p) S%d TX RR(0) R%d\n",
-	       lapb->dev, lapb->state, lapb->vr);
-#endif
+	lapb_dbg(1, "(%p) S%d TX RR(0) R%d\n",
+		 lapb->dev, lapb->state, lapb->vr);
 	lapb_send_control(lapb, LAPB_RR, LAPB_POLLOFF, LAPB_RESPONSE);
 
 	lapb->condition &= ~LAPB_ACK_PENDING_CONDITION;
diff --git a/net/lapb/lapb_subr.c b/net/lapb/lapb_subr.c
index 066225b..9d0a426 100644
--- a/net/lapb/lapb_subr.c
+++ b/net/lapb/lapb_subr.c
@@ -13,6 +13,8 @@
  *	LAPB 001	Jonathan Naylor	Started Coding
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/socket.h>
@@ -111,11 +113,9 @@ int lapb_decode(struct lapb_cb *lapb, struct sk_buff *skb,
 {
 	frame->type = LAPB_ILLEGAL;
 
-#if LAPB_DEBUG > 2
-	printk(KERN_DEBUG "lapb: (%p) S%d RX %02X %02X %02X\n",
-	       lapb->dev, lapb->state,
-	       skb->data[0], skb->data[1], skb->data[2]);
-#endif
+	lapb_dbg(2, "(%p) S%d RX %02X %02X %02X\n",
+		 lapb->dev, lapb->state,
+		 skb->data[0], skb->data[1], skb->data[2]);
 
 	/* We always need to look at 2 bytes, sometimes we need
 	 * to look at 3 and those cases are handled below.
@@ -284,12 +284,10 @@ void lapb_transmit_frmr(struct lapb_cb *lapb)
 		dptr++;
 		*dptr++ = lapb->frmr_type;
 
-#if LAPB_DEBUG > 1
-	printk(KERN_DEBUG "lapb: (%p) S%d TX FRMR %02X %02X %02X %02X %02X\n",
-	       lapb->dev, lapb->state,
-	       skb->data[1], skb->data[2], skb->data[3],
-	       skb->data[4], skb->data[5]);
-#endif
+		lapb_dbg(1, "(%p) S%d TX FRMR %02X %02X %02X %02X %02X\n",
+			 lapb->dev, lapb->state,
+			 skb->data[1], skb->data[2], skb->data[3],
+			 skb->data[4], skb->data[5]);
 	} else {
 		dptr    = skb_put(skb, 4);
 		*dptr++ = LAPB_FRMR;
@@ -301,11 +299,9 @@ void lapb_transmit_frmr(struct lapb_cb *lapb)
 		dptr++;
 		*dptr++ = lapb->frmr_type;
 
-#if LAPB_DEBUG > 1
-	printk(KERN_DEBUG "lapb: (%p) S%d TX FRMR %02X %02X %02X\n",
-	       lapb->dev, lapb->state, skb->data[1],
-	       skb->data[2], skb->data[3]);
-#endif
+		lapb_dbg(1, "(%p) S%d TX FRMR %02X %02X %02X\n",
+			 lapb->dev, lapb->state, skb->data[1],
+			 skb->data[2], skb->data[3]);
 	}
 
 	lapb_transmit_buffer(lapb, skb, LAPB_RESPONSE);
diff --git a/net/lapb/lapb_timer.c b/net/lapb/lapb_timer.c
index f8cd641..54563ad 100644
--- a/net/lapb/lapb_timer.c
+++ b/net/lapb/lapb_timer.c
@@ -14,6 +14,8 @@
  *	LAPB 002	Jonathan Naylor	New timer architecture.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/socket.h>
@@ -105,21 +107,17 @@ static void lapb_t1timer_expiry(unsigned long param)
 				lapb_clear_queues(lapb);
 				lapb->state = LAPB_STATE_0;
 				lapb_disconnect_indication(lapb, LAPB_TIMEDOUT);
-#if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S1 -> S0\n", lapb->dev);
-#endif
+				lapb_dbg(0, "(%p) S1 -> S0\n", lapb->dev);
 				return;
 			} else {
 				lapb->n2count++;
 				if (lapb->mode & LAPB_EXTENDED) {
-#if LAPB_DEBUG > 1
-					printk(KERN_DEBUG "lapb: (%p) S1 TX SABME(1)\n", lapb->dev);
-#endif
+					lapb_dbg(1, "(%p) S1 TX SABME(1)\n",
+						 lapb->dev);
 					lapb_send_control(lapb, LAPB_SABME, LAPB_POLLON, LAPB_COMMAND);
 				} else {
-#if LAPB_DEBUG > 1
-					printk(KERN_DEBUG "lapb: (%p) S1 TX SABM(1)\n", lapb->dev);
-#endif
+					lapb_dbg(1, "(%p) S1 TX SABM(1)\n",
+						 lapb->dev);
 					lapb_send_control(lapb, LAPB_SABM, LAPB_POLLON, LAPB_COMMAND);
 				}
 			}
@@ -133,15 +131,11 @@ static void lapb_t1timer_expiry(unsigned long param)
 				lapb_clear_queues(lapb);
 				lapb->state = LAPB_STATE_0;
 				lapb_disconnect_confirmation(lapb, LAPB_TIMEDOUT);
-#if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S2 -> S0\n", lapb->dev);
-#endif
+				lapb_dbg(0, "(%p) S2 -> S0\n", lapb->dev);
 				return;
 			} else {
 				lapb->n2count++;
-#if LAPB_DEBUG > 1
-				printk(KERN_DEBUG "lapb: (%p) S2 TX DISC(1)\n", lapb->dev);
-#endif
+				lapb_dbg(1, "(%p) S2 TX DISC(1)\n", lapb->dev);
 				lapb_send_control(lapb, LAPB_DISC, LAPB_POLLON, LAPB_COMMAND);
 			}
 			break;
@@ -155,9 +149,7 @@ static void lapb_t1timer_expiry(unsigned long param)
 				lapb->state = LAPB_STATE_0;
 				lapb_stop_t2timer(lapb);
 				lapb_disconnect_indication(lapb, LAPB_TIMEDOUT);
-#if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S3 -> S0\n", lapb->dev);
-#endif
+				lapb_dbg(0, "(%p) S3 -> S0\n", lapb->dev);
 				return;
 			} else {
 				lapb->n2count++;
@@ -173,9 +165,7 @@ static void lapb_t1timer_expiry(unsigned long param)
 				lapb_clear_queues(lapb);
 				lapb->state = LAPB_STATE_0;
 				lapb_disconnect_indication(lapb, LAPB_TIMEDOUT);
-#if LAPB_DEBUG > 0
-				printk(KERN_DEBUG "lapb: (%p) S4 -> S0\n", lapb->dev);
-#endif
+				lapb_dbg(0, "(%p) S4 -> S0\n", lapb->dev);
 				return;
 			} else {
 				lapb->n2count++;
