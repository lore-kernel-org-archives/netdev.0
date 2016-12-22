From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] stmmac: CSR clock configuration fix
Date: Thu, 22 Dec 2016 12:28:18 +0000
Message-ID: <7b969fb0-8d73-1d19-5839-79b79af65de3@synopsys.com>
References: <6d4c6d15a60c93a8aef5e3e03b9cd64cdcf232c8.1482232420.git.jpinto@synopsys.com>
 <20161221.132104.1026207180067066991.davem@davemloft.net>
 <41c56a6a-b7ce-6305-5dbb-02a023df5642@synopsys.com>
 <db749688-5b91-a7c6-4220-3440a8a689b5@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <hock.leong.kweh@intel.com>,
        <niklas.cassel@axis.com>, <pavel@ucw.cz>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:58947 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934904AbcLVMa6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 07:30:58 -0500
In-Reply-To: <db749688-5b91-a7c6-4220-3440a8a689b5@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 12:23 PM de 12/22/2016, Joao Pinto escreveu:
> 
> Hi David,
> 
> Às 10:15 AM de 12/22/2016, Joao Pinto escreveu:
>> Às 6:21 PM de 12/21/2016, David Miller escreveu:
>>> From: Joao Pinto <Joao.Pinto@synopsys.com>
>>> Date: Tue, 20 Dec 2016 11:21:47 +0000
>>>
>>>> When testing stmmac with my QoS reference design I checked a problem in the
>>>> CSR clock configuration that was impossibilitating the phy discovery, since
>>>> every read operation returned 0x0000ffff. This patch fixes the issue.
>>>>
>>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>>>
>>> This isn't enough.
>>>
>>> It looks like various parts of this driver set the mask field
>>> differently.
>>>
>>> dwmac1000_core.c and dwmac100_core.c set the mask to be the low bits.
>>>
>>> But dwmac4_core.c uses GENMASK(11, 8) which means the mask is a value
>>> which is shifted up already.
>>>
>>> So your patch will break chips driven by dwmac4_core.c.
>>
>> I am using a GMAC4 reference design to test the patches. The clock configuration
>> as is, does not work, resulting in the phy discovery failure. By applying this
>> patch I am able to set the clock value properly.
>>
>> I am going to check in the Databook of GMAC4 and older versions in order to
>> justify better.
> 
> So from the 4.20 Databook:
> 
> Bits
> 11:8 CR parameter
> 0000: CSR clock = 60-100 MHz; MDC clock = CSR
> 0001: CSR clock = 100-150 MHz; MDC clock = CSR
> 0010: CSR clock = 20-35 MHz; MDC clock = CSR
> 0011: CSR clock = 35-60 MHz; MDC clock = CSR
> 0100: CSR clock = 150-250 MHz; MDC clock = CSR
> 0101: CSR clock = 250-300 MHz; MDC clock = CSR
> 0110, 0111: Reserved
> 
> For example, if you want configure the CSR clock to 250-300MHZ (my case), you
> will set the parameter CR to 0x5. The current mechanism simply messes the value.
> With this fix, the 0x5 is shifted to 11:8 like the databook specifies and
> applies a GENMASK(11:8) on top, causing the reset of every bit outside the 11:8
> which is an assurance.
> 
> For older cores like 4.10 and 4.00 the logic is the same. The information was
> confirmed by R&D.
> 
> Thanks.

Bu checking DWMAC100 and DWMAC1000 I understand your concern now. I am going to
change their masks also in order to put it right. V2 comming soon.

Thanks.

> 
>>
>>>
>>> In order for your change to be correct you must consolidate all of
>>> these various pieces to use the same convention.
>>>
>>
>> Thanks.
>>
> 
