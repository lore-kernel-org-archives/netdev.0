From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v1 2/2] TCPCT API sockopt update to draft -03
Date: Wed, 12 Jan 2011 12:59:38 -0500
Message-ID: <4D2DEC0A.70608@gmail.com>
References: <4D2DE824.10205@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040307090408090103060503"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D2DE824.10205@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040307090408090103060503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use most recently specified symbols of RFC-to-be-6013.

Permit setting either cookie or s_data (alternatively).

Split the data value from socket option header, saving more than
1K of stack space in the handler by copying long data values
directly from user space into the kref block.

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/linux/tcp.h |   35 ++++++++++++-----
  net/ipv4/tcp.c      |  102 +++++++++++++++++++++++++++++++++++---------------
  2 files changed, 96 insertions(+), 41 deletions(-)

--------------040307090408090103060503
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+API-03v1+2.6.37.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="TCPCT+API-03v1+2.6.37.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index e64f4c6..c8f4017 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -185,22 +185,37 @@ struct tcp_md5sig {
 #define TCP_COOKIE_PAIR_SIZE	(2*TCP_COOKIE_MAX)
 
 /* Flags for both getsockopt and setsockopt */
-#define TCP_COOKIE_IN_ALWAYS	(1 << 0)	/* Discard SYN without cookie */
-#define TCP_COOKIE_OUT_NEVER	(1 << 1)	/* Prohibit outgoing cookies,
+#define TCPCT_IN_ALWAYS		(1 << 0)	/* Discard SYN without cookie */
+#define TCPCT_OUT_NEVER		(1 << 1)	/* Prohibit outgoing cookies,
 						 * supercedes everything. */
