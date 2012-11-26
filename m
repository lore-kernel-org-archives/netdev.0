From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: performance regression on HiperSockets depending on MTU size
Date: Mon, 26 Nov 2012 08:12:31 -0800
Message-ID: <1353946351.30446.1779.camel@edumazet-glaptop>
References: <20121126153242.GA61652@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:52843 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485Ab2KZQMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 11:12:35 -0500
In-Reply-To: <20121126153242.GA61652@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-26 at 16:32 +0100, Frank Blaschka wrote:
> Hi Eric,
> 
> since kernel 3.6 we see a massive performance regression on s390
> HiperSockets devices.
> 
> HiperSockets differ from normal devices by the fact they support
> large MTU sizes (up to 56K). Here are some iperf numbers to show
> the problem depended on MTU size:
> 
> # ifconfig hsi0 mtu 1500
> # iperf -c 10.42.49.2
> ------------------------------------------------------------
> Client connecting to 10.42.49.2, TCP port 5001
> TCP window size: 47.6 KByte (default)
> ------------------------------------------------------------
> [  3] local 10.42.49.1 port 55855 connected with 10.42.49.2 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-10.0 sec    632 MBytes    530 Mbits/sec
> 
> # ifconfig hsi0 mtu 9000
> # iperf -c 10.42.49.2
> ------------------------------------------------------------
> Client connecting to 10.42.49.2, TCP port 5001
> TCP window size: 97.0 KByte (default)
> ------------------------------------------------------------
> [  3] local 10.42.49.1 port 55856 connected with 10.42.49.2 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-10.0 sec  2.26 GBytes  1.94 Gbits/sec
> 
> # ifconfig hsi0 mtu 32000
> # iperf -c 10.42.49.2
> ------------------------------------------------------------
> Client connecting to 10.42.49.2, TCP port 5001
> TCP window size:   322 KByte (default)
> ------------------------------------------------------------
> [  3] local 10.42.49.1 port 55857 connected with 10.42.49.2 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-10.3 sec  3.12 MBytes  2.53 Mbits/sec
> 
> Prior the regression throughput grows with the MTU size but now it drops
> to a few Mbits if the MTU is bigger then 15000. It is interesting to see
> if 2 or more connections are running in parallel the regression is gone.
> 
> # ifconfig hsi0 mtu 32000
> # iperf -c 10.42.49.2 -P2
> ------------------------------------------------------------
> Client connecting to 10.42.49.2, TCP port 5001
> TCP window size:   322 KByte (default)
> ------------------------------------------------------------
> [  4] local 10.42.49.1 port 55869 connected with 10.42.49.2 port 5001
> [  3] local 10.42.49.1 port 55868 connected with 10.42.49.2 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  4]  0.0-10.0 sec  2.19 GBytes  1.88 Gbits/sec
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-10.0 sec  2.17 GBytes  1.87 Gbits/sec
> [SUM]  0.0-10.0 sec  4.36 GBytes  3.75 Gbits/sec
> 
> I bisected the problem to following patch:
> 
> commit 46d3ceabd8d98ed0ad10f20c595ca784e34786c5
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Wed Jul 11 05:50:31 2012 +0000
> 
>     tcp: TCP Small Queues
> 
>     This introduce TSQ (TCP Small Queues)
> 
>     TSQ goal is to reduce number of TCP packets in xmit queues (qdisc &
>     device queues), to reduce RTT and cwnd bias, part of the bufferbloat
>     problem.
> 
> Changing sysctl net.ipv4.tcp_limit_output_bytes to a higher value
> (e.g. 640000) seems to fix the problem.
> 
> How does MTU influence/effects TSQ?
> Why is the problem gone if there are more connections?
> Do you see any drawbacks by increasing net.ipv4.tcp_limit_output_bytes?
> Finally is this expected behavior or is there a bug depending on the big
> MTU? What can I do to check ... ?
> 

Hi Frank, thanks for this report.

You could tweak tcp_limit_output_bytes, but IMO the root of the problem
is in the driver itself.

For example, I had to change mlx4 driver for the same problem : Make
sure a TX packet can be "TX completed" in a short amount of time.

In the case of mlx4, the wait time was 128 us, but I suspect on your
case its more like an infinite time or several ms.
 
The driver is delaying the free of TX skb by a fixed amount of time,
or relies on following transmits to perform the TX completion


Check for an example :

commit ecfd2ce1a9d5e6376ff5c00b366345160abdbbb7
Author: Eric Dumazet <edumazet@google.com>
Date:   Mon Nov 5 16:20:42 2012 +0000

    mlx4: change TX coalescing defaults
    
    mlx4 currently uses a too high tx coalescing setting, deferring
    TX completion interrupts by up to 128 us.
    
    With the recent skb_orphan() removal in commit 8112ec3b872,
    performance of a single TCP flow is capped to ~4 Gbps, unless
    we increase tcp_limit_output_bytes.
    
    I suggest using 16 us instead of 128 us, allowing a finer control.
    
    Performance of a single TCP flow is restored to previous levels,
    while keeping TCP small queues fully enabled with default sysctl.
    
    This patch is also a BQL prereq.
    
    Reported-by: Vimalkumar <j.vimal@gmail.com>
    Signed-off-by: Eric Dumazet <edumazet@google.com>
