From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH net-next] net: stmmac: Handle different error codes from platform_get_irq_byname
Date: Wed, 28 May 2014 14:44:50 +0800
Message-ID: <CAGb2v66W4EkUkxEdE+7MQp6pYue_SycpXvktHhwr-tSEXXJ62Q@mail.gmail.com>
References: <1401166194-19085-1-git-send-email-wens@csie.org> <CAL_Jsq+dkdYsw+dQc_tuTT5FJ9QWk2cX7Lq4UiGEH2UqmB24gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev <netdev@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Kevin Hilman <khilman@linaro.org>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f178.google.com ([209.85.220.178]:50371 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050AbaE1GpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 02:45:11 -0400
Received: by mail-vc0-f178.google.com with SMTP id ij19so8624080vcb.9
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 23:45:10 -0700 (PDT)
In-Reply-To: <CAL_Jsq+dkdYsw+dQc_tuTT5FJ9QWk2cX7Lq4UiGEH2UqmB24gg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2014 at 8:58 AM, Rob Herring <robh@kernel.org> wrote:
> On Mon, May 26, 2014 at 11:49 PM, Chen-Yu Tsai <wens@csie.org> wrote:
>> The following patch moved device tree interrupt resolution into
>> platform_get_irq_byname:
>>
>>   ad69674 of/irq: do irq resolution in platform_get_irq_byname()
>>
>> As a result, the function no longer only return -ENXIO on error.
>> This breaks DT based probing of stmmac, as seen in test runs of
>> linux-next next-20140526 cubie2-sunxi_defconfig:
>>
>>   http://lists.linaro.org/pipermail/kernel-build-reports/2014-May/003659.html
>>
>> This patch makes the stmmac_platform probe function properly handle
>> error codes, such as returning for deferred probing, and other codes
>> returned by of_irq_get_by_name.
>
> ST u8500 is also broken as reported by Kevin Hilman.

Saw the mail today.

>>
>> Signed-off-by: Chen-Yu Tsai <wens@csie.org>
>> ---
>>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c    | 20 +++++++++++++++-----
>>  1 file changed, 15 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> index 46aef510..9562b18 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> @@ -237,10 +237,12 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
>>
>>         /* Get the MAC information */
>>         priv->dev->irq = platform_get_irq_byname(pdev, "macirq");
>> -       if (priv->dev->irq == -ENXIO) {
>> -               pr_err("%s: ERROR: MAC IRQ configuration "
>> -                      "information not found\n", __func__);
>> -               return -ENXIO;
>> +       if (priv->dev->irq < 0) {
>> +               if (priv->wol_irq != -EPROBE_DEFER) {
>
> s/wol_irq/dev->irq/

Copy paste error :(

>> +                       pr_err("%s: ERROR: MAC IRQ configuration "
>
> netdev_err
>
>> +                              "information not found\n", __func__);
>
> Don't split strings.

It was in the original code. Will fix.

>> +               }
>> +               return priv->dev->irq;
>>         }
>>
>>         /*
>> @@ -252,10 +254,18 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
>>          * so the driver will continue to use the mac irq (ndev->irq)
>>          */
>>         priv->wol_irq = platform_get_irq_byname(pdev, "eth_wake_irq");
>> -       if (priv->wol_irq == -ENXIO)
>> +       if (priv->wol_irq < 0) {
>> +               if (priv->wol_irq == -EPROBE_DEFER)
>> +                       return -EPROBE_DEFER;
>>                 priv->wol_irq = priv->dev->irq;
>> +       }
>>
>>         priv->lpi_irq = platform_get_irq_byname(pdev, "eth_lpi");
>> +       if (priv->lpi_irq < 0) {
>
> You don't need this if.

stmmac core driver checks lpi_irq != -ENXIO for valid interrupt.
Might as well change that check to  lpi_irq >= 0.
(0 is a valid interrupt, correct?)

Interestingly, stmmac_pci never sets lpi_irq, there might be a glitch
there.

>> +               if (priv->wol_irq == -EPROBE_DEFER)
>
> s/wol_irq/lpi_irq/

ditto

>> +                       return -EPROBE_DEFER;
>> +               priv->lpi_irq = -ENXIO;
>> +       }
>>
>>         platform_set_drvdata(pdev, priv->dev);
>>
>> --
>> 2.0.0.rc2
>>


Thanks
ChenYu
