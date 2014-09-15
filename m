From: Zhi Li <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Patch v4 net-next 04/12] net: fec: parser max queue number from
 dt file
Date: Mon, 15 Sep 2014 10:33:45 -0500
Message-ID: <CAHrpEqQHf7wDYhivq9MMY6cqFu73SEQEu+-YhVsyeeKO-An+zw@mail.gmail.com>
References: <1410555657-10744-1-git-send-email-Frank.Li@freescale.com>
	<1410555657-10744-5-git-send-email-Frank.Li@freescale.com>
	<20140915093926.11bdbc32@ipc1.ka-ro>
	<CAHrpEqTCBMn-P2O7VZOOLUN=Zbc8h_Ow9MKrv5cV5gZPENRqUw@mail.gmail.com>
	<20140915170804.39061c0d@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org" <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Duan Fugang-B38611 <b38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: =?UTF-8?Q?Lothar_Wa=C3=9Fmann?= <LW-AvR2QvxeiV7DiMYJYoSAnRvVK+yQ3ZXh@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140915170804.39061c0d-VjFSrY7JcPWvSplVBqRQBQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 15, 2014 at 10:08 AM, Lothar Wa=C3=9Fmann <LW@karo-electron=
ics.de> wrote:
> Hi,
>
> Zhi Li wrote:
>> On Mon, Sep 15, 2014 at 2:39 AM, Lothar Wa=C3=9Fmann <LW@karo-electr=
onics.de> wrote:
>> > Hi,
>> >
>> > Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org wrote:
>> >> From: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>> >>
>> >> By default, the tx/rx queue number is 1, user can config the queu=
e number
>> >> at DTS file like this:
>> >>       fsl,num-tx-queues=3D<3>;
>> >>       fsl,num-rx-queues=3D<3>
>> >>
>> >> Since i.MX6SX enet-AVB IP support multi queues, so use multi queu=
es
>> >> interface to allocate and set up an Ethernet device.
>> >>
>> >> Signed-off-by: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>> >> Signed-off-by: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>> >> ---
>> >>  drivers/net/ethernet/freescale/fec.h      |  2 ++
>> >>  drivers/net/ethernet/freescale/fec_main.c | 46 +++++++++++++++++=
+++++++++++++-
>> >>  2 files changed, 47 insertions(+), 1 deletion(-)
>> >>
>> >> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/e=
thernet/freescale/fec.h
>> >> index b2b91f8..72fb90f 100644
>> >> --- a/drivers/net/ethernet/freescale/fec.h
>> >> +++ b/drivers/net/ethernet/freescale/fec.h
>> >> @@ -356,6 +356,8 @@ struct fec_enet_private {
>> >>
>> >>       bool ptp_clk_on;
>> >>       struct mutex ptp_clk_mutex;
>> >> +     unsigned int num_tx_queues;
>> >> +     unsigned int num_rx_queues;
>> >>
>> >>       /* The saved address of a sent-in-place packet/buffer, for =
skfree(). */
>> >>       struct fec_enet_priv_tx_q *tx_queue[FEC_ENET_MAX_TX_QS];
>> >> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/=
net/ethernet/freescale/fec_main.c
>> >> index 4c0d2ee..2240df0 100644
>> >> --- a/drivers/net/ethernet/freescale/fec_main.c
>> >> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> >> @@ -2709,6 +2709,42 @@ static void fec_reset_phy(struct platform_=
device *pdev)
>> >>  }
>> >>  #endif /* CONFIG_OF */
>> >>
>> >> +static void
>> >> +fec_enet_get_queue_num(struct platform_device *pdev, int *num_tx=
, int *num_rx)
>> >> +{
>> >> +     struct device_node *np =3D pdev->dev.of_node;
>> >> +     int err;
>> >> +
>> >> +     *num_tx =3D *num_rx =3D 1;
>> >> +
>> >> +     if (!np || !of_device_is_available(np))
>> >> +             return;
>> >> +
>> >> +     /* parse the num of tx and rx queues */
>> >> +     err =3D of_property_read_u32(np, "fsl,num-tx-queues", num_t=
x);
>> >> +     err |=3D of_property_read_u32(np, "fsl,num-rx-queues", num_=
rx);
>> >> +     if (err) {
>> >> +             *num_tx =3D 1;
>> >> +             *num_rx =3D 1;
>> > Shouldn't these be handled seperately? So that if only one of thos=
e
>> > properties is given in DT the specified value for that property sh=
ould
>> > be used?
>>
>> I worry about asymmetric design in future.
>>
> Then why do you use two distinct properties in the first place?

Sorry, I miss understand your means firstly.
I see now.
You are right.

Because David has applied this patch, I will create a new patch to fix =
it.

>
>> And use two property is the easy debug two directory.
>>
> I don't understand this sentence.
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
> www.karo-electronics.de | info-AvR2QvxeiV7DiMYJYoSAnRvVK+yQ3ZXh@public.gmane.org
> ___________________________________________________________
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
