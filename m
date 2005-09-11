From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH 11/12] Implement G8PZT Circuit reset for NET/ROM
Date: Sun, 11 Sep 2005 23:12:56 +0100
Message-ID: <20050911221256.GA9226@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET/ROM is lacking a connection reset like TCP's RST flag which at times
may result in a connecting having to slowly timing out instead of just being
reset.  An earlier attempt to reset the connection by sending a
NR_CONNACK | NR_CHOKE_FLAG transport was inacceptable as it did result in
crashes of BPQ systems.  An alternative approach of introducing a new
transport type 7 (NR_RESET) has be implemented several years ago in
Paula Jayne Dowie G8PZT's Xrouter.

Implement NR_RESET for Linux's NET/ROM but like any messing with the state
engine consider this experimental for now and thus control it by a sysctl
(net.netrom.reset) which for the time being defaults to off.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 include/linux/sysctl.h         |    3 ++-
 include/net/netrom.h           |   27 ++++++++++++++++++++++++++-
 net/netrom/af_netrom.c         |   21 +++++++++++----------
 net/netrom/nr_in.c             |   15 +++++++++++++++
 net/netrom/nr_subr.c           |    7 +++----
 net/netrom/sysctl_net_netrom.c |   12 ++++++++++++
 6 files changed, 69 insertions(+), 16 deletions(-)

Index: linux-cvs/include/net/netrom.h
===================================================================
--- linux-cvs.orig/include/net/netrom.h
+++ linux-cvs/include/net/netrom.h
@@ -22,6 +22,7 @@
 #define	NR_DISCACK			0x04
 #define	NR_INFO				0x05
 #define	NR_INFOACK			0x06
+#define	NR_RESET			0x07
 
 #define	NR_CHOKE_FLAG			0x80
 #define	NR_NAK_FLAG			0x40
