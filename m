From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH V3] net: stmmac: socfpga: Remove re-registration of reset
 controller
Date: Wed, 27 Apr 2016 00:33:39 +0200
Message-ID: <571FECC3.8010004@denx.de>
References: <1461240710-5381-1-git-send-email-marex@denx.de>	<CAGhQ9VzpZcP23DC0LZ95YggtsBDsUCe-NHEtna7hY9Yvdr=ZGg@mail.gmail.com>	<571EA05F.3070200@denx.de>	<CAGhQ9Vz568hdSk+HWGHXuSNn4DU7HZkUBfVbajQyRkq+rBYY7Q@mail.gmail.com>	<571F636C.9040503@denx.de> <CAGhQ9Vz2FSENtif66SfXsgZqaJaaKeiBsw4qCSevM_4XDnUPCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"peppe.cavallaro" <peppe.cavallaro@st.com>,
	alexandre.torgue@st.com,
	Matthew Gerlach <mgerlach@opensource.altera.com>,
	Dinh Nguyen <dinguyen@opensource.altera.com>,
	"David S . Miller" <davem@davemloft.net>
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:33538 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbcDZWdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 18:33:44 -0400
In-Reply-To: <CAGhQ9Vz2FSENtif66SfXsgZqaJaaKeiBsw4qCSevM_4XDnUPCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2016 11:22 PM, Joachim Eastwood wrote:
> On 26 April 2016 at 14:47, Marek Vasut <marex@denx.de> wrote:
>> On 04/26/2016 02:26 PM, Joachim Eastwood wrote:
>>> On 26 April 2016 at 00:55, Marek Vasut <marex@denx.de> wrote:
>>>> On 04/25/2016 08:11 PM, Joachim Eastwood wrote:
>>>>> On 21 April 2016 at 14:11, Marek Vasut <marex@denx.de> wrote:
>>>>>>
>>>>>> Finally, plat_dat->exit and socfpga_dwmac_exit() is no longer necessary,
>>>>>> since the functionality is already performed by the stmmac core.
>>>>>
>>>>> I am trying to rebase my changes on top of your two patches and
>>>>> noticed a couple of things.
>>>>>
>>>>>>  static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
>>>>>>  {
>>>>>> -       struct socfpga_dwmac    *dwmac = priv;
>>>>>> +       struct socfpga_dwmac *dwmac = priv;
>>>>>>         struct net_device *ndev = platform_get_drvdata(pdev);
>>>>>>         struct stmmac_priv *stpriv = NULL;
>>>>>>         int ret = 0;
>>>>>>
>>>>>> -       if (ndev)
>>>>>> -               stpriv = netdev_priv(ndev);
>>>>>> +       if (!ndev)
>>>>>> +               return -EINVAL;
>>>>>
>>>>> ndev can never be NULL here. socfpga_dwmac_init() is only called if
>>>>> stmmac_dvr_probe() succeeds or we are running the resume callback. So
>>>>> I don't see how this could ever be NULL.
>>>>
>>>> That's a good point, this check can indeed be removed. While you're at
>>>> the patching, can you remove this one ?
>>>
>>> Yes, my patch will refactor the init() function so this will go away.
>>
>> Thanks!
>>
>>>>>> +
>>>>>> +       stpriv = netdev_priv(ndev);
>>>>>
>>>>> It's not really nice to access 'stmmac_priv' as it should be private
>>>>> to the core driver, but I don't see any other good solution right now.
>>>>
>>>> I guess some stmmac_reset_assert() wrapper would be nicer, yes. What do
>>>> you think ?
>>>>
>>>>>> +       if (!stpriv)
>>>>>> +               return -EINVAL;
>>>>>>
>>>>>>         /* Assert reset to the enet controller before changing the phy mode */
>>>>>> -       if (dwmac->stmmac_rst)
>>>>>> -               reset_control_assert(dwmac->stmmac_rst);
>>>>>> +       if (stpriv->stmmac_rst)
>>>>>> +               reset_control_assert(stpriv->stmmac_rst);
>>>>>>
>>>>>>         /* Setup the phy mode in the system manager registers according to
>>>>>>          * devicetree configuration
>>>>>> @@ -227,8 +210,8 @@ static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
>>>>>>         /* Deassert reset for the phy configuration to be sampled by
>>>>>>          * the enet controller, and operation to start in requested mode
>>>>>>          */
>>>>>> -       if (dwmac->stmmac_rst)
>>>>>> -               reset_control_deassert(dwmac->stmmac_rst);
>>>>>> +       if (stpriv->stmmac_rst)
>>>>>> +               reset_control_deassert(stpriv->stmmac_rst);
>>>>>>
>>>>>>         /* Before the enet controller is suspended, the phy is suspended.
>>>>>>          * This causes the phy clock to be gated. The enet controller is
>>>>>> @@ -245,7 +228,7 @@ static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
>>>>>>          * control register 0, and can be modified by the phy driver
>>>>>>          * framework.
>>>>>>          */
>>>>>> -       if (stpriv && stpriv->phydev)
>>>>>> +       if (stpriv->phydev)
>>>>>>                 phy_resume(stpriv->phydev);
>>>>>
>>>>> Before this change phy_resume() was only called during driver resume
>>>>> when , but your patches cause phy_resume() to called at probe time as
>>>>> well. Is this okey?
>>>>
>>>> I _hope_ it's OK. The cryptic comment above is not very helpful in this
>>>> aspect. Dinh ? :)
>>>
>>> My patches will move phy_resume() to the resume callback so it
>>> preserves the previous behavior. But if someone knows more about this
>>> that would be useful.
>>>
>>>
>>>> btw I wish you reviewed my patch a bit earlier to catch these bits.
>>>
>>> Sorry, about that. I have been really busy with other things lately.
>>
>> Oh I'm real happy someone is doing the refactoring :) I appreciate your
>> work, sorry if that was unclear.
>>
>>> My patches based on next from Friday can be found here now:
>>> https://github.com/manabian/linux-lpc/tree/net-socfpga-dwmac-on-next
>>>
>>> I had to add your latest patch as well since the next version I used
>>> didn't have it. I'll post the patches on netdev later today or
>>> tomorrow.
>>
>> Looks like next wasn't synced for a few days, yeah.
>>
>> You can add my:
>>
>> On SoCFPGA Cyclone V SoC (DENX MCVEVK):
>> Tested-by: Marek Vasut <marex@denx.de>
>>
>> to those patches
> 
> Excellent. Thanks Marek.
> 
> btw, did you also test suspend/resume?

No, I believe that is unsupported on SoCFPGA Cyclone V in general.

-- 
Best regards,
Marek Vasut
