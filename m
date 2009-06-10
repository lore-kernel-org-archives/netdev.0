From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 14/31: nf_ct_tcp: TCP simultaneous open support
Date: Wed, 10 Jun 2009 21:46:39 +0200 (MEST)
Message-ID: <20090610194637.11112.48298.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 874ab9233eeddb85fd2dd85131c145bde75da39a
Author: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Date:   Tue Jun 2 13:58:56 2009 +0200

    netfilter: nf_ct_tcp: TCP simultaneous open support
    
    The patch below adds supporting TCP simultaneous open to conntrack. The
    unused LISTEN state is replaced by a new state (SYN_SENT2) denoting the
    second SYN sent from the reply direction in the new case. The state table
    is updated and the function tcp_in_window is modified to handle
    simultaneous open.
    
    The functionality can fairly easily be tested by socat. A sample tcpdump
    recording
    
    23:21:34.244733 IP (tos 0x0, ttl 64, id 49224, offset 0, flags [DF], proto TCP (6), length 60) 192.168.0.254.2020 > 192.168.0.1.2020: S, cksum 0xe75f (correct), 3383710133:3383710133(0) win 5840 <mss 1460,sackOK,timestamp 173445629 0,nop,wscale 7>
    23:21:34.244783 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 40) 192.168.0.1.2020 > 192.168.0.254.2020: R, cksum 0x0253 (correct), 0:0(0) ack 3383710134 win 0
    23:21:36.038680 IP (tos 0x0, ttl 64, id 28092, offset 0, flags [DF], proto TCP (6), length 60) 192.168.0.1.2020 > 192.168.0.254.2020: S, cksum 0x704b (correct), 2634546729:2634546729(0) win 5840 <mss 1460,sackOK,timestamp 824213 0,nop,wscale 1>
    23:21:36.038777 IP (tos 0x0, ttl 64, id 49225, offset 0, flags [DF], proto TCP (6), length 60) 192.168.0.254.2020 > 192.168.0.1.2020: S, cksum 0xb179 (correct), 3383710133:3383710133(0) ack 2634546730 win 5840 <mss 1460,sackOK,timestamp 173447423 824213,nop,wscale 7>
    23:21:36.038847 IP (tos 0x0, ttl 64, id 28093, offset 0, flags [DF], proto TCP (6), length 52) 192.168.0.1.2020 > 192.168.0.254.2020: ., cksum 0xebad (correct), ack 3383710134 win 2920 <nop,nop,timestamp 824213 173447423>
    
    and the corresponding netlink events:
    
        [NEW] tcp      6 120 SYN_SENT src=192.168.0.254 dst=192.168.0.1 sport=2020 dport=2020 [UNREPLIED] src=192.168.0.1 dst=192.168.0.254 sport=2020 dport=2020
     [UPDATE] tcp      6 120 LISTEN src=192.168.0.254 dst=192.168.0.1 sport=2020 dport=2020 src=192.168.0.1 dst=192.168.0.254 sport=2020 dport=2020
     [UPDATE] tcp      6 60 SYN_RECV src=192.168.0.254 dst=192.168.0.1 sport=2020 dport=2020 src=192.168.0.1 dst=192.168.0.254 sport=2020 dport=2020
     [UPDATE] tcp      6 432000 ESTABLISHED src=192.168.0.254 dst=192.168.0.1 sport=2020 dport=2020 src=192.168.0.1 dst=192.168.0.254 sport=2020 dport=2020 [ASSURED]
    
    The RST packet was dropped in the raw table, thus it did not reach
    conntrack.  nfnetlink_conntrack is unpatched so it shows the new SYN_SENT2
    state as the old unused LISTEN.
    
    With TCP simultaneous open support we satisfy REQ-2 in RFC 5382  ;-) .
    
    Additional minor correction in this patch is that in order to catch
    uninitialized reply directions, "td_maxwin == 0" is used instead of
    "td_end == 0" because the former can't be true except in uninitialized
    state while td_end may accidentally be equal to zero in the mid of a
    connection.
    
    Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/nf_conntrack_tcp.h b/include/linux/netfilter/nf_conntrack_tcp.h
index 3066789..74c27ca 100644
--- a/include/linux/netfilter/nf_conntrack_tcp.h
+++ b/include/linux/netfilter/nf_conntrack_tcp.h
@@ -15,7 +15,8 @@ enum tcp_conntrack {
 	TCP_CONNTRACK_LAST_ACK,
 	TCP_CONNTRACK_TIME_WAIT,
 	TCP_CONNTRACK_CLOSE,
-	TCP_CONNTRACK_LISTEN,
+	TCP_CONNTRACK_LISTEN,	/* obsolete */
+#define TCP_CONNTRACK_SYN_SENT2	TCP_CONNTRACK_LISTEN
 	TCP_CONNTRACK_MAX,
 	TCP_CONNTRACK_IGNORE
 };
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index b5ccf2b..4c7f6f0 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -59,7 +59,7 @@ static const char *const tcp_conntrack_names[] = {
 	"LAST_ACK",
 	"TIME_WAIT",
 	"CLOSE",
-	"LISTEN"
+	"SYN_SENT2",
 };
 
 #define SECS * HZ