@@ -51,6 +52,7 @@ enum {
 #define	NR_DEFAULT_TTL			16		/* Default Time To Live - 16 */
 #define	NR_DEFAULT_ROUTING		1		/* Is routing enabled ? */
 #define	NR_DEFAULT_FAILS		2		/* Link fails until route fails */
+#define	NR_DEFAULT_RESET		0		/* Sent / accept reset cmds? */
 
 #define NR_MODULUS 			256
 #define NR_MAX_WINDOW_SIZE		127			/* Maximum Window Allowable - 127 */
@@ -176,6 +178,8 @@ extern int  sysctl_netrom_transport_requ
 extern int  sysctl_netrom_transport_no_activity_timeout;
 extern int  sysctl_netrom_routing_control;
 extern int  sysctl_netrom_link_fails_count;
+extern int  sysctl_netrom_reset_circuit;
+
 extern int  nr_rx_frame(struct sk_buff *, struct net_device *);
 extern void nr_destroy_socket(struct sock *);
 
@@ -218,7 +222,28 @@ extern void nr_requeue_frames(struct soc
 extern int  nr_validate_nr(struct sock *, unsigned short);
 extern int  nr_in_rx_window(struct sock *, unsigned short);
 extern void nr_write_internal(struct sock *, int);
-extern void nr_transmit_refusal(struct sk_buff *, int);
+
+extern void __nr_transmit_reply(struct sk_buff *skb, int mine,
+	unsigned char cmdflags);
+
+/*
+ * This routine is called when a Connect Acknowledge with the Choke Flag
+ * set is needed to refuse a connection.
+ */
+#define nr_transmit_refusal(skb, mine)					\
+do {									\
+	__nr_transmit_reply((skb), (mine), NR_CONNACK | NR_CHOKE_FLAG);	\
+} while (0)
+
+/*
+ * This routine is called when we don't have a circuit matching an incoming
+ * NET/ROM packet.  This is an G8PZT Xrouter extension.
+ */
+#define nr_transmit_reset(skb, mine)					\
+do {									\
+	__nr_transmit_reply((skb), (mine), NR_RESET);			\
+} while (0)
+
 extern void nr_disconnect(struct sock *, int);
 
 /* nr_timer.c */
Index: linux-cvs/net/netrom/af_netrom.c
===================================================================
--- linux-cvs.orig/net/netrom/af_netrom.c
+++ linux-cvs/net/netrom/af_netrom.c
@@ -56,6 +56,7 @@ int sysctl_netrom_transport_requested_wi
 int sysctl_netrom_transport_no_activity_timeout   = NR_DEFAULT_IDLE;
 int sysctl_netrom_routing_control                 = NR_DEFAULT_ROUTING;
 int sysctl_netrom_link_fails_count                = NR_DEFAULT_FAILS;
+int sysctl_netrom_reset_circuit                   = NR_DEFAULT_RESET;
 
 static unsigned short circuit = 0x101;
 
@@ -908,17 +909,17 @@ int nr_rx_frame(struct sk_buff *skb, str
 	if (frametype != NR_CONNREQ) {
 		/*
 		 * Here it would be nice to be able to send a reset but
-		 * NET/ROM doesn't have one. The following hack would
-		 * have been a way to extend the protocol but apparently
-		 * it kills BPQ boxes... :-(
+		 * NET/ROM doesn't have one.  We've tried to extend the protocol
+		 * by sending NR_CONNACK | NR_CHOKE_FLAGS replies but that
+		 * apparently kills BPQ boxes... :-(
+		 * So now we try to follow the established behaviour of
+		 * G8PZT's Xrouter which is sending packets with command type 7
+		 * as an extension of the protocol.
 		 */
-#if 0
-		/*
-		 * Never reply to a CONNACK/CHOKE.
-		 */
-		if (frametype != NR_CONNACK || flags != NR_CHOKE_FLAG)
-			nr_transmit_refusal(skb, 1);
-#endif
+		if (sysctl_netrom_reset_circuit &&
+		    (frametype != NR_RESET || flags != 0))
+			nr_transmit_reset(skb, 1);
+
 		return 0;
 	}
 
Index: linux-cvs/net/netrom/nr_in.c
===================================================================
--- linux-cvs.orig/net/netrom/nr_in.c
+++ linux-cvs/net/netrom/nr_in.c
@@ -98,6 +98,11 @@ static int nr_state1_machine(struct sock
 		nr_disconnect(sk, ECONNREFUSED);
 		break;
 
+	case NR_RESET:
+		if (sysctl_netrom_reset_circuit);
+			nr_disconnect(sk, ECONNRESET);
+		break;
+
 	default:
 		break;
 	}
@@ -124,6 +129,11 @@ static int nr_state2_machine(struct sock
 		nr_disconnect(sk, 0);
 		break;
 
+	case NR_RESET:
+		if (sysctl_netrom_reset_circuit);
+			nr_disconnect(sk, ECONNRESET);
+		break;
+
 	default:
 		break;
 	}
@@ -254,6 +264,11 @@ static int nr_state3_machine(struct sock
 		}
 		break;
 
+	case NR_RESET:
+		if (sysctl_netrom_reset_circuit);
+			nr_disconnect(sk, ECONNRESET);
+		break;
+
 	default:
 		break;
 	}
Index: linux-cvs/include/linux/sysctl.h
===================================================================
--- linux-cvs.orig/include/linux/sysctl.h
+++ linux-cvs/include/linux/sysctl.h
@@ -544,7 +544,8 @@ enum {
 	NET_NETROM_TRANSPORT_REQUESTED_WINDOW_SIZE=8,
 	NET_NETROM_TRANSPORT_NO_ACTIVITY_TIMEOUT=9,
 	NET_NETROM_ROUTING_CONTROL=10,
-	NET_NETROM_LINK_FAILS_COUNT=11
+	NET_NETROM_LINK_FAILS_COUNT=11,
+	NET_NETROM_RESET=12
 };
 
 /* /proc/sys/net/ax25 */
Index: linux-cvs/net/netrom/sysctl_net_netrom.c
===================================================================
--- linux-cvs.orig/net/netrom/sysctl_net_netrom.c
+++ linux-cvs/net/netrom/sysctl_net_netrom.c
@@ -30,6 +30,7 @@ static int min_idle[]    = {0 * HZ};
 static int max_idle[]    = {65535 * HZ};
 static int min_route[]   = {0}, max_route[]   = {1};
 static int min_fails[]   = {1}, max_fails[]   = {10};
+static int min_reset[]   = {0}, max_reset[]   = {1};
 
 static struct ctl_table_header *nr_table_header;
 
@@ -155,6 +156,17 @@ static ctl_table nr_table[] = {
 		.extra1		= &min_fails,
 		.extra2		= &max_fails
 	},
+        {
+		.ctl_name	= NET_NETROM_RESET,
+		.procname	= "reset",
+		.data		= &sysctl_netrom_reset_circuit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &min_reset,
+		.extra2		= &max_reset
+	},
 	{ .ctl_name = 0 }
 };
 
Index: linux-cvs/net/netrom/nr_subr.c
===================================================================
--- linux-cvs.orig/net/netrom/nr_subr.c
+++ linux-cvs/net/netrom/nr_subr.c
@@ -210,10 +210,9 @@ void nr_write_internal(struct sock *sk, 
 }
 
 /*
- * This routine is called when a Connect Acknowledge with the Choke Flag
- * set is needed to refuse a connection.
+ * This routine is called to send an error reply.
  */
-void nr_transmit_refusal(struct sk_buff *skb, int mine)
+void __nr_transmit_reply(struct sk_buff *skb, int mine, unsigned char cmdflags)
 {
 	struct sk_buff *skbn;
 	unsigned char *dptr;
@@ -254,7 +253,7 @@ void nr_transmit_refusal(struct sk_buff 
 		*dptr++ = 0;
 	}
 
-	*dptr++ = NR_CONNACK | NR_CHOKE_FLAG;
+	*dptr++ = cmdflags;
 	*dptr++ = 0;
 
 	if (!nr_route_frame(skbn, NULL))
