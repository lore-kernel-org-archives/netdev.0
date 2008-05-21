From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/2] [TCP]: Reorganize tcp_sock to fill 64-bit holes & improve
 locality
Date: Wed, 21 May 2008 15:40:15 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805211536390.16829@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0805211534170.16829@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696208474-1096597956-1211373368=:16829"
Cc: Netdev <netdev@vger.kernel.org>, Eric Dumazet <dada1@cosmosbay.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37361 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762306AbYEUMkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 08:40:16 -0400
In-Reply-To: <Pine.LNX.4.64.0805211534170.16829@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0805211536391.16829@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1096597956-1211373368=:16829
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805211536392.16829@wrl-59.cs.helsinki.fi>


I tried to group recovery related fields nearby (non-CA_Open
related variables, to be more accurate) so that one to three
cachelines would not be necessary in CA_Open. These are now
contiguously deployed:

  struct sk_buff_head        out_of_order_queue;   /*  1968    80 */
  /* --- cacheline 32 boundary (2048 bytes) --- */
  struct tcp_sack_block      duplicate_sack[1];    /*  2048     8 */
  struct tcp_sack_block      selective_acks[4];    /*  2056    32 */
  struct tcp_sack_block      recv_sack_cache[4];   /*  2088    32 */
  /* --- cacheline 33 boundary (2112 bytes) was 8 bytes ago --- */
  struct sk_buff *           highest_sack;         /*  2120     8 */
  int                        lost_cnt_hint;        /*  2128     4 */
  int                        retransmit_cnt_hint;  /*  2132     4 */
  u32                        lost_retrans_low;     /*  2136     4 */
  u8                         reordering;           /*  2140     1 */
  u8                         keepalive_probes;     /*  2141     1 */

  /* XXX 2 bytes hole, try to pack */

  u32                        prior_ssthresh;       /*  2144     4 */
  u32                        high_seq;             /*  2148     4 */
  u32                        retrans_stamp;        /*  2152     4 */
  u32                        undo_marker;          /*  2156     4 */
  int                        undo_retrans;         /*  2160     4 */
  u32                        total_retrans;        /*  2164     4 */

...and they're then followed by URG slowpath & keepalive related
variables.

Head of the out_of_order_queue always needed for empty checks,
if that's empty (and TCP is in CA_Open), following ~200 bytes
(in 64-bit) shouldn't be necessary for anything. If only OFO
queue exists but TCP is in CA_Open, selective_acks (and possibly
duplicate_sack) are necessary besides the out_of_order_queue
but the rest of the block again shouldn't be (ie., the other
direction had losses).

As the cacheline boundaries depend on many factors in the
preceeding stuff, trying to align considering them doesn't
make too much sense.

Commented one ordering hazard.

There are number of low utilized u8/16s that could be combined
get 2 bytes less in total so that the hole could be made to vanish
(includes at least ecn_flags, urg_data, urg_mode, frto_counter,
nonagle).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Cc: Eric Dumazet <dada1@cosmosbay.com>
---

