From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: fix TCP roundtrip time update code
Date: 03 Jun 2003 19:41:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1054662070.701.6.camel@tux.rsn.bth.se>
References: <200306031552.h53FqknC023999@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
   linux-ia64@linuxia64.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davidm@hpl.hp.com
In-Reply-To: <200306031552.h53FqknC023999@napali.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(trimmed CC line and added netdev)

On Tue, 2003-06-03 at 17:52, David Mosberger wrote:
> One of those very-hard-to-track-down, trivial-to-fix kind of problems:
> without this patch, TCP roundtrip time measurements will corrupt the
> routing cache's RTT estimates under heavy network load (the bug causes
> RTAX_RTT to go negative, but since its type is u32, you end up with a
> huge positive value...).  From there on, later TCP connections quickly
> will go south.
> 
> The typo was introduced 8 months ago in v1.29 of the file by the patch
> entitled "Cleanup DST metrics and abstrct MSS/PMTU further".

I tested this patch and it looks like it has cured my mysterious TCP
stalls.

without patch:

    cache  mtu 1500 rtt 479411ms rttvar 953813ms cwnd 46 advmss 1460

I see that before and during the stall if not using this patch.
(rtt is never above 20ms accoring to ping)

With the patch I see normal rtt and rttvar times.
Havn't seen a stall yet (~30 kernelcompiles with distcc over a sometimes
congested link), will continue testing.

> ===== net/ipv4/tcp_input.c 1.36 vs edited =====
> --- 1.36/net/ipv4/tcp_input.c	Mon Apr 28 09:27:57 2003
> +++ edited/net/ipv4/tcp_input.c	Tue Jun  3 08:19:36 2003
> @@ -556,8 +556,8 @@
>  			if (m >= dst_metric(dst, RTAX_RTTVAR))
>  				dst->metrics[RTAX_RTTVAR-1] = m;
>  			else
> -				dst->metrics[RTAX_RTT-1] -=
> -					(dst->metrics[RTAX_RTT-1] - m)>>2;
> +				dst->metrics[RTAX_RTTVAR-1] -=
> +					(dst->metrics[RTAX_RTTVAR-1] - m)>>2;
>  		}
>  
>  		if (tp->snd_ssthresh >= 0xFFFF) {

-- 
/Martin
