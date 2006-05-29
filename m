From: "#ZHOU BIN#" <ZHOU0022@ntu.edu.sg>
Subject: RE: [PATCH] TCP Veno module for kernel 2.6.16.13
Date: Mon, 29 May 2006 11:26:27 +0800
Message-ID: <A975FFC51622704CBEAB749E263D1799015540BF@mail01.student.main.ntu.edu.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Fu Cheng Peng, Franklin" <ASCPFu@ntu.edu.sg>, <jmorris@namei.org>,
	<shemminger@osdl.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp2.ntu.edu.sg ([155.69.5.9]:13857 "EHLO exsmtp2.ntu.edu.sg")
	by vger.kernel.org with ESMTP id S1751110AbWE2D0a convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 May 2006 23:26:30 -0400
Content-class: urn:content-classes:message
To: "Thomas Kho" <thomaskho@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Thomas Kho [mailto:thomaskho@gmail.com]
> Sent: Monday, May 29, 2006 6:22 AM
> To: #ZHOU BIN#
> Cc: jmorris@namei.org; netdev@vger.kernel.org
> Subject: Re: [PATCH] TCP Veno module for kernel 2.6.16.13
> 
> 
> On 5/24/06, #ZHOU BIN# <ZHOU0022@ntu.edu.sg> wrote:
> > +       u16     cntRTT;         /* # of RTTs measured 
> within last RTT */
> 
> > +       /* veno->cntRTT = 0; */
> 
> It looks like this counter is never initialized

Yes, I agree. It should be done at tcp_veno_init(). I've corrected it.  Also avoid the mix caps this time, according to the suggestion from J. Morris. Following is the new patch.

Thank you all for the comments.


Sign-off-by: Bin Zhou <zhou0022@ntu.edu.sg>, Cheng Peng Fu <ascpfu@ntu.edu.sg>

diff -urN linux-2.6.16.13/net/ipv4/Kconfig linux-2.6.16.13-veno-1/net/ipv4/Kconfig
--- linux-2.6.16.13/net/ipv4/Kconfig	2006-05-03 05:38:44.000000000 +0800
+++ linux-2.6.16.13-veno-1/net/ipv4/Kconfig	2006-05-20 16:16:44.712926200 +0800
@@ -521,6 +521,18 @@
 	window. TCP Vegas should provide less packet loss, but it is
 	not as aggressive as TCP Reno.
 
+config TCP_CONG_VENO
+	tristate "TCP Veno"
+	depends on EXPERIMENTAL
+	default n
+	---help---
+	TCP Veno is a sender-side only enhancement of TCP to obtain better
+	throughput over wirless networks. TCP Veno makes use of state 
+	distinguishing to circumvent the difficult judgment of the packet loss type.
+	TCP Veno cuts down less congestion window in response to random loss
+	packets. 
+	See http://www.ntu.edu.sg/home5/ZHOU0022/papers/CPFu03a.pdf
+	
 config TCP_CONG_SCALABLE
 	tristate "Scalable TCP"
 	depends on EXPERIMENTAL
diff -urN linux-2.6.16.13/net/ipv4/Makefile linux-2.6.16.13-veno-1/net/ipv4/Makefile
--- linux-2.6.16.13/net/ipv4/Makefile	2006-05-03 05:38:44.000000000 +0800
+++ linux-2.6.16.13-veno-1/net/ipv4/Makefile	2006-05-20 15:57:45.308758200 +0800
@@ -40,6 +40,7 @@
 obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybla.o
 obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
 obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
+obj-$(CONFIG_TCP_CONG_VENO) += tcp_veno.o
 obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
