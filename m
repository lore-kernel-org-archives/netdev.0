From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 1/8] tipc: decrease connection
	flow control window
Date: Wed, 14 May 2014 05:39:08 -0400
Message-ID: <1400060355-26308-2-git-send-email-jon.maloy@ericsson.com>
References: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Memory overhead when allocating big buffers for data transfer may
be quite significant. E.g., truesize of a 64 KB buffer turns out
to be 132 KB, 2 x the requested size.

This invalidates the "worst case" calculation we have been
using to determine the default socket receive buffer limit,
which is based on the assumption that 1024x64KB = 67MB buffers
may be queued up on a socket.

Since TIPC connections cannot survive hitting the buffer limit,
we have to compensate for this overhead.

We do that in this commit by dividing the fix connection flow
control window from 1024 (2*512) messages to 512 (2*256). Since
older version nodes send out acks at 512 message intervals,
compatibility with such nodes is guaranteed, although performance
may be non-optimal in such cases.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/core.c   |    7 ++++---
 net/tipc/port.h   |    9 +++++----
 net/tipc/socket.c |    4 ++--
 3 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 57f8ae9..676d180 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -154,10 +154,11 @@ static int __init tipc_init(void)
 	tipc_max_ports = CONFIG_TIPC_PORTS;
 	tipc_net_id = 4711;
 
-	sysctl_tipc_rmem[0] = CONN_OVERLOAD_LIMIT >> 4 << TIPC_LOW_IMPORTANCE;
-	sysctl_tipc_rmem[1] = CONN_OVERLOAD_LIMIT >> 4 <<
+	sysctl_tipc_rmem[0] = TIPC_CONN_OVERLOAD_LIMIT >> 4 <<
+			      TIPC_LOW_IMPORTANCE;
+	sysctl_tipc_rmem[1] = TIPC_CONN_OVERLOAD_LIMIT >> 4 <<
 			      TIPC_CRITICAL_IMPORTANCE;
-	sysctl_tipc_rmem[2] = CONN_OVERLOAD_LIMIT;
+	sysctl_tipc_rmem[2] = TIPC_CONN_OVERLOAD_LIMIT;
 
 	res = tipc_core_start();
 	if (res)
diff --git a/net/tipc/port.h b/net/tipc/port.h
index a003973..5dfd165 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -42,9 +42,10 @@
 #include "msg.h"
 #include "node_subscr.h"
 
-#define TIPC_FLOW_CONTROL_WIN 512
-#define CONN_OVERLOAD_LIMIT	((TIPC_FLOW_CONTROL_WIN * 2 + 1) * \
-				SKB_TRUESIZE(TIPC_MAX_USER_MSG_SIZE))
+#define TIPC_CONNACK_INTV         256
+#define TIPC_FLOWCTRL_WIN        (TIPC_CONNACK_INTV * 2)
+#define TIPC_CONN_OVERLOAD_LIMIT ((TIPC_FLOWCTRL_WIN * 2 + 1) * \
+				  SKB_TRUESIZE(TIPC_MAX_USER_MSG_SIZE))
 
 /**
  * struct tipc_port - TIPC port structure
@@ -187,7 +188,7 @@ static inline void tipc_port_unlock(struct tipc_port *p_ptr)
 
 static inline int tipc_port_congested(struct tipc_port *p_ptr)
 {
-	return (p_ptr->sent - p_ptr->acked) >= (TIPC_FLOW_CONTROL_WIN * 2);
+	return ((p_ptr->sent - p_ptr->acked) >= TIPC_FLOWCTRL_WIN);
 }
 
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3f9912f..8685daf 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1101,7 +1101,7 @@ restart:
 	/* Consume received message (optional) */
 	if (likely(!(flags & MSG_PEEK))) {
 		if ((sock->state != SS_READY) &&
-		    (++port->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
+		    (++port->conn_unacked >= TIPC_CONNACK_INTV))
 			tipc_acknowledge(port->ref, port->conn_unacked);
 		advance_rx_queue(sk);
 	}
@@ -1210,7 +1210,7 @@ restart:
 
 	/* Consume received message (optional) */
 	if (likely(!(flags & MSG_PEEK))) {
-		if (unlikely(++port->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
+		if (unlikely(++port->conn_unacked >= TIPC_CONNACK_INTV))
 			tipc_acknowledge(port->ref, port->conn_unacked);
 		advance_rx_queue(sk);
 	}
-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
