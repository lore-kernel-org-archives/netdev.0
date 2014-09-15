From: Zhi Li <lznuaa@gmail.com>
Subject: Re: [Patch v4 net-next 04/12] net: fec: parser max queue number from
 dt file
Date: Mon, 15 Sep 2014 08:21:28 -0500
Message-ID: <CAHrpEqS3aVoWxi_E_dvCkfZJaFwC_HUvjn5u1x=zLSd-vcYyuA@mail.gmail.com>
References: <1410555657-10744-1-git-send-email-Frank.Li@freescale.com>
	<1410555657-10744-5-git-send-email-Frank.Li@freescale.com>
	<20140915093926.11bdbc32@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Duan Fugang-B38611 <b38611@freescale.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Shawn Guo <shawn.guo@linaro.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: =?UTF-8?Q?Lothar_Wa=C3=9Fmann?= <LW@karo-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:37519 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbaIONVb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 09:21:31 -0400
In-Reply-To: <20140915093926.11bdbc32@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 2:39 AM, Lothar Wa=C3=9Fmann <LW@karo-electroni=
cs.de> wrote:
> Hi,
>
> Frank.Li@freescale.com wrote:
>> From: Fugang Duan <B38611@freescale.com>
>>
>> By default, the tx/rx queue number is 1, user can config the queue n=
umber
>> at DTS file like this:
>>       fsl,num-tx-queues=3D<3>;
>>       fsl,num-rx-queues=3D<3>
>>
>> Since i.MX6SX enet-AVB IP support multi queues, so use multi queues
>> interface to allocate and set up an Ethernet device.
>>
>> Signed-off-by: Fugang Duan <B38611@freescale.com>
>> Signed-off-by: Frank Li <Frank.Li@freescale.com>
>> ---
>>  drivers/net/ethernet/freescale/fec.h      |  2 ++
>>  drivers/net/ethernet/freescale/fec_main.c | 46 ++++++++++++++++++++=
++++++++++-
>>  2 files changed, 47 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethe=
rnet/freescale/fec.h
>> index b2b91f8..72fb90f 100644
>> --- a/drivers/net/ethernet/freescale/fec.h
>> +++ b/drivers/net/ethernet/freescale/fec.h
>> @@ -356,6 +356,8 @@ struct fec_enet_private {
>>
>>       bool ptp_clk_on;
>>       struct mutex ptp_clk_mutex;
>> +     unsigned int num_tx_queues;
>> +     unsigned int num_rx_queues;
>>
>>       /* The saved address of a sent-in-place packet/buffer, for skf=
ree(). */
>>       struct fec_enet_priv_tx_q *tx_queue[FEC_ENET_MAX_TX_QS];
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net=
/ethernet/freescale/fec_main.c
>> index 4c0d2ee..2240df0 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -2709,6 +2709,42 @@ static void fec_reset_phy(struct platform_dev=
ice *pdev)
>>  }
>>  #endif /* CONFIG_OF */
>>
>> +static void
>> +fec_enet_get_queue_num(struct platform_device *pdev, int *num_tx, i=
nt *num_rx)
>> +{
>> +     struct device_node *np =3D pdev->dev.of_node;
>> +     int err;
>> +
>> +     *num_tx =3D *num_rx =3D 1;
>> +
>> +     if (!np || !of_device_is_available(np))
>> +             return;
>> +
>> +     /* parse the num of tx and rx queues */
>> +     err =3D of_property_read_u32(np, "fsl,num-tx-queues", num_tx);
>> +     err |=3D of_property_read_u32(np, "fsl,num-rx-queues", num_rx)=
;
>> +     if (err) {
>> +             *num_tx =3D 1;
>> +             *num_rx =3D 1;
> Shouldn't these be handled seperately? So that if only one of those
> properties is given in DT the specified value for that property shoul=
d
> be used?
>
>> +             return;
>> +     }
>> +
>> +     if (*num_tx < 1 || *num_tx > FEC_ENET_MAX_TX_QS) {
>> +             dev_err(&pdev->dev, "Invalidate num_tx(=3D%d), fail ba=
ck to 1\n",
>>
> s/Invalidate/Invalid/
> s/fail/fall/
> If the problem is fixed up by the driver rather than leading to an
> error exit it should be dev_warn() rather than dev_err().
>
>> +                     *num_tx);
>> +             *num_tx =3D 1;
>> +             return;
>> +     }
>> +
>> +     if (*num_rx < 1 || *num_rx > FEC_ENET_MAX_RX_QS) {
>> +             dev_err(&pdev->dev, "Invalidate num_rx(=3D%d), fail ba=
ck to 1\n",
> dto.
>
>> +                     *num_rx);
>> +             *num_rx =3D 1;
>> +             return;
>> +     }
>> +
>> +}
>> +
>>  static int
>>  fec_probe(struct platform_device *pdev)
>>  {
>> @@ -2720,13 +2756,18 @@ fec_probe(struct platform_device *pdev)
>>       const struct of_device_id *of_id;
>>       static int dev_id;
>>       struct device_node *np =3D pdev->dev.of_node, *phy_node;
>> +     int num_tx_qs =3D 1;
>> +     int num_rx_qs =3D 1;
>>
> useless initialization. These variables are initialized in
> fec_enet_get_queue_num() anyway.


David have applied the whole patch serials.
How to handle it? use new patch?

best regards
=46rank Li

>
>>       of_id =3D of_match_device(fec_dt_ids, &pdev->dev);
>>       if (of_id)
>>               pdev->id_entry =3D of_id->data;
>>
>> +     fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
>> +
>
>
> Lothar Wa=C3=9Fmann
> --
> ___________________________________________________________
>
> Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
> Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
> Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
> Handelsregistereintrag: Amtsgericht Aachen, HRB 4996
>
> www.karo-electronics.de | info@karo-electronics.de
> ___________________________________________________________
