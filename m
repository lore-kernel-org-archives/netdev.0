From: Rayagond K <rayagond@vayavyalabs.com>
Subject: Re: [net-next.git 2/9] stmmac: add IEEE 1588-2002 PTP support
Date: Fri, 8 Mar 2013 13:21:20 +0530
Message-ID: <CAJ3bTp5vKmEgjWsJ7YhxKZ+T8nK-VwJN=BiO5T1NaEN4g-kUpg@mail.gmail.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
	<1362653419-1047-3-git-send-email-peppe.cavallaro@st.com>
	<20130308063437.GB2382@netboy.at.omicron.at>
	<51398CFD.9010605@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	bh74.an@samsung.com
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:39619 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283Ab3CHHvV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 02:51:21 -0500
Received: by mail-wg0-f48.google.com with SMTP id 16so2101875wgi.15
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 23:51:20 -0800 (PST)
In-Reply-To: <51398CFD.9010605@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 8, 2013 at 12:32 PM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
>
> On 3/8/2013 7:34 AM, Richard Cochran wrote:
>>
>> I have a few comments, below.
>
>
> thanks for them.
>
>
>>> HW Timestamp support can be enabled while configuring the Kernel an=
d
>>> the Koption is: STMMAC_USE_HWSTAMP
>>> At runtime, the support is verified by looking at the HW capability
>>> register.
>>
>>
>> As davem said, since you have the ability to detect this at run time=
,
>> then there is no need for a kconfig option.
>
>
> I'll try to give you more details about this replying to D. Miller
>
> [snip]
>
>
>>> +       /* get tx/rx timestamp low value */
>>> +       u32 (*get_timestamp_low) (struct dma_desc *p);
>>> +       /* get tx/rx timestamp high value */
>>> +       u32 (*get_timestamp_high) (struct dma_desc *p);
>>
>>
>> These two separate functions should be combined into one.
>
>
> ok
>
>
>>> +       /* get rx timestamp status */
>>> +       int (*get_rx_timestamp_status) (struct dma_desc *p);
>
>
>>> +
>>> +static int enh_desc_get_rx_timestamp_status(struct dma_desc *p)
>>> +{
>>> +       /* FIXME if Enhance descriptor with 8 DWORDS is enabled */
>>
>>
>> Why not fix these FIXMEs for the next respin?
>
>
> This is fixed in the patch #5 where we use the extended descriptors
> for PTP2.
>
>
>>> +       if ((p->des2 =3D=3D 0xffffffff) && (p->des3 =3D=3D 0xffffff=
ff))
>>> +               /* timestamp is currupted, hence don't store it */
>>
>>
>> corrupted
>
>
> thanks
>
>
>
>>> +       /* Convert the ptp_clock to nano second
>>> +        * formula =3D (1/ptp_clock) * 1000000000
>>> +        * where, ptp_clock =3D 50MHz for FINE correction method &
>>> +        * ptp_clock =3D STMMAC_SYSCLOCK for COARSE correction meth=
od
>>> +        */
>>
>>
>> What are these coarse/fine method? Can't we always use the fine one?
>
>
> This is explained in the "4.1.2 System Time Register Module" of Synop=
sys
> Databook. Summarizing, the MAC can have an optional module and use th=
is
> coarse correction method. In the fine correction method, a slave cloc=
k=92s
> frequency drift with respect to the master clock is corrected over a =
period
> of time instead of in one clock, as in coarse correction.
>
> Pls, Rayagond feels free to provide more details...

Yes Synopsys core support two method for correcting the system time ie
COARSE method  and FINE method.

In the fine correction method, a slave clock=92s frequency drift with
respect to the master clock (as defined in IEEE 1588) is corrected
over a period of time instead of in one clock, as in coarse
correction. This helps maintain linear time and does not introduce
drastic changes (or a large jitter) in the reference time between PTP
Sync message intervals.

And updating the SSNR (Sub Second Increment Register) depends on which
method is selected during the initialization.

>
>>> +       if (value & PTP_TCR_TSCFUPDT)
>>> +               data =3D (1000000000ULL / 50000000);
>>> +       else
>>> +               data =3D (1000000000ULL / STMMAC_SYSCLOCK);
>>> +
>>> +       writel(data, ioaddr + PTP_SSIR);
>>> +}
>>> +
>>> +static int stmmac_init_systime(void __iomem *ioaddr, u32 sec, u32 =
nsec)
>>> +{
>>> +       int limit;
>>> +       u32 value;
>>> +
>>> +       /* wait for previous(if any) system time initialize to comp=
lete
>>> */
>>> +       limit =3D 100;
>>> +       while (limit--) {
>>> +               if (!(readl(ioaddr + PTP_TCR) & PTP_TCR_TSINIT))
>>> +                       break;
>>> +               mdelay(10);
>>> +       }
>>> +
>>> +       if (limit < 0)
>>> +               return -EBUSY;
>>> +
>>
>>
>> Ugh, this is terrible...
>>
>>> +       writel(sec, ioaddr + PTP_STSUR);
>>> +       writel(nsec, ioaddr + PTP_STNSUR);
>>> +       /* issue command to initialize the system time value */
>>> +       value =3D readl(ioaddr + PTP_TCR);
>>> +       value |=3D PTP_TCR_TSINIT;
>>> +       writel(value, ioaddr + PTP_TCR);
>>> +
>>> +       /* wait for present system time initialize to complete */
>>> +       limit =3D 100;
>>> +       while (limit--) {
>>> +               if (!(readl(ioaddr + PTP_TCR) & PTP_TCR_TSINIT))
>>> +                       break;
>>> +               mdelay(10);
>>> +       }
>>> +       if (limit < 0)
>>> +               return -EBUSY;
>>
>>
>> ... for a number of reasons.
>>
>> 1. You are polling for 100*10ms =3D one second, and the caller has
>>     disabled interrupts! This is way too long. Is the hardware reall=
y
>>     that slow? If so, then you need to use delayed work or find some
>>     other way not to block.

Sorry for this, during testing I just used maximum delay as there was
bug in the HW initially. But after fixing the HW issue I noticed that
HW is not that much slow. We will reduce the delay in all functions.

>>
>> 2. You are waiting both before and after for the status bit. Pick on=
e
>>     or the other. You don't need both.
>>
>> This same pattern is repeated a few times here, and it needs fixing =
in
>> each case.

Sure will change it. I added just to make sure double check here.
Practically first wait is not required, will remove this.

>
>
> This is for the Author. I've no HW where test. Rayagond tested all on=
 his
> side. Pls Rayagond fixes it and gives me the new code.
>
>
>>> +       struct stmmac_priv *priv =3D netdev_priv(dev);
>>> +       struct hwtstamp_config config;
>>> +       struct timespec now;
>>> +       u64 temp =3D 0;
>>
>>
>> You add this new code here, but you change it all around again a few
>> patches later. Please just submit the final, combined version.
>
>
> we kept these separately because the patch #5 (for example) depends o=
n
> another one that adds the extended descriptor support. Also If I add
> all the code in a single patch this will be very big. I had some
> problems to review all separately. So I suspect that if we merge all
> in a single patch this will not help (especially myself). At any rate=
,
> tell me if you prefer to have a single patch. I can do that.
>
> peppe
>>
>>
>> Thanks,
>> Richard
>>
>

Thanks
Rayagond.
