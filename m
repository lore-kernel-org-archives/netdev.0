From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: [PATCH] CUBIC v2.3 with new improved slow start
Date: Wed, 29 Oct 2008 17:28:26 -0400
Message-ID: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_005D_01C939EB.C02B49D0"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uni12mr.unity.ncsu.edu ([152.1.1.171]:54242 "EHLO
	uni12mr.unity.ncsu.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392AbYJ2VpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 17:45:04 -0400
Received: from ncsu2cc0c3fa00 (bakdu.csc.ncsu.edu [152.14.88.74])
	by uni12mr.unity.ncsu.edu (8.13.7/8.13.8/Nv5.2008.0610.1) with SMTP id m9TLSRH3027842
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 17:28:28 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------=_NextPart_000_005D_01C939EB.C02B49D0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit

I am releasing a new patch for CUBIC. This patch implements a new slow start 
mechanism called HyStart. There were some discussions in the mailing list on 
the poor performance of TCP slow start; our patch addresses those 
performance issues arising from slow start.  For more information, please 
refer to the following technical report:

 Sangtae Ha and Injong Rhee, "Taming the Elephants: New TCP Slow
Start", NCSU Technical Report 2008. Available at
http://netsrv.csc.ncsu.edu/export/hystart_techreport_2008.pdf


The new update improves the start-up throughput of CUBIC substantially by 
avoiding system overloading during slow start and shortening the 
fast-recovery period after slow start. The key performance issues arising 
when Linux is used with Windows XP or FreeBSD receivers are also addressed. 
Our tests over Internet2 paths are very encouraging. The scheme is verified 
to work well even for asymmetric paths,  with diverse receiver settings of 
delayed acknowledgements, and with various operating systems (Windows XP and 
FreeBSD). You can find the testing results from

http://netsrv.csc.ncsu.edu/wiki/index.php/TCP_Testing

Please let us know if there are other performance issues of TCP that you 
want us to look into.

Injong and Sangtae.


------=_NextPart_000_005D_01C939EB.C02B49D0
Content-Type: application/octet-stream;
	name="0001-TCP-CUBIC-v2.3.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-TCP-CUBIC-v2.3.patch"

>From ee61f3e3f5aee0707eac02cd8cec2ab37e7114ee Mon Sep 17 00:00:00 2001=0A=
From: Sangtae Ha <sha2@ncsu.edu>=0A=
Date: Wed, 29 Oct 2008 00:07:18 -0400=0A=
Subject: [PATCH] [TCP] CUBIC v2.3=0A=
=0A=
=0A=
Signed-off-by: Sangtae Ha <sha2@ncsu.edu>=0A=
---=0A=
 net/ipv4/tcp_cubic.c |  120 =
+++++++++++++++++++++++++++++++++++++++++++++-----=0A=
 1 files changed, 109 insertions(+), 11 deletions(-)=0A=
=0A=
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c=0A=
index 4a1221e..ee467ec 100644=0A=
--- a/net/ipv4/tcp_cubic.c=0A=
+++ b/net/ipv4/tcp_cubic.c=0A=
@@ -1,13 +1,23 @@=0A=
 /*=0A=
- * TCP CUBIC: Binary Increase Congestion control for TCP v2.2=0A=
+ * TCP CUBIC: Binary Increase Congestion control for TCP v2.3=0A=
  * Home page:=0A=
  *      http://netsrv.csc.ncsu.edu/twiki/bin/view/Main/BIC=0A=
  * This is from the implementation of CUBIC TCP in=0A=
- * Injong Rhee, Lisong Xu.=0A=
- *  "CUBIC: A New TCP-Friendly High-Speed TCP Variant=0A=
- *  in PFLDnet 2005=0A=
+ * Sangtae Ha, Injong Rhee and Lisong Xu,=0A=
+ *  "CUBIC: A New TCP-Friendly High-Speed TCP Variant"=0A=
+ *  in ACM SIGOPS Operating System Review, July 2008.=0A=
  * Available from:=0A=
- *  http://netsrv.csc.ncsu.edu/export/cubic-paper.pdf=0A=
+ *  http://netsrv.csc.ncsu.edu/export/cubic_a_new_tcp_2008.pdf=0A=
+ *=0A=
+ * CUBIC integrates a new slow start algorithm, called HyStart.=0A=
+ * The details of HyStart are presented in=0A=
+ *  Sangtae Ha and Injong Rhee,=0A=
+ *  "Taming the Elephants: New TCP Slow Start", NCSU TechReport 2008.=0A=
+ * Available from:=0A=
+ *  http://netsrv.csc.ncsu.edu/export/hystart_techreport_2008.pdf=0A=
+ *=0A=
+ * All testing results are available from:=0A=
+ * http://netsrv.csc.ncsu.edu/wiki/index.php/TCP_Testing=0A=
  *=0A=
  * Unless CUBIC is enabled and congestion window is large=0A=
  * this behaves the same as the original Reno.=0A=
@@ -23,12 +33,26 @@=0A=
 					 */=0A=
 #define	BICTCP_HZ		10	/* BIC HZ 2^10 =3D 1024 */=0A=
 =0A=
