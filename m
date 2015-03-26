From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] tcp: Allow sk_wmem_alloc to exceed
 sysctl_tcp_limit_output_bytes
Date: Thu, 26 Mar 2015 10:14:30 -0700
Message-ID: <1427390070.25985.145.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427388414-31077-1-git-send-email-jonathan.davies@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Eric Dumazet <edumazet@google.com>
To: Jonathan Davies <jonathan.davies@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:34562 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbbCZROd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 13:14:33 -0400
Received: by iedfl3 with SMTP id fl3so58098535ied.1
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 10:14:32 -0700 (PDT)
In-Reply-To: <1427388414-31077-1-git-send-email-jonathan.davies@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-26 at 16:46 +0000, Jonathan Davies wrote:
> Network drivers with slow TX completion can experience poor network transmit
> throughput, limited by hitting the sk_wmem_alloc limit check in tcp_write_xmit.
> The limit is 128 KB (by default), which means we are limited to two 64 KB skbs
> in-flight. This has been observed to limit transmit throughput with xen-netfront
> because its TX completion can be relatively slow compared to physical NIC
> drivers.
> 
> There have been several modifications to the calculation of the sk_wmem_alloc
> limit in the past. Here is a brief history:
> 
>  * Since TSQ was introduced, the queue size limit was
>        sysctl_tcp_limit_output_bytes.
> 
>  * Commit c9eeec26 ("tcp: TSQ can use a dynamic limit") made the limit
>        max(skb->truesize, sk->sk_pacing_rate >> 10).
>    This allows more packets in-flight according to the estimated rate.
> 
>  * Commit 98e09386 ("tcp: tsq: restore minimal amount of queueing") made the
>    limit
>        max_t(unsigned int, sysctl_tcp_limit_output_bytes,
>                            sk->sk_pacing_rate >> 10).
>    This ensures at least sysctl_tcp_limit_output_bytes in flight but allowed
>    more if rate estimation shows this to be worthwhile.
> 
>  * Commit 605ad7f1 ("tcp: refine TSO autosizing") made the limit
>        min_t(u32, max(2 * skb->truesize, sk->sk_pacing_rate >> 10),
>                   sysctl_tcp_limit_output_bytes).
>    This meant that the limit can never exceed sysctl_tcp_limit_output_bytes,
>    regardless of what rate estimation suggests. It's not clear from the commit
>    message why this significant change was justified, changing
>    sysctl_tcp_limit_output_bytes from being a lower bound to an upper bound.
> 
> This patch restores the behaviour that allows the limit to grow above
> sysctl_tcp_limit_output_bytes according to the rate estimation.
> 
> This has been measured to improve xen-netfront throughput from a domU to dom0
> from 5.5 Gb/s to 8.0 Gb/s. Or, in the case of transmitting from one domU to
> another (on the same host), throughput rose from 2.8 Gb/s to 8.0 Gb/s. In the
> latter case, TX completion is especially slow, explaining the large improvement.
> These values were measured against 4.0-rc5 using "iperf -c <ip> -i 1" using
> CentOS 7.0 VM(s) on Citrix XenServer 6.5 on a Dell R730 host with a pair of Xeon
> E5-2650 v3 CPUs.
> 
> Fixes: 605ad7f184b6 ("tcp: refine TSO autosizing")
> Signed-off-by: Jonathan Davies <jonathan.davies@citrix.com>
> ---
>  net/ipv4/tcp_output.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 1db253e..3a49af8 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2052,7 +2052,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
>  		 * One example is wifi aggregation (802.11 AMPDU)
>  		 */
>  		limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
> -		limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
> +		limit = max_t(u32, limit, sysctl_tcp_limit_output_bytes);
>  
>  		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
>  			set_bit(TSQ_THROTTLED, &tp->tsq_flags);


That will get a NACK from me and Google TCP team of course.

Try your patch with low throughput flows, like 64kbps, GSO off...

And observe TCP timestamps and rtt estimations, critical for vegas or
any CC based on delay.

I get line rate on 40Gbps NIC using this (low) limit of 2 TSO packets.

This topic was discussed for wifi recently, and I suggested multiple
ways to solve the problem on problematic drivers.

There is a reason sysctl_tcp_limit_output_bytes exists : You can change
its value to whatever you want.

vi +652 Documentation/networking/ip-sysctl.txt

tcp_limit_output_bytes - INTEGER
        Controls TCP Small Queue limit per tcp socket.
        TCP bulk sender tends to increase packets in flight until it
        gets losses notifications. With SNDBUF autotuning, this can
        result in a large amount of packets queued in qdisc/device
        on the local machine, hurting latency of other flows, for
        typical pfifo_fast qdiscs.
        tcp_limit_output_bytes limits the number of bytes on qdisc
        or device to reduce artificial RTT/cwnd and reduce bufferbloat.
        Default: 131072

Documentation is pretty clear : This is the max value, not a min one.
