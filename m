From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Mon, 24 Apr 2017 15:18:34 +0200
Message-ID: <20170424151834.66fd0a43@redhat.com>
References: <20170415005949.GB73685@ast-mbp.thefacebook.com>
        <20170418190535.GG4730@C02RW35GFVH8.dhcp.broadcom.net>
        <20170418.150708.1605529107204449972.davem@davemloft.net>
        <20170418.152916.1361453741909754079.davem@davemloft.net>
        <20170419142903.GJ4730@C02RW35GFVH8.dhcp.broadcom.net>
        <20170420163034.053ec42c@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alexei.starovoitov@gmail.com,
        michael.chan@broadcom.com, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org, brouer@redhat.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56106 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1170736AbdDXNSl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 09:18:41 -0400
In-Reply-To: <20170420163034.053ec42c@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 20 Apr 2017 16:30:34 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Wed, 19 Apr 2017 10:29:03 -0400
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> > I ran this on top of a card that uses the bnxt_en driver on a desktop
> > class system with an i7-6700 CPU @ 3.40GHz, sending a single stream of
> > UDP traffic with flow control disabled and saw the following (all stats
> > in Million PPS).
> > 
> >                 xdp1                xdp2            xdp_tx_tunnel
> > Generic XDP      7.8    5.5 (1.3 actual)         4.6 (1.1 actual)
> > Optimized XDP   11.7		     9.7                      4.6
> > 
> > One thing to note is that the Generic XDP case shows some different
> > results for reported by the application vs actual (seen on the wire).  I
> > did not debug where the drops are happening and what counter needs to be
> > incremented to note this -- I'll add that to my TODO list.  The
> > Optimized XDP case does not have a difference in reported vs actual
> > frames on the wire.  
> 
> The reported application vs actual (seen on the wire) number sound scary.
> How do you evaluate/measure "seen on the wire"?
> 
> Perhaps you could use ethtool -S stats to see if anything is fishy?
> I recommend using my tool[1] like:
> 
>  ~/git/network-testing/bin/ethtool_stats.pl --dev mlx5p2 --sec 2
> 
> [1] https://github.com/netoptimizer/network-testing/blob/master/bin/ethtool_stats.pl
> 
> I'm evaluating this patch on a mlx5 NIC, and something is not right...
> I'm seeing:
> 
>  Ethtool(mlx5p2) stat:     349599 (        349,599) <= tx_multicast_phy /sec
>  Ethtool(mlx5p2) stat:    4940185 (      4,940,185) <= tx_packets /sec
>  Ethtool(mlx5p2) stat:     349596 (        349,596) <= tx_packets_phy /sec
>  [...]
>  Ethtool(mlx5p2) stat:      36898 (         36,898) <= rx_cache_busy /sec
>  Ethtool(mlx5p2) stat:      36898 (         36,898) <= rx_cache_full /sec
>  Ethtool(mlx5p2) stat:    4903287 (      4,903,287) <= rx_cache_reuse /sec
>  Ethtool(mlx5p2) stat:    4940185 (      4,940,185) <= rx_csum_complete /sec
>  Ethtool(mlx5p2) stat:    4940185 (      4,940,185) <= rx_packets /sec
> 
> Something is wrong... when I tcpdump on the generator machine, I see
> garbled packets with IPv6 multicast addresses.
> 
> And it looks like I'm only sending 349,596 tx_packets_phy/sec on the "wire".
> 

Not seeing packets on the TX wire was caused by the NIC HW dropping the
packets, because the ethernet MAC-addr were not changed/swapped.

Fixed this XDP_TX bug in my test program xdp_bench01_mem_access_cost.
https://github.com/netoptimizer/prototype-kernel/commit/85f7ba2f0ea2

Even added a new option --swapmac for creating another test option for
modifying the packet.
https://github.com/netoptimizer/prototype-kernel/commit/fe080e6f3ccf

I will shortly publish a full report of testing this patch.
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