+/* Two methods of hybrid slow start */=0A=
+#define HYSTART_ACK_TRAIN	0x1=0A=
+#define HYSTART_DELAY		0x2=0A=
+=0A=
+/* Number of delay samples for detecting the increase of delay */=0A=
+#define HYSTART_MIN_SAMPLES	8=0A=
+#define HYSTART_DELAY_MIN	(2U<<3)=0A=
+#define HYSTART_DELAY_MAX	(16U<<3)=0A=
+#define HYSTART_DELAY_THRESH(x)	clamp(x, HYSTART_DELAY_MIN, =
HYSTART_DELAY_MAX)=0A=
+=0A=
 static int fast_convergence __read_mostly =3D 1;=0A=
 static int beta __read_mostly =3D 717;	/* =3D 717/1024 =
(BICTCP_BETA_SCALE) */=0A=
 static int initial_ssthresh __read_mostly;=0A=
 static int bic_scale __read_mostly =3D 41;=0A=
 static int tcp_friendliness __read_mostly =3D 1;=0A=
 =0A=
+static int hystart __read_mostly =3D 1;=0A=
+static int hystart_detect __read_mostly =3D HYSTART_ACK_TRAIN | =
HYSTART_DELAY;=0A=
+static int hystart_low_window __read_mostly =3D 16;=0A=
+=0A=
 static u32 cube_rtt_scale __read_mostly;=0A=
 static u32 beta_scale __read_mostly;=0A=
 static u64 cube_factor __read_mostly;=0A=
