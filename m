From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Thu, 05 Feb 2015 04:57:18 -0800
Message-ID: <1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	 <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	 <1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	 <1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
	 <1422973660.907.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>
	 <1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
	 <1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
	 <1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423056591.907.130.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:41457 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbbBEM5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 07:57:21 -0500
In-Reply-To: <CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-05 at 09:38 +0100, Michal Kazior wrote:
> On 4 February 2015 at 22:11, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > I do not see how a TSO patch could hurt a flow not using TSO/GSO.
> >
> > This makes no sense.
> 
> Hmm..
> 
> @@ -2018,8 +2053,8 @@ static bool tcp_write_xmit(struct sock *sk,
> unsigned int mss_now, int nonagle,
>                  * of queued bytes to ensure line rate.
>                  * One example is wifi aggregation (802.11 AMPDU)
>                  */
> -               limit = max_t(unsigned int, sysctl_tcp_limit_output_bytes,
> -                             sk->sk_pacing_rate >> 10);
> +               limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
> +               limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
> 
>                 if (atomic_read(&sk->sk_wmem_alloc) > limit) {
>                         set_bit(TSQ_THROTTLED, &tp->tsq_flags);
> 
> Doesn't this effectively invert how tcp_limit_output_bytes is used?
> This would explain why raising the limit wasn't changing anything
> anymore when you asked me do so. Only decreasing it yielded any
> change.
> 
> I've added a printk to show up the new and old values. Excerpt from logs:
> 
> [  114.782740] (4608 39126 131072 = 39126) vs (131072 39126 = 131072)
> 
> (2*truesize, pacing_rate, tcp_limit = limit) vs (tcp_limit, pacing_rate = limit)
> 
> Reverting this patch hunk alone fixes my TCP problem. Not that I'm
> saying the old logic was correct (it seems it wasn't, a limit should
> be applied as min(value, max_value), right?).
> 
> Anyway the change doesn't seem to be TSO-only oriented so it would
> explain the "makes no sense".


The intention is to control the queues to the following :

1 ms of buffering, but limited to a configurable value.

On a 40Gbps flow, 1ms represents 5 MB, which is insane.

We do not want to queue 5 MB of traffic, this would destroy latencies
for all concurrent flows. (Or would require having fq_codel or fq as
packet schedulers, instead of default pfifo_fast)

This is why having 1.5 ms delay between the transmit and TX completion
is a problem in your case.

 
