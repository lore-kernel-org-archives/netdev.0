From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [RFC v3 1/6] can: extend sockaddr_can to include j1939 members
Date: Mon, 14 Mar 2011 14:24:09 +0100
Message-ID: <20110314132409.GB333@e-circ.dyndns.org>
References: <20110314132004.GA333@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110314132004.GA333-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch prepares struct sockaddr_can for SAE J1939.
The size of this structure increases. To stay binary compatible,
the required_size macro is introduced for existing CAN protocols.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
---
diff --git a/include/linux/can.h b/include/linux/can.h
index d183333..9c2523c 100644
--- a/include/linux/can.h
+++ b/include/linux/can.h
@@ -67,7 +67,8 @@ struct can_frame {
 #define CAN_TP20	4 /* VAG Transport Protocol v2.0 */
 #define CAN_MCNET	5 /* Bosch MCNet */
 #define CAN_ISOTP	6 /* ISO 15765-2 Transport Protocol */
-#define CAN_NPROTO	7
+#define CAN_J1939	7 /* SAE J1939 */
+#define CAN_NPROTO	8
 
 #define SOL_CAN_BASE 100
 
@@ -84,6 +85,23 @@ struct sockaddr_can {
 		/* transport protocol class address information (e.g. ISOTP) */
 		struct { canid_t rx_id, tx_id; } tp;
 
+		/* J1939 address information */
+		struct {
+			/* 8 byte name when using dynamic addressing */
+			__u64 name;
+			/*
+			 * pgn:
+			 * 8bit: PS in PDU2 case, else 0
+			 * 8bit: PF
+			 * 1bit: DP
+			 * 1bit: reserved
+			 */
+			__u32 pgn;
+
+			/* 1byte address */
+			__u8 addr;
+		} j1939;
+
 		/* reserved for future CAN protocols address information */
 	} can_addr;
 };
diff --git a/include/linux/can/core.h b/include/linux/can/core.h
index 6c507be..653c33e 100644
--- a/include/linux/can/core.h
+++ b/include/linux/can/core.h
@@ -42,6 +42,15 @@ struct can_proto {
 	struct proto     *prot;
 };
 
+/*
+ * required_size
+ * macro to find the minimum size of a struct
+ * that includes a requested member
+ */
+#define required_size(member, struct_type) \
+	(offsetof(typeof(struct_type), member) + \
+	 sizeof(((typeof(struct_type) *)(0))->member))
+
 /* function prototypes for the CAN networklayer core (af_can.c) */
 
 extern int  can_proto_register(struct can_proto *cp);
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 092dc88..b286e45 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1256,7 +1256,7 @@ static int bcm_sendmsg(struct kiocb *iocb, struct socket *sock,
 		struct sockaddr_can *addr =
 			(struct sockaddr_can *)msg->msg_name;
 
-		if (msg->msg_namelen < sizeof(*addr))
+		if (msg->msg_namelen < required_size(can_ifindex, *addr))
 			return -EINVAL;
 
 		if (addr->can_family != AF_CAN)
@@ -1493,7 +1493,7 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 	struct sock *sk = sock->sk;
 	struct bcm_sock *bo = bcm_sk(sk);
 
-	if (len < sizeof(*addr))
+	if (len < required_size(can_ifindex, *addr))
 		return -EINVAL;
 
 	if (bo->bound)
diff --git a/net/can/raw.c b/net/can/raw.c
index 883e9d7..a5f1f41 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -350,7 +350,7 @@ static int raw_bind(struct socket *sock, struct sockaddr *uaddr, int len)
 	int err = 0;
 	int notify_enetdown = 0;
 
-	if (len < sizeof(*addr))
+	if (len < required_size(can_ifindex, *addr))
 		return -EINVAL;
 
 	lock_sock(sk);
@@ -649,7 +649,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 		struct sockaddr_can *addr =
 			(struct sockaddr_can *)msg->msg_name;
 
-		if (msg->msg_namelen < sizeof(*addr))
+		if (msg->msg_namelen < required_size(can_ifindex, *addr))
 			return -EINVAL;
 
 		if (addr->can_family != AF_CAN)
