From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [PATCH update 2] firewire: net: throttle TX queue before
	running out of tlabels
Date: Sun, 14 Nov 2010 06:50:28 +0200
Message-ID: <1289710228.8581.16.camel@maxim-laptop>
References: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
	<tkrat.39c164e4c52e2fc8@s5r6.in-berlin.de>
	<tkrat.eaac597cf54bb660@s5r6.in-berlin.de>
	<tkrat.83117f4523f0d928@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <tkrat.83117f4523f0d928@s5r6.in-berlin.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sat, 2010-11-13 at 23:07 +0100, Stefan Richter wrote:
> This prevents firewire-net from submitting write requests in fast
> succession until failure due to all 64 transaction labels were used up
> for unfinished split transactions.  The netif_stop/wake_queue API is
> used for this purpose.
> 
> Without this stop/wake mechanism, datagrams were simply lost whenever
> the tlabel pool was exhausted.  Plus, tlabel exhaustion by firewire-net
> also prevented other unrelated outbound transactions to be initiated.
> 
> The high watermark is set to considerably less than 64 (I chose 8)
> because peers which run current Linux firewire-ohci are still easily
> saturated by this (i.e. some datagrams are dropped with ack-busy-*
> events), depending on the hardware at transmitter and receiver side.
> 
> I did not see changes to resulting throughput that were discernible from
> the usual measuring noise.  To do:  Revisit the choice of queue depth
> once firewire-ohci's AR DMA was improved.
> 
> I wonder what a good net_device.tx_queue_len value is.  I just set it
> to the same value as the chosen watermark for now.
> 
> Note:  This removes some netif_wake_queue from reception code paths.
> They were apparently copy&paste artefacts from a nonsensical
> netif_wake_queue use in the older eth1394 driver.  This belongs only
> into the transmit path.
> 
> Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
> ---
> Update 2:  Maxim told me to de-obfuscate status tracking.  I realized
> that netif_queue_stopped can be used for that and thereby noticed bogus
> usages of it in the rx path.

In fact after lot of testing I see that original patch, 
'[PATCH 4/4] firewire: net: throttle TX queue before running out of
tlabels' works the best here.
With AR fixes, I don't see even a single fwnet_write_complete error on
ether side.

However the 'update 2' (maybe update 1 too, didn't test), lowers
desktop->laptop throughput somewhat.
(250 vs 227 Mbits/s). I tested this many times.

Actuall raw troughput possible with UDP stream and ether no throttling
or higher packets in flight count (I tested 50/30), it 280 Mbits/s.

BTW, I still don't understand fully  why my laptop sends only at 180
Mbits/s pretty much always regardless of patches or TCP/UDP.

I also tested performance impact of other patches, and it is too small
to see through the noise.

Not bad, ah? From complete trainwreck, the IP over 1394, turned out into
very stable and fast connection that beats 100 Mbit ethernet a bit.

Now next on my list a POC (Piece of cake) items.

I need to figure out why s2ram hoses the network connection.
In fact usually, firewire-ohci does work, and reload of firewire-net
restores the connection.

Also, I need to add all required bits to make firewire-net work with NM.

I need to make resets more robust. Currently after cable plug it takes
some time until connection starts working.

So thanks again, especially to Clemens Ladisch for the hardest fixes
that made all this possible.

And of course feel free to not merge my AR rewrite, it is mostly done
as a prof of concept to see if my hardware is buggy or not.
I am sure these patches can be done better.

Best regards,
	Maxim Levitsky


------------------------------------------------------------------------------
Centralized Desktop Delivery: Dell and VMware Reference Architecture
Simplifying enterprise desktop deployment and management using
Dell EqualLogic storage and VMware View: A highly scalable, end-to-end
client virtualization framework. Read more!
http://p.sf.net/sfu/dell-eql-dev2dev
