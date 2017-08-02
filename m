From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [RFC PATCH v2 0/2] nb8800 suspend/resume support
Date: Wed, 02 Aug 2017 16:36:14 +0100
Message-ID: <yw1xshhagexd.fsf@mansr.com>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
        <aa8885b8-e6bb-3624-2bf9-0bb40505ac54@free.fr>
        <dd883398-1511-0bfd-972b-a11ef8709f0d@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:35412 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751154AbdHBPgS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 11:36:18 -0400
In-Reply-To: <dd883398-1511-0bfd-972b-a11ef8709f0d@free.fr> (Mason's message
        of "Wed, 2 Aug 2017 17:26:21 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> On 02/08/2017 16:41, Mason wrote:
>
>> On 01/08/2017 18:32, Mason wrote:
>> 
>>> I need suspend/resume support in the nb8800 driver.
>>> On tango platforms, suspend loses all context (MMIO registers).
>>> To make the task easy, we just close the device on suspend,
>>> and open it again on resume. This requires properly resetting
>>> the HW on resume.
>>>
>>> Patch 1 moves all the HW init to nb8800_init()
>>> Patch 2 adds suspend/resume support
>> 
>> I have now confirmed that the "flow control" issue I reported
>> in another thread has nothing to do with flow control per se.
>> 
>> The problem is that nb8800_pause_config() calls nb8800_dma_stop()
>> and when it does, RX is borked.
>> 
>> On a GigE switch:
>> [   21.444268] ENTER nb8800_pause_config
>> [   21.448604] rxcr=06100a8f pause_rx=1 pause_tx=0 pause=1 asym_pause=1
>> [   21.455020] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
>> 
>> In this case, pause_tx and RCR_FL match, so we skip the
>> silly dance.
>
> The documentation states:
>
> Receive Channel Control Register
> Description:
> The Receive Channel Control Register holds channel enable, mode, endian,
> DMA control, and interrupt control information.  This register can only
> be written when the Receive DMA Channel is idle - the Enable bit in it is "0".
> Register Number:  0x200
> Access:  read/write
> Reset Value: le = AMBA_LE; all other bits = 0x0
> Fields:
>
> fl:  Flow control enable.  "1" indicates flow control is enabled. 
> When flow control is enabled and a Receive FIFO overrun occurs,
> the Ethernet 10/100/1000 Subsystem will send PAUSE frames if in
> full duplex mode.  This continues until the Receive FIFO is emptied.
>
> en:  Receive DMA Channel enable.  "1" indicates that the Receive
> DMA Channel is being configured from a descriptor, or that the DMA
> operation is in progress.  The Receive DMA Channel is idle when
> this enable bit is "0".  Software sets this bit to "1" to start the
> configuration from a descriptor and DMA operation.  When the DMA
> operation is finished, this bit is automatically reset to "0".

Here's the problem.  Once started, there is no way to forcibly stop rx
dma.  It keeps going until it hits a descriptor with the end of chain
flag set.

>> Receive DMA Channel Disabling
>>
>> When the entire receive frame has been read from the Receive FIFO and
>> sent over the AMBA bus, the DMA operation ends, and the Receive DMA
>> Channel is automatically disabled.  To do this, hardware resets the
>> Enable bit in the Receive Channel Control Register to "0" after the
>> last data has been read from the Receive FIFO and sent over the AMBA
>> bus.
>> 
>> When operating in descriptor mode, upon completion of a receive frame
>> DMA operation, if the descriptor chain has not ended when a receive
>> frame DMA operation completes, the next receive frame DMA operation
>> begins.  The last descriptor in a descriptor chain is indicated by
>> having its End Of Chain- EOC, flag set to "1".  If this EOC flag is
>> "0", to begin the next receive frame DMA operation, the next
>> descriptor is automatically retrieved and used to configure the
>> Receive DMA Channel.  The Receive DMA Channel is then automatically
>> re-enabled and the next receive frame DMA operation begins.
>> 
>> In descriptor mode, an AMBA bus error can occur when reading receive
>> descriptor data.  If this happens, receive descriptor processing ends
>> and the Receive DMA Channel is turned off.  The Descriptor Error bit
>> in the Receive Status Register is set to "1".
>
> Hmmm, I guess this is what Maxime/Mans did...
>
> Looking at the tango-specific integration, I note this nugget:
>
> 1.5.4 Stopping & Starting the DMA
>
> This feature has been added to allow the software to stop and start
> the DMA without any issues.
>
> Procedure:
> 1- STOP:
> 2- Stop RX core;
> 3- Set OWN bit of all descriptor of the chain to 1;
> 4- Stop DMA by writing dma_stop bit to 1 in  RX_DMA_Stop register
> 5- Wait around 100 clock cycles.
>
> The pending packets are held until the system will re-start.
>
> RE-START:
> 1- Clear dma_stop bit (note that if at the time of stopping the DMA,
> the next packet in the FIFO was an UDP packet, when clearing dma_stop,
> this packet will directly start being written in the DRAM since UDP
> packets are not controlled by the descriptor mechanism);
> 2- Program a new chain of descriptor;
> 3- Re-enable DMA (rx_ctrl register)
>
> rx_dma_stop:
> Software control to stop the Rx DMA.
> A write to this bit with “1” will gracefully stop the Rx DMA by after
> transferring the current packet. If more packets are pending they will
> be held until the software clears this bit.
>
> Hmmm, what do you think? This looks promising...

This is only available in the more recent Sigma versions.  Although it
is nicer, I didn't think it was worth the trouble to support both
methods since the older method should work on all chips.

-- 
Måns Rullgård
