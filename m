From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 2/2] r8152: rx descriptor check
Date: Sun, 13 Nov 2016 15:34:05 -0500
Message-ID: <cd36fce8-2f17-debd-d514-e3cbe7ed3762@pobox.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-228-Taiwan-albertk@realtek.com>
 <20161113.123954.2134945576362221851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>, hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161113.123954.2134945576362221851.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-13 12:39 PM, David Miller wrote:
> From: Hayes Wang <hayeswang@realtek.com>
> Date: Fri, 11 Nov 2016 15:15:41 +0800
> 
>> For some platforms, the data in memory is not the same with the one
>> from the device. That is, the data of memory is unbelievable. The
>> check is used to find out this situation.
>>
>> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> 
> I'm all for adding consistency checks, but I disagree with proceeding
> in this manner for this.
> 
> If you add this patch now, there is a much smaller likelyhood that you
> will work with a high priority to figure out _why_ this is happening.
> 
> For all we know this could be a platform bug in the DMA API for the
> systems in question.
> 
> It could also be a bug elsewhere in the driver, either in setting up
> the descriptor DMA mappings or how the chip is programmed.
> 
> Either way the true cause must be found before we start throwing
> changes like this into the driver.

I agree.

The system I use it with is a 32-bit ppc476, with non-coherent RAM,
and using 16KB page sizes.

The dongle instantly becomes a lot more reliable when r8152.c is updated
to use usb_alloc_coherent() for URB buffers, rather than kmalloc().

Not sure why that would be though, as the USB stack normally would handle
kmalloc'd buffers just fine.  It is calling the appropriate routines,
which boil down to invalidating the dcache lines (for inbound bulk xfers)
as part of usb_submit_urb(), and yet the problem there persists.

It could be caused by cache-line sharing with other allocations, but that seems
unlikely as the kmalloc() size is 16384 bytes per buffer.  Perhaps the driver
is somehow accessing the buffer space again after doing usb_submit_urb()?
That would certainly produce this kind of behaviour.

Or maybe there's just a memory barrier missing somewhere in path.

The really weird thing is that ASIX-based dongles (which use a different driver)
don't have this problem, and yet they also use kmalloc'd buffers.

I have access to the test system only for a day or two a week,
and it takes a few hours to do a good test as to whether something helps or not.
I'll continue to poke at it as time and New Ideas permit.

New Ideas welcome!
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
