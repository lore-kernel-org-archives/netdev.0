From: deepaksi <deepak.sikri@st.com>
Subject: Re: [PATCH 5/6] stmmac: configure burst related GMAC DMA parameters
Date: Wed, 7 Mar 2012 11:48:01 +0530
Message-ID: <4F56FD99.4040702@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com> <1330692928-30330-2-git-send-email-deepak.sikri@st.com> <1330692928-30330-3-git-send-email-deepak.sikri@st.com> <1330692928-30330-4-git-send-email-deepak.sikri@st.com> <1330692928-30330-5-git-send-email-deepak.sikri@st.com> <1330692928-30330-6-git-send-email-deepak.sikri@st.com> <4F55C00C.6030208@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: spear-devel <spear-devel@list.st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shiraz HASHIM <shiraz.hashim@st.com>,
	Vikas MANOCHA <vikas.manocha@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:35917 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751410Ab2CGGSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 01:18:37 -0500
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id B9D5710C
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 06:10:06 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas4.st.com [10.80.176.69])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 9279010E9
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 06:18:31 +0000 (GMT)
In-Reply-To: <4F55C00C.6030208@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hellp Giuseppe,

>
> bit 24 in the Bus Mode Register represents the 8xPBL in databooks new=
er
> than the 3.50a. In older databook it is 4xPBL.
> So maybe, the DMA_BUS_MODE_4PBL define should be renamed as
> DMA_BUS_PBL_MODE (to be more generic and surrounded by a nice comment
> that details its meaning for different devices).
>
> but ...

Ok, will do that

>> @@ -56,6 +56,18 @@ static int dwmac1000_dma_init(void __iomem *ioadd=
r, int pbl, u32 dma_tx,
>>   	value |=3D DMA_BUS_MODE_DA;	/* Rx has priority over tx */
>>   #endif
>>   	writel(value, ioaddr + DMA_BUS_MODE);
>> +	/*
>> +	 * We need to program DMA_AXI_BUS_MODE for supported bursts in
>> +	 * case DMA_BUS_MODE_FB mode is selected
>> +	 * Note: This is applicable only for revision GMACv3.61a. For
>> +	 * older version this register is reserved and shall have no
>> +	 * effect.
>> +	 * Further we directly write 0xFF to this register. This would
>> +	 * ensure that all bursts supported by platform is set and those
>> +	 * which are not supported would remain ineffective.
>> +	 */
>> +	if (value&  DMA_BUS_MODE_FB)
>> +		writel(0xFF, ioaddr + DMA_AXI_BUS_MODE);
> ... this patch sets the FB: Fixed Burst (not set on other GMAC!) and
> then always writes into the DMA_AXI_BUS_MODE register.
>
> I agree that the DMA_AXI_BUS_MODE Reg is reserved in old devices but =
I'd
> like to have a new platform parameter to do this kind of thing.
>
> We could have .fixed_burst in the linux/stmmac.h (like .pbl).
>
> If it is passed, so we set the DMA_BUS_MODE_FB in the DMA Reg 0.
>
> In this case, we can also set the DMA reg11 but, pls, not using 0xff.
> I wonder if you could improve the code adding the defines for this re=
gister.
>
> With this approach we have no impact on other GMAC!
>
> peppe

Looks good, will use the <include/linux/stmmac.h> for passing the fixed=
=20
burst option, and also
program the DMA register accordingly.

Along with that, we may need to program following things.
- For Fixed burst mode, the fixed burst length that has to be programme=
d.
- For no-fixed burst mode, the maximum allowed burst length need to be =
set.

This is in sync with the following information captured from the stmmac=
=20
core manual for the
bit-0  of the DMA AXI Bus Mode register

**********************************************************************
UNDEF: AXI Undefined Burst Length
This bit is read-only bit and indicates the complement (invert) value o=
f=20
=46B bit
in Register0 (Bus Mode Register[16]).
=E2=80=A2 When this bit is set to 1, the GMAC-AXI is allowed to perform=
 any burst
length equal to or below the maximum allowed burst length as
programmed in bits[7:1]
=E2=80=A2 When this bit is set to 0, the GMAC-AXI is allowed to perform=
 only fixed
burst lengths as indicated by BLEN256/128/64/32/16/8/4, or a burst
length of 1.
*********************************************************************

It would be better if additionally we pass the burst length, signifying=
 the
- Fixed burst length for fixed burst mode
- Max Burst length for non-fixed burst mode.


Regards
Deepak
