From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: allow for bigger reordering level
Date: Mon, 27 Oct 2014 21:45:24 -0700
Message-ID: <1414471524.13259.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yaogong Wang <wygivan@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:44975 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519AbaJ1Ep0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 00:45:26 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so4450272pab.24
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 21:45:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While testing upcoming Yaogong patch (converting out of order queue
into an RB tree), I hit the max reordering level of linux TCP stack.

Reordering level was limited to 127 for no good reason, and some
network setups [1] can easily reach this limit and get limited
throughput.

Allow a new max limit of 300, and add a sysctl to allow admins to even
allow bigger (or lower) values if needed.

[1] Aggregation of links, per packet load balancing, fabrics not doing
 deep packet inspections, alternative TCP congestion modules...

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yaogong Wang <wygivan@google.com>
---
 Documentation/networking/bonding.txt   |    7 ++-----
 Documentation/networking/ip-sysctl.txt |   10 +++++++++-
 include/linux/tcp.h                    |    4 ++--
 include/net/tcp.h                      |    4 +---
 net/ipv4/sysctl_net_ipv4.c             |    7 +++++++
 net/ipv4/tcp_input.c                   |    3 ++-
 6 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index eeb5b2e97bedac5ce910a06cc03bf42035d544d4..7ddd70df4d9aaa76b5806bf4a74fd1583ba7e198 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -2230,11 +2230,8 @@ balance-rr: This mode is the only mode that will permit a single
 
 	It is possible to adjust TCP/IP's congestion limits by
 	altering the net.ipv4.tcp_reordering sysctl parameter.  The
-	usual default value is 3, and the maximum useful value is 127.
-	For a four interface balance-rr bond, expect that a single
-	TCP/IP stream will utilize no more than approximately 2.3
-	interface's worth of throughput, even after adjusting
-	tcp_reordering.
+	usual default value is 3. But keep in mind TCP stack is able
+	to automatically increase this when it detects reorders.
 
 	Note that the fraction of packets that will be delivered out of
 	order is highly variable, and is unlikely to be zero.  The level
diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 0307e2875f2159cb669b741f9d6a949618c3a055..9028b879a97baebc29832c42694896361ecfba03 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -376,9 +376,17 @@ tcp_orphan_retries - INTEGER
 	may consume significant resources. Cf. tcp_max_orphans.
 
 tcp_reordering - INTEGER
-	Maximal reordering of packets in a TCP stream.
+	Initial reordering level of packets in a TCP stream.
+	TCP stack can then dynamically adjust flow reordering level
+	between this initial value and tcp_max_reordering
 	Default: 3
 
+tcp_max_reordering - INTEGER
+	Maximal reordering level of packets in a TCP stream.
+	300 is a fairly conservative value, but you might increase it
+	if paths are using per packet load balancing (like bonding rr mode)
+	Default: 300
+
 tcp_retrans_collapse - BOOLEAN
 	Bug-to-bug compatibility with some broken printers.
 	On retransmit try to send bigger packets to work around bugs in
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index c2dee7deefa8cb32af530d20e5aa32a61b10ce68..f566b8567892ef0bb213de0540b37cfc6ac03ca0 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -204,10 +204,10 @@ struct tcp_sock {
 
 	u16	urg_data;	/* Saved octet of OOB data and control flags */
 	u8	ecn_flags;	/* ECN status bits.			*/
-	u8	reordering;	/* Packet reordering metric.		*/
+	u8	keepalive_probes; /* num of allowed keep alive probes	*/
+	u32	reordering;	/* Packet reordering metric.		*/
 	u32	snd_up;		/* Urgent pointer		*/
 
-	u8	keepalive_probes; /* num of allowed keep alive probes	*/
 /*
  *      Options received (usually on last packet, some only on SYN packets).
  */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index c73fc145ee4533c3f65adf5370e9c0348dfb4395..3a35b1500359446d98ee9f1cd0b55d34ac66d477 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -70,9 +70,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 /* After receiving this amount of duplicate ACKs fast retransmit starts. */
 #define TCP_FASTRETRANS_THRESH 3
 
-/* Maximal reordering. */
-#define TCP_MAX_REORDERING	127
-
 /* Maximal number of ACKs sent quickly to accelerate slow-start. */
 #define TCP_MAX_QUICKACKS	16U
 
@@ -252,6 +249,7 @@ extern int sysctl_tcp_abort_on_overflow;
 extern int sysctl_tcp_max_orphans;
 extern int sysctl_tcp_fack;
 extern int sysctl_tcp_reordering;
+extern int sysctl_tcp_max_reordering;
 extern int sysctl_tcp_dsack;
 extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index b3c53c8b331efc3d5cf6437fd3ec7634a154263c..e0ee384a448fb0e6eb5b957d98dbcb272ea97edb 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -496,6 +496,13 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "tcp_max_reordering",
+		.data		= &sysctl_tcp_max_reordering,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "tcp_dsack",
 		.data		= &sysctl_tcp_dsack,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a12b455928e52211efdc6b471ef54de6218f5df0..9a18cdd633f37e6a805f0f096edece0b0852bc20 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -81,6 +81,7 @@ int sysctl_tcp_window_scaling __read_mostly = 1;
 int sysctl_tcp_sack __read_mostly = 1;
 int sysctl_tcp_fack __read_mostly = 1;
 int sysctl_tcp_reordering __read_mostly = TCP_FASTRETRANS_THRESH;
+int sysctl_tcp_max_reordering __read_mostly = 300;
 EXPORT_SYMBOL(sysctl_tcp_reordering);
 int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
@@ -833,7 +834,7 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
 	if (metric > tp->reordering) {
 		int mib_idx;
 
-		tp->reordering = min(TCP_MAX_REORDERING, metric);
+		tp->reordering = min(sysctl_tcp_max_reordering, metric);
 
 		/* This exciting event is worth to be remembered. 8) */
 		if (ts)
