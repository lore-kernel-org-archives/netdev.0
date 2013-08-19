From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] driver:net:stmmac: Disable DMA store and forward mode
 if platform data force_sf_dma_mode is negative.
Date: Mon, 19 Aug 2013 16:29:48 +0200
Message-ID: <52122BDC.5030500@st.com>
References: <1376552256-7421-1-git-send-email-sonic.adi@gmail.com> <5211B524.4030609@st.com> <CAJxxZ0PZUYeFnfnHVNaVi=wx_YDiTmsUNCfNyR27=jSuBH+tzg@mail.gmail.com> <5211CD14.3080808@st.com> <CAJxxZ0NFhMMKp2eB+b168=c6+JsmJE6-yva7ZOGKciK3e4b8Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	adi-buildroot-devel@lists.sourceforge.net,
	Sonic Zhang <sonic.zhang@analog.com>
To: Sonic Zhang <sonic.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:57166 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750748Ab3HSOaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 10:30:02 -0400
In-Reply-To: <CAJxxZ0NFhMMKp2eB+b168=c6+JsmJE6-yva7ZOGKciK3e4b8Yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/19/2013 12:51 PM, Sonic Zhang wrote:
> Hi Giuseppe,
>
> On Mon, Aug 19, 2013 at 3:45 PM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com> wrote:
>> On 8/19/2013 9:31 AM, Sonic Zhang wrote:
>>>
>>> Hi Giuseppe,
>>>
>>> On Mon, Aug 19, 2013 at 2:03 PM, Giuseppe CAVALLARO
>>> <peppe.cavallaro@st.com> wrote:
>>>>
>>>> Hello Sonic
>>>>
>>>>
>>>> On 8/15/2013 9:37 AM, Sonic Zhang wrote:
>>>>>
>>>>>
>>>>> From: Sonic Zhang <sonic.zhang@analog.com>
>>>>>
>>>>> Some synopsys ip implementation doesn't support DMA store and forward
>>>>> mode,
>>>>> such as BF60x. So, define force_sf_dma_mode negative to use DMA
>>>>> thresholds
>>>>> only.
>>>>
>>>>
>>>>
>>>> I think that you should not pass the force_sf_dma_mode platform field
>>>> at all (and it doesn't make sense to force it as negative).
>>>> To use the threshold you should reset tx_coe. In fact, your HW cannot
>>>> perform the Hw csum if SF is not available.
>>>> Note that, the HW cap register (if available) can override (set/reset)
>>>>    tx_coe.
>>>
>>>
>>> Even if I reset tx_coe, the SF mode is still set to RX DMA in current
>>> stmmac_dma_operation_mode(). SF mode is not supported in both RX DMA
>>> and TX DMA in Blackfin MAC.
>>
>>
>> yes this is true. the SF is always set for the RX path because I have
>> never had and known HW w/o RX csum (since the 209).
>>
>> So I think the code could be improved to disable/enable the SF also for
>> the RX path.
>>
>>
>>>>
>>>> I tested, long time ago, this scenario on old mac w/o HW cap register
>>>> and w/o SF.
>>>
>>>
>>> Blackfin synopsys MAC IP has the HW cap register with tx_coe set to 1,
>>> but the HW tx_coe doesn't really work. I have the other patch to
>>> disable HW tx_coe in board file and override the HW cap register.
>>
>>
>> AFAIK the HW shouldn't be able to perform the csum in HW w/o SF.
>>
>> Maybe, an easy way could be to use a new field to force the threshold
>> mode. This should also remove the csum in HW (IMO) and program the
>> DMA operation register.
>>
>
> The problem is that HW RX csum works perfectly on Blackfin MAC
> although the SF mode is not supported in RX DMA.

hmm maybe we should ask SYNP. I'll try.

> I may need 2 platform
> fields to force RX DMA threshold and disable HW tx_coe. One field
> doesn't cover both cases well.

concerning tx_coe, I had added it to inform the stmmac that the HW
was (or not) able to do the csum in hw. This was true on chip w/o
the HW cap register. If you have the HW cap reg so let me assume
there is another problem. For example, I worked (time ago) on an HW
where the cap reg declared that the mac was able to perform the csum
in hw but, after debugging it, I discovered that the problem was on
SG. I mean, the HW was able to do the csum in HW but had problems on
fragmented frame (I mean, frames that were split in one more
descriptor).

I will send you the patch I used to fix that... maybe you are in the
same scenario.

Concerning the threshold, just to avoid to complicate the code, we could
keep force_sf_dma_mode and add force_thresh_dma_mode that force both
rx and tx. I do not want to remove the force_sf_dma_mode that is also
used on some platforms (AFAIK).
Do not forget to update the stmmac.txt and devicetree support
What do you think?
I also think that the patch should be prepared on top of net-next.

Peppe
>
> Which 2 fields do you prefer?
>
> Thanks
>
> Sonic
>
>
