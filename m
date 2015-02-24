From: Arun Chandran <achandran@mvista.com>
Subject: Re: [PATCH] net: macb: Add big endian CPU support
Date: Tue, 24 Feb 2015 23:27:51 +0530
Message-ID: <CAFdej02XAmpWotSWoo0_Uxsuw6J6HoTAHXH_e5Xjk7x_X5uCQQ@mail.gmail.com>
References: <54EB34E7.7060400@monstr.eu>
	<1424763572-23317-1-git-send-email-achandran@mvista.com>
	<54EC7522.40006@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Michal Simek <monstr@monstr.eu>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54EC7522.40006@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 24, 2015 at 6:27 PM, Nicolas Ferre <nicolas.ferre@atmel.com=
> wrote:
> Le 24/02/2015 08:39, Arun Chandran a =C3=A9crit :
>> This patch converts all __raw_readl and __raw_writel function calls
>> to their corresponding readl_relaxed and writel_relaxed variants.
>>
>> It also tells the driver to set ahb_endian_swp_mgmt_en bit in dma_cf=
g
>> when the cpu is configured in big endian mode.
>>
>> Signed-off-by: Arun Chandran <achandran@mvista.com>
>> ---
>>       This patch is tested on xilinx ZC702 evaluation board with
>>       CONFIG_CPU_BIG_ENDIAN=3Dy and booting NFS rootfs
>>       Added on the fly IP endianness detection according to
>>       comments from Michal Simek.
>> ---
>> ---
>>  drivers/net/ethernet/cadence/macb.c | 33 ++++++++++++++++++++++++++=
+------
>>  drivers/net/ethernet/cadence/macb.h | 15 ++++++++-------
>>  2 files changed, 35 insertions(+), 13 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ether=
net/cadence/macb.c
>> index ad76b8e..1642911 100644
>> --- a/drivers/net/ethernet/cadence/macb.c
>> +++ b/drivers/net/ethernet/cadence/macb.c
>> @@ -449,7 +449,7 @@ static void macb_update_stats(struct macb *bp)
>>       WARN_ON((unsigned long)(end - p - 1) !=3D (MACB_TPF - MACB_PFR=
) / 4);
>>
>>       for(; p < end; p++, reg++)
>> -             *p +=3D __raw_readl(reg);
>> +             *p +=3D readl_relaxed(reg);
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
>>               dmacfg =3D gem_readl(bp, DMACFG) & ~GEM_BF(RXBS, -1L);
>> @@ -1585,7 +1586,25 @@ static void macb_configure_dma(struct macb *b=
p)
>>               if (bp->dma_burst_length)
>>                       dmacfg =3D GEM_BFINS(FBLDO, bp->dma_burst_leng=
th, dmacfg);
>>               dmacfg |=3D GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
>> -             dmacfg &=3D ~GEM_BIT(ENDIA);
>> +             dmacfg &=3D ~GEM_BIT(ENDIA_PKT);
>
> I think this will fail... (see below)
>
>> +
>> +             /* Here we use the loopback bit of net_ctrl register t=
o detect
>> +              * endianness on IP. save it first. Program swaped mod=
e for
>> +              * management descriptor accesses if writing to loop b=
ack bit
>> +              * and reading it back brings no change in bit value.
>> +              */
>> +             ncr =3D macb_readl(bp, NCR);
>> +             __raw_writel(MACB_BIT(LLB), bp->regs + MACB_NCR);
>> +             tmp =3D  __raw_readl(bp->regs + MACB_NCR);
>> +
>> +             if (tmp =3D=3D MACB_BIT(LLB))
>> +                     dmacfg &=3D ~GEM_BIT(ENDIA_DESC);
>
> Ditto
>
>> +             else
>> +                     dmacfg |=3D GEM_BIT(ENDIA_DESC);
>
> Ditto

Actually GEM_BIT(ENDIA_DESC) won't fail as I have defined
GEM_ENDIA_DESC_OFFSET. But I failed to notice others (GEM_BF*)

I will send another version. Thank you for spotting it.

--Arun
