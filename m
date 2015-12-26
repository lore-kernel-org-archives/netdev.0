From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v2 net-next] ravb: Add dma queue interrupt support
Date: Sun, 27 Dec 2015 02:09:21 +0300
Message-ID: <567F1E21.2040900@cogentembedded.com>
References: <1450602948-6777-1-git-send-email-ykaneko0929@gmail.com>
 <56796600.3010407@cogentembedded.com>
 <CAH1o70JdmPDchbCnRjbt+SmW4juow+ConD96_BBv8u51-KEW6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAH1o70JdmPDchbCnRjbt+SmW4juow+ConD96_BBv8u51-KEW6A@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/26/2015 02:26 PM, Yoshihiro Kaneko wrote:

>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>
>>> This patch supports the following interrupts.
>>>
>>> - One interrupt for multiple (descriptor, error, management)
>>> - One interrupt for emac
>>> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
>>
>>     You still don't say why it's better than the current scheme...
>
> I missed the comment for some reason.
> I will think about updating the changelog.

    TIA.

>>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
[...]
>>> b/drivers/net/ethernet/renesas/ravb.h
>>> index 9fbe92a..71badd6d 100644
>>> --- a/drivers/net/ethernet/renesas/ravb.h
>>> +++ b/drivers/net/ethernet/renesas/ravb.h
[...]
>>> @@ -1223,23 +1343,68 @@ static const struct ethtool_ops ravb_ethtool_ops =
>>> {
>>>    static int ravb_open(struct net_device *ndev)
>>>    {
>>>          struct ravb_private *priv = netdev_priv(ndev);
>>> -       int error;
>>> +       struct platform_device *pdev = priv->pdev;
>>> +       struct device *dev = &pdev->dev;
>>> +       int error, i;
>>> +       char *name;
>>>
>>>          napi_enable(&priv->napi[RAVB_BE]);
>>>          napi_enable(&priv->napi[RAVB_NC]);
>>>
>>> -       error = request_irq(ndev->irq, ravb_interrupt, IRQF_SHARED,
>>> ndev->name,
>>> -                           ndev);
>>> -       if (error) {
>>> -               netdev_err(ndev, "cannot request IRQ\n");
>>> -               goto out_napi_off;
>>> -       }
>>> -
>>> -       if (priv->chip_id == RCAR_GEN3) {
>>> -               error = request_irq(priv->emac_irq, ravb_interrupt,
>>> -                                   IRQF_SHARED, ndev->name, ndev);
>>> +       if (priv->chip_id == RCAR_GEN2) {
>>> +               error = request_irq(ndev->irq, ravb_interrupt,
>>> IRQF_SHARED,
>>> +                                   ndev->name, ndev);
>>>                  if (error) {
>>>                          netdev_err(ndev, "cannot request IRQ\n");
>>> +                       goto out_napi_off;
>>> +               }
>>> +       } else {
>>> +               name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch22:multi",
>>> +                                     ndev->name);
>>> +               error = request_irq(ndev->irq, ravb_multi_interrupt,
>>> +                                   IRQF_SHARED, name, ndev);
>>> +               if (error) {
>>> +                       netdev_err(ndev, "cannot request IRQ %s\n", name);
>>> +                       goto out_napi_off;
>>> +               }
>>> +               name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch24:emac",
>>> +                                     ndev->name);
>>> +               error = request_irq(priv->emac_irq, ravb_emac_interrupt,
>>> +                                   IRQF_SHARED, name, ndev);
>>> +               if (error) {
>>> +                       netdev_err(ndev, "cannot request IRQ %s\n", name);
>>> +                       goto out_free_irq;
>>> +               }
>>> +               name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch0:rx_be",
>>> +                                     ndev->name);
>>> +               error = request_irq(priv->rx_irqs[RAVB_BE],
>>> ravb_be_interrupt,
>>> +                                   IRQF_SHARED, name, ndev);
>>> +               if (error) {
>>> +                       netdev_err(ndev, "cannot request IRQ %s\n", name);
>>> +                       goto out_free_irq;
>>> +               }
>>> +               name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch18:tx_be",
>>> +                                     ndev->name);
>>> +               error = request_irq(priv->tx_irqs[RAVB_BE],
>>> ravb_be_interrupt,
>>> +                                   IRQF_SHARED, name, ndev);
>>> +               if (error) {
>>> +                       netdev_err(ndev, "cannot request IRQ %s\n", name);
>>> +                       goto out_free_irq;
>>> +               }
>>> +               name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch1:rx_nc",
>>> +                                     ndev->name);
>>> +               error = request_irq(priv->rx_irqs[RAVB_NC],
>>> ravb_nc_interrupt,
>>> +                                   IRQF_SHARED, name, ndev);
>>> +               if (error) {
>>> +                       netdev_err(ndev, "cannot request IRQ %s\n", name);
>>> +                       goto out_free_irq;
>>> +               }
>>> +               name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch19:tx_nc",
>>> +                                     ndev->name);
>>> +               error = request_irq(priv->tx_irqs[RAVB_NC],
>>> ravb_nc_interrupt,
>>> +                                   IRQF_SHARED, name, ndev);
>>> +               if (error) {
>>> +                       netdev_err(ndev, "cannot request IRQ %s\n", name);
>>>                          goto out_free_irq;
>>>                  }
>>
>>
>>     This error case is repetitive, couldn't you consolidate it somehow?
>
> It seems to be impossible to be solved by the simple change of the code.
> Do you intend to add macro or a small helper function?

    What I meant should look like this:

	} else {
		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch22:multi",
				      ndev->name);
		error = request_irq(ndev->irq, ravb_multi_interrupt,
				    IRQF_SHARED, name, ndev);
		if (error)
			goto out;
[...]
		name = devm_kasprintf(dev, GFP_KERNEL, "%s:ch19:tx_nc",
				      ndev->name);
		error = request_irq(priv->tx_irqs[RAVB_NC], ravb_nc_interrupt,
                                    IRQF_SHARED, name, ndev);
		if (error)
			goto out;
	}

out:
	if (error) {
		netdev_err(ndev, "cannot request IRQ %s\n", name);
		goto out_free_irq;
	}

    Did it make things clearer?
    But indeed, a helper function would probably be even better...

[...]
>>> @@ -1798,6 +1973,22 @@ static int ravb_probe(struct platform_device *pdev)
>>>                          goto out_release;
>>>                  }
>>>                  priv->emac_irq = irq;
>>> +               for (i = 0; i < NUM_RX_QUEUE; i++) {
>>> +                       irq = platform_get_irq_byname(pdev,
>>> ravb_rx_irqs[i]);
>>> +                       if (irq < 0) {
>>> +                               error = irq;
>>> +                               goto out_release;
>>> +                       }
>>> +                       priv->rx_irqs[i] = irq;
>>> +               }
>>> +               for (i = 0; i < NUM_TX_QUEUE; i++) {
>>> +                       irq = platform_get_irq_byname(pdev,
>>> ravb_tx_irqs[i]);
>>> +                       if (irq < 0) {
>>> +                               error = irq;
>>> +                               goto out_release;
>>> +                       }
>>> +                       priv->tx_irqs[i] = irq;
>>> +               }
>>
>>
>>     Perhaps it would better to use sprintf() here, in both loops...
>
> Could you give me some more details?

    I think it would be better to use sprintf() to generate the IRQ names 
passed to platfrom_get_irq_byname() instead of string literals grouped into 
arrays. I may be wrong though...

[...]

> Thanks,
> kaneko

MBR, Sergei

