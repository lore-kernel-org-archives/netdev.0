From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and el bits)
Date: Mon, 21 May 2007 12:35:43 -0500
Message-ID: <e3819b7a866b1117fd5a69e6a85e0784@bga.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com> <464DDE3E.9010400@roinet.com>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Scott Feldman <sfeldma@pobox.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, "Kok, Auke" <auke-jan.h.kok@intel.com>
To: David Acker <dacker@roinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mercury.realtime.net ([205.238.132.86]:49906 "EHLO
	ruth.realtime.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755107AbXEURgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 13:36:50 -0400
In-Reply-To: <464DDE3E.9010400@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 18, 2007, at 12:11 PM, David Acker wrote:

> Kok, Auke wrote:
>> First impression just came in: It seems RX performance is dropped to 
>> 10mbit. TX is unaffected and runs at 94mbit/tcp, but RX the new code 
>> seems to misbehave and  fluctuate, dropping below 10mbit after a few 
>> netperf runs and staying there...
>> ideas?
>
> I found the problem.  Another casualty of working with two different 
> kernels at once...arg.
> The blank rfd needs to have its el-bit clear now.  Here is the new and 
> improved patch.
>
> On the ARM, their is a race condition between software allocating a 
> new receive
> buffer and hardware writing into a buffer.  The two race on touching 
> the last
> Receive Frame Descriptor (RFD).  It has its el-bit set and its next 
> link equal
> to 0.  When hardware encounters this buffer it attempts to write data 
> to it
> and then update Status Word bits and Actual Count in the RFD.  At the 
> same time
> software may try to clear the el-bit and set the link address to a new 
> buffer.
> Since the entire RFD is once cache-line, the two write operations can
> collide.  This can lead to the receive unit stalling or freed receive 
> buffers
> getting written to.
>
> The fix is to set the el-bit on and the size to 0 on the next to last 
> buffer
> in the chain.  When the hardware encounters this buffer it stops and 
> does
> not write to it at all.  The hardware issues an RNR interrupt with the
> receive unit in the No Resources state.  When software allocates 
> buffers,
> it can update the tail of the list because it knows the hardware will 
> stop
> at the buffer before it.  Once it has a new next to last buffer 
> prepared,
> it can clear the el-bit and set the size on the previous one.  The 
> race on
> this buffer is safe since the link already points to a valid next 
> buffer.
> If the hardware sees the el-bit cleared without the size set, it will
> move on to the next buffer and complete that one in error.  If it sees
> the size set but the el-bit still set, it will complete that buffer
> and then RNR interrupt and wait.
>
>
> Signed-off-by: David Acker <dacker@roinet.com>
>


This patch doesn't apply.  It appears white space damaged somewhere:

(1) blank lines in diff are empty not <space>
(2) unchanged lines starting with tab are <space><space><tab>

After fixing the above I still get:

patching file drivers/net/e100.c
Hunk #1 FAILED at 285.
Hunk #4 FAILED at 1749.
Hunk #8 FAILED at 1865.
Hunk #10 succeeded at 1965 with fuzz 1.
Hunk #11 succeeded at 1982 with fuzz 1.
3 out of 14 hunks FAILED -- saving rejects to file 
drivers/net/e100.c.rej

although I haven't figured out what is wrong.

Proceeding with the review:

Coding style:
(1) if body on seperate line.
(2) space after if before (
(3) The other enums in this driver are not ALL_CAPS
(4) This driver doesn't do CONSTANT != value but value != enum
     (see nic->mac for examples)

I don't understand why the old logic in start_receiver doesn't work.
When would the rx passed not be rx_to_clean ?

The driver sets EL (end-of-list) to stop the receiver.  I was trying
to determine if this is the right decision or we should use suspend
bit.  I think the EL is the right choice because it will count
discarded frames while the card waits to be refilled, it is not
obvious that those counters count in the suspended state.  Also,
we want to use the RU_START not RU_RESUME so that it reads the
RFD again with the size (as opposed to just the S bit)

However, we should not call this state RU_SUSPENDED because
that is a different state in the hw.

I also see that the driver sets the size from 0 back to frame
size.  While there is a wmb() between the removal of EL and the
restore of the frame size, there is only one pci_sync for both
of them.  Since the size is in a separate word, depending on skb
alignment it may be in a different cache line and we may end up
with all orderings being visible to the device.

This patch adds a lot of code that checks if the next RFD has
EL set and assumes that if it sees the next frame to clean has
EL set then the device will have seen it and entered the stopped
state.   In theory, the device might be held off on the PCI bus
and not have yet read the descriptor and stopped.   In addition,
while it anticipates the RNR interrupt and restarts the receiver
from the clean process, it doesn't clear the pending interrupt
and the cpu will still take the interrupt, although it will read
the status and not actually restart the RU.

It would seem simpler to me to just check the device status on
the way out after refilling and restoring the descriptor.  If
the device has stopped, rx_to_clean will still point to the
no-longer-size-0 not EL buffer and will be the correct restart
place.

Also, I think this exposes us to a window with coherent hardware
where the device will see EL cleared but size 0 and will skip
completing the frame but continue on to the next RFD.  The driver
will then issue a start command while the RU is active, which is
prohibited.

This window also means that the device may have skipped this
previously 0-length descriptor and gone on to the next one,
so we will stick waiting for the device to write to this
descriptor while it went on to the next one.

The description of how we use the EL bit and size 0 should go
in the big comment at the top describing the operation of the
driver.  Also, the description of size 0 should be separated
from the description of EL being set, as those are independent.


milton

