From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH] igb: Record hardware RX overruns in
	net_stats
Date: Wed, 06 May 2009 15:09:11 +0200
Message-ID: <1241615351.5172.60.camel@localhost.localdomain>
References: <20090505.115819.84151021.davem@davemloft.net>
	<Pine.LNX.4.64.0905052249110.1294@ask.diku.dk>
	<9929d2390905051432h795d183bh40fbe1beb35a4de9@mail.gmail.com>
	<20090505.143529.148721206.davem@davemloft.net>
	<1241595993.5172.4.camel@localhost.localdomain>
	<Pine.WNT.4.64.0905060048570.22956@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "hawk@diku.dk" <hawk@diku.dk>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <Pine.WNT.4.64.0905060048570.22956@ppwaskie-MOBL2.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2009-05-06 at 01:11 -0700, Waskiewicz Jr, Peter P wrote:
> On Wed, 6 May 2009, Jesper Dangaard Brouer wrote:
> 
> > On Tue, 2009-05-05 at 14:35 -0700, David Miller wrote:
> > > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > Date: Tue, 5 May 2009 14:32:04 -0700
> > > 
> > > > the manual[1] for the hardware says:
> > > > RNBC:
> > > > This register counts the number of times that frames were received
> > > > when there were no available buffers in host memory to store those
> > > > frames (receive descriptor head and tail pointers were equal). The
> > > > packet is still received if there is space in the FIFO. This register
> > > > only increments if receives are enabled. This register does not
> > > > increment when flow control packets are received.
> > > > 
> > > > The critical bit "The packet is still received if there is space in
> > > > the FIFO" (AND a host memory buffer becomes available) So the reason
> > > > we don't want to put it in the net_stats stats for drops is that the
> > > > packet
> > > > *wasn't* necessarily dropped.
> > > > 
> > > > The rx_missed errors is for packets that were definitely dropped, and
> > > > is already stored in the net_stats structure.
> > > 
> > > While not an "rx_missed" because we do eventually take the
> > > packet, conceptually it is a "fifo overflow" in the sense
> > > that we exceeded available receive resources at the time that
> > > the packet arrived.
> > 
> > Yes, with this argumentation, the MPC should then be kept as "rx_missed"
> > packets.  And the RNBC stored as "rx_fifo_errors" as its an overflow
> > indication, not a number of packets dropped.
> 
> The way RNBC works depends on how the queues themselves are configured.  
> Specifically, if you have packet drop enabled per queue or not will affect 
> RNBC.

Very good description, thank you Peter.
But I could not resist to actually verify/test it, and my observations
differ some! ;-)  (patch in bottom indicate where I set it in the code)

> In the SRRCTL registers, there is a DROP_EN bit, bit 31.  If this 
> bit is set to 1b for the queue in question, then the packet will be 
> dropped when there are no buffers in the packet buffer.  This does not 
> mean the FIFO is full or has been overrun, it just means there's no more
> descriptors available in the Rx ring for that queue.  In this case, RNBC 
> is incremented, MPC is not.

My experience is that if DROP_EN bit is *set*. Then I cannot find the
drop count anywhere... not in RNBC and not in MPC ... and I can still
see the drops with my netfilter module mp2t.

ethtool -S eth21 | egrep 'rx_no_buffer_count|rx_miss'
     rx_no_buffer_count: 0
     rx_missed_errors: 0

I'm guessing that the drop counters are now in the per queue RQDPC
register (Receive Queue Drop Packet Count), but reading that is not
implemented in the driver.

(kernel: [438792.665028] Hawk hack -- Register: srrctl:[0x82000002])

> If bit 31 in SRRCTL is 0b, then if there's no room in the packet buffer
> (no more descriptors available), the device tries to store the packet in
> the FIFO.  RNBC will *not* be incremented in this case.  If there's no space
> in the FIFO, then the packet is dropped.  RNBC still is not incremented in this
> case, rather MPC will be incremented, since the packet was dropped due to the FIFO 
> being full.

My experience is that if DROP_EN bit is *NOT* set. Then the RNBC *is*
incremented...

 ethtool -S eth21 | egrep 'rx_no_buffer_count|rx_miss'
     rx_no_buffer_count: 26436
     rx_missed_errors: 0

(kernel: [439261.463628] Hawk hack -- Register: srrctl:[0x2000002])


> In 82576, according to the manual, SRRCTL bit 31 is 0b for queue 0 by 
> default, and is 1b for all other queues by default.

Funny default...

> I hope this helps explain what the hardware is doing, and how these two 
> counters get used in overrun cases.

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


Testing the SRRCTL_DROP_EN bit behavior.

From: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/igb/igb_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)


diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3ee00a5..20117ce 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -49,7 +49,7 @@
 #endif
 #include "igb.h"
 
-#define DRV_VERSION "1.3.16-k2"
+#define DRV_VERSION "1.3.16-k2-test-drop-bit"
 char igb_driver_name[] = "igb";
 char igb_driver_version[] = DRV_VERSION;
 static const char igb_driver_string[] =
@@ -2091,6 +2091,11 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 		wr32(E1000_VMOLR(j), vmolr);
 	}
 
+	/* Hawk: Hack to test the SRRCTL_DROP_EN bit behavior */
+	srrctl &= ~E1000_SRRCTL_DROP_EN; /* Unset bit */
+	//srrctl |= E1000_SRRCTL_DROP_EN; /* Set bit */
+	printk(KERN_INFO "Hawk hack -- Register: srrctl:[0x%X]\n", srrctl);
+
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		j = adapter->rx_ring[i].reg_idx;
 		wr32(E1000_SRRCTL(j), srrctl);



------------------------------------------------------------------------------
The NEW KODAK i700 Series Scanners deliver under ANY circumstances! Your
production scanning environment may not be a perfect world - but thanks to
Kodak, there's a perfect scanner to get the job done! With the NEW KODAK i700
Series Scanner you'll get full speed at 300 dpi even with all image 
processing features enabled. http://p.sf.net/sfu/kodak-com