-
-/* Flags for getsockopt */
-#define TCP_S_DATA_IN		(1 << 2)	/* Was data received? */
-#define TCP_S_DATA_OUT		(1 << 3)	/* Was data sent? */
-
-/* TCP_COOKIE_TRANSACTIONS data */
+#define TCPCT_IN_DATA		(1 << 2)	/* Was data received? */
+#define TCPCT_OUT_DATA		(1 << 3)	/* Was data sent? */
+/* reserved for future use: bits 4 .. 6 */
+#define TCPCT_EXTEND		(1 << 7)
+
+/* Extended Option flags for both getsockopt and setsockopt */
+#define TCPCT_EXTEND_SIZE	(0x7)		/* mask */
+#define TCPCT_EXTEND_TS32	(0x1)		/* default */
+#define TCPCT_EXTEND_TS64	(0x2)
+#define TCPCT_EXTEND_TS128	(0x4)
+
+/* TCP_COOKIE_TRANSACTIONS socket option header */
 struct tcp_cookie_transactions {
 	__u16	tcpct_flags;			/* see above */
-	__u8	__tcpct_pad1;			/* zero */
+	__u8	tcpct_extended;
 	__u8	tcpct_cookie_desired;		/* bytes */
 	__u16	tcpct_s_data_desired;		/* bytes of variable data */
 	__u16	tcpct_used;			/* bytes in value */
-	__u8	tcpct_value[TCP_MSS_DEFAULT];
+};
+
+struct tcpct_full {
+	struct tcp_cookie_transactions soh;
+	__u8	tcpct_value[TCP_COOKIE_PAIR_SIZE];
+};
+
+struct tcpct_half {
+	struct tcp_cookie_transactions soh;
+	__u8	tcpct_value[TCP_COOKIE_MAX];
 };
 
 #ifdef __KERNEL__
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6c11eec..a5c7933 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2143,25 +2143,14 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_COOKIE_TRANSACTIONS: {
 		struct tcp_cookie_transactions ctd;
 		struct tcp_cookie_values *cvp = NULL;
+		int s_data_used = 0;
 
 		if (sizeof(ctd) > optlen)
 			return -EINVAL;
 		if (copy_from_user(&ctd, optval, sizeof(ctd)))
 			return -EFAULT;
 
-		if (ctd.tcpct_used > sizeof(ctd.tcpct_value) ||
-		    ctd.tcpct_s_data_desired > TCP_MSS_DESIRED)
-			return -EINVAL;
-
-		if (ctd.tcpct_cookie_desired == 0) {
-			/* default to global value */
-		} else if ((0x1 & ctd.tcpct_cookie_desired) ||
-			   ctd.tcpct_cookie_desired > TCP_COOKIE_MAX ||
-			   ctd.tcpct_cookie_desired < TCP_COOKIE_MIN) {
-			return -EINVAL;
-		}
-
-		if (TCP_COOKIE_OUT_NEVER & ctd.tcpct_flags) {
+		if (TCPCT_OUT_NEVER & ctd.tcpct_flags) {
 			/* Supercedes all other values */
 			lock_sock(sk);
 			if (tp->cookie_values != NULL) {
@@ -2175,6 +2164,41 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			return err;
 		}
 
+		if (ctd.tcpct_cookie_desired == 0) {
+			/* default to global value */
+		} else if ((0x1 & ctd.tcpct_cookie_desired) ||
+			   ctd.tcpct_cookie_desired > TCP_COOKIE_MAX ||
+			   ctd.tcpct_cookie_desired < TCP_COOKIE_MIN) {
+			return -EINVAL;
+		}
+
+		if (ctd.tcpct_used > 0) {
+			if (ctd.tcpct_used + sizeof(ctd) > optlen)
+				return -EINVAL;
+			if (TCPCT_OUT_DATA & ctd.tcpct_flags) {
+				if (ctd.tcpct_used >
+						sysctl_tcp_syn_ack_data_limit)
+					return -EINVAL;
+				if (ctd.tcpct_s_data_desired > 0)
+					return -EINVAL;
+				s_data_used = ctd.tcpct_used;
+			} else {
+				if (ctd.tcpct_used > TCP_COOKIE_PAIR_SIZE)
+					return -EINVAL;
+				if (ctd.tcpct_used !=
+						ctd.tcpct_cookie_desired &&
+				    ctd.tcpct_used !=
+						ctd.tcpct_cookie_desired * 2)
+					return -EINVAL;
+				if (ctd.tcpct_s_data_desired >
+						sysctl_tcp_syn_data_limit)
+					return -EINVAL;
+			}
+		} else if (TCPCT_OUT_DATA & ctd.tcpct_flags) {
+			/* unexpected flag without s_data */
+			return -EINVAL;
+		}
+
 		/* Allocate ancillary memory before locking.
 		 */
 		if (ctd.tcpct_used > 0 ||
@@ -2182,7 +2206,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		     (sysctl_tcp_cookie_size > 0 ||
 		      ctd.tcpct_cookie_desired > 0 ||
 		      ctd.tcpct_s_data_desired > 0))) {
-			cvp = kzalloc(sizeof(*cvp) + ctd.tcpct_used,
+			cvp = kzalloc(sizeof(*cvp) + s_data_used,
 				      GFP_KERNEL);
 			if (cvp == NULL)
 				return -ENOMEM;
@@ -2191,7 +2215,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		}
 		lock_sock(sk);
 		tp->rx_opt.cookie_in_always =
-			(TCP_COOKIE_IN_ALWAYS & ctd.tcpct_flags);
+			(TCPCT_IN_ALWAYS & ctd.tcpct_flags);
 		tp->rx_opt.cookie_out_never = 0; /* false */
 
 		if (tp->cookie_values != NULL) {
@@ -2210,11 +2234,27 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		if (cvp != NULL) {
 			cvp->cookie_desired = ctd.tcpct_cookie_desired;
 
-			if (ctd.tcpct_used > 0) {
-				memcpy(cvp->s_data_payload, ctd.tcpct_value,
-				       ctd.tcpct_used);
-				cvp->s_data_desired = ctd.tcpct_used;
+			if (s_data_used > 0) {
+				if (copy_from_user(cvp->s_data_payload,
+						   optval + sizeof(ctd),
+						   s_data_used)) {
+					kref_put(&cvp->kref,
+						 tcp_cookie_values_release);
+					return -EFAULT;
+				}
+				cvp->s_data_desired = s_data_used;
 				cvp->s_data_constant = 1; /* true */
+			} else if (ctd.tcpct_used > 0) {
+				if (copy_from_user(cvp->cookie_pair,
+						   optval + sizeof(ctd),
+						   ctd.tcpct_used)) {
+					kref_put(&cvp->kref,
+						 tcp_cookie_values_release);
+					return -EFAULT;
+				}
+				/* No constant payload data. */
+				cvp->s_data_desired = ctd.tcpct_s_data_desired;
+				cvp->s_data_constant = 0; /* false */
 			} else {
 				/* No constant payload data. */
 				cvp->s_data_desired = ctd.tcpct_s_data_desired;
@@ -2574,7 +2614,7 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		return 0;
 
 	case TCP_COOKIE_TRANSACTIONS: {
-		struct tcp_cookie_transactions ctd;
+		struct tcpct_full ctd;
 		struct tcp_cookie_values *cvp = tp->cookie_values;
 
 		if (get_user(len, optlen))
@@ -2583,23 +2623,23 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 			return -EINVAL;
 
 		memset(&ctd, 0, sizeof(ctd));
-		ctd.tcpct_flags = (tp->rx_opt.cookie_in_always ?
-				   TCP_COOKIE_IN_ALWAYS : 0)
-				| (tp->rx_opt.cookie_out_never ?
-				   TCP_COOKIE_OUT_NEVER : 0);
+		ctd.soh.tcpct_flags = (tp->rx_opt.cookie_in_always ?
+				       TCPCT_IN_ALWAYS : 0)
+				    | (tp->rx_opt.cookie_out_never ?
+				       TCPCT_OUT_NEVER : 0);
 
 		if (cvp != NULL) {
-			ctd.tcpct_flags |= (cvp->s_data_in ?
-					    TCP_S_DATA_IN : 0)
-					 | (cvp->s_data_out ?
-					    TCP_S_DATA_OUT : 0);
+			ctd.soh.tcpct_flags |= (cvp->s_data_in ?
+						TCPCT_IN_DATA : 0)
+					     | (cvp->s_data_out ?
+						TCPCT_OUT_DATA : 0);
 
-			ctd.tcpct_cookie_desired = cvp->cookie_desired;
-			ctd.tcpct_s_data_desired = cvp->s_data_desired;
+			ctd.soh.tcpct_cookie_desired = cvp->cookie_desired;
+			ctd.soh.tcpct_s_data_desired = cvp->s_data_desired;
 
 			memcpy(&ctd.tcpct_value[0], &cvp->cookie_pair[0],
 			       cvp->cookie_pair_size);
-			ctd.tcpct_used = cvp->cookie_pair_size;
+			ctd.soh.tcpct_used = cvp->cookie_pair_size;
 		}
 
 		if (put_user(sizeof(ctd), optlen))
-- 
1.7.1


--------------040307090408090103060503--
