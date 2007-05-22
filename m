From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and
 el bits)
Date: Tue, 22 May 2007 18:07:43 -0400
Message-ID: <465369AF.8080508@roinet.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com> <464DDE3E.9010400@roinet.com> <e3819b7a866b1117fd5a69e6a85e0784@bga.com> <4651DAC1.7050604@intel.com> <53c44b6f03973eb1b28f221859d3002c@bga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Scott Feldman <sfeldma@pobox.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Milton Miller <miltonm@bga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:33044
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757749AbXEVWGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 18:06:42 -0400
In-Reply-To: <53c44b6f03973eb1b28f221859d3002c@bga.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Milton Miller wrote:
>>> Proceeding with the review:
>>> Coding style:
>>> (1) if body on seperate line.
>>> (2) space after if before (
>>> (3) The other enums in this driver are not ALL_CAPS
>>> (4) This driver doesn't do CONSTANT != value but value != enum
>>>      (see nic->mac for examples)
>>
>> I sent Milton my copy of this patch which has these style issues 
>> corrected and
>> applies cleanly to a recent git tree. If anyone else specifically 
>> wants a copy
>> let me know.
>>
>> Auke
> 
> It addressed 1 and 2, and applies, but did not address 3 and 4.
> 

Sorry about the style bugs.  I will be more careful about that next time.

Many of the issues you bring have been in the e100 for some time.  If 
you ignore the s-bit patch, I basically did the the following:
moved the el-bit to before the last buffer so that the last buffer was 
protected during chaining.
set the el-bit buffer (next-to-last) size to 0 so that it is not written 
to while we are writing to it.

This seemed the only way to protect the buffers we are changing while 
having code to stay ahead of the hardware.

(3) The driver had these all caps constants before my patch.  They went 
away with the s-bit patch.  I just put them back.  I agree they stick 
out but I wanted to leave style changes out of a bug fix patch.

I agree about the name of the constant, RU_SUSPENDED.  It is not 
accurate and I had a patch to fix this when I experimented with using 
the S-bit.

> 
> But the bigger point is it didn't address the holes I identified.

> I also see that the driver sets the size from 0 back to frame
> size.  While there is a wmb() between the removal of EL and the
> restore of the frame size, there is only one pci_sync for both
> of them.  Since the size is in a separate word, depending on skb
> alignment it may be in a different cache line and we may end up
> with all orderings being visible to the device. 
Hmmm...interesting.  The start of the data of the skb may not be aligned 
on a cache line.  Ok DMA experts...what happens when you sync across 
cache lines?  It should dump both of them, right?  I guess the orderings 
could vary...hence why I saw completions with size set but the el-bit 
still set.  So perhaps the skb alloc needs to be aligned by cache line? 
     This issue existed before my patches as well.


> This patch adds a lot of code that checks if the next RFD has
> EL set and assumes that if it sees the next frame to clean has
> EL set then the device will have seen it and entered the stopped
> state.   In theory, the device might be held off on the PCI bus
> and not have yet read the descriptor and stopped.   In addition,
> while it anticipates the RNR interrupt and restarts the receiver
> from the clean process, it doesn't clear the pending interrupt
> and the cpu will still take the interrupt, although it will read
> the status and not actually restart the RU. 
So the device is just before the el-bit buffer and stops.  We get a poll 
call with interrupts disabled and see the el-bit buffer and decide we 
need to restart.  First we alloc new buffers and move the el-bit/size 0 
down.  The restart occurs on the next poll (interrupts are not turned on 
if we did any work).  In theory, the hardware could have read the buffer 
that no longer has a size of 0 and tried to use it when we hit it with 
the start.  I am not sure how the hardware handles this.  Perhaps it is 
ignored and thus harmless.  We could poll the hardware to check before 
actually sending the start...it adds an extra pci operation but would 
avoid a command that is illegal in the manual.

If we ignore a buffer with the el-bit set but without the complete bit, 
we must wait for the hardware to RNR interrupt.  I have found that when 
a buffer has both the el-bit set and the size set to 0, it will not set 
the complete bit on that buffer.  This was part of the reason why my 
first patch had hardware just using the list of buffers given all the 
way up until the end.

> I think we need to change the logic to reclaim the size from 0
> only if we are restarting, and make rx_indicate look ahead to
> rx->next if it encounters a !EL size 0 buffer.  Without this we
> are doing a "prohibited" rx_start to a running machine.
The hardware is only restarted when we enter the RU_SUSPENDED state. 
This only happens when we:
1) get an RNR interrupt
2) get an EL-bit buffer without a completion
3) get an el-bit buffer with a completion (hardware saw size set but not 
el-bit clear)

State 2) seems to be the problem.  Get rid of that and we wait for an 
interrupt to tell us it saw the buffer in most cases.  Of course, then 
we always wait.

If we do not reclaim the size from 0, but clear the el-bit, that buffer 
will always return an error.

 > The
> device can still see this size 0 !EL state.  Also we will get
> stuck when the device finds the window between the two writes.

 > This window also means that the device may have skipped this
 > previously 0-length descriptor and gone on to the next one,
 > so we will stick waiting for the device to write to this
 > descriptor while it went on to the next one.
If the hardware sees both size 0 and EL, it RNR interrupts, does not 
write to the buffer at all and stops.

If the hardware sees size 0 and !EL, (which I never saw in testing but 
could happen) it would return the buffer with an error and continue. 
This is ok since we already have written a new size 0 and EL.  Our 
polling code would just find a packet completed in error.

If the hardware sees size set and EL, it RNR interrupts, and does write 
data and status to the buffer, and then stops.  I have see this one 
occur and it isn't a problem.

If hardware sees size set and !EL, it writes data and continues.


> We can remove some register pressure by finding old_before_last_rfd
> when we are ready to use it, just comparing old_before_last_rx
> to new.
Sure.

> 
> Also, as I pointed out, the rx_to_start change to start_reciever
> is compicated and unnecessary, as rx_to_clean can always be used
> and it was the starting point before the changes.
This was in the driver before my patch and the s-bit patch.  I agree 
that it could go away as rx_to_clean should not be capable of changing.

> 
> As far as the RU_SUSPENDED, I don't think we need it, instead
> we should poll the device.
RU_SUSPENDED is pretty much used as it was before all the patches. The 
only waste I found is that if we find the EL-bit while interrupts are 
disabled (say during a NAPI poll), we set RU_SUSPENDED and then have to 
wait for the next poll to figure out that we need to restart the receiver.

> 
> Here is my proposal:
> rx_indicate can stop when it hits the packet with EL.  If it
> hits a packet with size 0, look ahead to rx->next to see if
> it is complete, if so complete this one otherwise leave it
> as next to clean.  After the rx_indicate loop, try to allocate
> more skbs.  If we are successful, then fixup the before-next
> as we do now.  Then check the device status for RNR, and if
> its stopped then set rx_to_clean rfd size back to ETH_LEN
> and restart the reciever.
> 
> This does have a small hole: if we only add one packet at
> a time we will end up with all size 0 descriptors in the
> lopp.   We can detect that and not remove EL from the old
> before-next unless we are restarting.  That would imply
> moving the status poll before we allocate the list.
Can you send a patch or pseudo-code?  It would help to see some main parts:
1. blank_rfd setup
2. single buffer alloc
3. el-bit handling (when do we set it and when do we clear it)
4. size handling (when do we set it and when do we clear it)


What if we just fixed the alignment of rfd to make sure it is cache 
aligned?  Then we know our syncs will be a single cache flush.
-Ack
