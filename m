From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH/RFC v4 net-next] ravb: Add dma queue interrupt support
Date: Tue, 9 Feb 2016 02:19:03 +0900
Message-ID: <CAH1o70JFUVaRb07ivtnZhOYNbh8n2mdZpH41nsMjEenx5yNeeQ@mail.gmail.com>
References: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
	<56AA4674.6020001@cogentembedded.com>
	<CAH1o70LRuYwKGwhWBy1m6AuWfe-rNRBER7-Oi2u84ahX5+NyuA@mail.gmail.com>
	<56B77A57.2080902@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <56B77A57.2080902@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei-san,

2016-02-08 2:09 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
> On 02/07/2016 07:50 PM, Yoshihiro Kaneko wrote:
>
>> I apologize for not responding to you earlier.
>
>
>    Absolutely no problem, these reviews/tests take time from my main tasks
> anyway. :-)
>
>
>>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>>
>>>> This patch supports the following interrupts.
>>>>
>>>> - One interrupt for multiple (descriptor, error, management)
>>>> - One interrupt for emac
>>>> - Four interrupts for dma queue (best effort rx/tx, network control
>>>> rx/tx)
>>>>
>>>> This patch improve efficiency of the interrupt handler by adding the
>>>> interrupt handler corresponding to each interrupt source described
>>>> above. Additionally, it reduces the number of times of the access to
>>>> EthernetAVB IF.
>>>>
>>>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>>>> ---
>>>>
>>>> This patch is based on the master branch of David Miller's next
>>>> networking
>>>> tree.
>>>>
>>>> v4 [Yoshihiro Kaneko]
>>>> * compile tested only
>>>> * As suggested by Sergei Shtylyov
>>>>     drivers/net/ethernet/renesas/ravb.h:
>>>>       - make two lines of comment into one line.
>>>>       - remove unused definition of xxx_ALL.
>>>>     drivers/net/ethernet/renesas/ravb_main.c:
>>>>       - remove unrelated change (fix indentation).
>>>>       - output warning messages when napi_schedule_prep() fails in
>>>> ravb_dmaq_
>>>>         interrupt() like ravb_interrupt().
>>>>       - change the function name from req_irq to hook_irq.
>>>>       - fix programming error in hook_irq().
>>>>       - do free_irq() for rx_irqs[] and tx_irqs[] for only gen3 in
>>>> out_free_
>>>>         irq label in ravb_open().
>>>>
>>>> v3 [Yoshihiro Kaneko]
>>>> * compile tested only
>>>> * As suggested by Sergei Shtylyov
>>>>     - update changelog
>>>>     drivers/net/ethernet/renesas/ravb.h:
>>>>       - add comments to the additional registers like CIE
>>>>     drivers/net/ethernet/renesas/ravb_main.c:
>>>>       - fix the initialization of the interrupt in ravb_dmac_init()
>>>>       - revert ravb_error_interrupt() because gen3 code is wrong
>>>>       - change the comment "Management" in ravb_multi_interrupt()
>>>>       - add a helper function for request_irq() in ravb_open()
>>>>       - revert ravb_close() because atomicity is not necessary here
>>>>     drivers/net/ethernet/renesas/ravb_ptp.c:
>>>>       - revert ravb_ptp_stop() because atomicity is not necessary here
>>>>
>>>> v2 [Yoshihiro Kaneko]
>>>> * compile tested only
>>>> * As suggested by Sergei Shtylyov
>>>>     - add comment to CIE
>>>>     - remove comments from CIE bits
>>>>     - fix value of TIx_ALL
>>>>     - define each bits for CIE, GIE, GID, RIE0, RID0, RIE2, RID2, TIE,
>>>> TID
>>>>     - reversed Christmas tree declaration ordered
>>>>     - rename _ravb_emac_interrupt() to ravb_emac_interrupt_unlocked()
>>>>     - remove unnecessary clearing of CIE
>>>>     - use a bit name corresponding to the target register, RIE0, RIE2,
>>>> TIE,
>>>>       TID, RID2, GID, GIE
>>>
>>>
>>>
>>>     As I already noted, the changes made to the original patch are
>>> supposed
>>> to be documented above --- (no need to separate diff versions there
>>> though).
>>>     Either that, or just say that it's your patch, based on
>>> Mizuguchi-san's
>>> work (the amount of changes makes that possible, I think).
>>
>>
>> I will record that I made a change to this patch in the commit log of
>> the next version.
>> I don't think that I changed the essence of this patch. I changed
>> various trivial things, or fixed bugs you pointed out.
>
>
>    OK, as you wish. But in case this gets too tedious, I'll understand if
> you change the authorship.
>
>>> [...]
>>>>
>>>>
>>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>>>> b/drivers/net/ethernet/renesas/ravb_main.c
>>>> index ac43ed9..076f25f 100644
>>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>
>
> [...]
>
>>>
>>>> +
>>>> +       spin_lock(&priv->lock);
>>>> +
>>>> +       ris0 = ravb_read(ndev, RIS0);
>>>> +       ric0 = ravb_read(ndev, RIC0);
>>>> +       tis  = ravb_read(ndev, TIS);
>>>> +       tic  = ravb_read(ndev, TIC);
>>>> +
>>>> +       /* Timestamp updated */
>>>> +       if (tis & TIS_TFUF) {
>>>> +               ravb_write(ndev, TID_TFUD, TID);
>>>
>>>
>>>
>>>     Wait, you're supposed to clear the TFUF interrupt, not to disable!
>>
>>
>> Thanks for finding this bug.
>>
>>> And with that fixed, this interrupt's handler could get factored out into
>>> a
>>> function...
>>
>>
>> Is this not too small to make a function?
>
>
>    I wouldn't say so. But need to count the summary LoCs, of course...
> perhaps indeed not worth it...

I don't feel need for making it a function.
It only clears the interrupt and calls ravb_get_tx_tstamp(). The main processing
is executed in ravb_get_tx_tstamp(). And the caller is only one place
(ravb_interrupt)
other than here.

>
> [...]
>
>>>> @@ -1215,29 +1332,64 @@ static const struct ethtool_ops ravb_ethtool_ops
>>>> =
>>>> {
>>>>          .get_ts_info            = ravb_get_ts_info,
>>>>    };
>>>>
>>>> +static inline int hook_irq(unsigned int irq, irq_handler_t handler,
>
>
>>>     Namespacing this function with 'ravb_' prefix would be preferable, I
>>> did
>>> that for all functions, even those that didn't have this prefix in
>>> sh_eth...
>
>
>    Didn't have 'sh_eth_' prefix, I meant.
>
>> Got it.
>
>
>    OK.
>
>>>
>>>> +                          struct net_device *ndev, struct device *dev,
>>>> +                          const char *ch)
>>>> +{
>>>> +       char *name;
>>>> +       int error;
>>>> +
>>>> +       name = devm_kasprintf(dev, GFP_KERNEL, "%s:%s", ndev->name, ch);
>>>> +       error = request_irq(irq, handler, IRQF_SHARED, name, ndev);
>>>
>>>
>>>
>>>     Not sure if we need IRQF_SHARED on those IRQs, they're not really
>>> shareable...
>>
>>
>> I don't know whether this causes something bad.
>> I think this controller is supporting a shared IRQ.
>
>
>    Based on the high-level trigger, I'd rather suspect not. Anyway, all the
> SoC IRQs are dedicated to a certain (single) source.

I don't want to change that if there is no fatal issue in the use of
IRQF_SHARED.
However, I will remove the flag if it is simple waste...

>
> [...]
>
> [...]
>>>
>>>
>>>     OK, I'll now proceed to sanity-testing this patch on the gen2
>>> hardware.
>
>
>    I'm afraid this will have to wait until I have a gen2 board with fully
> working AVB... :-(

Does it take long time?

>
>> Thanks,
>> kaneko
>
>
> MBR, Sergei
>

Thanks,
kaneko
