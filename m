From: David Howells <dhowells@redhat.com>
Subject: [PATCH 6/8] af_rxrpc: Expose more RxRPC parameters via sysctls [ver
 #2]
Date: Thu, 06 Mar 2014 12:46:57 +0000
Message-ID: <20140306124657.16645.83497.stgit@warthog.procyon.org.uk>
References: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, tim@electronghost.co.uk,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Expose RxRPC parameters via sysctls to control the Rx window size, the Rx MTU
maximum size and the number of packets that can be glued into a jumbo packet.

More info added to Documentation/networking/rxrpc.txt.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   19 +++++++++++++++++++
 net/rxrpc/ar-ack.c                 |   26 +++++++++++++++++++++++---
 net/rxrpc/ar-call.c                |    2 +-
 net/rxrpc/ar-internal.h            |    3 +++
 net/rxrpc/sysctl.c                 |   33 +++++++++++++++++++++++++++++++++
 5 files changed, 79 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index aa08d2625f05..16a924c486bf 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -926,3 +926,22 @@ adjusted through sysctls in /proc/net/rxrpc/:
      The amount of time in seconds after a transport was last used before we
      remove it from the transport list.  Whilst a transport is in existence, it
      serves to anchor the peer data and keeps the connection ID counter.
+
+ (*) rxrpc_rx_window_size
+
+     The size of the receive window in packets.  This is the maximum number of
+     unconsumed received packets we're willing to hold in memory for any
+     particular call.
+
+ (*) rxrpc_rx_mtu
+
+     The maximum packet MTU size that we're willing to receive in bytes.  This
+     indicates to the peer whether we're willing to accept jumbo packets.
+
+ (*) rxrpc_rx_jumbo_max
+
+     The maximum number of packets that we're willing to accept in a jumbo
+     packet.  Non-terminal packets in a jumbo packet must contain a four byte
+     header plus exactly 1412 bytes of data.  The terminal packet must contain
+     a four byte header plus any amount of data.  In any event, a jumbo packet
+     may not exceed rxrpc_rx_mtu in size.
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 1a490d976e7e..c6be17a959a6 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -43,6 +43,26 @@ unsigned rxrpc_soft_ack_delay = 1 * HZ;
  */
 unsigned rxrpc_idle_ack_delay = 0.5 * HZ;
 
+/*
+ * Receive window size in packets.  This indicates the maximum number of
+ * unconsumed received packets we're willing to retain in memory.  Once this
+ * limit is hit, we should generate an EXCEEDS_WINDOW ACK and discard further
+ * packets.
+ */
+unsigned rxrpc_rx_window_size = 32;
+
+/*
+ * Maximum Rx MTU size.  This indicates to the sender the size of jumbo packet
+ * made by gluing normal packets together that we're willing to handle.
+ */
+unsigned rxrpc_rx_mtu = 5692;
+
+/*
+ * The maximum number of fragments in a received jumbo packet that we tell the
+ * sender that we're willing to handle.
+ */
+unsigned rxrpc_rx_jumbo_max = 4;
+
 static const char *rxrpc_acks(u8 reason)
 {
 	static const char *const str[] = {
@@ -1195,11 +1215,11 @@ send_ACK:
 	mtu = call->conn->trans->peer->if_mtu;
 	mtu -= call->conn->trans->peer->hdrsize;
 	ackinfo.maxMTU	= htonl(mtu);
-	ackinfo.rwind	= htonl(32);
+	ackinfo.rwind	= htonl(rxrpc_rx_window_size);
 
 	/* permit the peer to send us jumbo packets if it wants to */
-	ackinfo.rxMTU	= htonl(5692);
-	ackinfo.jumbo_max = htonl(4);
+	ackinfo.rxMTU	= htonl(rxrpc_rx_mtu);
+	ackinfo.jumbo_max = htonl(rxrpc_rx_jumbo_max);
 
 	hdr.serial = htonl(atomic_inc_return(&call->conn->serial));
 	_proto("Tx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index 1e0903a2a0db..6e4d58c9b042 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -99,7 +99,7 @@ static struct rxrpc_call *rxrpc_alloc_call(gfp_t gfp)
 	call->rx_data_expect = 1;
 	call->rx_data_eaten = 0;
 	call->rx_first_oos = 0;
-	call->ackr_win_top = call->rx_data_eaten + 1 + RXRPC_MAXACKS;
+	call->ackr_win_top = call->rx_data_eaten + 1 + rxrpc_rx_window_size;
 	call->creation_jif = jiffies;
 	return call;
 }
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 036e1dd84223..1ecd070e9149 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -436,6 +436,9 @@ int rxrpc_reject_call(struct rxrpc_sock *);
 extern unsigned rxrpc_requested_ack_delay;
 extern unsigned rxrpc_soft_ack_delay;
 extern unsigned rxrpc_idle_ack_delay;
+extern unsigned rxrpc_rx_window_size;
+extern unsigned rxrpc_rx_mtu;
+extern unsigned rxrpc_rx_jumbo_max;
 
 void __rxrpc_propose_ACK(struct rxrpc_call *, u8, __be32, bool);
 void rxrpc_propose_ACK(struct rxrpc_call *, u8, __be32, bool);
diff --git a/net/rxrpc/sysctl.c b/net/rxrpc/sysctl.c
index cdc85e72af5d..50a98a910eb1 100644
--- a/net/rxrpc/sysctl.c
+++ b/net/rxrpc/sysctl.c
@@ -17,6 +17,9 @@
 static struct ctl_table_header *rxrpc_sysctl_reg_table;
 static const unsigned zero = 0;
 static const unsigned one = 1;
+static const unsigned four = 4;
+static const unsigned n_65535 = 65535;
+static const unsigned n_max_acks = RXRPC_MAXACKS;
 
 /*
  * RxRPC operating parameters.
@@ -94,6 +97,36 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= (void *)&one,
 	},
+
+	/* Non-time values */
+	{
+		.procname	= "rx_window_size",
+		.data		= &rxrpc_rx_window_size,
+		.maxlen		= sizeof(unsigned),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void *)&one,
+		.extra2		= (void *)&n_max_acks,
+	},
+	{
+		.procname	= "rx_mtu",
+		.data		= &rxrpc_rx_mtu,
+		.maxlen		= sizeof(unsigned),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void *)&one,
+		.extra1		= (void *)&n_65535,
+	},
+	{
+		.procname	= "rx_jumbo_max",
+		.data		= &rxrpc_rx_jumbo_max,
+		.maxlen		= sizeof(unsigned),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void *)&one,
+		.extra2		= (void *)&four,
+	},
+
 	{ }
 };
 
