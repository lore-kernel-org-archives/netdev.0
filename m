From: Johannes Stezenbach <js@sig21.net>
Subject: Re: 100Mbit ethernet performance on embedded devices
Date: Fri, 28 Aug 2009 16:41:38 +0200
Message-ID: <20090828144138.GB7375@sig21.net>
References: <20090819145057.GA25400@sig21.net>
 <20090819153534.GC30013@shareable.org>
 <20090820125649.GA29029@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-embedded@vger.kernel.org, netdev@vger.kernel.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-embedded-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090820125649.GA29029@sig21.net>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 20, 2009 at 02:56:49PM +0200, Johannes Stezenbach wrote:
> On Wed, Aug 19, 2009 at 04:35:34PM +0100, Jamie Lokier wrote:
> > Johannes Stezenbach wrote:
> > > 
> > >   TCP RX ~70Mbit/sec  (iperf -s on SoC, iperf -c on destop PC)
> > >   TCP TX ~56Mbit/sec  (iperf -s on destop PC, iperf -c o SoC)
> > > 
> > > The CPU load during the iperf test is around
> > > 1% user, 44% system, 4% irq, 48% softirq, with 7500 irqs/sec.
> > > 
> > > The kernel used in these measurements does not have iptables
> > > support, I think packet filtering will slow it down noticably,
> > > but I didn't actually try.  The ethernet driver uses NAPI,
> > > but it doesn't seem to be a win judging from the irq/sec number.
> > 
> > You should see far fewer interrupts if NAPI was working properly.
> > Rather than NAPI not being a win, it looks like it's not active at
> > all.
> > 
> > 7500/sec is close to the packet rate, for sending TCP with
> > full-size ethernet packages over a 100Mbit ethernet link.
> 
> From debug output I can see that NAPI works in principle, however
> the timing seems to be such that ->poll() almost always completes
> before the next packet is received.  I followed the NAPI_HOWTO.txt
> which came with the 2.6.20 kernel.  The delay between irq ->
> netif_rx_schedule() -> NET_RX_SOFTIRQ ->  ->poll()  doesn't seem
> to be long enough.  But of course my understanding of NAPI is
> very limited, probably I missed something...

It would've been nice to get a comment on this.  Yeah I know,
old kernel, non-mainline driver...

On this platform NAPI seems to be a win when receiving small packets,
but not for a single max-bandwidth TCP stream.  The folks at
stlinux.com seem to be using a dedicated hw timer to delay
the NAPI poll() calls:
http://www.stlinux.com/drupal/kernel/network/stmmac-optimizations

This of course adds some latency to the packet processing,
however in the single TCP stream case this wouldn't matter.


Thanks,
Johannes
