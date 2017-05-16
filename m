From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: switchdev offload & ecmp
Date: Tue, 16 May 2017 17:11:49 +0300
Message-ID: <20170516141149.GA1874@splinter.mtl.com>
References: <84b9801f-0c2a-cd55-61a4-411261943024@6wind.com>
 <20170515164036.GA5669@splinter.mtl.com>
 <4c70d1fc-ba11-e358-2142-d373f44cb5a1@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0074.outbound.protection.outlook.com ([104.47.0.74]:3719
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753507AbdEPOL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 10:11:57 -0400
Content-Disposition: inline
In-Reply-To: <4c70d1fc-ba11-e358-2142-d373f44cb5a1@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 02:57:47PM +0200, Nicolas Dichtel wrote:
> >> I suspect that there can be scenarii where some packets of a flow are forwarded
> >> by the driver and some other are forwarded by the kernel.
> > 
> > Can you elaborate? The kernel only sees specific packets, which were
> > trapped to the CPU. See:
> > https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/tree/drivers/net/ethernet/mellanox/mlxsw/spectrum.c#n2996
> Ok, this part was not clear for me, thank you for the pointer.
> 
> So, when an arp resolution is needed, the packets are not trapped to the CPU,
> the device manages the queue itself?

There are two cases here. If you need an ARP resolution following a hit
of a directly connected route and this neighbour isn't in the device's
table, then packet is trapped (HOST_MISS_IPV4 in above list) to the CPU
and triggers ARP resolution in the kernel. Eventually a NETEVENT will be
sent and the neighbour will be programmed to the device.

If you need an ARP resolution of a nexthop, then this is a bit
different. If you have an ECMP group with several nexthops, then once
one of them is resolved, packets will be forwarded using it. To make
sure other nexthops will also be resolved we try to periodically refresh
them. Otherwise packets will always be forwarded using a single nexthop,
as the kernel won't have motivation to resolve the others.
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c#n987

In case no nexthops can be resolved, then packets will be trapped to the
CPU (RTR_INGRESS0 in above list) and forwarded by the kernel.
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c#n1896
