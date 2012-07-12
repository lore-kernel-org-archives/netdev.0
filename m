From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: resurrecting tcphealth
Date: Thu, 12 Jul 2012 15:29:06 -0700
Message-ID: <4FFF4FB2.8050202@xenotime.net>
References: <dee325378a2d3b7792da9640fc14905f.squirrel@webmail.univie.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Piotr Sawuk <a9702387@unet.univie.ac.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dee325378a2d3b7792da9640fc14905f.squirrel@webmail.univie.ac.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/12/2012 01:55 PM, Piotr Sawuk wrote:

> hello! I haven't done any kernel-hacking before, so be patient.
> 
> I got as far as to make tcphealth run, but now I need some help:
> how does read-locking work in the tcp_sock struct?
> the original code (for 2.5.1) made a read_lock(&head->lock) with
> struct tcp_ehash_bucket *head = &tcp_ehash[i];
> at the beginning of the for-loop over all sk=head->chain.
> i.e.
>        for (i=0; i < tcp_ehash_size; i++) {
>                struct tcp_ehash_bucket *head = &tcp_ehash[i];
>                struct sock *sk;
>                struct tcp_opt *tp;
> 
>                read_lock(&head->lock);
>                for (sk=head->chain; sk; sk=sk->next) {
>                        if (!TCP_INET_FAMILY(sk->family))
>                                continue;
> 
> and in the new kernel this construction has been replaced by
> 
>         if (st->state==TCP_SEQ_STATE_ESTABLISHED)
> ...
> static struct tcp_seq_afinfo tcphealth_seq_afinfo
> ...
> 
> and the example with proc/net/tcp is seemingly not locking anything. do I
> actually need a read-lock for diagnostic data from tcp_sock? why did the
> original author need to lock the whole chain of tcp_sock?
> 
> here's my patch against 3.4.4 so far, any further comments welcome:


Along with what Mr. Hemminger said:

Don't make patches to a stable kernel version.  Just make them
to mainline (e.g., 3.5-rc6).

More comments below.


> 
> diff -rub linux-3.4.4/include/linux/tcp.h
> linux-3.4.4-heal-lsm/include/linux/tcp.h
> --- linux-3.4.4/include/linux/tcp.h	2012-06-22 20:37:50.000000000 +0200
> +++ linux-3.4.4-heal-lsm/include/linux/tcp.h	2012-07-06 10:23:13.000000000
> +0200



See the 2 lines above.  They should be all on one line (the +0200 is
on a separate line).  Something along the way split this long line for
you, but this is bad.  It corrupts the patch.


> @@ -472,6 +474,15 @@
>  	 * contains related tcp_cookie_transactions fields.
>  	 */
>  	struct tcp_cookie_values  *cookie_values;
> +
> +	/*
> +	 * TCP health monitoring counters.
> +	 */
> +	__u32	dup_acks_sent;
> +	__u32	dup_pkts_recv;
> +	__u32	acks_sent;
> +	__u32	pkts_recv;
> +		__u32	last_ack_sent;	/* Sequence number of the last ack we sent.


Extra tab before __u32 above.

 */
>  };
> 
>  static inline struct tcp_sock *tcp_sk(const struct sock *sk)
> diff -rub linux-3.4.4/net/ipv4/tcp_input.c
> linux-3.4.4-heal-lsm/net/ipv4/tcp_input.c
> --- linux-3.4.4/net/ipv4/tcp_input.c	2012-06-22 20:37:50.000000000 +0200
> +++ linux-3.4.4-heal-lsm/net/ipv4/tcp_input.c	2012-07-06
> 10:12:12.000000000 +0200


Bad line(s) above.

> @@ -5375,6 +5382,14 @@
> 
>  	tp->rx_opt.saw_tstamp = 0;
> 
> +	/*
> +	 *	Tcp health monitoring is interested in
> +	 *	total per-connection packet arrivals.
> +	 *	This is in the fast path, but is quick.
> +	 */
> +


The	*/
is enough white space; don't add an extra line.

> +	tp->pkts_recv++;
> +
>  	/*	pred_flags is 0xS?10 << 16 + snd_wnd
>  	 *	if header_prediction is to be made
>  	 *	'S' will always be tp->tcp_header_len >> 2
> diff -rub linux-3.4.4/net/ipv4/tcp_ipv4.c
> linux-3.4.4-heal-lsm/net/ipv4/tcp_ipv4.c
> --- linux-3.4.4/net/ipv4/tcp_ipv4.c	2012-06-22 20:37:50.000000000 +0200
> +++ linux-3.4.4-heal-lsm/net/ipv4/tcp_ipv4.c	2012-07-11 09:34:22.000000000
> +0200
> @@ -2533,6 +2533,82 @@
>  	return 0;
>  }
> 
> +
> +/*
> + *	Output /proc/net/tcphealth
> + */
> +#define LINESZ 128
> +
> +int tcp_health_seq_show(struct seq_file *seq, void *v)
> +{
> +	int len, num;
> +       char srcIP[32], destIP[32];


Use tab above for indentation (don't use spaces).

> +
> +	unsigned long  SmoothedRttEstimate,
> +		AcksSent, DupAcksSent, PktsRecv, DupPktsRecv;
> +	struct tcp_iter_state *st;
> +
> +	if (v == SEQ_START_TOKEN) {
> +		seq_printf(seq,
> +		"TCP Health Monitoring (established connections only)\n"
> +		" -Duplicate ACKs indicate lost or reordered packets on the connection.\n"
> +		" -Duplicate Packets Received signal a slow and badly inefficient
> connection.\n"
> +		" -RttEst estimates how long future packets will take on a round trip
> over the connection.\n"
> +		"id   Local Address        Remote Address       RttEst(ms) AcksSent "
> +		"DupAcksSent PktsRecv DupPktsRecv\n");
> +		goto out;
> +	}
> +
> +	/* Loop through established TCP connections */
> +	st = seq->private;
> +
> +
> +	if (st->state==TCP_SEQ_STATE_ESTABLISHED)
> +	{


Kernel style is:

	if (st->state == TCP_SEQ_STATE_ESTABLISHED) {


> +/*	; //insert read-lock here */
> +		const struct tcp_sock *tp = tcp_sk(v);
> +		const struct inet_sock *inet = inet_sk(v);
> +		__be32 dest = inet->inet_daddr;
> +		__be32 src = inet->inet_rcv_saddr;
> +		__u16 destp = ntohs(inet->inet_dport);
> +		__u16 srcp = ntohs(inet->inet_sport);
> +
> +		num=st->num;


		num = st->num;

> +		SmoothedRttEstimate = (tp->srtt >> 3);
> +		AcksSent = tp->acks_sent;
> +		DupAcksSent = tp->dup_acks_sent;
> +		PktsRecv = tp->pkts_recv;
> +		DupPktsRecv = tp->dup_pkts_recv;
> +
> +		sprintf(srcIP, "%lu.%lu.%lu.%lu:%u",
> +			((src >> 24) & 0xFF), ((src >> 16) & 0xFF), ((src >> 8) & 0xFF), (src
> & 0xFF),
> +			srcp);
> +		sprintf(destIP, "%3d.%3d.%3d.%3d:%u",
> +			((dest >> 24) & 0xFF), ((dest >> 16) & 0xFF), ((dest >> 8) & 0xFF),
> (dest & 0xFF),
> +			destp);
> +
> +		seq_printf(seq, "%d: %-21s %-21s "
> +				"%8lu %8lu %8lu %8lu %8lu%n",
> +				num,
> +				srcIP,
> +				destIP,
> +				SmoothedRttEstimate,
> +				AcksSent,
> +				DupAcksSent,
> +				PktsRecv,
> +				DupPktsRecv,
> +
> +				&len
> +			);
> +
> +		seq_printf(seq, "%*s\n", LINESZ - 1 - len, "");
> +/*	; //insert read-unlock here */
> +	}
> +
> +out:
> +	return 0;
> +}
> +
>  static const struct file_operations tcp_afinfo_seq_fops = {
>  	.owner   = THIS_MODULE,
>  	.open    = tcp_seq_open,
> @@ -2541,6 +2617,15 @@
>  	.release = seq_release_net
>  };
> 
> +static struct tcp_seq_afinfo tcphealth_seq_afinfo = {
> +	.name		= "tcphealth",
> +	.family		= AF_INET,
> +	.seq_fops	= &tcp_afinfo_seq_fops,
> +	.seq_ops	= {
> +		.show		= tcp_health_seq_show,
> +	},
> +};
> +
>  static struct tcp_seq_afinfo tcp4_seq_afinfo = {
>  	.name		= "tcp",
>  	.family		= AF_INET,
> @@ -2552,12 +2637,15 @@
> 
>  static int __net_init tcp4_proc_init_net(struct net *net)
>  {
> -	return tcp_proc_register(net, &tcp4_seq_afinfo);
> +	int ret=tcp_proc_register(net, &tcp4_seq_afinfo);


	int ret = tcp_proc_register(...);

> +	if(ret==0) ret=tcp_proc_register(net, &tcphealth_seq_afinfo);


	if (ret == 0)
		ret = tcp_proc_register(...);

> +	return ret;
>  }
> 
>  static void __net_exit tcp4_proc_exit_net(struct net *net)
>  {
>  	tcp_proc_unregister(net, &tcp4_seq_afinfo);
> +	tcp_proc_unregister(net, &tcphealth_seq_afinfo);
>  }
> 
>  static struct pernet_operations tcp4_net_ops = {
> diff -rub linux-3.4.4/net/ipv4/tcp_output.c
> linux-3.4.4-heal-lsm/net/ipv4/tcp_output.c
> --- linux-3.4.4/net/ipv4/tcp_output.c	2012-06-22 20:37:50.000000000 +0200
> +++ linux-3.4.4-heal-lsm/net/ipv4/tcp_output.c	2012-07-06
> 17:15:14.000000000 +0200


Bad split lines above.

> @@ -2754,8 +2755,15 @@
>  	skb_reserve(buff, MAX_TCP_HEADER);
>  	tcp_init_nondata_skb(buff, tcp_acceptable_seq(sk), TCPHDR_ACK);
> 
> +		/* If the rcv_nxt has not advanced since sending our last ACK, this is
> a duplicate. */
> +		if (tcp_sk(sk)->rcv_nxt == tcp_sk(sk)->last_ack_sent)
> +			tcp_sk(sk)->dup_acks_sent++;
> +		/* Record the total number of acks sent on this connection. */
> +		tcp_sk(sk)->acks_sent++;
> +
>  	/* Send it off, this clears delayed acks for us. */
>  	TCP_SKB_CB(buff)->when = tcp_time_stamp;
> +		tcp_sk(sk)->last_ack_sent = tcp_sk(sk)->rcv_nxt;


Extra tab indentation above.

>  	tcp_transmit_skb(sk, buff, 0, GFP_ATOMIC);
>  }
> 
> 
> --


-- 
~Randy
