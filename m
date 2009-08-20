From: Johannes Stezenbach <js@sig21.net>
Subject: Re: 100Mbit ethernet performance on embedded devices
Date: Thu, 20 Aug 2009 14:56:49 +0200
Message-ID: <20090820125649.GA29029@sig21.net>
References: <20090819145057.GA25400@sig21.net>
 <20090819153534.GC30013@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-embedded@vger.kernel.org, netdev@vger.kernel.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:40308 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754169AbZHTM4v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 08:56:51 -0400
Content-Disposition: inline
In-Reply-To: <20090819153534.GC30013@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2009 at 04:35:34PM +0100, Jamie Lokier wrote:
> Johannes Stezenbach wrote:
> > 
> >   TCP RX ~70Mbit/sec  (iperf -s on SoC, iperf -c on destop PC)
> >   TCP TX ~56Mbit/sec  (iperf -s on destop PC, iperf -c o SoC)
> > 
> > The CPU load during the iperf test is around
> > 1% user, 44% system, 4% irq, 48% softirq, with 7500 irqs/sec.
> > 
> > The kernel used in these measurements does not have iptables
> > support, I think packet filtering will slow it down noticably,
> > but I didn't actually try.  The ethernet driver uses NAPI,
> > but it doesn't seem to be a win judging from the irq/sec number.
> 
> You should see far fewer interrupts if NAPI was working properly.
> Rather than NAPI not being a win, it looks like it's not active at
> all.
> 
> 7500/sec is close to the packet rate, for sending TCP with
> full-size ethernet packages over a 100Mbit ethernet link.

>From debug output I can see that NAPI works in principle, however
the timing seems to be such that ->poll() almost always completes
before the next packet is received.  I followed the NAPI_HOWTO.txt
which came with the 2.6.20 kernel.  The delay between irq ->
netif_rx_schedule() -> NET_RX_SOFTIRQ ->  ->poll()  doesn't seem
to be long enough.  But of course my understanding of NAPI is
very limited, probably I missed something...

> > What I'm interested in are some numbers for similar hardware,
> > to find out if my hardware and/or ethernet driver can be improved,
> > or if the CPU will always be the limiting factor.
> 
> I have a SoC with a 166MHz ARMv4 (ARM7TDMI I think, but I'm not sure),
> and an external RTL8139 100Mbit ethernet chip over the SoC's PCI bus.
> 
> It gets a little over 80Mbit/s actual data throughput in both
> directions, running a simple FTP client.

I found one interesting page which defines network driver performance
in terms of "CPU MHz per Mbit".
http://www.stlinux.com/drupal/node/439

I can't really tell from their table how big a win HW csum is, but
what they call "interrupt mitigation optimisations" (IOW: working NAPI)
seems important.  (compare the values for STx7105)

If some has an embedded platform with 100Mbit ethernet where they can switch
HW checksum via ethtool and benchmark both under equal conditions, that
would be very interesting.


Thanks
Johannes
