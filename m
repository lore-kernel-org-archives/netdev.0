From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] firewire: net: rate-limit log spam at transmit failure
Date: Sun, 07 Nov 2010 12:10:29 +0100
Message-ID: <4CD68925.8080302@s5r6.in-berlin.de>
References: <tkrat.01ca17fba0508ae0@s5r6.in-berlin.de>	
	<tkrat.1b9925fa1d199c23@s5r6.in-berlin.de>	
	<tkrat.18b9f67ac78dcbea@s5r6.in-berlin.de>	
	<tkrat.276aeae22ec60090@s5r6.in-berlin.de>
	<1289100404.3277.28.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux1394-devel@lists.sourceforge.net
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1289100404.3277.28.camel@maxim-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Maxim Levitsky wrote:
> On Sun, 2010-11-07 at 00:23 +0100, Stefan Richter wrote:
>> On  6 Nov, Stefan Richter wrote:
>>> Then I tried an XIO2213A card in the AMD PC (again the Intel PC as peer)
>>> and got 243 times "failed: 12" i.e. RCODE_BUSY and 81 times "failed: 10"
>>> i.e. RCODE_SEND_ERROR during ftp transfer of a >500 MB large file from
>>> XIO2213A to FW323.
> 
> I also am getting strange results (but very good compared to what I had
> recently).
> 
> With all your patches, I get very stable TCP and UDP streams from laptop
> to desktop at 180~190 Mbits/s.
> 
> However, the opposite direction (desktop->laptop) still suffers from
> tlabel exhaustion.
> I added some printks, and I see, clearly that netif_stop_queue doesn't
> always work (probably this is intended?).
> 
> If I replace == with >= in inc_queue_packets and similar in
> dec_queued_packets, then tlabel exhaustion disappears, and I get ~240
> Mbit/s on TCP and UDP.

Remind me, is this FireWire 800?  And what controllers in particular?  I get
about half of your numbers with FireWire 400 connections.

The == vs. >= is a good hint.  If .ndo_start_xmit can be entered by multiple
CPUs, the upper limit will clearly exceeded eventually.

With >= instead of ==, the same test as that quoted above gives 71x RCODE_BUSY
+ 0x RCODE_SEND_ERROR, and 59x RCODE_BUSY + 0x RCODE_SEND_ERROR in a
repetition.  (0x + 0x in the other direction.)  There were no RCODE_CANCELLED
occurrences, which I had occasionally in the past.

I then tried

	if (dev->queued_packets >= FWNET_MAX_QUEUED_PACKETS)
		return NETDEV_TX_BUSY;

at the top of fwnet_tx but it did not change the amount of RCODE_BUSY, which
is not too surprising.  So next I should have a look at the responder side again.

BTW, FireWire 400 CardBus controllers usually feature a limitation of max_rec
= 1024 (maximum size of asynchronous packets they can receive).  Incidentally,
the VT6306 card that I used in my other tests from yesterday is one of those.
So, since link fragmentation is quite common due to this kind of cards, I
should perhaps count queued fragments instead of queued datagrams.

> UDP transfers work quite well, tested for few minutes.
> TCP transfers unfortunelly trigger (probably a hardware) bug in notebook
> OHCI controller (I have seen that meny times so far.)
> 
> Transfer just stops, and controller goes south.
> If I unload the firewire-ohci, then when I load it:
> 
> [ 2062.632532] firewire_ohci 0000:07:00.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
> [ 2072.650173] firewire_ohci: Failed to reset ohci card.
> [ 2072.650267] firewire_ohci 0000:07:00.0: PCI INT A disabled
> [ 2072.650314] firewire_ohci: probe of 0000:07:00.0 failed with error -16
> 
> 
> Only suspend to ram helps bring it back from that state.

On the bright side, s2ram fixes things for once instead of breaking them...
-- 
Stefan Richter
-=====-==-=- =-== --===
http://arcgraph.de/sr/

------------------------------------------------------------------------------
The Next 800 Companies to Lead America's Growth: New Video Whitepaper
David G. Thomson, author of the best-selling book "Blueprint to a 
Billion" shares his insights and actions to help propel your 
business during the next growth cycle. Listen Now!
http://p.sf.net/sfu/SAP-dev2dev
