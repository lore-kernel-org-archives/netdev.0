From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: Remove checks on clock handles
Date: Wed, 22 Jul 2015 16:56:01 -0700
Message-ID: <55B02D91.1020800@gmail.com>
References: <1437603114-27235-1-git-send-email-f.fainelli@gmail.com> <CAGXr9JEtRD0eY9aS1_M+cVYueoa8xnPBSwtCs1LEHyeyrDyLxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:36289 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611AbbGVX57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 19:57:59 -0400
Received: by pdjr16 with SMTP id r16so148982974pdj.3
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 16:57:59 -0700 (PDT)
In-Reply-To: <CAGXr9JEtRD0eY9aS1_M+cVYueoa8xnPBSwtCs1LEHyeyrDyLxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/07/15 16:52, Petri Gynther wrote:
> On Wed, Jul 22, 2015 at 3:11 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>
>> Instead of multiplying the number of checks for IS_ERR(priv->clk),
>> simply NULLify the 'struct clk' pointer which is something the Linux
>> common clock framework perfectly deals with and does early return for
>> each and every single clk_* API functions.
>>
>> Having every single function check for !IS_ERR(priv->clk) is both
>> redundant and error prone, as it turns out, we were doing it for the
>> main GENET clock: priv->clk, but not for the Wake-on-LAN or EEE clock,
>> so let's just be consistent here.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 20 ++++++++++----------
>>  1 file changed, 10 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> index 5bf7ce0ae221..133bb10fdd34 100644
>> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> @@ -2625,8 +2625,7 @@ static int bcmgenet_open(struct net_device *dev)
>>         netif_dbg(priv, ifup, dev, "bcmgenet_open\n");
>>
>>         /* Turn on the clock */
>> -       if (!IS_ERR(priv->clk))
>> -               clk_prepare_enable(priv->clk);
>> +       clk_prepare_enable(priv->clk);
>>
>>         /* If this is an internal GPHY, power it back on now, before UniMAC is
>>          * brought out of reset as absolutely no UniMAC activity is allowed
>> @@ -2703,8 +2702,7 @@ err_irq0:
>>  err_fini_dma:
>>         bcmgenet_fini_dma(priv);
>>  err_clk_disable:
>> -       if (!IS_ERR(priv->clk))
>> -               clk_disable_unprepare(priv->clk);
>> +       clk_disable_unprepare(priv->clk);
>>         return ret;
>>  }
>>
>> @@ -2761,8 +2759,7 @@ static int bcmgenet_close(struct net_device *dev)
>>         if (priv->internal_phy)
>>                 ret = bcmgenet_power_down(priv, GENET_POWER_PASSIVE);
>>
>> -       if (!IS_ERR(priv->clk))
>> -               clk_disable_unprepare(priv->clk);
>> +       clk_disable_unprepare(priv->clk);
>>
>>         return ret;
>>  }
>> @@ -3215,11 +3212,12 @@ static int bcmgenet_probe(struct platform_device *pdev)
>>                 priv->version = pd->genet_version;
>>
>>         priv->clk = devm_clk_get(&priv->pdev->dev, "enet");
>> -       if (IS_ERR(priv->clk))
>> +       if (IS_ERR(priv->clk)) {
>>                 dev_warn(&priv->pdev->dev, "failed to get enet clock\n");
>> +               priv->clk = NULL;
>> +       }
> 
> Wouldn't the above be a fatal error? If you can't get the enet main
> clock, any point to go further in this code?

No, you could have a system with no clock provider at all because:

- you purposely disabled your clock driver
- you removed clock phandles from e.g: Device Tree

but your HW might still be turned on by default and this would be by design.

> 
>>
>> -       if (!IS_ERR(priv->clk))
>> -               clk_prepare_enable(priv->clk);
>> +       clk_prepare_enable(priv->clk);
>>
>>         bcmgenet_set_hw_params(priv);
>>
>> @@ -3230,8 +3228,10 @@ static int bcmgenet_probe(struct platform_device *pdev)
>>         INIT_WORK(&priv->bcmgenet_irq_work, bcmgenet_irq_task);
>>
>>         priv->clk_wol = devm_clk_get(&priv->pdev->dev, "enet-wol");
>> -       if (IS_ERR(priv->clk_wol))
>> +       if (IS_ERR(priv->clk_wol)) {
>>                 dev_warn(&priv->pdev->dev, "failed to get enet-wol clock\n");
>> +               priv->clk_wol = NULL;
>> +       }
>>
>>         priv->clk_eee = devm_clk_get(&priv->pdev->dev, "enet-eee");
>>         if (IS_ERR(priv->clk_eee)) {
>> --
>> 2.1.0
>>
> 
> Looking at the rest of the code in bcmgenet_probe(), I still see:
>         /* Turn off the main clock, WOL clock is handled separately */
>         if (!IS_ERR(priv->clk))
>                 clk_disable_unprepare(priv->clk);
> 
> err_clk_disable:
>         if (!IS_ERR(priv->clk))
>                 clk_disable_unprepare(priv->clk);
> 
> you probably want to convert those as well, right?

Yes, thanks for catching these.
-- 
Florian
