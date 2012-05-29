From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: Re: [PATCH] r6040: disable pci device if the subsequent calls (after
 pci_enable_device) fails
Date: Tue, 29 May 2012 15:28:51 +0530
Message-ID: <CAHdPZaPWM3MfyARfwOm2KkKPPvm4dEfncF47N2xASyp27HdzsA@mail.gmail.com>
References: <1338206223-26781-1-git-send-email-devendra.aaru@gmail.com>
	<1659482.3g1Zl6FDuM@flexo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1659482.3g1Zl6FDuM@flexo>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Florian,

On Tue, May 29, 2012 at 2:50 PM, Florian Fainelli <florian@openwrt.org>=
 wrote:
> On Monday 28 May 2012 17:27:03 Devendra Naga wrote:
>> the calls after the pci_enable_device may fail, and will error out w=
ith out
>> disabling it. disable the device at error paths.
>
> Looks good, thanks Devendra!
>
>>
>> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
>
> Acked-by: Florian Fainelli <florian@openwrt.org>
>
>> ---
>> =A0drivers/net/ethernet/rdc/r6040.c | =A0 10 ++++++----
>> =A01 file changed, 6 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/rdc/r6040.c
> b/drivers/net/ethernet/rdc/r6040.c
>> index 4de7364..8f5079a 100644
>> --- a/drivers/net/ethernet/rdc/r6040.c
>> +++ b/drivers/net/ethernet/rdc/r6040.c
>> @@ -1096,20 +1096,20 @@ static int __devinit r6040_init_one(struct p=
ci_dev
> *pdev,
>> =A0 =A0 =A0 if (err) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "32-bit PCI DMA addr=
esses"
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "not sup=
ported by the card\n");
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto err_out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto err_out_disable_dev;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 err =3D pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(3=
2));
>> =A0 =A0 =A0 if (err) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "32-bit PCI DMA addr=
esses"
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "not sup=
ported by the card\n");
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto err_out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto err_out_disable_dev;
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 /* IO Size check */
>> =A0 =A0 =A0 if (pci_resource_len(pdev, bar) < io_size) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "Insufficient PCI re=
sources, aborting\n");
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EIO;
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto err_out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto err_out_disable_dev;
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 pci_set_master(pdev);
>> @@ -1117,7 +1117,7 @@ static int __devinit r6040_init_one(struct pci=
_dev
> *pdev,
>> =A0 =A0 =A0 dev =3D alloc_etherdev(sizeof(struct r6040_private));
>> =A0 =A0 =A0 if (!dev) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOMEM;
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto err_out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto err_out_disable_dev;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 SET_NETDEV_DEV(dev, &pdev->dev);
>> =A0 =A0 =A0 lp =3D netdev_priv(dev);
>> @@ -1238,6 +1238,8 @@ err_out_free_res:
>> =A0 =A0 =A0 pci_release_regions(pdev);
>> =A0err_out_free_dev:
>> =A0 =A0 =A0 free_netdev(dev);
>> +err_out_disable_dev:
>> + =A0 =A0 pci_disable_device(dev);
>> =A0err_out:
>> =A0 =A0 =A0 return err;
>> =A0}
>> --
>> 1.7.9.5
>>

Thanks for the Ack.
I found one more problem. Its when mdiobus_alloc fails in
r6040_init_one, we need to do call to the netif_napi_del and set the
NULL to pci_set_drvdata, at  err_out_unmap.

Thanks,
Devendra.
