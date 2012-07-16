From: "Piotr Sawuk" <a9702387@unet.univie.ac.at>
Subject: Re: resurrecting tcphealth
Date: Mon, 16 Jul 2012 17:12:26 +0200
Message-ID: <436a23ea8f8df4e8e3c71c369f1e3649.squirrel@webmail.univie.ac.at>
References: <cc6495b92f1df180c1ad43057ceb0b98.squirrel@webmail.univie.ac.at>
    <1342445557.2523.8.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from grace.univie.ac.at ([131.130.3.115]:48847 "EHLO
	grace.univie.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab2GPPM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 11:12:29 -0400
In-Reply-To: <1342445557.2523.8.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 16.07.2012, 15:32, Ben Hutchings wrote:
> On Sat, 2012-07-14 at 09:56 +0200, Piotr Sawuk wrote:
>> On Sa, 14.07.2012, 03:31, valdis.kletnieks@vt.edu wrote:
>> > On Fri, 13 Jul 2012 16:55:44 -0700, Stephen Hemminger said:
>> >
>> >> >+			/* Course retransmit inefficiency- this packet has been received
>> >> twice. */
>> >> >+			tp->dup_pkts_recv++;
>> >> I don't understand that comment, could you use a better sentence
>> please?
>> >
>> > I think what was intended was:
>> >
>> > /* Curse you, retransmit inefficiency! This packet has been received at
>> least twice */
>> >
>>
>> LOL, no. I think "course retransmit" is short for "course-grained timeout
>> caused retransmit" but I can't be sure since I'm not the author of these
>> lines. I'll replace that comment with the non-shorthand version though.
>> however, I think the real comment here should be:
> [...]
>
> The word you are looking for is 'coarse' not 'course' (they are
> generally pronounced the same, to confuse you).

that was my first thought too.
but then I noticed the word "course" in the kernel's comments.
judging by context it describes the events of a round-trip.
so I guess Course-Grained means RTT-grained.
especially since this misspelling was consistent in the author's paper.

anyway, new patch, made some mistakes in my previous version.
also I added the jiffies_to_msecs noone dared to mention
comments and suggestions as always welcome:

diff -rub A/include/linux/tcp.h B/include/linux/tcp.h
--- A/include/linux/tcp.h	2012-07-08 02:23:56.000000000 +0200
+++ B/include/linux/tcp.h	2012-07-16 16:42:08.000000000 +0200
@@ -492,6 +492,17 @@
 	 * contains related tcp_cookie_transactions fields.
 	 */
 	struct tcp_cookie_values  *cookie_values;
+
+#ifdef CONFIG_TCPHEALTH
+	/*
+	 * TCP health monitoring counters.
+	 */
+	__u32	dup_acks_sent;
+	__u32	dup_pkts_recv;
+	__u32	acks_sent;
+	__u32	pkts_recv;
+	__u32	last_ack_sent;	/* Sequence number of the last ack we sent. */
+#endif
 };

 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff -rub A/net/ipv4/Kconfig B/net/ipv4/Kconfig
--- A/net/ipv4/Kconfig	2012-07-08 02:23:56.000000000 +0200
+++ B/net/ipv4/Kconfig	2012-07-16 11:56:15.000000000 +0200
@@ -619,6 +619,28 @@
 	default "reno" if DEFAULT_RENO
 	default "cubic"

+config TCPHEALTH
+	bool "TCP client-side health-statistics (/proc/net/tcphealth)"
+	default n
+	---help---
+	TCP Health Monitoring (established connections only):
+	 -Duplicate ACKs indicate there could be lost or reordered packets
+	  on the connection.
+	 -Duplicate Packets Received signal a slow and badly inefficient
+	  connection.
+	 -RttEst estimates how long future packets will take on a round trip
+	  over the connection.
+
+	Additionally you get total amount of sent ACKs and received Packets.
+	All these values are displayed seperately for each connection.
+	If you are running a dedicated server you wont need this.
+	Duplicate ACKs refers only to those sent upon receiving a Packet.
+	A server most likely doesn't receive much Packets to count.
+	Hence for a server these statistics wont be meaningful.
+	especially since they are split into individual connections.
+
+	If you plan to investigate why some download is slow, say Y.
+
 config TCP_MD5SIG
 	bool "TCP: MD5 Signature Option support (RFC2385) (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
diff -rub A/net/ipv4/tcp_input.c B/net/ipv4/tcp_input.c
--- A/net/ipv4/tcp_input.c	2012-07-08 02:23:56.000000000 +0200
+++ B/net/ipv4/tcp_input.c	2012-07-16 16:45:17.000000000 +0200
@@ -4492,6 +4492,11 @@
 		}

 		if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
+#ifdef CONFIG_TCPHEALTH
+			/* Course-Grained Timeout caused retransmit inefficiency-
+			 * this packet has been received twice. */
+			tp->dup_pkts_recv++;
+#endif
 			SOCK_DEBUG(sk, "ofo packet was already received\n");
 			__skb_unlink(skb, &tp->out_of_order_queue);
 			__kfree_skb(skb);
@@ -4824,6 +4829,12 @@
 		return;
 	}

