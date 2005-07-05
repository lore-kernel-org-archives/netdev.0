From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Wed, 06 Jul 2005 01:16:02 +0200
Message-ID: <42CB14B2.5090601@cosmosbay.com>
References: <20050705173411.GK16076@postel.suug.ch>	<20050705.142210.14973612.davem@davemloft.net>	<20050705213355.GM16076@postel.suug.ch> <20050705.143548.28788459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080605050609050601090102"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, tgraf@suug.ch
In-Reply-To: <20050705.143548.28788459.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080605050609050601090102
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j65NMiH9017351

David S. Miller a =E9crit :
> From: Thomas Graf <tgraf@suug.ch>
> Date: Tue, 5 Jul 2005 23:33:55 +0200
>=20
>=20
>>* David S. Miller <20050705.142210.14973612.davem@davemloft.net> 2005-0=
7-05 14:22
>>
>>>So I'll apply the original unrolling patch for now.
>>
>>The patch must be changed to use __qdisc_dequeue_head() instead of
>>__skb_dequeue() or we screw up the backlog.
>=20
>=20
> Ok, good thing the patch didn't apply correctly anyways :)
>=20
>=20
Oh well, I was unaware of last changes in 2.6.13-rc1 :(

Given the fact that the PFIFO_FAST_BANDS macro was introduced, I wonder i=
f the patch should be this one or not...
Should we assume PFIFO_FAST_BANDS will stay at 3 or what ?

[NET] : unroll a small loop in pfifo_fast_dequeue(). Compiler generates b=
etter code.
     oprofile says this function uses now 0.29% instead of 1.22 %, on a x=
86_64 target.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------080605050609050601090102
Content-Type: text/plain;
 name="patch.sch_generic"
Content-Disposition: inline;
 filename="patch.sch_generic"
Content-Transfer-Encoding: 7bit

--- linux-2.6.13-rc1/net/sched/sch_generic.c	2005-07-06 00:46:53.000000000 +0200
+++ linux-2.6.13-rc1-ed/net/sched/sch_generic.c	2005-07-06 01:05:04.000000000 +0200
@@ -328,18 +328,31 @@
 
 static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 {
-	int prio;
 	struct sk_buff_head *list = qdisc_priv(qdisc);
 
-	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++, list++) {
-		struct sk_buff *skb = __qdisc_dequeue_head(qdisc, list);
-		if (skb) {
-			qdisc->q.qlen--;
-			return skb;
+#if PFIFO_FAST_BANDS == 3
+	for (;;) {
+		if (!skb_queue_empty(list))
+			break;
+		list++;
+		if (!skb_queue_empty(list))
+			break;
+		list++;
+		if (!skb_queue_empty(list))
+			break;
+		return NULL;
 		}
-	}
-
-	return NULL;
+#else
+	int prio;
+	for (prio = 0;; list++) {
+		if (!skb_queue_empty(list))
+			break;
+		if (++prio == PFIFO_FAST_BANDS)
+			return NULL;
+		}
+#endif
+	qdisc->q.qlen--;
+	return __qdisc_dequeue_head(qdisc, list);
 }
 
 static int pfifo_fast_requeue(struct sk_buff *skb, struct Qdisc* qdisc)

--------------080605050609050601090102--
