From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100
	rx: or s and el bits)
Date: Thu, 24 May 2007 00:26:06 -0500
Message-ID: <039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net>
	<46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com>
	<463BA906.30205@roinet.com>
	<85f07fc58d5ed2147d5214d0f0b4fe32@bga.com>
	<4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com>
	<464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com>
	<464DB619.3070900@roinet.com> <464DC676.90504@intel.com>
	<464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com>
	<464DDE3E.9010400@roinet.com>
	<e3819b7a866b1117fd5a69e6a85e0784@bga.com>
	<4651DAC1.7050604@intel.com>
	<53c44b6f03973eb1b28f221859d3002c@bga.com>
	<465369AF.8080508@roinet.com>
	<f83441453b1233771c5bda869912aeca@bga.com>
	<4654B2E4.9010308@roinet.com>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: David Acker <dacker@roinet.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4654B2E4.9010308@roinet.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On May 23, 2007, at 4:32 PM, David Acker wrote:
> Milton Miller wrote:
>> My current reading of the manual is that the C bit will not be
>> set on an RFD that is size 0.  It goes on to processes EL and
>> S, and decides to stop and interrupt RNR or suspend, or just
>> go to the next packet.
> I double checked this with a quick experiment and it appears you are 
> correct.
>
> What about if we always did the following:
> set the size:
> sync();
> clear el-bit
> sync()
>
> Then if the hardware sees just the size set, the packet completes but 
> with the el-bit and we know we need to restart since it completed.
> If it sees the size == 0, and the el bit set, it stops and RNR 
> interrupts.

I think this is exposed to a hole and a race:  we don't know if the 
hardware
read the RFD before we set the size or after, just that it was before 
the EL
bit was cleared.  If it read it before the size was set, then it will 
not
set the C bit.  If it reads it after the size is set, it will complete 
it.

For coherent DMA we can always observe the C bit.  But for the 
incoherent DMA
case, our store to clear the EL bit may overwrite the dma from the 
device to
the beginning of the packet, or the write to EOF, F, and size, and/or 
the
write to C, OK, and status bits to tell us its done.  In the worst 
case, we
would overwrite the beginning of the data but catch the C bit and even 
the
actual size, and therefore would receive corrupted data.

We can only detect the hardware went RNR when it does so or decide we 
won the
race when it receives and completes the next frame.

> When we find a buffer that is not completed but has the el-bit set, we 
> read the status byte of the status control block to see if the RU is 
> in the no resources state.  If it isn't, it means that we found that 
> buffer  before the hardware did and thus need to wait for it.  We will 
> either find it on the next poll or enable interrupts and get told 
> about it by hardware.
>
> What do you think?

I think the second part is good ...

Ok here's my just-before-dinner brainstorming, as relayed after dinner:

We add two flags to struct rx:  one says this packet is EL, and one says
it is or was size 0.   We create a function, find_mark_el(struct nic,
is_running) that is called after initial alloc and/or after refilling
skb list.   In find_mark_el, we start with rx_to_use (lets rename this
rx_to_fill), and go back two entries, call this rx_to_mark.   If
is_running and rx_to_mark->prev->el then just return, leave EL alone.
Otherwise, set EL and size to 0, set the two flags in the rx struct,
sync the RFD, then search for the current EL (we could save the pointer,
but its always the odl rx_to_use (fill) or its ->prev).  Clear RFD->EL,
sync,  clear rx->el.  Set size non-zero, sync,  Leave the was_0 flag set
if is_running (clear it only if we know reciever is stopped).

At this point, if the receiver was stopped we can restart it,.  We
should do so in the caller.  (We always restart at rx_to_clean).
Restart should ack the RNR status before issuing the ru_start command to
avoid a spurious RNR interrupt.

In the receive loop, if RFD->C is not set, rx->was_0 is set and el
is not set, then we need to check rx->next->RFD->C bit (after
pci_sync_for_cpu).   If the next packet C bit is set then we consider
this skb as used, and just complete it with no data to the stack.

Because find_mark_el will only advance EL if the receiver was stopped
or we had more than 1 packet added, we can guarantee that if packet
N has was_0 set, then packet N+1 will not have it set, so we have
bounded lookahead.

This adds two flags to struct rx, but that is allocated as a single
array and the array size is filled out as forward and back pointers.
Rx clean only has to look at was_0 on the last packet when it
decides C is not set, and only if both are set does it peek at the
next packet.  In other words, we shouldn't worry about the added
flags making it a non-power-of-2 size.

By setting size != 0 after we have modified all other fields, the
device will only write to this packet if we are done writing.  If
we loose the race and only partially complete, it will just go on
to the next packet and we find it.  If we totally loose, then the
receiver will go RNR and we can reclaim all the buffer space we
have allocated.

Comments?  Questions?

We need to enforce a minimum rx ring size (3? 4?).

We rely on other mechanisms to guarantee the RFD in this skb
will not cache line conflict with the data in antoher scb
(slab allocs of the skb should give us this).

milton


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
