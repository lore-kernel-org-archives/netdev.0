From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH V2 1/1] net: cdc_ncm: Reduce memory use when kernel memory low
Date: Fri, 30 Jun 2017 19:38:34 +0200
Message-ID: <87bmp5s7dx.fsf@miraculix.mork.no>
References: <1498682129-9129-1-git-send-email-jim_baxter@mentor.com>
        <1498682129-9129-2-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Oliver Neukum <oliver@neukum.org>,
        David Laight <David.Laight@ACULAB.COM>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498682129-9129-2-git-send-email-jim_baxter@mentor.com> (Jim
        Baxter's message of "Wed, 28 Jun 2017 21:35:29 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jim Baxter <jim_baxter@mentor.com> writes:

> The CDC-NCM driver can require large amounts of memory to create
> skb's and this can be a problem when the memory becomes fragmented.
>
> This especially affects embedded systems that have constrained
> resources but wish to maximise the throughput of CDC-NCM with 16KiB
> NTB's.
>
> The issue is after running for a while the kernel memory can become
> fragmented and it needs compacting.
> If the NTB allocation is needed before the memory has been compacted
> the atomic allocation can fail which can cause increased latency,
> large re-transmissions or disconnections depending upon the data
> being transmitted at the time.
> This situation occurs for less than a second until the kernel has
> compacted the memory but the failed devices can take a lot longer to
> recover from the failed TX packets.
>
> To ease this temporary situation I modified the CDC-NCM TX path to
> temporarily switch into a reduced memory mode which allocates an NTB
> that will fit into a USB_CDC_NCM_NTB_MIN_OUT_SIZE (default 2048 Bytes)
> sized memory block and only transmit NTB's with a single network frame
> until the memory situation is resolved.
> Each time this issue occurs we wait for an increasing number of
> reduced size allocations before requesting a full size one to not
> put additional pressure on a low memory system.
>
> Once the memory is compacted the CDC-NCM data can resume transmitting
> at the normal tx_max rate once again.
>
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>

This looks good to me.

I would still be happier if we didn't need something like this, but I
understand that we do.  And this patch looks as clean as it can get.  I
haven't tested the patch under any sort of memory pressure, but I did a
basic runtime test on a single MBIM device.  As expected, I did not
notice any changes with this patch applied.

But regarding noticable effects: The patch adds no printks, counters or
sysfs attributes which could tell the user that the initial buffer
allocation has failed.  Maybe add some sort of debug helper(s) in a
followup patch? How did you verify the patch operation while testing it?

Anyway, that's no show stopper of course.  So FWIW:

Reviewed-by: Bj=C3=B8rn Mork <bjorn@mork.no>