+#ifdef CONFIG_TCPHEALTH
+	/* A packet is a "duplicate" if it contains bytes we have already
received. */
+	if (before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt))
+		tp->dup_pkts_recv++;
+#endif
+
 	if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
 		/* A retransmit, 2nd most common case.  Force an immediate ack. */
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOST);
@@ -5535,6 +5546,12 @@

 	tp->rx_opt.saw_tstamp = 0;

+#ifdef CONFIG_TCPHEALTH
+	/*
+	 *	total per-connection packet arrivals.
+	 */
+	tp->pkts_recv++;
+#endif
 	/*	pred_flags is 0xS?10 << 16 + snd_wnd
 	 *	if header_prediction is to be made
 	 *	'S' will always be tp->tcp_header_len >> 2
diff -rub A/net/ipv4/tcp_ipv4.c B/net/ipv4/tcp_ipv4.c
--- A/net/ipv4/tcp_ipv4.c	2012-07-08 02:23:56.000000000 +0200
+++ B/net/ipv4/tcp_ipv4.c	2012-07-16 16:29:05.000000000 +0200
@@ -2500,6 +2500,57 @@
 	return 0;
 }

+#ifdef CONFIG_TCPHEALTH
+/*
+ *	Output /proc/net/tcphealth
+ */
+#define LINESZ 128
+
+int tcp_health_seq_show(struct seq_file *seq, void *v)
+{
+	int len;
+	struct tcp_iter_state *st;
+
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(seq,
+		"id   Local Address        Remote Address       RttEst(ms) AcksSent "
+		"DupAcksSent PktsRecv DupPktsRecv\n");
+		goto out;
+	}
+
+	/* Loop through established TCP connections */
+	st = seq->private;
+
+
+	if (st->state == TCP_SEQ_STATE_ESTABLISHED)
+	{
+		const struct tcp_sock *tp = tcp_sk(v);
+		const struct inet_sock *inet = inet_sk(v);
+
+		seq_printf(seq, "%d: %-21pI4:%u %-21pI4:%u "
+				"%8u %8lu %8lu %8lu %8lu%n",
+				st->num,
+				&inet->inet_rcv_saddr,
+				ntohs(inet->inet_sport),
+				&inet->inet_daddr,
+				ntohs(inet->inet_dport),
+				jiffies_to_msecs(tp->srtt),
+				tp->acks_sent,
+				tp->dup_acks_sent,
+				tp->pkts_recv,
+				tp->dup_pkts_recv,
+
+				&len
+			);
+
+		seq_printf(seq, "%*s\n", LINESZ - 1 - len, "");
+	}
+
+out:
+	return 0;
+}
+#endif /* CONFIG_TCPHEALTH */
+
 static const struct file_operations tcp_afinfo_seq_fops = {
 	.owner   = THIS_MODULE,
 	.open    = tcp_seq_open,
@@ -2508,6 +2559,17 @@
 	.release = seq_release_net
 };

+#ifdef CONFIG_TCPHEALTH
+static struct tcp_seq_afinfo tcphealth_seq_afinfo = {
+	.name		= "tcphealth",
+	.family		= AF_INET,
+	.seq_fops	= &tcp_afinfo_seq_fops,
+	.seq_ops	= {
+		.show		= tcp_health_seq_show,
+	},
+};
+#endif
+
 static struct tcp_seq_afinfo tcp4_seq_afinfo = {
 	.name		= "tcp",
 	.family		= AF_INET,
@@ -2519,12 +2581,20 @@

 static int __net_init tcp4_proc_init_net(struct net *net)
 {
-	return tcp_proc_register(net, &tcp4_seq_afinfo);
+	int ret = tcp_proc_register(net, &tcp4_seq_afinfo);
+#ifdef CONFIG_TCPHEALTH
+	if(ret == 0)
+		ret = tcp_proc_register(net, &tcphealth_seq_afinfo);
+#endif
+	return ret;
 }

 static void __net_exit tcp4_proc_exit_net(struct net *net)
 {
 	tcp_proc_unregister(net, &tcp4_seq_afinfo);
+#ifdef CONFIG_TCPHEALTH
+	tcp_proc_unregister(net, &tcphealth_seq_afinfo);
+#endif
 }

 static struct pernet_operations tcp4_net_ops = {
diff -rub A/net/ipv4/tcp_output.c B/net/ipv4/tcp_output.c
--- A/net/ipv4/tcp_output.c	2012-07-08 02:23:56.000000000 +0200
+++ B/net/ipv4/tcp_output.c	2012-07-16 09:44:02.000000000 +0200
@@ -2772,8 +2772,19 @@
 	skb_reserve(buff, MAX_TCP_HEADER);
 	tcp_init_nondata_skb(buff, tcp_acceptable_seq(sk), TCPHDR_ACK);

+#ifdef CONFIG_TCPHEALTH
+	/* If the rcv_nxt has not advanced since sending our last ACK, this is a
duplicate. */
+	if (tcp_sk(sk)->rcv_nxt == tcp_sk(sk)->last_ack_sent)
+		tcp_sk(sk)->dup_acks_sent++;
+	/* Record the total number of acks sent on this connection. */
+	tcp_sk(sk)->acks_sent++;
+#endif
+
 	/* Send it off, this clears delayed acks for us. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
+#ifdef CONFIG_TCPHEALTH
+	tcp_sk(sk)->last_ack_sent = tcp_sk(sk)->rcv_nxt;
+#endif
 	tcp_transmit_skb(sk, buff, 0, GFP_ATOMIC);
 }
