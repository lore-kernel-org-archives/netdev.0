From: Tejun Heo <tj@kernel.org>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Mon, 19 Jul 2010 16:57:36 +0200
Message-ID: <4C4467E0.9080907@kernel.org>
References: <4C358AAA.9080400@kernel.org> <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi> <4C3EF7EA.2040900@nets.rwth-aachen.de> <1279195528.2496.2.camel@edumazet-laptop> <4C3F053F.7090704@nets.rwth-aachen.de> <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 07/16/2010 02:02 PM, Ilpo J=E4rvinen wrote:
> Besides, Tejun has also found that it's hint->next ptr which is NULL =
in=20
> his case so this won't solve his case anyway. Tejun, can you confirm=20
> whether it was retransmit_skb_hint->next being NULL on _entry time_ t=
o=20
> tcp_xmit_retransmit_queue() or later on in the loop after the updates=
 done=20
> by the loop itself to the hint (or that your testing didn't conclude=20
> either)?

Sorry about the delay.  I was traveling last week.  Unfortunately, I
don't know whether ->next was NULL on entry or not.  I hacked up the
following ugly patch for the next test run.  It should have everything
which has come up till now + list and hint sanity checking before
starting processing them.  I'm planning on deploying it w/ crashdump
enabled in several days.  If I've missed something, please let me
know.

Thanks.

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b4ed957..1c8b1e0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2190,6 +2190,53 @@ static int tcp_can_forward_retransmit(struct soc=
k *sk)
 	return 1;
 }

+static void print_queue(struct sock *sk, struct sk_buff *old, struct s=
k_buff *hole)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *skb, *prev;
+	bool do_panic =3D false;
+
+	skb =3D tcp_write_queue_head(sk);
+	prev =3D (struct sk_buff *)(&sk->sk_write_queue);
+
+	if (skb =3D=3D NULL) {
+		printk("XXX NULL head, pkts %u\n", tp->packets_out);
+		do_panic =3D true;
+	}
+
+	printk("XXX head %p tail %p sendhead %p oldhint %p now %p hole %p hig=
h %u\n",
+	       tcp_write_queue_head(sk), tcp_write_queue_tail(sk),
+	       tcp_send_head(sk), old, tp->retransmit_skb_hint, hole,
+	       tp->retransmit_high);
+
+	while (skb) {
+		printk("XXX skb %p (%u-%u) next %p prev %p sacked %u\n",
+		       skb, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq,
+		       skb->next, skb->prev, TCP_SKB_CB(skb)->sacked);
+		if (prev !=3D skb->prev) {
+			printk("XXX Inconsistent prev\n");
+			do_panic =3D true;
+		}
+
+		if (skb =3D=3D tcp_write_queue_tail(sk)) {
+			if (skb->next !=3D (struct sk_buff *)(&sk->sk_write_queue)) {
+				printk("XXX Improper next at tail\n");
+				do_panic =3D true;
+			}
+			break;
+		}
+
+		prev =3D skb;
+		skb =3D skb->next;
+	}
+	if (!skb) {
+		printk("XXX Encountered unexpected NULL\n");
+		do_panic =3D true;
+	}
+	if (do_panic)
+		panic("XXX panicking");
+}
+
 /* This gets called after a retransmit timeout, and the initially
  * retransmitted data is acknowledged.  It tries to continue
  * resending the rest of the retransmit queue, until either
@@ -2198,19 +2245,53 @@ static int tcp_can_forward_retransmit(struct so=
ck *sk)
  * based retransmit packet might feed us FACK information again.
  * If so, we use it to avoid unnecessarily retransmissions.
  */
+static unsigned int caught_it;
+
 void tcp_xmit_retransmit_queue(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
-	struct sk_buff *skb;
+	struct sk_buff *skb, *prev;
 	struct sk_buff *hole =3D NULL;
+	struct sk_buff *old =3D tp->retransmit_skb_hint;
 	u32 last_lost;
 	int mib_idx;
 	int fwd_rexmitting =3D 0;
+	bool saw_hint =3D false;
+
+	if (!tp->packets_out) {
+		if (net_ratelimit())
+			printk("XXX !tp->packets_out, retransmit_skb_hint=3D%p, write_queue=
_head=3D%p\n",
+			       tp->retransmit_skb_hint, tcp_write_queue_head(sk));
+		return;
+	}

 	if (!tp->lost_out)
 		tp->retransmit_high =3D tp->snd_una;

+	for (skb =3D tcp_write_queue_head(sk),
+	     prev =3D (struct sk_buff *)&sk->sk_write_queue;
+	     skb !=3D (struct sk_buff *)&sk->sk_write_queue;
+	     prev =3D skb, skb =3D skb->next) {
+		if (prev !=3D skb->prev) {
+			printk("XXX sanity check: prev corrupt\n");
+			print_queue(sk, old, hole);
+		}
+		if (skb =3D=3D tp->retransmit_skb_hint)
+			saw_hint =3D true;
+		if (skb =3D=3D tcp_write_queue_tail(sk) &&
+		    skb->next !=3D (struct sk_buff *)(&sk->sk_write_queue)) {
+			printk("XXX sanity check: end corrupt\n");
+			print_queue(sk, old, hole);
+		}
+	}
+	if (tp->retransmit_skb_hint && !saw_hint) {
+		printk("XXX sanity check: retransmit_skb_hint=3D%p is not on list, c=
laring hint\n",
+		       tp->retransmit_skb_hint);
+		print_queue(sk, old, hole);
+		tp->retransmit_skb_hint =3D NULL;
+	}
+
 	if (tp->retransmit_skb_hint) {
 		skb =3D tp->retransmit_skb_hint;
 		last_lost =3D TCP_SKB_CB(skb)->end_seq;
@@ -2218,7 +2299,17 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 			last_lost =3D tp->retransmit_high;
 	} else {
 		skb =3D tcp_write_queue_head(sk);
-		last_lost =3D tp->snd_una;
+		if (skb)
+			last_lost =3D tp->snd_una;
+	}
+
+checknull:
+	if (skb =3D=3D NULL) {
+		print_queue(sk, old, hole);
+		caught_it++;
+		if (net_ratelimit())
+			printk("XXX Errors caught so far %u\n", caught_it);
+		return;
 	}

 	tcp_for_write_queue_from(skb, sk) {
@@ -2261,7 +2352,7 @@ begin_fwd:
 		} else if (!(sacked & TCPCB_LOST)) {
 			if (hole =3D=3D NULL && !(sacked & (TCPCB_SACKED_RETRANS|TCPCB_SACK=
ED_ACKED)))
 				hole =3D skb;
-			continue;
+			goto cont;

 		} else {
 			last_lost =3D TCP_SKB_CB(skb)->end_seq;
@@ -2272,7 +2363,7 @@ begin_fwd:
 		}

 		if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
-			continue;
+			goto cont;

 		if (tcp_retransmit_skb(sk, skb))
 			return;
@@ -2282,6 +2373,9 @@ begin_fwd:
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 						  inet_csk(sk)->icsk_rto,
 						  TCP_RTO_MAX);
+cont:
+		skb =3D skb->next;
+		goto checknull;
 	}
 }

--=20
tejun
