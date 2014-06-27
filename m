From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance loss with GRO enabled on tunnels
Date: Thu, 26 Jun 2014 21:17:01 -0700
Message-ID: <1403842621.15139.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+mtBx9uvD7Ddg4xQxDKxFK395ccEc3YvwhFVZJU9xJvUsAdGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:63746 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbaF0ERF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 00:17:05 -0400
Received: by mail-we0-f171.google.com with SMTP id q58so4634679wes.2
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 21:17:04 -0700 (PDT)
In-Reply-To: <CA+mtBx9uvD7Ddg4xQxDKxFK395ccEc3YvwhFVZJU9xJvUsAdGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-06-26 at 17:59 -0700, Tom Herbert wrote:
> I'm seeing quite a performance difference with GRO enabled/disabled on
> the tun interface for GRE and IPIP. Physical interface is bnx2x with
> lro enable and GRO disabled. Looks like tun interface inherits GRO as
> an "always supported SW feature".
> 
> 200 connection TCP_RR with GRE and no GRO on tun0
>   1.06046e+06 tps
>   71.06% CPU utilization
> 
> With GRO enabled on tun0
>   406879 tps
>   28.14% CPU utilization
> 
> Given CPU utilization is not particularly high, so I would guess
> things are being slowed down by something like lock contention.
> 
> Generally, I wonder if there's really any value on enabling GRO on the
> tunnel interface anyway, seems like GRO is going to be most beneficial
> if we do this at the physical device-- if we're aggregating at the
> tunnel interface we've already done a lot of processing on the
> individual packets.

GRO is enabled on all interfaces by default.

There is nothing special about tunnels to 'turn it off by default'

Here at Google, we cooked patches to address this problem, please take a
look at Google-Bug-Id: 13655458


commit 974ca81a5948be5d99be679296f2929d70131422
Author: Eric Dumazet <edumazet@google.com>
Date:   Sat May 31 17:36:15 2014 -0700

    net-gro: use one gro_cell per cpu
    
    GRO layer used on GRE tunnels uses skb->queue_mapping as a hash
    to select a gro_cell from an array of 8 available cells.
    
    Unfortunately queue_mapping can be cleared before reaching this
    selection, and even if not cleared, its possible all GRE packets
    are received into a single RX queue on the NIC.
    
    If we believe RPS/RFS did a good job, then we simply should use
    one gro_cell per cpu, and use current cpu id instead of a field
    taken from skb. This helps because the overhead of TCP checksum
    validation can be spread among all cpus.
    
    Tested:
     Ran a tunnel on lpk51/lpk52 (bnx2x 2x10Gb NIC), and tested
     super_netperf 200 -t TCP_STREAM to check no lock contention
     was happening on the gro_cell's spinlock
    Effort: net-gro
    Google-Bug-Id: 13655458
    Change-Id: Ie260771992c40bb23dcdd53476954f8436fdf097
