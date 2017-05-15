From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: switchdev offload & ecmp
Date: Mon, 15 May 2017 19:40:36 +0300
Message-ID: <20170515164036.GA5669@splinter.mtl.com>
References: <84b9801f-0c2a-cd55-61a4-411261943024@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0074.outbound.protection.outlook.com ([104.47.0.74]:42592
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934223AbdEOQkq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 12:40:46 -0400
Content-Disposition: inline
In-Reply-To: <84b9801f-0c2a-cd55-61a4-411261943024@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, May 15, 2017 at 04:25:43PM +0200, Nicolas Dichtel wrote:
> Hi Jiri and Ido,
> 
> I'm trying to understand how ecmp offloading works. It seems that rocker doesn't
> support it:
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/rocker/rocker_ofdpa.c#n2409.
> But I saw that the support was added in spectrum:
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/log/?h=684a95c064fc.
> 
> Is there a consistency between the ecmp algorithm of the kernel and the one from
> spectrum?

We currently use the hardware's defaults for ECMP hashing, which include
both L3 and L4 fields. I'm aware of Nik's patch, but we've yet to
reflect that. Note that the L4 fields aren't considered for fragmented
packets.

> I suspect that there can be scenarii where some packets of a flow are forwarded
> by the driver and some other are forwarded by the kernel.

Can you elaborate? The kernel only sees specific packets, which were
trapped to the CPU. See:
https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/tree/drivers/net/ethernet/mellanox/mlxsw/spectrum.c#n2996

> For example, an ecmp route with two nexthops: a connected route and a gw? 

Not sure I'm following you. A packet will either hit a remote route or a
directly connected one. We distinguish between the two based on the
scope of the first nexthop in the group. See:
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c#n2043

> In that case, the periodic nexthops update
> (https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c#n987)
> won't help. How do you ensure that all packets of the flow are always forwarded
> through the same nexthop?

I don't think we can ensure that for a flow in which some packets are
forwarded by the kernel and some by the device, but I failed to
understand your example of such a flow.

Thanks