@@ -44,6 +68,13 @@ module_param(bic_scale, int, 0444);=0A=
 MODULE_PARM_DESC(bic_scale, "scale (scaled by 1024) value for bic =
function (bic_scale/1024)");=0A=
 module_param(tcp_friendliness, int, 0644);=0A=
 MODULE_PARM_DESC(tcp_friendliness, "turn on/off tcp friendliness");=0A=
+module_param(hystart, int, 0644);=0A=
+MODULE_PARM_DESC(hystart, "turn on/off hybrid slow start algorithm");=0A=
+module_param(hystart_detect, int, 0644);=0A=
+MODULE_PARM_DESC(hystart_detect, "hyrbrid slow start detection =
mechanisms"=0A=
+		 " 1: packet-train 2: delay 3: both packet-train and delay");=0A=
+module_param(hystart_low_window, int, 0644);=0A=
+MODULE_PARM_DESC(hystart_low_window, "lower bound cwnd for hybrid slow =
start");=0A=
 =0A=
 /* BIC TCP Parameters */=0A=
 struct bictcp {=0A=
@@ -59,7 +90,13 @@ struct bictcp {=0A=
 	u32	ack_cnt;	/* number of acks */=0A=
 	u32	tcp_cwnd;	/* estimated tcp cwnd */=0A=
 #define ACK_RATIO_SHIFT	4=0A=
-	u32	delayed_ack;	/* estimate the ratio of Packets/ACKs << 4 */=0A=
+	u16	delayed_ack;	/* estimate the ratio of Packets/ACKs << 4 */=0A=
+	u8	sample_cnt;	/* number of samples to decide curr_rtt */=0A=
+	u8	found;		/* the exit point is found? */=0A=
+	u32	round_start;	/* beginning of each round */=0A=
+	u32	end_seq;	/* end_seq of the round */=0A=
+	u32	last_jiffies;	/* last time when the ACK spacing is close */=0A=
+	u32	curr_rtt;	/* the minimum rtt of current round */=0A=
 };=0A=
 =0A=
 static inline void bictcp_reset(struct bictcp *ca)=0A=
@@ -76,12 +113,28 @@ static inline void bictcp_reset(struct bictcp *ca)=0A=
 	ca->delayed_ack =3D 2 << ACK_RATIO_SHIFT;=0A=
 	ca->ack_cnt =3D 0;=0A=
 	ca->tcp_cwnd =3D 0;=0A=
+	ca->found =3D 0;=0A=
+}=0A=
+=0A=
+static inline void bictcp_hystart_reset(struct sock *sk)=0A=
+{=0A=
+	struct tcp_sock *tp =3D tcp_sk(sk);=0A=
+	struct bictcp *ca =3D inet_csk_ca(sk);=0A=
+=0A=
+	ca->round_start =3D ca->last_jiffies =3D jiffies;=0A=
+	ca->end_seq =3D tp->snd_nxt;=0A=
+	ca->curr_rtt =3D 0;=0A=
+	ca->sample_cnt =3D 0;=0A=
 }=0A=
 =0A=
 static void bictcp_init(struct sock *sk)=0A=
 {=0A=
 	bictcp_reset(inet_csk_ca(sk));=0A=
-	if (initial_ssthresh)=0A=
+=0A=
+	if (hystart)=0A=
+		bictcp_hystart_reset(sk);=0A=
+=0A=
+	if (!hystart && initial_ssthresh)=0A=
 		tcp_sk(sk)->snd_ssthresh =3D initial_ssthresh;=0A=
 }=0A=
 =0A=
@@ -235,9 +288,11 @@ static void bictcp_cong_avoid(struct sock *sk, u32 =
ack, u32 in_flight)=0A=
 	if (!tcp_is_cwnd_limited(sk, in_flight))=0A=
 		return;=0A=
 =0A=
-	if (tp->snd_cwnd <=3D tp->snd_ssthresh)=0A=
+	if (tp->snd_cwnd <=3D tp->snd_ssthresh) {=0A=
+		if (hystart && after(ack, ca->end_seq))=0A=
+			bictcp_hystart_reset(sk);=0A=
 		tcp_slow_start(tp);=0A=
-	else {=0A=
+	} else {=0A=
 		bictcp_update(ca, tp->snd_cwnd);=0A=
 =0A=
 		/* In dangerous area, increase slowly.=0A=
@@ -281,8 +336,45 @@ static u32 bictcp_undo_cwnd(struct sock *sk)=0A=
 =0A=
 static void bictcp_state(struct sock *sk, u8 new_state)=0A=
 {=0A=
-	if (new_state =3D=3D TCP_CA_Loss)=0A=
+	if (new_state =3D=3D TCP_CA_Loss) {=0A=
 		bictcp_reset(inet_csk_ca(sk));=0A=
+		bictcp_hystart_reset(sk);=0A=
+	}=0A=
+}=0A=
+=0A=
+static void hystart_update(struct sock *sk, u32 delay)=0A=
+{=0A=
+	struct tcp_sock *tp =3D tcp_sk(sk);=0A=
+	struct bictcp *ca =3D inet_csk_ca(sk);=0A=
+=0A=
+	if (!(ca->found & hystart_detect)) {=0A=
+		u32 curr_jiffies =3D jiffies;=0A=
+=0A=
+		/* first detection parameter - ack-train detection */=0A=
+		if (curr_jiffies - ca->last_jiffies <=3D msecs_to_jiffies(2)) {=0A=
+			ca->last_jiffies =3D curr_jiffies;=0A=
+			if (curr_jiffies - ca->round_start >=3D ca->delay_min>>4)=0A=
+				ca->found |=3D HYSTART_ACK_TRAIN;=0A=
+		}=0A=
+=0A=
+		/* obtain the minimum delay of more than sampling packets */=0A=
+		if (ca->sample_cnt < HYSTART_MIN_SAMPLES) {=0A=
+			if (ca->curr_rtt =3D=3D 0 || ca->curr_rtt > delay)=0A=
+				ca->curr_rtt =3D delay;=0A=
+=0A=
+			ca->sample_cnt++;=0A=
+		} else {=0A=
+			if (ca->curr_rtt > ca->delay_min +=0A=
+			    HYSTART_DELAY_THRESH(ca->delay_min>>4))=0A=
+				ca->found |=3D HYSTART_DELAY;=0A=
+		}=0A=
+		/*=0A=
+		 * Either one of two conditions are met,=0A=
+		 * we exit from slow start immediately.=0A=
+		 */=0A=
+		if (ca->found & hystart_detect)=0A=
+			tp->snd_ssthresh =3D tp->snd_cwnd;=0A=
+	}=0A=
 }=0A=
 =0A=
 /* Track delayed acknowledgment ratio using sliding window=0A=
@@ -291,6 +383,7 @@ static void bictcp_state(struct sock *sk, u8 =
new_state)=0A=
 static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)=0A=
 {=0A=
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);=0A=
+	const struct tcp_sock *tp =3D tcp_sk(sk);=0A=
 	struct bictcp *ca =3D inet_csk_ca(sk);=0A=
 	u32 delay;=0A=
 =0A=
@@ -314,6 +407,11 @@ static void bictcp_acked(struct sock *sk, u32 cnt, =
s32 rtt_us)=0A=
 	/* first time call or link delay decreases */=0A=
 	if (ca->delay_min =3D=3D 0 || ca->delay_min > delay)=0A=
 		ca->delay_min =3D delay;=0A=
+=0A=
+	/* hystart triggers when cwnd is larger than some threshold */=0A=
+	if (hystart && tp->snd_cwnd <=3D tp->snd_ssthresh &&=0A=
+	    tp->snd_cwnd >=3D hystart_low_window)=0A=
+		hystart_update(sk, delay);=0A=
 }=0A=
 =0A=
 static struct tcp_congestion_ops cubictcp =3D {=0A=
@@ -372,4 +470,4 @@ module_exit(cubictcp_unregister);=0A=
 MODULE_AUTHOR("Sangtae Ha, Stephen Hemminger");=0A=
 MODULE_LICENSE("GPL");=0A=
 MODULE_DESCRIPTION("CUBIC TCP");=0A=
-MODULE_VERSION("2.2");=0A=
+MODULE_VERSION("2.3");=0A=
-- =0A=
1.5.2.2=0A=
=0A=

------=_NextPart_000_005D_01C939EB.C02B49D0--

