From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: fix possible seqlock seadlock in
 sctp_packet_transmit()
Date: Tue, 5 Aug 2014 10:59:07 -0400
Message-ID: <20140805145907.GA20550@hmsreliant.think-freely.org>
References: <20140805134115.GA25110@redhat.com>
 <1407250192.3178.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>, Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51216 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbaHEO7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 10:59:23 -0400
Content-Disposition: inline
In-Reply-To: <1407250192.3178.86.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2014 at 04:49:52PM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Dave reported following splat, caused by improper use of
> IP_INC_STATS_BH() in process context.
> 
> BUG: using __this_cpu_add() in preemptible [00000000] code: trinity-c117/14551
> caller is __this_cpu_preempt_check+0x13/0x20
> CPU: 3 PID: 14551 Comm: trinity-c117 Not tainted 3.16.0+ #33
>  ffffffff9ec898f0 0000000047ea7e23 ffff88022d32f7f0 ffffffff9e7ee207
>  0000000000000003 ffff88022d32f818 ffffffff9e397eaa ffff88023ee70b40
>  ffff88022d32f970 ffff8801c026d580 ffff88022d32f828 ffffffff9e397ee3
> Call Trace:
>  [<ffffffff9e7ee207>] dump_stack+0x4e/0x7a
>  [<ffffffff9e397eaa>] check_preemption_disabled+0xfa/0x100
>  [<ffffffff9e397ee3>] __this_cpu_preempt_check+0x13/0x20
>  [<ffffffffc0839872>] sctp_packet_transmit+0x692/0x710 [sctp]
>  [<ffffffffc082a7f2>] sctp_outq_flush+0x2a2/0xc30 [sctp]
>  [<ffffffff9e0d985c>] ? mark_held_locks+0x7c/0xb0
>  [<ffffffff9e7f8c6d>] ? _raw_spin_unlock_irqrestore+0x5d/0x80
>  [<ffffffffc082b99a>] sctp_outq_uncork+0x1a/0x20 [sctp]
>  [<ffffffffc081e112>] sctp_cmd_interpreter.isra.23+0x1142/0x13f0 [sctp]
>  [<ffffffffc081c86b>] sctp_do_sm+0xdb/0x330 [sctp]
>  [<ffffffff9e0b8f1b>] ? preempt_count_sub+0xab/0x100
>  [<ffffffffc083b350>] ? sctp_cname+0x70/0x70 [sctp]
>  [<ffffffffc08389ca>] sctp_primitive_ASSOCIATE+0x3a/0x50 [sctp]
>  [<ffffffffc083358f>] sctp_sendmsg+0x88f/0xe30 [sctp]
>  [<ffffffff9e0d673a>] ? lock_release_holdtime.part.28+0x9a/0x160
>  [<ffffffff9e0d62ce>] ? put_lock_stats.isra.27+0xe/0x30
>  [<ffffffff9e73b624>] inet_sendmsg+0x104/0x220
>  [<ffffffff9e73b525>] ? inet_sendmsg+0x5/0x220
>  [<ffffffff9e68ac4e>] sock_sendmsg+0x9e/0xe0
>  [<ffffffff9e1c0c09>] ? might_fault+0xb9/0xc0
>  [<ffffffff9e1c0bae>] ? might_fault+0x5e/0xc0
>  [<ffffffff9e68b234>] SYSC_sendto+0x124/0x1c0
>  [<ffffffff9e0136b0>] ? syscall_trace_enter+0x250/0x330
>  [<ffffffff9e68c3ce>] SyS_sendto+0xe/0x10
>  [<ffffffff9e7f9be4>] tracesys+0xdd/0xe2
> 
> This is a followup of commits f1d8cba61c3c4b ("inet: fix possible
> seqlock deadlocks") and 7f88c6b23afbd315 ("ipv6: fix possible seqlock
> deadlock in ip6_finish_output2")
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Reported-by: Dave Jones <davej@redhat.com>
> ---
>  net/sctp/output.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 1eedba5195a3..42dffd428389 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -599,7 +599,7 @@ out:
>  	return err;
>  no_route:
>  	kfree_skb(nskb);
> -	IP_INC_STATS_BH(sock_net(asoc->base.sk), IPSTATS_MIB_OUTNOROUTES);
> +	IP_INC_STATS(sock_net(asoc->base.sk), IPSTATS_MIB_OUTNOROUTES);
>  
>  	/* FIXME: Returning the 'err' will effect all the associations
>  	 * associated with a socket, although only one of the paths of the
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