@@ -82,6 +82,7 @@ static unsigned int tcp_timeouts[TCP_CONNTRACK_MAX] __read_mostly = {
 	[TCP_CONNTRACK_LAST_ACK]	= 30 SECS,
 	[TCP_CONNTRACK_TIME_WAIT]	= 2 MINS,
 	[TCP_CONNTRACK_CLOSE]		= 10 SECS,
+	[TCP_CONNTRACK_SYN_SENT2]	= 2 MINS,
 };
 
 #define sNO TCP_CONNTRACK_NONE
@@ -93,7 +94,7 @@ static unsigned int tcp_timeouts[TCP_CONNTRACK_MAX] __read_mostly = {
 #define sLA TCP_CONNTRACK_LAST_ACK
 #define sTW TCP_CONNTRACK_TIME_WAIT
 #define sCL TCP_CONNTRACK_CLOSE
-#define sLI TCP_CONNTRACK_LISTEN
+#define sS2 TCP_CONNTRACK_SYN_SENT2
 #define sIV TCP_CONNTRACK_MAX
 #define sIG TCP_CONNTRACK_IGNORE
 
@@ -123,6 +124,7 @@ enum tcp_bit_set {
  *
  * NONE:	initial state
  * SYN_SENT:	SYN-only packet seen
+ * SYN_SENT2:	SYN-only packet seen from reply dir, simultaneous open
  * SYN_RECV:	SYN-ACK packet seen
  * ESTABLISHED:	ACK packet seen
  * FIN_WAIT:	FIN packet seen
@@ -131,26 +133,24 @@ enum tcp_bit_set {
  * TIME_WAIT:	last ACK seen
  * CLOSE:	closed connection (RST)
  *
- * LISTEN state is not used.
- *
  * Packets marked as IGNORED (sIG):
  *	if they may be either invalid or valid
  *	and the receiver may send back a connection
  *	closing RST or a SYN/ACK.
  *
  * Packets marked as INVALID (sIV):
- *	if they are invalid
- *	or we do not support the request (simultaneous open)
+ *	if we regard them as truly invalid packets
  */
 static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
 	{
 /* ORIGINAL */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sLI	*/
-/*syn*/	   { sSS, sSS, sIG, sIG, sIG, sIG, sIG, sSS, sSS, sIV },
+/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*syn*/	   { sSS, sSS, sIG, sIG, sIG, sIG, sIG, sSS, sSS, sS2 },
 /*
  *	sNO -> sSS	Initialize a new connection
  *	sSS -> sSS	Retransmitted SYN
- *	sSR -> sIG	Late retransmitted SYN?
+ *	sS2 -> sS2	Late retransmitted SYN
+ *	sSR -> sIG
  *	sES -> sIG	Error: SYNs in window outside the SYN_SENT state
  *			are errors. Receiver will reply with RST
  *			and close the connection.
@@ -161,22 +161,30 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sSS	Reopened connection (RFC 1122).
  *	sCL -> sSS
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sLI	*/
-/*synack*/ { sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV },
+/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*synack*/ { sIV, sIV, sIG, sIG, sIG, sIG, sIG, sIG, sIG, sSR },
 /*
- * A SYN/ACK from the client is always invalid:
- *	- either it tries to set up a simultaneous open, which is
- *	  not supported;
- *	- or the firewall has just been inserted between the two hosts
- *	  during the session set-up. The SYN will be retransmitted
- *	  by the true client (or it'll time out).
+ *	sNO -> sIV	Too late and no reason to do anything
+ *	sSS -> sIV	Client can't send SYN and then SYN/ACK
+ *	sS2 -> sSR	SYN/ACK sent to SYN2 in simultaneous open
+ *	sSR -> sIG
+ *	sES -> sIG	Error: SYNs in window outside the SYN_SENT state
+ *			are errors. Receiver will reply with RST
+ *			and close the connection.
+ *			Or we are not in sync and hold a dead connection.
+ *	sFW -> sIG
+ *	sCW -> sIG
+ *	sLA -> sIG
+ *	sTW -> sIG
+ *	sCL -> sIG
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sLI	*/
+/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*fin*/    { sIV, sIV, sFW, sFW, sLA, sLA, sLA, sTW, sCL, sIV },
 /*
  *	sNO -> sIV	Too late and no reason to do anything...
  *	sSS -> sIV	Client migth not send FIN in this state:
  *			we enforce waiting for a SYN/ACK reply first.
+ *	sS2 -> sIV
  *	sSR -> sFW	Close started.
  *	sES -> sFW
  *	sFW -> sLA	FIN seen in both directions, waiting for
@@ -187,11 +195,12 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sTW
  *	sCL -> sCL
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sLI	*/
+/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*ack*/	   { sES, sIV, sES, sES, sCW, sCW, sTW, sTW, sCL, sIV },
 /*
  *	sNO -> sES	Assumed.
  *	sSS -> sIV	ACK is invalid: we haven't seen a SYN/ACK yet.
+ *	sS2 -> sIV
  *	sSR -> sES	Established state is reached.
  *	sES -> sES	:-)
  *	sFW -> sCW	Normal close request answered by ACK.
@@ -200,29 +209,31 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sTW	Retransmitted last ACK. Remain in the same state.
  *	sCL -> sCL
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sLI	*/
-/*rst*/    { sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sIV },
+/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*rst*/    { sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL },
 /*none*/   { sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV }
 	},
 	{
 /* REPLY */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sLI	*/
-/*syn*/	   { sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV },
+/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*syn*/	   { sIV, sS2, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sS2 },
 /*
  *	sNO -> sIV	Never reached.
- *	sSS -> sIV	Simultaneous open, not supported
- *	sSR -> sIV	Simultaneous open, not supported.
- *	sES -> sIV	Server may not initiate a connection.
+ *	sSS -> sS2	Simultaneous open
+ *	sS2 -> sS2	Retransmitted simultaneous SYN
+ *	sSR -> sIV	Invalid SYN packets sent by the server
+ *	sES -> sIV
  *	sFW -> sIV
  *	sCW -> sIV
  *	sLA -> sIV
  *	sTW -> sIV	Reopened connection, but server may not do it.
  *	sCL -> sIV
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sLI	*/
-/*synack*/ { sIV, sSR, sSR, sIG, sIG, sIG, sIG, sIG, sIG, sIV },
+/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*synack*/ { sIV, sSR, sSR, sIG, sIG, sIG, sIG, sIG, sIG, sSR },
 /*
  *	sSS -> sSR	Standard open.
+ *	sS2 -> sSR	Simultaneous open
  *	sSR -> sSR	Retransmitted SYN/ACK.
  *	sES -> sIG	Late retransmitted SYN/ACK?
  *	sFW -> sIG	Might be SYN/ACK answering ignored SYN
@@ -231,10 +242,11 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sIG
  *	sCL -> sIG
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sLI	*/
+/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*fin*/    { sIV, sIV, sFW, sFW, sLA, sLA, sLA, sTW, sCL, sIV },
 /*
  *	sSS -> sIV	Server might not send FIN in this state.
+ *	sS2 -> sIV
  *	sSR -> sFW	Close started.
  *	sES -> sFW
  *	sFW -> sLA	FIN seen in both directions.
@@ -243,10 +255,11 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sTW
  *	sCL -> sCL
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sLI	*/
-/*ack*/	   { sIV, sIG, sSR, sES, sCW, sCW, sTW, sTW, sCL, sIV },
+/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*ack*/	   { sIV, sIG, sSR, sES, sCW, sCW, sTW, sTW, sCL, sIG },
 /*
  *	sSS -> sIG	Might be a half-open connection.
+ *	sS2 -> sIG
  *	sSR -> sSR	Might answer late resent SYN.
  *	sES -> sES	:-)
  *	sFW -> sCW	Normal close request answered by ACK.
@@ -255,8 +268,8 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sTW -> sTW	Retransmitted last ACK.
  *	sCL -> sCL
  */
-/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sLI	*/
-/*rst*/    { sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sIV },
+/* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
+/*rst*/    { sIV, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL, sCL },
 /*none*/   { sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sIV }
 	}
 };
@@ -521,13 +534,14 @@ static bool tcp_in_window(const struct nf_conn *ct,
 		 receiver->td_end, receiver->td_maxend, receiver->td_maxwin,
 		 receiver->td_scale);
 
-	if (sender->td_end == 0) {
+	if (sender->td_maxwin == 0) {
 		/*
 		 * Initialize sender data.
 		 */
-		if (tcph->syn && tcph->ack) {
+		if (tcph->syn) {
 			/*
-			 * Outgoing SYN-ACK in reply to a SYN.
+			 * SYN-ACK in reply to a SYN
+			 * or SYN from reply direction in simultaneous open.
 			 */
 			sender->td_end =
 			sender->td_maxend = end;
@@ -543,6 +557,9 @@ static bool tcp_in_window(const struct nf_conn *ct,
 			      && receiver->flags & IP_CT_TCP_FLAG_WINDOW_SCALE))
 				sender->td_scale =
 				receiver->td_scale = 0;
+			if (!tcph->ack)
+				/* Simultaneous open */
+				return true;
 		} else {
 			/*
 			 * We are in the middle of a connection,
@@ -1068,7 +1085,7 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 
 	ct->proto.tcp.seen[1].td_end = 0;
 	ct->proto.tcp.seen[1].td_maxend = 0;
-	ct->proto.tcp.seen[1].td_maxwin = 1;
+	ct->proto.tcp.seen[1].td_maxwin = 0;
 	ct->proto.tcp.seen[1].td_scale = 0;
 
 	/* tcp_packet will set them */
@@ -1310,6 +1327,13 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
+		.procname	= "ip_conntrack_tcp_timeout_syn_sent2",
+		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_SENT2],
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
 		.procname	= "ip_conntrack_tcp_timeout_syn_recv",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_RECV],
 		.maxlen		= sizeof(unsigned int),
