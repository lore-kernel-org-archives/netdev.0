From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Meet alignment requirements for DMA
Date: Tue, 26 Sep 2017 10:34:00 -0700 (PDT)
Message-ID: <20170926.103400.1009342814128022820.davem@davemloft.net>
References: <1506078833-14002-1-git-send-email-matt.redfearn@imgtec.com>
        <20170922.182639.272534775457081015.davem@davemloft.net>
        <587dc9a8-b974-e222-95b4-93c2a8f2aba2@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com,
        peppe.cavallaro@st.com, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, paul.burton@imgtec.com,
        james.hogan@imgtec.com
To: matt.redfearn@imgtec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <587dc9a8-b974-e222-95b4-93c2a8f2aba2@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Redfearn <matt.redfearn@imgtec.com>
Date: Tue, 26 Sep 2017 14:57:39 +0100

> Since the MIPS architecture requires software cache management,
> performing a dma_map_single(TO_DEVICE) will writeback and invalidate
> the cachelines for the required region. To comply with (our
> interpretation of) the DMA API documentation, the MIPS implementation
> expects a cacheline aligned & sized buffer, so that it can writeback a
> set of complete cachelines. Indeed a recent patch
> (https://patchwork.linux-mips.org/patch/14624/) causes the MIPS dma
> mapping code to emit warnings if the buffer it is requested to sync is
> not cachline aligned. This driver, as is, fails this test and causes
> thousands of warnings to be emitted.

For a device write, if the device does what it is told and does not
access bytes outside of the periphery of the DMA mapping, nothing bad
can happen.

When the DMA buffer is mapped, the cpu side cachelines are flushed (even
ones which are partially part of the requsted mapping, this is _fine_).

The device writes into only the bytes it was given access to, which
starts at the DMA address.

The unmap and/or sync operation after the DMA transfer needs to do
nothing on the cpu side since the map operation flushed the cpu side
caches already.

When the cpu reads, it will pull the cacheline from main memory and
see what the device wrote.

It's not like the device can put "garbage" into the bytes earlier in
the cacheline it was given partial access to.

A device read is similar, the cpu cachelines are written out to main
memory at map time and the device sees what it needs to see.

I want to be shown a real example where corruption or bad data can
occur when the DMA API is used correctly.

Other platforms write "complete cachelines" in order to implement
the cpu and/or host controller parts of the DMA API implementation.
I see nothing special about MIPS at all.

If you're given a partial cache line, you align the addresses such
that you flush every cache line contained within the provided address
range.

I really don't see what the problem is and why MIPS needs special
handling.  You will have to give specific examples, step by step,
where things can go wrong before I will be able to consider your
changes.

Thanks.
