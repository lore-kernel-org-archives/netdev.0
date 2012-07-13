From: "Piotr Sawuk" <a9702387@unet.univie.ac.at>
Subject: Re: resurrecting tcphealth
Date: Fri, 13 Jul 2012 09:33:46 +0200
Message-ID: <e9caf38359467bfa8a1e2ac86f6ef2cc.squirrel@webmail.univie.ac.at>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Do, 12.07.2012, 23:35, Stephen Hemminger wrote:
> On Thu, 12 Jul 2012 22:55:57 +0200
> "Piotr Sawuk" <a9702387@unet.univie.ac.at> wrote:
>
>> + *		Federico D. Sacerdoti:	Added TCP health monitoring.
>
> Please don't do this.
> The kernel community no longer maintains a list of contributors
> in the comments. The history is maintained in the git commit log.
>

thanks for the proof-reading, to Randy Dunlap too. now I have tested the
patch against mainline.

so, anyone has a comment on my actual question about the need for a read-lock?

currently my patch looks like this (again comments are welcome):

diff -rub A/include/linux/tcp.h B/include/linux/tcp.h
--- A/include/linux/tcp.h	2012-06-22 20:37:50.000000000 +0200
+++ B/include/linux/tcp.h	2012-07-06 10:23:13.000000000 +0200
@@ -472,6 +474,15 @@
 	 * contains related tcp_cookie_transactions fields.
 	 */
 	struct tcp_cookie_values  *cookie_values;
+
+	/*
+	 * TCP health monitoring counters.
+	 */
+	__u32	dup_acks_sent;
+	__u32	dup_pkts_recv;
+	__u32	acks_sent;
+	__u32	pkts_recv;
+	__u32	last_ack_sent;	/* Sequence number of the last ack we sent. */
 };

 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff -rub A/net/ipv4/tcp_input.c B/net/ipv4/tcp_input.c
--- A/net/ipv4/tcp_input.c	2012-06-22 20:37:50.000000000 +0200
+++ B/net/ipv4/tcp_input.c	2012-07-06 10:12:12.000000000 +0200
@@ -4414,6 +4415,8 @@
 		}

 		if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
+			/* Course retransmit inefficiency- this packet has been received twice. */
+			tp->dup_pkts_recv++;
 			SOCK_DEBUG(sk, "ofo packet was already received\n");
 			__skb_unlink(skb, &tp->out_of_order_queue);
 			__kfree_skb(skb);
@@ -4664,6 +4667,10 @@
 		return;
 	}

+	/* A packet is a "duplicate" if it contains bytes we have already
received. */
+	if (before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt))
+		tp->dup_pkts_recv++;
+
 	if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
 		/* A retransmit, 2nd most common case.  Force an immediate ack. */
NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOST);
@@ -5375,6 +5382,13 @@

 	tp->rx_opt.saw_tstamp = 0;

