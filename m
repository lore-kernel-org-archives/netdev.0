From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 13:34:08 -0500
Message-ID: <c3ca9e10-64de-2454-b99a-19e8302f5c12@pobox.com>
References: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
 <20161124.121140.2054576632424977475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
        nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
        linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161124.121140.2054576632424977475.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-24 12:11 PM, David Miller wrote:
> From: Mark Lord <mlord@pobox.com>
> Date: Thu, 24 Nov 2016 11:43:53 -0500
> 
>> So even if this were a platform memory coherency issue, one should
>> still never see ASCII data at the beginning of an rx buffer.
> 
> I'm not so convinced, since this is the kind of random corruption one
> would expect to see when dealing with virtual caches that have
> aliasing or similar issues.
> 
> Writes to address X that show up at address Y or not at all are
> precisely the signature of virtual cache aliasing problems.
> 
> Is it a case of the chip writing to X but the cpu is still seeing
> stale data from a previous CPU store?
> 
> For NFS the cpu is writing into the page cache, so we know that
> cpu side stores are where the ASCII text is coming from.
> 
> Now is the r8152 buffer one that the USB host controller is DMA'ing
> into directly, or is it one that SWIOMMU or similar bounce buffering
> is copying into?  In the latter case we are doing cpu stores into
> the area and the writes aren't coming from the device.

>From tracing through the powerpc arch code, this is the buffer that
is being directly DMA'd into.  And the USB layer does an invalidate_dcache
on that entire buffer before initiating the DMA (confirmed via printk).

The driver itself NEVER writes anything to that buffer,
and nobody else has a pointer to it other than the USB host controller,
so there's nothing else that can write to it either.

According to the driver writer, the chip should only ever write a fresh
rx_desc struct at the beginning of a buffer, never ASCII data.

So how does that buffer end up containing ASCII data from the NFS transfers?

The only explanation I can see, is if the URB itself contains
the data that we see in the URB buffer.  Which is what one would expect.
So for that to happen, the ethernet chip must be transferring that data.

The thing that is special about the situation here, is that the processor
is very slow (800Mhz 32-bit powerpc), and very busy elsewhere.
So it can easily fall way behind in servicing the ethernet dongle,
something that never happens with most modern faster machines.
So perhaps this results in a FIFO overflow somewhere in the chip.

We can boot/run this same machine from a USB memory stick, and nary a problem.
Ditto for other types of ethernet dongles.
But boot/run from that specific ethernet dongle, and we get regular
random segfaults from corrupted page fetches over NFS.

The only end-to-end data integrity available here is the rx checksum,
when verified by software rather than trusting it to the chip/driver.

One thought:  bulk data streams are byte streams, not packets.
Scheduling on the USB bus can break up larger transfers across
multiple in-kernel buffers.  A "real" URB buffer on USB2 is max 512 bytes.
The driver is providing 16384-byte buffers, and assumes that data will
never spill over from one such buffer to the next.
Yet the observations here consistently show otherwise.

Cheers
-- 
Mark Lord
