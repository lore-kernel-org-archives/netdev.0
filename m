From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support for GEM
Date: Fri, 18 Nov 2016 09:59:47 +0530
Message-ID: <CAFcVEC+RqUMQF39oe2EuCoisX6dCwRQ3G81zFMqoOHU3HpfPHQ@mail.gmail.com>
References: <BN3PR07MB2516B2EBCF0AE7079971DBF6C9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECJ-ZYjGg-3CbWD2Ka8yKzOokUxS8ZHHOJXa2Z6anuTr7Q@mail.gmail.com>
 <e6773b4e-a633-4754-893d-fd2351d07459@atmel.com> <BN3PR07MB2516EBCDD8822FC5F8A9095FC9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rafal Ozieblo <rafalo@cadence.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN3PR07MB2516EBCDD8822FC5F8A9095FC9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rafal,

On Thu, Nov 17, 2016 at 7:05 PM, Rafal Ozieblo <rafalo@cadence.com> wrote:
> -----Original Message-----
> From: Nicolas Ferre [mailto:nicolas.ferre@atmel.com]
> Sent: 17 listopada 2016 14:29
> To: Harini Katakam; Rafal Ozieblo
> Cc: harini.katakam@xilinx.com; netdev@vger.kernel.org; linux-kernel@vger.=
kernel.org
> Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support for=
 GEM
>
>> Le 17/11/2016 =C3=A0 13:21, Harini Katakam a =C3=A9crit :
>> > Hi Rafal,
>> >
>> > On Thu, Nov 17, 2016 at 5:20 PM, Rafal Ozieblo <rafalo@cadence.com> wr=
ote:
>> >> Hello,
>> >> I think, there could a bug in your patch.
>> >>
>> >>> +
>> >>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>> >>> +             dmacfg |=3D GEM_BIT(ADDR64); #endif
>> >>
>> >> You enable 64 bit addressing (64b dma bus width) always when appropri=
ate architecture config option is enabled.
>> >> But there are some legacy controllers which do not support that featu=
re. According Cadence hardware team:
>> >> "64 bit addressing was added in July 2013. Earlier version do not hav=
e it.
>> >> This feature was enhanced in release August 2014 to have separate upp=
er address values for transmit and receive."
>> >>
>> >>> /* Bitfields in NSR */
>> >>> @@ -474,6 +479,10 @@
>> >>>  struct macb_dma_desc {
>> >>  >      u32     addr;
>> >>>       u32     ctrl;
>> >>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>> >>> +     u32     addrh;
>> >>> +     u32     resvd;
>> >>> +#endif
>> >>>  };
>> >>
>> >> It will not work for legacy hardware. Old descriptor is 2 words wide,=
 the new one is 4 words wide.
>> >> If you enable CONFIG_ARCH_DMA_ADDR_T_64BIT but hardware doesn't
>> >> support it at all, you will miss every second descriptor.
>> >>
>> >
>> > True, this feature is not available in all of Cadence IP versions.
>> > In fact, the IP version Zynq does not support this. But the one in Zyn=
qMP does.
>> > So, we enable kernel config for 64 bit DMA addressing for this SoC and
>> > hence the driver picks it up. My assumption was that if the legacy IP
>> > does not support
>> > 64 bit addressing, then this DMA option wouldn't be enabled.
>> >
>> > There is a design config register in Cadence IP which is being read to
>> > check for 64 bit address support - DMA mask is set based on that.
>> > But the addition of two descriptor words cannot be based on this runti=
me check.
>> > For this reason, all the static changes were placed under this check.
>>
>> We have quite a bunch of options in this driver to determinate what is t=
he real capacity of the underlying hardware.
>> If HW configuration registers are not appropriate, and it seems they are=
 not, I would advice to simply use the DT compatibility string.
>>
>> Best regards,
>> --
>> Nicolas Ferre
>
> HW configuration registers are appropriate. The issue is that this code d=
oesn=E2=80=99t use the capability bit to switch between different dma descr=
iptors (2 words vs. 4 words).
> DMA descriptor size is chosen based on kernel configuration, not based on=
 hardware capabilities.

HW configuration register does give appropriate information.
But addition of two address words in the macb descriptor structure is
a static change.

+static inline void macb_set_addr(struct macb_dma_desc *desc, dma_addr_t ad=
dr)
+{
+       desc->addr =3D (u32)addr;
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+       desc->addrh =3D (u32)(addr >> 32);
+#endif
+

Even if the #ifdef condition here is changed to HW config check, addr
and addrh are different.
And "addrh" entry has to be present for 64 bit desc case to be handled
separately.
Can you please tell me how you propose change in DMA descriptor structure f=
rom
4 to 2 or 2 to 4 words *after* reading the DCFG register?

Regards,
Harini