+	/*
+	 *	Tcp health monitoring is interested in
+	 *	total per-connection packet arrivals.
+	 *	This is in the fast path, but is quick.
+	 */
+	tp->pkts_recv++;
+
 	/*	pred_flags is 0xS?10 << 16 + snd_wnd
 	 *	if header_prediction is to be made
 	 *	'S' will always be tp->tcp_header_len >> 2
diff -rub A/net/ipv4/tcp_ipv4.c B/net/ipv4/tcp_ipv4.c
--- A/net/ipv4/tcp_ipv4.c	2012-06-22 20:37:50.000000000 +0200
+++ B/net/ipv4/tcp_ipv4.c	2012-07-11 09:34:22.000000000 +0200
@@ -2533,6 +2533,82 @@
 	return 0;
 }

+
+/*
+ *	Output /proc/net/tcphealth
+ */
+#define LINESZ 128
+
+int tcp_health_seq_show(struct seq_file *seq, void *v)
+{
+	int len, num;
+	char srcIP[32], destIP[32];
+
+	unsigned long  SmoothedRttEstimate,
+		AcksSent, DupAcksSent, PktsRecv, DupPktsRecv;
+	struct tcp_iter_state *st;
+
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(seq,
+		"TCP Health Monitoring (established connections only)\n"
+		" -Duplicate ACKs indicate lost or reordered packets on the
connection.\n"
+		" -Duplicate Packets Received signal a slow and badly inefficient
connection.\n"
+		" -RttEst estimates how long future packets will take on a round trip
over the connection.\n"
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
+/*	; //insert read-lock here */
+		const struct tcp_sock *tp = tcp_sk(v);
+		const struct inet_sock *inet = inet_sk(v);
+		__be32 dest = inet->inet_daddr;
+		__be32 src = inet->inet_rcv_saddr;
+		__u16 destp = ntohs(inet->inet_dport);
+		__u16 srcp = ntohs(inet->inet_sport);
+
+		num = st->num;
+		SmoothedRttEstimate = (tp->srtt >> 3);
+		AcksSent = tp->acks_sent;
+		DupAcksSent = tp->dup_acks_sent;
+		PktsRecv = tp->pkts_recv;
+		DupPktsRecv = tp->dup_pkts_recv;
+
+		sprintf(srcIP, "%lu.%lu.%lu.%lu:%u",
+			((src >> 24) & 0xFF), ((src >> 16) & 0xFF), ((src >> 8) & 0xFF), (src &
0xFF),
+			srcp);
+		sprintf(destIP, "%3d.%3d.%3d.%3d:%u",
+			((dest >> 24) & 0xFF), ((dest >> 16) & 0xFF), ((dest >> 8) & 0xFF),
(dest & 0xFF),
+			destp);
+
+		seq_printf(seq, "%d: %-21s %-21s "
+				"%8lu %8lu %8lu %8lu %8lu%n",
+				num,
+				srcIP,
+				destIP,
+				SmoothedRttEstimate,
+				AcksSent,
+				DupAcksSent,
+				PktsRecv,
+				DupPktsRecv,
+
+				&len
+			);
+
+		seq_printf(seq, "%*s\n", LINESZ - 1 - len, "");
+/*	; //insert read-unlock here */
+	}
+
+out:
+	return 0;
+}
+
 static const struct file_operations tcp_afinfo_seq_fops = {
 	.owner   = THIS_MODULE,
 	.open    = tcp_seq_open,
@@ -2541,6 +2617,15 @@
 	.release = seq_release_net
 };

+static struct tcp_seq_afinfo tcphealth_seq_afinfo = {
+	.name		= "tcphealth",
+	.family		= AF_INET,
+	.seq_fops	= &tcp_afinfo_seq_fops,
+	.seq_ops	= {
+		.show		= tcp_health_seq_show,
+	},
+};
+
 static struct tcp_seq_afinfo tcp4_seq_afinfo = {
 	.name		= "tcp",
 	.family		= AF_INET,
@@ -2552,12 +2637,16 @@

 static int __net_init tcp4_proc_init_net(struct net *net)
 {
-	return tcp_proc_register(net, &tcp4_seq_afinfo);
+	int ret = tcp_proc_register(net, &tcp4_seq_afinfo);
+	if(ret == 0)
+		ret = tcp_proc_register(net, &tcphealth_seq_afinfo);
+	return ret;
 }

 static void __net_exit tcp4_proc_exit_net(struct net *net)
 {
 	tcp_proc_unregister(net, &tcp4_seq_afinfo);
+	tcp_proc_unregister(net, &tcphealth_seq_afinfo);
 }

 static struct pernet_operations tcp4_net_ops = {
diff -rub A/net/ipv4/tcp_output.c B/net/ipv4/tcp_output.c
--- A/net/ipv4/tcp_output.c	2012-06-22 20:37:50.000000000 +0200
+++ B/net/ipv4/tcp_output.c	2012-07-06 17:15:14.000000000 +0200
@@ -2754,8 +2755,15 @@
 	skb_reserve(buff, MAX_TCP_HEADER);
 	tcp_init_nondata_skb(buff, tcp_acceptable_seq(sk), TCPHDR_ACK);

+		/* If the rcv_nxt has not advanced since sending our last ACK, this is a
duplicate. */
+		if (tcp_sk(sk)->rcv_nxt == tcp_sk(sk)->last_ack_sent)
+			tcp_sk(sk)->dup_acks_sent++;
+		/* Record the total number of acks sent on this connection. */
+		tcp_sk(sk)->acks_sent++;
+
 	/* Send it off, this clears delayed acks for us. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
+	tcp_sk(sk)->last_ack_sent = tcp_sk(sk)->rcv_nxt;
 	tcp_transmit_skb(sk, buff, 0, GFP_ATOMIC);
 }
