From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] pkt_sched: fq: avoid artificial bursts for
 clocked flows
Date: Mon, 02 Feb 2015 11:24:52 -0800
Message-ID: <1422905092.21689.122.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422903556-30393-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:33277 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932562AbbBBTYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 14:24:54 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so4621844igd.4
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 11:24:53 -0800 (PST)
In-Reply-To: <1422903556-30393-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-02-02 at 19:59 +0100, Kenneth Klette Jonassen wrote:
> Current pacing behavior always throttle flows for a time equal to one full
> quantum, starting at the instance in time when a flow depletes its credit.
> This is optimal for burst sizes that are a multiple of the chosen quantum.
> 
> For flows with many small and evenly clocked packets, the depletion and
> refilling of credits cause packets to queue and transmit in bursts, even
> when their clocked rate is below the pacing rate. With TCP ACKs, this
> artificial queueing induces significant noise to RTTs, e.g. up to 2.07 ms
> for rtt 20 ms, cwnd 10 and quantum 3028.
> 
> Packetdrill script to illustrate bursts:
> 0.000 socket(..., SOCK_DGRAM, IPPROTO_UDP) = 3
> 0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> 0.000 bind(3, ..., ...) = 0
> 0.000 connect(3, ..., ...) = 0
> 
> // SO_MAX_PACING_RATE: 2500 Bps, 100 ms per quantum, 20 ms per 50B packet.
> 0.000 setsockopt(3, SOL_SOCKET, 47, [2500], 4) = 0
> 0.000 `tc qdisc add dev tun0 root fq initial_quantum 250 quantum 250`
> 
> // Use 200 credits: send four perfectly spaced 50 byte packets.
> 0.000 write(3, ..., 22) = 22
> 0.000 > udp (22)
> 0.020 write(3, ..., 22) = 22
> 0.020 > udp (22)
> 0.040 write(3, ..., 22) = 22
> 0.040 > udp (22)
> 0.060 write(3, ..., 22) = 22
> 0.060 > udp (22)


We do not want to perfectly space packets, but have an efficient packet
scheduler, allowing TCP pacing.

I chose to not use ktime_get() in enqueue() when I wrote sch_fq.

A Token Bucket Filter has the notion of quantum, meaning you configure
the granularity given this quantum.

At Google, we have a special handling for TCP ACK packets, so that they
do not interfere with FQ/pacing.

ACK packets are not paced, ever.

This patch also allows skb->ooo_okay being set even if the DATA packet
immediately follows a train of ACK packets (as in typical RPC patterns)
