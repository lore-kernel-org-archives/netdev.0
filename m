From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Thu, 29 Jan 2015 05:14:57 -0800
Message-ID: <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:36820 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753566AbbA2NPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 08:15:00 -0500
In-Reply-To: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-29 at 12:48 +0100, Michal Kazior wrote:
> Hi,
> 
> I'm not subscribed to netdev list and I can't find the message-id so I
> can't reply directly to the original thread `BW regression after "tcp:
> refine TSO autosizing"`.
> 
> I've noticed a big TCP performance drop with ath10k
> (drivers/net/wireless/ath/ath10k) on 3.19-rc5. Instead of 500mbps I
> get 250mbps in my testbed.
> 
> After bisecting I ended up at `tcp: refine TSO autosizing`. Reverting
> `tcp: refine TSO autosizing` and `tcp: Do not apply TSO segment limit
> to non-TSO packets` (for conflict free reverts) fixes the problem.
> 
> My testing setup is as follows:
> 
>  a) ath10k AP, github.com/kvalo/ath/tree/master 3.19-rc5, w/ reverts
>  b) ath10k STA connected to (a), github.com/kvalo/ath/tree/master
> 3.19-rc5, w/ reverts
>  c) (b) w/o reverts
> 
> Devices are 3x3 (AP) and 2x2 (Client) and are RF cabled. 11ac@80MHz
> 2x2 has 866mbps modulation rate. In practice this should deliver
> ~700mbps of real UDP traffic.
> 
> Here are some numbers:
> 
> UDP: (b) -> (a): 672mbps
> UDP: (a) -> (b): 687mbps
> TCP: (b) -> (a): 526mbps
> TCP: (a) -> (b): 500mbps
> 
> UDP: (c) -> (a): 669mbps*
> UDP: (a) -> (c): 689mbps*
> TCP: (c) -> (a): 240mbps**
> TCP: (a) -> (c): 490mbps*
> 
> * no changes/within error margin
> ** the performance drop
> 
> I'm using iperf:
>   UDP: iperf -i1 -s -u vs iperf -i1 -c XX -u -B 200M -P5 -t 20
>   TCP: iperf -i1 -s vs iperf -i1 -c XX -P5 -t 20
> 
> Result values were obtained at the receiver side.
> 
> Iperf reports a few frames lost and out-of-order at each UDP test
> start (during first second) but later has no packet loss and no
> out-of-order. This shouldn't have any effect on a TCP session, right?
> 
> The device delivers batched up tx/rx completions (no way to change
> that). I suppose this could be an issue for timing sensitive
> algorithms. Also keep in mind 802.11n and 802.11ac devices have frame
> aggregation windows so there's an inherent extra (and non-uniform)
> latency when compared to, e.g. ethernet devices.
> 
> The driver doesn't have GRO. I have an internal patch which implements
> it. It improves overall TCP traffic (more stable, up to 600mbps TCP
> which is ~100mbps more than without GRO) but the TCP: (c) -> (a)
> performance drop remains unaffected regardless.
> 
> I've tried applying stretch ACK patchset (v2) on both machines and
> re-run the above tests. I got no measurable difference in performance.
> 
> I've also run these tests with iwlwifi 7260 (also a 2x2) as (b) and
> (c). It didn't seem to be affected by the TSO patch at all (it runs at
> ~360mbps of TCP regardless of the TSO patch).
> 
> Any hints/ideas?
> 

Hi Michal

This patch restored original TSQ behavior, because the 1ms worth of data
per flow had totally destroyed TSQ intent.

vi +630 Documentation/networking/ip-sysctl.txt

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

This is why I suggested to Eyal Perry to change the TX interrupt
mitigation parameters as in :

ethtool -C eth0 tx-frames 4 rx-frames 4

With this change and the stretch ack fixes, I got 37Gbps of throughput
on a single flow, on a 40Gbit NIC (mlx4)

If a driver needs to buffer more than tcp_limit_output_bytes=131072 to
get line rate, I suggest that you either :

1) tweak tcp_limit_output_bytes, but its not practical from a driver.

2) change the driver, knowing what are its exact requirements, by
removing a fraction of skb->truesize at ndo_start_xmit() time as in :

if ((skb->destructor == sock_wfree ||
     skb->restuctor == tcp_wfree) &&
    skb->sk) {
    u32 fraction = skb->truesize / 2;

    skb->truesize -= fraction;
    atomic_sub(fraction, &skb->sk->sk_wmem_alloc);
}

Thanks.