I'm not sure if this is a right time for such reorganization but it won't 
hurt to post it anyway.

 include/linux/tcp.h |   50 +++++++++++++++++++++++++-------------------------
 1 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 18e62e3..9881295 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -296,10 +296,9 @@ struct tcp_sock {
 	u32	rcv_ssthresh;	/* Current window clamp			*/
 
 	u32	frto_highmark;	/* snd_nxt when RTO occurred */
-	u8	reordering;	/* Packet reordering metric.		*/
+	u16	advmss;		/* Advertised MSS			*/
 	u8	frto_counter;	/* Number of new acks after RTO */
 	u8	nonagle;	/* Disable Nagle algorithm?             */
-	u8	keepalive_probes; /* num of allowed keep alive probes	*/
 
 /* RTT measurement */
 	u32	srtt;		/* smoothed round trip time << 3	*/
@@ -310,6 +309,10 @@ struct tcp_sock {
 
 	u32	packets_out;	/* Packets which are "in flight"	*/
 	u32	retrans_out;	/* Retransmitted packets out		*/
+
+	u16	urg_data;	/* Saved octet of OOB data and control flags */
+	u8	urg_mode;	/* In urgent mode		*/
+	u8	ecn_flags;	/* ECN status bits.			*/
 /*
  *      Options received (usually on last packet, some only on SYN packets).
  */
@@ -325,13 +328,24 @@ struct tcp_sock {
 	u32	snd_cwnd_used;
 	u32	snd_cwnd_stamp;
 
-	struct sk_buff_head	out_of_order_queue; /* Out of order segments go here */
-
  	u32	rcv_wnd;	/* Current receiver window		*/
 	u32	write_seq;	/* Tail(+1) of data held in tcp send buffer */
 	u32	pushed_seq;	/* Last pushed seq, required to talk to windows */
+	u32	lost_out;	/* Lost packets			*/
+	u32	sacked_out;	/* SACK'd packets			*/
+	u32	fackets_out;	/* FACK'd packets			*/
+	u32	tso_deferred;
+	u32	bytes_acked;	/* Appropriate Byte Counting - RFC3465 */
 
-/*	SACKs data	*/
+	/* from STCP, retrans queue hinting */
+	struct sk_buff* lost_skb_hint;
+	struct sk_buff *scoreboard_skb_hint;
+	struct sk_buff *retransmit_skb_hint;
+	struct sk_buff *forward_skb_hint;
+
+	struct sk_buff_head	out_of_order_queue; /* Out of order segments go here */
+
+	/* SACKs data, these 2 need to be together (see tcp_build_and_update_options) */
 	struct tcp_sack_block duplicate_sack[1]; /* D-SACK block */
 	struct tcp_sack_block selective_acks[4]; /* The SACKS themselves*/
 
@@ -342,23 +356,14 @@ struct tcp_sock {
 					 * sacked_out > 0)
 					 */
 
-	/* from STCP, retrans queue hinting */
-	struct sk_buff* lost_skb_hint;
-
-	struct sk_buff *scoreboard_skb_hint;
-	struct sk_buff *retransmit_skb_hint;
-	struct sk_buff *forward_skb_hint;
-
 	int     lost_cnt_hint;
 	int     retransmit_cnt_hint;
 
 	u32	lost_retrans_low;	/* Sent seq after any rxmit (lowest) */
 
-	u16	advmss;		/* Advertised MSS			*/
+	u8	reordering;	/* Packet reordering metric.		*/
+	u8	keepalive_probes; /* num of allowed keep alive probes	*/
 	u32	prior_ssthresh; /* ssthresh saved at recovery start	*/
-	u32	lost_out;	/* Lost packets			*/
-	u32	sacked_out;	/* SACK'd packets			*/
-	u32	fackets_out;	/* FACK'd packets			*/
 	u32	high_seq;	/* snd_nxt at onset of congestion	*/
 
 	u32	retrans_stamp;	/* Timestamp of the last retransmit,
@@ -366,25 +371,18 @@ struct tcp_sock {
 				 * the first SYN. */
 	u32	undo_marker;	/* tracking retrans started here. */
 	int	undo_retrans;	/* number of undoable retransmissions. */
+	u32	total_retrans;	/* Total retransmits for entire connection */
+
 	u32	urg_seq;	/* Seq of received urgent pointer */
-	u16	urg_data;	/* Saved octet of OOB data and control flags */
-	u8	urg_mode;	/* In urgent mode		*/
-	u8	ecn_flags;	/* ECN status bits.			*/
 	u32	snd_up;		/* Urgent pointer		*/
 
-	u32	total_retrans;	/* Total retransmits for entire connection */
-	u32	bytes_acked;	/* Appropriate Byte Counting - RFC3465 */
-
 	unsigned int		keepalive_time;	  /* time before keep alive takes place */
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
-	int			linger2;
 
 	struct tcp_deferred_accept_info defer_tcp_accept;
 
 	unsigned long last_synq_overflow; 
 
-	u32	tso_deferred;
-
 /* Receiver side RTT estimation */
 	struct {
 		u32	rtt;
@@ -412,6 +410,8 @@ struct tcp_sock {
 /* TCP MD5 Signagure Option information */
 	struct tcp_md5sig_info	*md5sig_info;
 #endif
+
+	int			linger2;
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
-- 
1.5.2.2

---696208474-1096597956-1211373368=:16829--
