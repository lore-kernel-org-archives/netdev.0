From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [E1000-devel] Transmission limit
Date: Wed, 01 Dec 2004 22:13:33 -0800
Message-ID: <1101967983.4782.9.camel@localhost.localdomain>
References: <1101484740.24742.213.camel@mellia.lipar.polito.it>
	 <41A76085.7000105@draigBrady.com>
	 <1101499285.1079.45.camel@jzny.localdomain>
	 <16811.8052.678955.795327@robur.slu.se>
	 <1101821501.1043.43.camel@jzny.localdomain>
	 <20041130134600.GA31515@xi.wantstofly.org>
	 <1101824754.1044.126.camel@jzny.localdomain>
	 <20041201001107.GE4203@xi.wantstofly.org>
	 <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
	 <20041201182943.GA14470@xi.wantstofly.org>
	 <20041201213550.GF14470@xi.wantstofly.org>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Robert Olsson <Robert.Olsson@data.slu.se>,
        P@draigBrady.com, mellia@prezzemolo.polito.it,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041201213550.GF14470@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-01 at 13:35, Lennert Buytenhek wrote: 
> Pretty graph attached.  From ~220B packets or so it does wire speed, but
> there's still an odd drop in performance around 256B packets (which is
> also there without your patch.)  From 350B packets or so, performance is
> identical with or without your patch (wire speed.)
Seems this is helping PCI nics but not PCI-X.  I was using PCI 32/33. 
Can't explain the dip around 256B.

> So.  Do you have any other good plans perhaps? :)

Idea#1

Is the write of TDT causing interference with DMA transactions?

In addition to my patch, what happens if you bump the Tx tail every n
packets, where n is like 16 or 32 or 64?  

if((i % 16) == 0)
	E1000_REG_WRITE(&adapter->hw, TDT, i);

This might piss the NETDEV timer off if the send count isn't a multiple
of n, so you might want to disable netdev->tx_timeout.

Idea#2

The Ultimate: queue up 4096 packets and then write TDT once to send all
4096 in one shot.  Well, maybe a few less that 4096 so we don't wrap the
ring.  How about pkt_size = 4000?

Take my patch and change the timer call in e1000_xmit_frame from 

	jiffies + 1

to

	jiffies + HZ

This will schedule the cleanup of the skbs 1 second after the first
queue, so we shouldn't be doing any cleanup while the 4000 packets are
DMA'ed.

Oh, and change the tail write to

if((i % 4000) == 0)
	E1000_REG_WRITE(&adapter->hw, TDT, i);

Of course you'll need to close/open the driver after each run.

Idea#3

http://www.mail-archive.com/freebsd-net@freebsd.org/msg10826.html

Set TXDMAC to 0 in e1000_configure_tx.

> > Once or twice it went into a state where it started spitting out these
> > kinds of messages and never recovered:
> > 
> > 	Dec  1 19:13:18 phi kernel: NETDEV WATCHDOG: eth1: transmit timed out
> > 	[...]
> > 	Dec  1 19:13:31 phi kernel: NETDEV WATCHDOG: eth1: transmit timed out
> > 	[...]
> > 	Dec  1 19:13:43 phi kernel: NETDEV WATCHDOG: eth1: transmit timed out
> 
> Didn't see this happen anymore.  (ifconfig down and then up recovered it
> both times I saw it happen.)

Well, it's probably not a HW bug that's causing the reset; it's probably
some bug with my patch.

-scott
