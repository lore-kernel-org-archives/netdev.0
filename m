From: Patrick McHardy <kaber@trash.net>
Subject: Re: Inaccuracies with SCH_CLK_CPU
Date: Sat, 07 Aug 2004 20:44:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41152301.5090405@trash.net>
References: <20040804094310.1d054b3a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000302010802040806010405"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040804094310.1d054b3a@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000302010802040806010405
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:

>I noticed that the netem delay values are off if using 
>CONFIG_NET_SCH_CKL_CPU. For example, if the latency is set to 500ms
> a ping reports the time as much less (343ms).
>
>Requested	JIFFIES	GETTIMEODAY	CPU
>0		.1	.1		.1
>1		2	2		1
>5		5	6		4
>10		10	11		7
>100		98	101		69
>500		489	500		343
>1000		976	1000		685
>
>The 1ms value is affected by the clock granularity.  Larger jiffie values
>are inaccurate due to the optimization of using shift to do divide (ie 1024 > 1000).
>
>With CLK_CPU /proc/net/psched is:
>000005d9 00000400 000f4240 000003e8
>  
>

sch_netem's interface is in us, but it doesn't convert the values to 
psched_us.
psched_us differ from us with CLK_CPU or CLK_JIFFIES for most values of HZ.
This patch fixes the problem, but the best solution is to change the 
interface
and pass the time values as psched_us from userspace, as done with 
rate-tables
and I think CBQ. I should have done this for HFSC too, but unlike for 
sch_netem,
I think it's too late to change the interface.

Regards
Patrick


--------------000302010802040806010405
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/07 20:32:26+02:00 kaber@coreworks.de 
#   [PKT_SCHED]: convert us values to psched_us in sch_netem
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_netem.c
#   2004/08/07 20:32:06+02:00 kaber@coreworks.de +23 -4
#   [PKT_SCHED]: convert us values to psched_us in sch_netem
# 
diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-08-07 20:40:30 +02:00
+++ b/net/sched/sch_netem.c	2004-08-07 20:40:30 +02:00
@@ -752,6 +752,25 @@
 	return ret;
 }
 
+static inline u_int32_t us2psched_us(u_int32_t us)
+{
+	u64 t;
+	
+	t = ((u64)us * PSCHED_JIFFIE2US(HZ));
+	t += 1000000 - 1;
+	do_div(t, 1000000);
+	return t;
+}
+
+static inline u_int32_t psched_us2us(u_int32_t psched_us)
+{
+	u64 t;
+
+	t = ((u64)psched_us * 1000000);
+	do_div(t, PSCHED_JIFFIE2US(HZ));
+	return t;
+}
+
 static int netem_change(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
@@ -778,8 +797,8 @@
 		if (child != &noop_qdisc)
 			qdisc_destroy(child);
 	
-		q->latency = qopt->latency;
-		q->jitter = qopt->jitter;
+		q->latency = us2psched_us(qopt->latency);
+		q->jitter = us2psched_us(qopt->jitter);
 		q->limit = qopt->limit;
 		q->gap = qopt->gap;
 		q->loss = qopt->loss;
@@ -821,8 +840,8 @@
 	unsigned char	 *b = skb->tail;
 	struct tc_netem_qopt qopt;
 
-	qopt.latency = q->latency;
-	qopt.jitter = q->jitter;
+	qopt.latency = psched_us2us(q->latency);
+	qopt.jitter = psched_us2us(q->jitter);
 	qopt.limit = sch->dev->tx_queue_len;
 	qopt.loss = q->loss;
 	qopt.gap = q->gap;

--------------000302010802040806010405--
