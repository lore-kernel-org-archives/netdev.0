From: Arun Chandran <achandran@mvista.com>
Subject: Re: [PATCH] net: macb: Add big endian CPU support
Date: Wed, 25 Feb 2015 16:26:45 +0530
Message-ID: <CAFdej00df2gcUXVTnR34M6E+Mr7ctgjHgMisEpJUsZK6kf_CpA@mail.gmail.com>
References: <54EB34E7.7060400@monstr.eu>
	<1424763572-23317-1-git-send-email-achandran@mvista.com>
	<54ED9DA8.3040809@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michal Simek <monstr@monstr.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54ED9DA8.3040809@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 25, 2015 at 3:32 PM, Michal Simek <monstr@monstr.eu> wrote:
> On 02/24/2015 08:39 AM, Arun Chandran wrote:
>> This patch converts all __raw_readl and __raw_writel function calls
>> to their corresponding readl_relaxed and writel_relaxed variants.
>>
>> It also tells the driver to set ahb_endian_swp_mgmt_en bit in dma_cfg
>> when the cpu is configured in big endian mode.
>>
>> Signed-off-by: Arun Chandran <achandran@mvista.com>
>> ---
>>       This patch is tested on xilinx ZC702 evaluation board with
>>       CONFIG_CPU_BIG_ENDIAN=y and booting NFS rootfs
>>       Added on the fly IP endianness detection according to
>>       comments from Michal Simek.
>> ---
>> ---
>>  drivers/net/ethernet/cadence/macb.c | 33 +++++++++++++++++++++++++++------
>>  drivers/net/ethernet/cadence/macb.h | 15 ++++++++-------
>>  2 files changed, 35 insertions(+), 13 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
>> index ad76b8e..1642911 100644
>> --- a/drivers/net/ethernet/cadence/macb.c
>> +++ b/drivers/net/ethernet/cadence/macb.c
>> @@ -449,7 +449,7 @@ static void macb_update_stats(struct macb *bp)
>>       WARN_ON((unsigned long)(end - p - 1) != (MACB_TPF - MACB_PFR) / 4);
>>
>>       for(; p < end; p++, reg++)
>> -             *p += __raw_readl(reg);
>> +             *p += readl_relaxed(reg);
>>  }
>>
>>  static int macb_halt_tx(struct macb *bp)
>> @@ -1578,6 +1578,7 @@ static u32 macb_dbw(struct macb *bp)
>>  static void macb_configure_dma(struct macb *bp)
>>  {
>>       u32 dmacfg;
>> +     u32 tmp, ncr;
>>
>>       if (macb_is_gem(bp)) {
>>               dmacfg = gem_readl(bp, DMACFG) & ~GEM_BF(RXBS, -1L);
>> @@ -1585,7 +1586,25 @@ static void macb_configure_dma(struct macb *bp)
>>               if (bp->dma_burst_length)
>>                       dmacfg = GEM_BFINS(FBLDO, bp->dma_burst_length, dmacfg);
>>               dmacfg |= GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
>> -             dmacfg &= ~GEM_BIT(ENDIA);
>> +             dmacfg &= ~GEM_BIT(ENDIA_PKT);
>> +
>> +             /* Here we use the loopback bit of net_ctrl register to detect
>> +              * endianness on IP. save it first. Program swaped mode for
>> +              * management descriptor accesses if writing to loop back bit
>> +              * and reading it back brings no change in bit value.
>> +              */
>> +             ncr = macb_readl(bp, NCR);
>> +             __raw_writel(MACB_BIT(LLB), bp->regs + MACB_NCR);
>> +             tmp =  __raw_readl(bp->regs + MACB_NCR);
>
>
> I have tested this patch on zc702 le and be and it is working.
> The comment is not fully accurate. Sorry I thought that you are using a little bit different
> configuration than Zynq. The case I had in mind is that CPU and also IP can have different endianness.
>
> The code above is not checking endianness on IP itself but CPU endianness because IP is in little

Ok. I will change the comment.

> endian mode all the time. But the logic for detecting this on CPU is correct and this is what
> you need to do on Zynq. You are writing big endian value to little endian register and read it back
> to see if it was correctly written or not.

Just curious; will the same code work without change on a CPU with Big
endian IP?
(ie. If zynq hardware comes with only one change; IP configured in BE;
 will the driver be needing further changes?)

--Arun
