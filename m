From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and
 performance degration
Date: Wed, 14 Mar 2012 11:25:36 -0700
Message-ID: <1331749536.6022.31.camel@edumazet-glaptop>
References: <20120314190156.622c8cd5@vostro>
	 <1331745314.6022.27.camel@edumazet-glaptop>
	 <20120314192945.65867e9f@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42855 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab2CNSZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 14:25:38 -0400
Received: by ghrr11 with SMTP id r11so2119740ghr.19
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 11:25:38 -0700 (PDT)
In-Reply-To: <20120314192945.65867e9f@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-14 at 19:29 +0200, Timo Teras wrote:
> On Wed, 14 Mar 2012 10:15:14 -0700 Eric Dumazet
> <eric.dumazet@gmail.com> wrote:
> 
> > On Wed, 2012-03-14 at 19:01 +0200, Timo Teras wrote:
> > > Hi,
> > > 
> > > I have a router box running linux-3.0.18 (with grsec patches).
> > > 
> > > with the NIC hardware:
> > > r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> > > r8169 0000:00:09.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
> > > r8169 0000:00:09.0: (unregistered net_device): no PCI Express
> > > capability r8169 0000:00:09.0: eth0: RTL8169sc/8110sc at
> > > 0xf82f8000, 00:30:18:ab:6b:54, XID 18000000 IRQ 18 r8169 Gigabit
> > > Ethernet driver 2.3LK-NAPI loaded r8169 0000:00:0b.0: PCI INT A ->
> > > GSI 19 (level, low) -> IRQ 19 r8169 0000:00:0b.0: (unregistered
> > > net_device): no PCI Express capability r8169 0000:00:0b.0: eth1:
> > > RTL8169sc/8110sc at 0xf82fa000, 00:30:18:ab:6b:55, XID 18000000 IRQ
> > > 19 r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded r8169
> > > 0000:00:0c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16 r8169
> > > 0000:00:0c.0: (unregistered net_device): no PCI Express capability
> > > r8169 0000:00:0c.0: eth2: RTL8169sc/8110sc at 0xf82fc000,
> > > 00:30:18:ab:6b:56, XID 18000000 IRQ 16
> > > 
> > > This box is working just as a plain IPv4 router (internal RFC1918
> > > address space) forwarding packets.
> > > 
> > > It routes basically from eth2 to multiple vlans over bond0
> > > consisting of eth0 and eth1.
> > > 
> > > I have most hw accel stuff turned off, and "ethtool -k eth0" says:
> > > Offload parameters for eth0:
> > > rx-checksumming: on
> > > tx-checksumming: on
> > > scatter-gather: off
> > > tcp segmentation offload: off
> > > udp fragmentation offload: off
> > > generic segmentation offload: off
> > > 
> > > The same applies for all interfaces (except lo).
> > > 
> > > However, tcpdump on this box indicates that I'm receiving very
> > > long (tcp length more than mtu) incoming packets on eth2 implying
> > > that gso/tso got turned on somehow. eth2 is connected with
> > > cross-over cable to similar box running a bit older linux box; but
> > > gso/tso is turned off there too. When dumping simultaneously on the
> > > other side, it indicates that all packets sent are normal length,
> > > and no merging was performed earlier (fits mtu 1500).
> > > 
> > > So it would appear that the router box somehow insists on doing
> > > gso/tso, and sadly it will also mess up on the send path (the
> > > incoming merged packet is forwarded, but sent out short) causing
> > > lost segments and serious performance degration.
> > > 
> > > Any pointers how to next debug/fix/workaround this issue?
> > > 
> > 
> > You are fighting the wrong side ;)
> > 
> > Here, its GRO doing the aggregation on receiver.
> 
> Yes, I figured this much. But I have explictly turned GRO off and it's
> still happening.
> 
> > What kind of problems do you experiment because of this ?
> 
> I'm getting lost packets (the non-first TCP segments off the GRO merged
> packet). This causes serious TCP speed degration (should get 10MB/s
> through 100mbit/s link; but I'm getting only 2-3MB/s). Doing the same
> transfer on the next hop router gives full speed, so the problem is
> definitely on this router and due to GRO badness.

There is something completely unrelated to GRO then. 2-3 MB/s sound more
a tcp issue.

> 
> I also remember this working before, so this seems a regression from
> upgrading 2.6.35.x kernel or something like that.
> 
> > ethtool -k eth2
> 
> gro off. I am even trying now with:
> 
> Offload parameters for eth2:
> rx-checksumming: off
> tx-checksumming: off
> scatter-gather: off
> tcp segmentation offload: off
> udp fragmentation offload: off
> generic segmentation offload: off
> 

I cant see how you can then receive tcp frames bigger than MTU.

> Additionally, I'm looking at my other router boxes with same hardware
> but different kernel versions. Looks that all of them are acting as GRO
> is enabled, even though it's turned off by ethtool.
> 
> I can verify that 2.6.35.8, 2.6.38.8, and 3.0.18 (all of these with
> grsec patch) are doing GRO for this r8169 hardware, even though it's
> configured OFF on all boxes.
> 
> There seems to be no performance issues in 2.6.35.8 kernel. This would
> indicate that the incoming GRO packets are properly handled and
> segmented (likely by software) on the path out. However, I'm also
> having issues with the 2.6.38.8 box, and badness on GRO send path
> seems to be the cause. And of course to mention that GRO is happening
> even though it's turned off.
> 
> Additionally, it seems that at the 2.6.38.8 and 3.0.18 kernels are
> having the performance issues even if it's locally terminated TCP
> connection. So it's not limited to the forward path. The latest good
> kernel I can verify is 2.6.35.x.
> 
> - Timo

If trafic is localy terminated :

netstat -s 

should give us some input.
