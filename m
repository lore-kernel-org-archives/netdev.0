From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] igb: Record hardware RX overruns in
	net_stats
Date: Wed, 6 May 2009 01:11:04 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0905060048570.22956@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090505.115819.84151021.davem@davemloft.net>
	<Pine.LNX.4.64.0905052249110.1294@ask.diku.dk>
	<9929d2390905051432h795d183bh40fbe1beb35a4de9@mail.gmail.com>
	<20090505.143529.148721206.davem@davemloft.net>
	<1241595993.5172.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "hawk@diku.dk" <hawk@diku.dk>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1241595993.5172.4.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 6 May 2009, Jesper Dangaard Brouer wrote:

> On Tue, 2009-05-05 at 14:35 -0700, David Miller wrote:
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date: Tue, 5 May 2009 14:32:04 -0700
> > 
> > > the manual[1] for the hardware says:
> > > RNBC:
> > > This register counts the number of times that frames were received
> > > when there were no available buffers in host memory to store those
> > > frames (receive descriptor head and tail pointers were equal). The
> > > packet is still received if there is space in the FIFO. This register
> > > only increments if receives are enabled. This register does not
> > > increment when flow control packets are received.
> > > 
> > > The critical bit "The packet is still received if there is space in
> > > the FIFO" (AND a host memory buffer becomes available) So the reason
> > > we don't want to put it in the net_stats stats for drops is that the
> > > packet
> > > *wasn't* necessarily dropped.
> > > 
> > > The rx_missed errors is for packets that were definitely dropped, and
> > > is already stored in the net_stats structure.
> > 
> > While not an "rx_missed" because we do eventually take the
> > packet, conceptually it is a "fifo overflow" in the sense
> > that we exceeded available receive resources at the time that
> > the packet arrived.
> 
> Yes, with this argumentation, the MPC should then be kept as "rx_missed"
> packets.  And the RNBC stored as "rx_fifo_errors" as its an overflow
> indication, not a number of packets dropped.

The way RNBC works depends on how the queues themselves are configured.  
Specifically, if you have packet drop enabled per queue or not will affect 
RNBC.

In the SRRCTL registers, there is a DROP_EN bit, bit 31.  If this 
bit is set to 1b for the queue in question, then the packet will be 
dropped when there are no buffers in the packet buffer.  This does not 
mean the FIFO is full or has been overrun, it just means there's no more
descriptors available in the Rx ring for that queue.  In this case, RNBC 
is incremented, MPC is not.

If bit 31 in SRRCTL is 0b, then if there's no room in the packet buffer
(no more descriptors available), the device tries to store the packet in
the FIFO.  RNBC will *not* be incremented in this case.  If there's no space
in the FIFO, then the packet is dropped.  RNBC still is not incremented in this
case, rather MPC will be incremented, since the packet was dropped due to the FIFO 
being full.

In 82576, according to the manual, SRRCTL bit 31 is 0b for queue 0 by 
default, and is 1b for all other queues by default.

I hope this helps explain what the hardware is doing, and how these two 
counters get used in overrun cases.

Cheers,
-PJ Waskiewicz

------------------------------------------------------------------------------
The NEW KODAK i700 Series Scanners deliver under ANY circumstances! Your
production scanning environment may not be a perfect world - but thanks to
Kodak, there's a perfect scanner to get the job done! With the NEW KODAK i700
Series Scanner you'll get full speed at 300 dpi even with all image 
processing features enabled. http://p.sf.net/sfu/kodak-com
