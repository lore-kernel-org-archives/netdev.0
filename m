From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: resurrecting tcphealth
Date: Fri, 13 Jul 2012 16:55:44 -0700
Message-ID: <20120713165544.6767ea8f@nehalam.linuxnetplumber.net>
References: <e9caf38359467bfa8a1e2ac86f6ef2cc.squirrel@webmail.univie.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Piotr Sawuk" <a9702387@unet.univie.ac.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e9caf38359467bfa8a1e2ac86f6ef2cc.squirrel@webmail.univie.ac.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am not sure if the is really necessary since the most
of the stats are available elsewhere.

Here are some comments on getting the simplified to match
the kernel style.

>
> static inline struct tcp_sock *tcp_sk(const struct sock *sk)
>diff -rub A/net/ipv4/tcp_input.c B/net/ipv4/tcp_input.c
>--- A/net/ipv4/tcp_input.c	2012-06-22 20:37:50.000000000 +0200
>+++ B/net/ipv4/tcp_input.c	2012-07-06 10:12:12.000000000 +0200
>@@ -4414,6 +4415,8 @@
> 		}
>
> 		if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
>+			/* Course retransmit inefficiency- this packet has been received twice. */
>+			tp->dup_pkts_recv++;

I don't understand that comment, could you use a better sentence please?

>
> 	tp->rx_opt.saw_tstamp = 0;
>
>+	/*
>+	 *	Tcp health monitoring is interested in
>+	 *	total per-connection packet arrivals.
>+	 *	This is in the fast path, but is quick.
>+	 */
>+	tp->pkts_recv++;
>+

Comment seems bigger justification than necessary for simple
operation.

>diff -rub A/net/ipv4/tcp_ipv4.c B/net/ipv4/tcp_ipv4.c
>--- A/net/ipv4/tcp_ipv4.c	2012-06-22 20:37:50.000000000 +0200
>+++ B/net/ipv4/tcp_ipv4.c	2012-07-11 09:34:22.000000000 +0200
>@@ -2533,6 +2533,82 @@
> 	return 0;
> }
>
>+
>+/*
>+ *	Output /proc/net/tcphealth
>+ */
>+#define LINESZ 128
>+
>+int tcp_health_seq_show(struct seq_file *seq, void *v)
>+{
>+	int len, num;
>+	char srcIP[32], destIP[32];
Unnecessary see below

>+
>+	unsigned long  SmoothedRttEstimate,
>+		AcksSent, DupAcksSent, PktsRecv, DupPktsRecv;

Do not use CamelCase in kernel code.

>+	struct tcp_iter_state *st;
>+
>+	if (v == SEQ_START_TOKEN) {
>+		seq_printf(seq,
>+		"TCP Health Monitoring (established connections only)\n"
>+		" -Duplicate ACKs indicate lost or reordered packets on the
>connection.\n"
>+		" -Duplicate Packets Received signal a slow and badly inefficient
>connection.\n"
>+		" -RttEst estimates how long future packets will take on a round trip
>over the connection.\n"
>+		"id   Local Address        Remote Address       RttEst(ms) AcksSent "

Header seems excessive, just put one line of header please.


>+		"DupAcksSent PktsRecv DupPktsRecv\n");
>+		goto out;
>+	}
>+
>+	/* Loop through established TCP connections */
>+	st = seq->private;
>+
>+
>+	if (st->state == TCP_SEQ_STATE_ESTABLISHED)
>+	{
>+/*	; //insert read-lock here */

Don't think you need read-lock

>+		const struct tcp_sock *tp = tcp_sk(v);
>+		const struct inet_sock *inet = inet_sk(v);
>+		__be32 dest = inet->inet_daddr;
>+		__be32 src = inet->inet_rcv_saddr;
>+		__u16 destp = ntohs(inet->inet_dport);
>+		__u16 srcp = ntohs(inet->inet_sport);
>+

These temp variables aren't redundant.

>+		num = st->num;
>+		SmoothedRttEstimate = (tp->srtt >> 3);
>+		AcksSent = tp->acks_sent;
>+		DupAcksSent = tp->dup_acks_sent;
>+		PktsRecv = tp->pkts_recv;
>+		DupPktsRecv = tp->dup_pkts_recv;
>+
>+		sprintf(srcIP, "%lu.%lu.%lu.%lu:%u",
>+			((src >> 24) & 0xFF), ((src >> 16) & 0xFF), ((src >> 8) & 0xFF), (src &
>0xFF),
>+			srcp);
>+		sprintf(destIP, "%3d.%3d.%3d.%3d:%u",
>+			((dest >> 24) & 0xFF), ((dest >> 16) & 0xFF), ((dest >> 8) & 0xFF),
>(dest & 0xFF),
>+			destp);
>+
>+		seq_printf(seq, "%d: %-21s %-21s "
>+				"%8lu %8lu %8lu %8lu %8lu%n",
>+				num,
>+				srcIP,
>+				destIP,
>+				SmoothedRttEstimate,
>+				AcksSent,
>+				DupAcksSent,
>+				PktsRecv,
>+				DupPktsRecv,
>+
>+				&len
>+			);
>+

Kernel has %pI4 to print IP addresses. 

	seq_printf(seq, "%d: %-21pI4 %-21pI4 "
			"%8lu %8lu %8lu %8lu %8lu\n",
			num,
			&inet->inet_rcv_saddr,
			&inet->inet_daddr,
			tp->srtt >> 3,
			tp->acks_sent,
			tp->dup_acks_sent,
			tp->pkts_recv,
			tp->dup_pkts_recv);
    
>+		seq_printf(seq, "%*s\n", LINESZ - 1 - len, "");

This padding of line is bogus, just print variable length line.
Are you trying to make it fixed length record file?
