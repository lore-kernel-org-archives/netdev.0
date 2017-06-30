From: "Baxter, Jim" <jim_baxter@mentor.com>
Subject: Re: [PATCH V2 1/1] net: cdc_ncm: Reduce memory use when kernel memory
 low
Date: Fri, 30 Jun 2017 18:53:56 +0100
Message-ID: <356bdf94-813d-94ef-4dc3-a582fe5b3343@mentor.com>
References: <1498682129-9129-1-git-send-email-jim_baxter@mentor.com>
 <1498682129-9129-2-git-send-email-jim_baxter@mentor.com>
 <87bmp5s7dx.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Oliver Neukum <oliver@neukum.org>,
        David Laight <David.Laight@ACULAB.COM>
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87bmp5s7dx.fsf@miraculix.mork.no>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Jim Baxter <jim_baxter@mentor.com> writes:
> 
>> The CDC-NCM driver can require large amounts of memory to create
>> skb's and this can be a problem when the memory becomes fragmented.
>>
>> This especially affects embedded systems that have constrained
>> resources but wish to maximise the throughput of CDC-NCM with 16KiB
>> NTB's.
>>
>> The issue is after running for a while the kernel memory can become
>> fragmented and it needs compacting.
>> If the NTB allocation is needed before the memory has been compacted
>> the atomic allocation can fail which can cause increased latency,
>> large re-transmissions or disconnections depending upon the data
>> being transmitted at the time.
>> This situation occurs for less than a second until the kernel has
>> compacted the memory but the failed devices can take a lot longer to
>> recover from the failed TX packets.
>>
>> To ease this temporary situation I modified the CDC-NCM TX path to
>> temporarily switch into a reduced memory mode which allocates an NTB
>> that will fit into a USB_CDC_NCM_NTB_MIN_OUT_SIZE (default 2048 Bytes)
>> sized memory block and only transmit NTB's with a single network frame
>> until the memory situation is resolved.
>> Each time this issue occurs we wait for an increasing number of
>> reduced size allocations before requesting a full size one to not
>> put additional pressure on a low memory system.
>>
>> Once the memory is compacted the CDC-NCM data can resume transmitting
>> at the normal tx_max rate once again.
>>
>> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
> 
> This looks good to me.
> 
> I would still be happier if we didn't need something like this, but I
> understand that we do.  And this patch looks as clean as it can get.  I
> haven't tested the patch under any sort of memory pressure, but I did a
> basic runtime test on a single MBIM device.  As expected, I did not
> notice any changes with this patch applied.
> 
> But regarding noticable effects: The patch adds no printks, counters or
> sysfs attributes which could tell the user that the initial buffer
> allocation has failed.  Maybe add some sort of debug helper(s) in a
> followup patch? How did you verify the patch operation while testing it?
> 
> Anyway, that's no show stopper of course.  So FWIW:
> 
> Reviewed-by: Bjørn Mork <bjorn@mork.no>
> 

Hello Bjørn,

I tested this with printk's to show when the low memory code was triggered
and the value of ctx->tx_low_mem_val and ctx->tx_low_mem_max_cnt.
I created a workqueue that slowly used up the atomic memory until the
code is triggered.

I could add debug prints, though I have noticed that cdc_ncm_fill_tx_frame()
does not currently have any debug prints do you think this is because it can be
called in an atomic context and I think debug messages if enabled could cause
too great a delay?

Regards,
Jim
