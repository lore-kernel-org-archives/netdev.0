From: Per Hurtig <per.hurtig@kau.se>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Fri, 21 Feb 2014 11:48:58 +0100
Message-ID: <0D363ECE-F568-4558-AC8A-724EE9DB6468@kau.se>
References: <20140218181205.GA7780@kau.se> <20140219132001.12a9cf65.billfink@mindspring.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	=?iso-8859-1?Q?Anna_Brunstr=F6m?= <anna.brunstrom@kau.se>,
	Andreas Petlund <apetlund@simula.no>,
	Michael Welzl <michawe@ifi.uio.no>,
	=?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.38]:58984 "EHLO tiger.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753958AbaBUK7j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 05:59:39 -0500
In-Reply-To: <20140219132001.12a9cf65.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 19 Feb 2014, at 19:20, Bill Fink <billfink@mindspring.com> wrote:

> On Tue, 18 Feb 2014, Per Hurtig wrote:
> 
>> This patch implements the RTO restart modification described in
>> http://tools.ietf.org/html/draft-ietf-tcpm-rtorestart-02
>> 
>> RTO Restart's goal is to provide quicker loss recovery for segments lost in the
>> end of a burst/connection. To accomplish this the algorithm adjusts the RTO
>> value on each rearm of the retransmission timer to be exactly RTO ms after the
>> earliest outstanding segment was sent. The offsetting against the earliest
>> outstanding segment is not done by the regular rearm algorithm, which causes
>> RTOs to occur, on average, after RTO+RTT ms.
>> 
>> As a faster timeout is only beneficial in scenarios where fast retransmit/early
>> retransmit cannot be triggered the algorithm will only kick in when there is a
>> small amount of outstanding segments.
>> 
>> The RTO Restart proposal is accepted as a working group item in the IETF TCP
>> Maintenance and Minor Extensions (tcpm) TCP wg and is intended for experimental
>> RFC status.
>> 
>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>> ---
>> include/net/tcp.h          |    1 +
>> net/ipv4/sysctl_net_ipv4.c |    7 +++++++
>> net/ipv4/tcp_input.c       |   11 +++++++++++
>> 3 files changed, 19 insertions(+)
> 
> This should also have a documentation update to ip-sysctl.txt.
> A separate patch for the TCP(7) man page would also be useful
> if the kernel patch is approved.
> 
> 					-Bill
> 

Thanks for pointing that out, we completely forgot it!


Best Regards,
Per Hurtig
> 
> 
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index 56fc366..575e82a 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -278,6 +278,7 @@ extern int sysctl_tcp_slow_start_after_idle;
>> extern int sysctl_tcp_thin_linear_timeouts;
>> extern int sysctl_tcp_thin_dupack;
>> extern int sysctl_tcp_early_retrans;
>> +extern int sysctl_tcp_rto_restart;
>> extern int sysctl_tcp_limit_output_bytes;
>> extern int sysctl_tcp_challenge_ack_limit;
>> extern unsigned int sysctl_tcp_notsent_lowat;
>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
>> index 44eba05..c605f4f 100644
>> --- a/net/ipv4/sysctl_net_ipv4.c
>> +++ b/net/ipv4/sysctl_net_ipv4.c
>> @@ -717,6 +717,13 @@ static struct ctl_table ipv4_table[] = {
>> 		.extra2		= &four,
>> 	},
>> 	{
>> +		.procname	= "tcp_rto_restart",
>> +		.data		= &sysctl_tcp_rto_restart,
>> +		.maxlen		= sizeof(int),
>> +		.mode		= 0644,
>> +		.proc_handler	= proc_dointvec,
>> +	},
>> +	{
>> 		.procname	= "tcp_min_tso_segs",
>> 		.data		= &sysctl_tcp_min_tso_segs,
>> 		.maxlen		= sizeof(int),
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 227cba7..450ee30 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -98,6 +98,7 @@ int sysctl_tcp_thin_dupack __read_mostly;
>> 
>> int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
>> int sysctl_tcp_early_retrans __read_mostly = 3;
>> +int sysctl_tcp_rto_restart __read_mostly = 1;
>> 
>> #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
>> #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
>> @@ -2972,6 +2973,16 @@ void tcp_rearm_rto(struct sock *sk)
>> 			 */
>> 			if (delta > 0)
>> 				rto = delta;
>> +		} else if (icsk->icsk_pending == ICSK_TIME_RETRANS &&
>> +			   sysctl_tcp_rto_restart &&
>> +			   sk->sk_send_head == NULL &&
>> +			   tp->packets_out < 4) {
>> +			struct sk_buff *skb = tcp_write_queue_head(sk);
>> +			const u32 rto_time_stamp = TCP_SKB_CB(skb)->when;
>> +			s32 delta = (s32)(tcp_time_stamp - rto_time_stamp);
>> +
>> +			if (delta > 0)
>> +				rto -= delta;
>> 		}
>> 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, rto,
>> 					  TCP_RTO_MAX);
>> -- 
>> 1.7.9.5
