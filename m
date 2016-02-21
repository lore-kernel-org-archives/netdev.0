From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v4 net-next] ravb: Add dma queue interrupt support
Date: Sun, 21 Feb 2016 18:42:41 +0300
Message-ID: <56C9DAF1.1030003@cogentembedded.com>
References: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
 <56AA4674.6020001@cogentembedded.com>
 <CAH1o70LRuYwKGwhWBy1m6AuWfe-rNRBER7-Oi2u84ahX5+NyuA@mail.gmail.com>
 <56B77A57.2080902@cogentembedded.com>
 <CAH1o70JFUVaRb07ivtnZhOYNbh8n2mdZpH41nsMjEenx5yNeeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <CAH1o70JFUVaRb07ivtnZhOYNbh8n2mdZpH41nsMjEenx5yNeeQ@mail.gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

    Sorry for the late reply -- I was hoping to get AVB working on another 
gen2 board...

On 02/08/2016 08:19 PM, Yoshihiro Kaneko wrote:

[...]
>>>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>>>
>>>>> This patch supports the following interrupts.
>>>>>
>>>>> - One interrupt for multiple (descriptor, error, management)
>>>>> - One interrupt for emac
>>>>> - Four interrupts for dma queue (best effort rx/tx, network control
>>>>> rx/tx)
>>>>>
>>>>> This patch improve efficiency of the interrupt handler by adding the
>>>>> interrupt handler corresponding to each interrupt source described
>>>>> above. Additionally, it reduces the number of times of the access to
>>>>> EthernetAVB IF.
>>>>>
>>>>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

[...]

>>>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>>>>> b/drivers/net/ethernet/renesas/ravb_main.c
>>>>> index ac43ed9..076f25f 100644
>>>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
[...]
>>>>> +
>>>>> +       spin_lock(&priv->lock);
>>>>> +
>>>>> +       ris0 = ravb_read(ndev, RIS0);
>>>>> +       ric0 = ravb_read(ndev, RIC0);
>>>>> +       tis  = ravb_read(ndev, TIS);
>>>>> +       tic  = ravb_read(ndev, TIC);
>>>>> +
>>>>> +       /* Timestamp updated */
>>>>> +       if (tis & TIS_TFUF) {
>>>>> +               ravb_write(ndev, TID_TFUD, TID);
>>>>
>>>>      Wait, you're supposed to clear the TFUF interrupt, not to disable!
>>>
>>> Thanks for finding this bug.
>>>
>>>> And with that fixed, this interrupt's handler could get factored out into
>>>> a
>>>> function...
>>>
>>> Is this not too small to make a function?
>>
>>     I wouldn't say so. But need to count the summary LoCs, of course...
>> perhaps indeed not worth it...
>
> I don't feel need for making it a function.
> It only clears the interrupt and calls ravb_get_tx_tstamp().

    I meant that the enclosing *if* statement should be a part of function too...

[...]

>>>>> +                          struct net_device *ndev, struct device *dev,
>>>>> +                          const char *ch)
>>>>> +{
>>>>> +       char *name;
>>>>> +       int error;
>>>>> +
>>>>> +       name = devm_kasprintf(dev, GFP_KERNEL, "%s:%s", ndev->name, ch);
>>>>> +       error = request_irq(irq, handler, IRQF_SHARED, name, ndev);
>>>>
>>>>      Not sure if we need IRQF_SHARED on those IRQs, they're not really
>>>> shareable...
>>>
>>> I don't know whether this causes something bad.
>>> I think this controller is supporting a shared IRQ.
>>
>>     Based on the high-level trigger, I'd rather suspect not. Anyway, all the
>> SoC IRQs are dedicated to a certain (single) source.
>
> I don't want to change that if there is no fatal issue in the use of
> IRQF_SHARED.
> However, I will remove the flag if it is simple waste...

    It's not a waste but it just shouldn't be needed.

[...]

>>>>      OK, I'll now proceed to sanity-testing this patch on the gen2
>>>> hardware.
>>
>>     I'm afraid this will have to wait until I have a gen2 board with fully
>> working AVB... :-(
>
> Does it take long time?

    Unfortunately. :-(
    I wasn't able to get the AVB driver to work on the modified Porter board 
and now I've ascertained that it doesn't work on the re-jumpred Alt board too, 
seemingly for the same reason -- the AVB_MDIO pin gets stuck at 1 during the 
MDIO bus scan, so the device opening fails due to the driver not able to 
connect to PHY. LTSI 3.10 based kernels do work, however...

> Thanks,
> kaneko

MBR, Sergei
