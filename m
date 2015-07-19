From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] inet: Always increment refcount in
 inet_twsk_schedule
Date: Sun, 19 Jul 2015 10:51:12 +0200
Message-ID: <1437295872.1026.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <d6222bf87f44ca3adf3988202bd31a3c.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34200 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbGSIvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2015 04:51:16 -0400
Received: by wibud3 with SMTP id ud3so66593387wib.1
        for <netdev@vger.kernel.org>; Sun, 19 Jul 2015 01:51:14 -0700 (PDT)
In-Reply-To: <d6222bf87f44ca3adf3988202bd31a3c.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-07-19 at 03:31 +0000, subashab@codeaurora.org wrote:
> I am seeing an issue with the reference count of time wait sockets which
> leads to freeing of active timer object. This occurs in some data stress
> test setups, so I am unable to determine the exact step when it occured.
> However, I logged the refcount and was able to find out the code path
> which leads to this problem.
> 
> //Initialize time wait socket and setup timer
> inet_twsk_alloc() tw_refcnt = 0
> __inet_twsk_hashdance() tw_refcnt = 3
> inet_twsk_schedule() tw_refcnt = 4
> inet_twsk_put() tw_refcnt = 3
> 
> //Receive packet 1 in timewait state
> tcp_timewait_state_process() -> inet_twsk_schedule tw_refcnt = 3 (no change)

This is obviously wrong.

If a timewait socket is found, do we increment its refcnt before
proceeding.

> TCP: tcp_v4_timewait_ack() -> inet_twsk_put() tw_refcnt = 2
> 
> //Receive packet 2 in timewait state
> tcp_timewait_state_process() -> inet_twsk_schedule tw_refcnt = 2 (no change)
> TCP: tcp_v4_timewait_ack() -> inet_twsk_put() tw_refcnt = 1
> 
> //Receive packet 3 in timewait state
> tcp_timewait_state_process() -> inet_twsk_schedule tw_refcnt = 1 (no change)
> TCP: tcp_v4_timewait_ack() -> inet_twsk_put() tw_refcnt = 0
> 
> After this step, the time wait socket is destroyed along with the active
> timer object. This leads to a warning being printed which eventually leads
> to a crash.
> 
> ODEBUG: free active (active state 0) object type: timer_list hint:
> tw_timer_handler+0x0/0x68
> 
> It appears that inet_twsk_schedule needs to increment the reference count
> unconditionally, otherwise the socket will be destroyed since reference
> count will be decremented each time an ack is sent out as a response for
> an incoming packet.
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> ---
>  net/ipv4/inet_timewait_sock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
> index cbeb022..99c349a 100644
> --- a/net/ipv4/inet_timewait_sock.c
> +++ b/net/ipv4/inet_timewait_sock.c
> @@ -246,9 +246,9 @@ void inet_twsk_schedule(struct inet_timewait_sock *tw,
> const int timeo)
> 
>  	tw->tw_kill = timeo <= 4*HZ;
>  	if (!mod_timer_pinned(&tw->tw_timer, jiffies + timeo)) {
> -		atomic_inc(&tw->tw_refcnt);
>  		atomic_inc(&tw->tw_dr->tw_count);
>  	}
> +	atomic_inc(&tw->tw_refcnt);
>  }
>  EXPORT_SYMBOL_GPL(inet_twsk_schedule);


This is wrong. You simply add a memory leak here. It might solve your
crash, but is not the proper way.

I've received some private mails about tw issues, that turned to be
caused by buggy drivers or buggy arch specific code.

Are you crashed observed on x86 ?
