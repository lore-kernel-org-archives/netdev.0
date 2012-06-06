From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Wed, 6 Jun 2012 14:34:27 +0200
Message-ID: <CAL8zT=hHDPnvRFcQ0w+D=AP+QK6ic4X=tva6Yw_XGwuTbAYjhQ@mail.gmail.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
 <1338360536.2760.85.camel@edumazet-glaptop> <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
 <1338361587.2760.94.camel@edumazet-glaptop> <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
 <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
 <3367B80B08154D42A3B2BC708B5D41F647C678B73F@EXMAIL.ad.emulex.com>
 <CAL8zT=iP+5o11am67ZBVOd=QrOfcjFWDydiuM9RrrAKe_k7LZw@mail.gmail.com>
 <CAL8zT=ggT7Y2on6qmsp3u9CLOCwd6nOr3VjQfEsGZzA+O6us0A@mail.gmail.com> <1338980484.2760.4219.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sathya.Perla@emulex.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:56764 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351Ab2FFMes convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 08:34:48 -0400
Received: by wibhn6 with SMTP id hn6so4993971wib.1
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 05:34:47 -0700 (PDT)
In-Reply-To: <1338980484.2760.4219.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/6/6 Eric Dumazet <eric.dumazet@gmail.com>:
> On Wed, 2012-06-06 at 12:04 +0200, Jean-Michel Hautbois wrote:
>
>> Well, well, well, after having tested several configurations, severa=
l
>> drivers, I have a big difference between an old 2.6.26 kernel and a
>> newer one (I tried 3.2 and 3.4).
>>
>> Here is my stream : UDP packets (multicast), 4000 bytes length, MTU
>> set to 4096. I am sending packets only, nothing on RX.
>> I send from 1Gbps upto 2.4Gbps and I see no drops in tc with 2.6.26
>> kernel, but a lot of drops with a newer kernel.
>> So, I don't know if I missed something in my kernel configuration, b=
ut
>> I have used the 2.6.26 one as a reference, in order to set the same
>> options (DMA related, etc).
>>
>> I easily reproduce this problem and setting a bigger txqueuelen solv=
es
>> it partially.
>> 1Gbps requires a txqueulen of 9000, 2.4Gbps requires more than 20000=
 !
>>
>> If you have any idea, I am interested, as this is a big issue for my=
 use case.
>>
>
> Yep.
>
> This driver wants to limit number of tx completions, thats just wrong=
=2E
>
> Fix and dirty patch:
>
>
> diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/eth=
ernet/emulex/benet/be.h
> index c5c4c0e..1e8f8a6 100644
> --- a/drivers/net/ethernet/emulex/benet/be.h
> +++ b/drivers/net/ethernet/emulex/benet/be.h
> @@ -105,7 +105,7 @@ static inline char *nic_name(struct pci_dev *pdev=
)
> =C2=A0#define MAX_TX_QS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A08
> =C2=A0#define MAX_ROCE_EQS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 5
> =C2=A0#define MAX_MSIX_VECTORS =C2=A0 =C2=A0 =C2=A0 (MAX_RSS_QS + MAX=
_ROCE_EQS) /* RSS qs + RoCE */
> -#define BE_TX_BUDGET =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 256
> +#define BE_TX_BUDGET =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 65535
> =C2=A0#define BE_NAPI_WEIGHT =C2=A0 =C2=A0 =C2=A0 =C2=A0 64
> =C2=A0#define MAX_RX_POST =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BE=
_NAPI_WEIGHT /* Frags posted at a time */
> =C2=A0#define RX_FRAGS_REFILL_WM =C2=A0 =C2=A0 (RX_Q_LEN - MAX_RX_POS=
T)
>

I will try that in a few minutes.
I also have a mlx4 driver (mlx4_en) which has a similar behaviour, and
a broadcom (bnx2x).

JM
