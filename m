From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Panic at tcp_xmit_retransmit_queue
Date: Wed, 3 Feb 2010 13:02:39 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1002031258160.7063@wel-95.cs.helsinki.fi>
References: <53cc795f1001190813m377c6c91l16b2dc04f63049e7@mail.gmail.com> <53cc795f1002010645w54b98b51s3dbdea18e5eb73f2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: sbs <gexlie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53cc795f1002010645w54b98b51s3dbdea18e5eb73f2@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 1 Feb 2010, sbs wrote:

> actually removing netconsole from kernel didnt help.
> i found many guys with the same problem but with different hardware
> configurations here:
> 
> freez in TCP stack :
> http://bugzilla.kernel.org/show_bug.cgi?id=14470
> 
> is there someone who can investigate it?
> 
> 
> On Tue, Jan 19, 2010 at 7:13 PM, sbs <gexlie@gmail.com> wrote:
> > We are hiting kernel panics on servers with nVidia MCP55 NICs once a day;
> > it appears usualy under a high network trafic ( around 10000Mbit/s) but
> > it is not a rule, it has happened even on low trafic.
> >
> > Servers are used as nginx+static content
> > On 2 equal servers this panic happens aprox 2 times a day depending on
> > network load. Machine completly freezes till the netconsole reboots.
> >
> > Kernel: 2.6.32.3
> >
> > what can it be? whats wrong with tcp_xmit_retransmit_queue() function ?
> > can anyone explain or fix?

You might want to try with to debug patch below. It might even make the 
box to survive the event (if I got it coded right).

-- 
 i.


--
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 383ce23..f4600fb 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2186,6 +2186,42 @@ static int tcp_can_forward_retransmit(struct sock *sk)
 	return 1;
 }
 
+static void print_queue(struct sock *sk, struct sk_buff *old, struct sk_buff *hole)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb, *prev;
+
+	skb = tcp_write_queue_head(sk);
+	prev = (struct sk_buff *)(&sk->sk_write_queue);
+
+	if (skb == NULL) {
+		printk("NULL head, pkts %u\n", tp->packets_out);
+		return;
+	}
+	printk("head %p tail %p sendhead %p oldhint %p now %p hole %p high %u\n",
+	       tcp_write_queue_head(sk), tcp_write_queue_tail(sk),
+	       tcp_send_head(sk), old, tp->retransmit_skb_hint, hole,
+	       tp->retransmit_high);
+
+	while (skb) {
+		printk("skb %p (%u-%u) next %p prev %p sacked %u\n",
+		       skb, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq,
+		       skb->next, skb->prev, TCP_SKB_CB(skb)->sacked);
+		if (prev != skb->prev)
+			printk("Inconsistent prev\n");
+
+		if (skb == tcp_write_queue_tail(sk)) {
+			if (skb->next != (struct sk_buff *)(&sk->sk_write_queue))
+				printk("Improper next at tail\n");
+			return;
+		}
+
+		prev = skb;
+		skb = skb->next;
+	}
+	printk("Encountered unexpected NULL\n");
+}
+
 /* This gets called after a retransmit timeout, and the initially
  * retransmitted data is acknowledged.  It tries to continue
  * resending the rest of the retransmit queue, until either
@@ -2194,12 +2230,15 @@ static int tcp_can_forward_retransmit(struct sock *sk)
  * based retransmit packet might feed us FACK information again.
  * If so, we use it to avoid unnecessarily retransmissions.
  */
+static int caught_it = 0;
+
 void tcp_xmit_retransmit_queue(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	struct sk_buff *hole = NULL;
+	struct sk_buff *old = tp->retransmit_skb_hint;
 	u32 last_lost;
 	int mib_idx;
 	int fwd_rexmitting = 0;
@@ -2217,6 +2256,16 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		last_lost = tp->snd_una;
 	}
 
+checknull:
+	if (skb == NULL) {
+		if (!caught_it)
+			print_queue(sk, old, hole);
+		caught_it++;
+		if (net_ratelimit())
+			printk("Errors caught so far %u\n", caught_it);
+		return;
+	}
+
 	tcp_for_write_queue_from(skb, sk) {
 		__u8 sacked = TCP_SKB_CB(skb)->sacked;
 
@@ -2257,7 +2306,7 @@ begin_fwd:
 		} else if (!(sacked & TCPCB_LOST)) {
 			if (hole == NULL && !(sacked & (TCPCB_SACKED_RETRANS|TCPCB_SACKED_ACKED)))
 				hole = skb;
-			continue;
+			goto checknull;
 
 		} else {
 			last_lost = TCP_SKB_CB(skb)->end_seq;
@@ -2268,7 +2317,7 @@ begin_fwd:
 		}
 
 		if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
-			continue;
+			goto checknull;
 
 		if (tcp_retransmit_skb(sk, skb))
 			return;
@@ -2278,6 +2327,7 @@ begin_fwd:
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 						  inet_csk(sk)->icsk_rto,
 						  TCP_RTO_MAX);
+		goto checknull;
 	}
 }
 