diff -urN linux-2.6.16.13/net/ipv4/tcp_veno.c linux-2.6.16.13-veno-1/net/ipv4/tcp_veno.c
--- linux-2.6.16.13/net/ipv4/tcp_veno.c	1970-01-01 08:00:00.000000000 +0800
+++ linux-2.6.16.13-veno-1/net/ipv4/tcp_veno.c	2006-05-29 11:10:04.368125900 +0800
@@ -0,0 +1,253 @@
+/*
+ * TCP Veno congestion control
+ *
+ * This is based on the congestion detection/avoidance scheme described in
+ *    C. P. Fu, S. C. Liew.
+ *    "TCP Veno: TCP Enhancement for Transmission over Wireless Access Networks."
+ *    IEEE Journal on Selected Areas in Communication,
+ *    Feb. 2003.
+ * 	See http://www.ntu.edu.sg/home5/ZHOU0022/papers/CPFu03a.pdf
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/inet_diag.h>
+
+#include <net/tcp.h>
+
+/* Default values of the Veno variables, in fixed-point representation
+ * with V_PARAM_SHIFT bits to the right of the binary point.
+ */
+#define V_PARAM_SHIFT 1
+static int beta  = 3<<V_PARAM_SHIFT;
+
+
+/* Veno variables */
+struct veno {
+	u8	doing_veno_now;/* if true, do veno for this RTT */
+	u16	cntrtt;		/* # of RTTs measured */
+	u32	minrtt;		/* min of RTTs measured within last RTT (in usec) */
+	u32	basertt;	/* the min of all Veno RTT measurements seen (in usec) */
+	u32	inc;	/* decide whether to increase cwnd */
+	u32 diff;	/* calculate the diff rate */
+};
+
+/* There are several situations when we must "re-start" Veno:
+ *
+ *  o when a connection is established
+ *  o after an RTO
+ *  o after fast recovery
+ *  o when we send a packet and there is no outstanding
+ *    unacknowledged data (restarting an idle connection)
+ *
+ */
+static inline void veno_enable(struct sock *sk)
+{
+	struct veno *veno = inet_csk_ca(sk);
+
+	/* turn on Veno */
+	veno->doing_veno_now = 1;
+
+	veno->minrtt = 0x7fffffff;
+}
+
+static inline void veno_disable(struct sock *sk)
+{
+	struct veno *veno = inet_csk_ca(sk);
+
+	/* turn off Veno */
+	veno->doing_veno_now = 0;
+}
+
+static void tcp_veno_init(struct sock *sk)
+{
+	struct veno *veno = inet_csk_ca(sk);
+
+	veno->basertt = 0x7fffffff;
+	veno->inc = 1;
+	veno->cntrtt = 0;
+	veno_enable(sk);
+}
+
+/* Do RTT sampling needed for Veno. */
+static void tcp_veno_rtt_calc(struct sock *sk, u32 usrtt)
+{
+	struct veno *veno = inet_csk_ca(sk);
+	u32 vrtt = usrtt + 1; /* Never allow zero rtt or baseRTT */
+
+	/* Filter to find propagation delay: */
+	if (vrtt < veno->basertt)
+		veno->basertt = vrtt;
+
+	/* Find the min RTT during the last RTT to find
+	 * the current prop. delay + queuing delay:
+	 */
+	veno->minrtt = min(veno->minrtt, vrtt);
+	veno->cntrtt++;
+}
+
+static void tcp_veno_state(struct sock *sk, u8 ca_state)
+{
+
+	if (ca_state == TCP_CA_Open)
+		veno_enable(sk);
+	else
+		veno_disable(sk);
+}
+
+/*
+ * If the connection is idle and we are restarting,
+ * then we don't want to do any Veno calculations
+ * until we get fresh RTT samples.  So when we
+ * restart, we reset our Veno state to a clean
+ * state. After we get acks for this flight of
+ * packets, _then_ we can make Veno calculations
+ * again.
+ */
+static void tcp_veno_cwnd_event(struct sock *sk, enum tcp_ca_event event)
+{
+	if (event == CA_EVENT_CWND_RESTART ||
+	    event == CA_EVENT_TX_START)
+		tcp_veno_init(sk);
+}
+
+static void tcp_veno_cong_avoid(struct sock *sk, u32 ack,
+				 u32 seq_rtt, u32 in_flight, int flag)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct veno *veno = inet_csk_ca(sk); 
+
+	if (!veno->doing_veno_now)
+		return tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag); 
+
+	/* limited by applications */
+	if (!tcp_is_cwnd_limited(sk, in_flight))
+		return;
+
+	/* We do the Veno calculations only if we got enough RTT samples */
+	if (veno->cntrtt <= 2) {
+		/* We don't have enough RTT samples to do the Veno
+		 * calculation, so we'll behave like Reno.
+		 */ 
+		tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag);
+	} else {
+		u32 rtt, target_cwnd;
+
+		/* We have enough RTT samples, so, using the Veno
+		 * algorithm, we determine the state of the network.
+		 */
+
+		rtt = veno->minrtt;
+
+		target_cwnd = ((tp->snd_cwnd * veno->basertt)
+			       << V_PARAM_SHIFT) / rtt;
+		
+		veno->diff = (tp->snd_cwnd << V_PARAM_SHIFT) - target_cwnd;
+		
+		if (tp->snd_cwnd <= tp->snd_ssthresh) {
+			/* Slow start.  */ 
+			tcp_slow_start(tp);
+		} 
+		else if (sysctl_tcp_abc) {
+ 			/* RFC3465: Apppriate Byte Count
+ 	 		* increase once for each full cwnd acked.
+ 	 		* Veno has no idear about it so far, so we keep
+ 	 		* it as Reno.
+ 	 		*/
+ 			if (tp->bytes_acked >= tp->snd_cwnd*tp->mss_cache) {
+ 				tp->bytes_acked -= tp->snd_cwnd*tp->mss_cache;
+ 				if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+ 					tp->snd_cwnd++;
+ 			}
+ 		}else {
+			/* Congestion avoidance. */ 
+			if (veno->diff < beta) {
+				/* In the "non-congestive state", increase cwnd
+				 *  every rtt.
+				 */ 
+				if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+ 					if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+ 						tp->snd_cwnd++;
+ 					tp->snd_cwnd_cnt = 0;
+ 				} else
+ 					tp->snd_cwnd_cnt++;
+			} else {
+				/* In the "congestive state", increase cwnd
+				 * every other rtt.
+				 */ 
+					if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+ 						if (veno->inc && tp->snd_cwnd < tp->snd_cwnd_clamp) {
+ 						tp->snd_cwnd++;
+						veno->inc = 0;
+			}
+					else
+						veno->inc = 1;
+ 						tp->snd_cwnd_cnt = 0;
+ 					} else
+ 						tp->snd_cwnd_cnt++;
+			}
+			
+		}
+		if (tp->snd_cwnd < 2)
+			tp->snd_cwnd = 2;
+		else if (tp->snd_cwnd > tp->snd_cwnd_clamp)
+			tp->snd_cwnd = tp->snd_cwnd_clamp;
+	}
+		/* Wipe the state clean for the next RTT. */
+	veno->minrtt = 0x7fffffff;
+	}
+
+/* Veno MD phase */
+u32 tcp_veno_ssthresh(struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	struct veno *veno = inet_csk_ca(sk); 
+	if(veno->diff < beta) {
+		/* in "non-congestive state", cut cwnd by 1/5 */ 
+		return max(tp->snd_cwnd*4/5, 2U);
+	}else {
+		/* in "congestive state", cut cwnd by 1/2 */ 
+		return max(tp->snd_cwnd >> 1U, 2U);
+	}
+}
+
+u32 tcp_veno_min_cwnd(struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk); 
+	return tp->snd_ssthresh;
+}
+
+
+static struct tcp_congestion_ops tcp_veno = {
+	.init		= tcp_veno_init,
+	.ssthresh	= tcp_veno_ssthresh,
+	.cong_avoid	= tcp_veno_cong_avoid,
+	.min_cwnd	= tcp_veno_min_cwnd,
+	.rtt_sample	= tcp_veno_rtt_calc,
+	.set_state	= tcp_veno_state, 
+	.cwnd_event	= tcp_veno_cwnd_event,
+
+	.owner		= THIS_MODULE,
+	.name		= "veno",
+};
+
+static int __init tcp_veno_register(void)
+{
+	BUG_ON(sizeof(struct veno) > ICSK_CA_PRIV_SIZE);
+	tcp_register_congestion_control(&tcp_veno);
+	return 0;
+}
+
+static void __exit tcp_veno_unregister(void)
+{
+	tcp_unregister_congestion_control(&tcp_veno);
+}
+
+module_init(tcp_veno_register);
+module_exit(tcp_veno_unregister);
+
+MODULE_AUTHOR("Bin Zhou, Cheng Peng Fu");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("TCP Veno");
