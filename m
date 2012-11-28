From: =?UTF-8?B?U3TDqXBoYW5lIEFOQ0VMT1Q=?= <sancelot@free.fr>
Subject: Re: RTL 8169  linux driver question
Date: Wed, 28 Nov 2012 01:35:18 +0100
Message-ID: <50B55C46.9090400@free.fr>
References: <50AFC971.7010103@free.fr> <50AFCB1D.8080002@free.fr> <AE90C24D6B3A694183C094C60CF0A2F6026B70BD@saturn3.aculab.com> <20121127224605.GA10228@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	=?UTF-8?B?U3TDqXBoYW5lIEFOQ0VM?= =?UTF-8?B?T1Q=?=
	<sancelot@numalliance.com>, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:54624 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753412Ab2K1Afc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 19:35:32 -0500
In-Reply-To: <20121127224605.GA10228@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/11/2012 23:46, Francois Romieu wrote:
> David Laight <David.Laight@ACULAB.COM> :
>> St=C3=A9phane ANCELOT <sancelot@free.fr> :
>>> I had problem with it, my application sends a frame that is immedia=
tely
>>> transmitted back by some slaves, there was abnormally 100us  lost
>>> between the send and receive call.
>>>
>>> Finally I found it was coming from the following register setup in =
the
>>> driver :
>>>
>>> RTL_W16(IntrMitigate, 0x5151);
>>>
>>> Can you give me some details about it, since I do not have the RTL8=
169
>>> programming guide.
>> That sounds like an 'interrupt mitigation' setting - which will caus=
e
>> RX interrupts to be delayed a short time in order to reduce the
>> interrupt load on the kernel.
>>
>> There is usually an 'ethtool' setting to disable interrupt mitigatio=
n.
> Something like the patch below against net-next could help once I wil=
l
> have tested it.
>
> I completely guessed the Tx usec scale factor at gigabit speed (125 u=
s,
> 100 us, disabled, who knows ?) and I have no idea which specific chip=
sets
> it should work with.
using 0x5151 value at 100mb FDX, I know it introduced exactly 100us=20
delay (Tx+Rx).


> Hayes, may I expect some hindsight regarding:
> 1 - the availability of the IntrMitigate (0xe2) register through the
>      8169, 8168 and 810x line of chipsets
> 2 - the Tx timer unit at gigabit speed
>
> It would save me some time.*
Hayes, it would have spared myself a lot of time ;-)

Have a look at what is driving this r8169 component :

http://www.youtube.com/watch?v=3Dwj30CeAFwuk&feature=3Dplcp
A question to nic components developers : I do not understand what=20
competitive advantage keeping these things like a secret....

These things are mostly boring for people and oem like myself at=20
Numalliance.

Regards,
Stephane Ancelot

> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index 248f883..2623b73 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -349,6 +349,12 @@ enum rtl_registers {
>   	RxMaxSize	=3D 0xda,
>   	CPlusCmd	=3D 0xe0,
>   	IntrMitigate	=3D 0xe2,
> +
> +#define RTL_COALESCE_MASK	0x0f
> +#define RTL_COALESCE_SHIFT	4
> +#define RTL_COALESCE_T_MAX	(RTL_COALESCE_MASK)
> +#define RTL_COALESCE_FRAME_MAX	(RTL_COALESCE_MASK << 2)
> +
>   	RxDescAddrLow	=3D 0xe4,
>   	RxDescAddrHigh	=3D 0xe8,
>   	EarlyTxThres	=3D 0xec,	/* 8169. Unit of 32 bytes. */
> @@ -1997,10 +2003,121 @@ static void rtl8169_get_strings(struct net_d=
evice *dev, u32 stringset, u8 *data)
>   	}
>   }
>  =20
> +static struct rtl_coalesce_scale {
> +	u32 speed;
> +	/* Rx / Tx */
> +	u16 usecs[2];
> +} rtl_coalesce_info[] =3D {
> +	{ .speed =3D SPEED_10,	.usecs =3D { 8000, 10000 } },
> +	{ .speed =3D SPEED_100,	.usecs =3D { 1000,  1000 } },
> +	{ .speed =3D SPEED_1000,	.usecs =3D {  125,   125 } }
> +};
> +
> +static struct rtl_coalesce_scale *rtl_coalesce_scale(struct net_devi=
ce *dev)
> +{
> +	struct ethtool_cmd ecmd;
> +	int rc, i;
> +
> +	rc =3D rtl8169_get_settings(dev, &ecmd);
> +	if (rc < 0)
> +		return ERR_PTR(rc);
> +
> +	for (i =3D 0; i < ARRAY_SIZE(rtl_coalesce_info); i++) {
> +		if (ethtool_cmd_speed(&ecmd) =3D=3D rtl_coalesce_info[i].speed)
> +			return rtl_coalesce_info + i;
> +	}
> +
> +	return ERR_PTR(-EINVAL);
> +}
> +
> +static int rtl_get_coalesce(struct net_device *dev, struct ethtool_c=
oalesce *ec)
> +{
> +	struct rtl8169_private *tp =3D netdev_priv(dev);
> +	void __iomem *ioaddr =3D tp->mmio_addr;
> +	struct rtl_coalesce_scale *scale;
> +	struct {
> +		u32 *max_frames;
> +		u32 *usecs;
> +	} coal_settings [] =3D {
> +		{ &ec->rx_max_coalesced_frames, &ec->rx_coalesce_usecs },
> +		{ &ec->tx_max_coalesced_frames, &ec->tx_coalesce_usecs }
> +	}, *p =3D coal_settings;
> +	int i;
> +	u16 w;
> +
> +	memset(ec, 0, sizeof(*ec));
> +
> +	for (w =3D RTL_R16(IntrMitigate); w; w >>=3D RTL_COALESCE_SHIFT, p+=
+) {
> +		*p->max_frames =3D (w & RTL_COALESCE_MASK) << 2;
> +		w >>=3D RTL_COALESCE_SHIFT;
> +		*p->usecs =3D w & RTL_COALESCE_MASK;
> +	}
> +
> +	/* Except for null parameeters, the meaning of coalescing parameter=
s
> +	 * depends on the link speed.
> +	 */
> +	scale =3D rtl_coalesce_scale(dev);
> +	if (PTR_ERR(scale) && (p !=3D coal_settings))
> +		return PTR_ERR(scale);
> +
> +	for (i =3D 0; i < 2; i++) {
> +		p =3D coal_settings + i;
> +		*p->usecs *=3D scale->usecs[i];
> +		if (!*p->usecs && !*p->max_frames)
> +			*p->max_frames =3D 1;
> +	}
> +
> +	return 0;
> +}
> +
> +static int rtl_set_coalesce(struct net_device *dev, struct ethtool_c=
oalesce *ec)
> +{
> +	struct rtl8169_private *tp =3D netdev_priv(dev);
> +	void __iomem *ioaddr =3D tp->mmio_addr;
> +	struct rtl_coalesce_scale *scale;
> +	struct {
> +		u32 frames;
> +		u32 usecs;
> +	} coal_settings [] =3D {
> +		{ ec->rx_max_coalesced_frames, ec->rx_coalesce_usecs },
> +		{ ec->tx_max_coalesced_frames, ec->tx_coalesce_usecs }
> +	}, *p =3D coal_settings;
> +	int i, rc;
> +	u16 w =3D 0;
> +
> +	scale =3D rtl_coalesce_scale(dev);
> +	rc =3D PTR_ERR(scale);
> +
> +	for (i =3D 0; i < 2; i++) {
> +		u32 units;
> +
> +		if (!p->usecs && p->frames =3D=3D 1)
> +			continue;
> +		if (rc < 0)
> +			goto out;
> +
> +		units =3D p->usecs / scale->usecs[i];
> +		if (units > RTL_COALESCE_T_MAX || p->usecs % scale->usecs[i] ||
> +		    p->frames > RTL_COALESCE_FRAME_MAX || p->frames % 4)
> +			return -EINVAL;
> +
> +		w <<=3D RTL_COALESCE_SHIFT;
> +		w |=3D units;
> +		w <<=3D RTL_COALESCE_SHIFT;
> +		w |=3D p->frames >> 2;
> +	}
> +
> +	RTL_W16(IntrMitigate, swab16(w));
> +out:
> +	return rc;
> +}
> +
>   static const struct ethtool_ops rtl8169_ethtool_ops =3D {
>   	.get_drvinfo		=3D rtl8169_get_drvinfo,
>   	.get_regs_len		=3D rtl8169_get_regs_len,
>   	.get_link		=3D ethtool_op_get_link,
> +	.get_coalesce		=3D rtl_get_coalesce,
> +	.set_coalesce		=3D rtl_set_coalesce,
>   	.get_settings		=3D rtl8169_get_settings,
>   	.set_settings		=3D rtl8169_set_settings,
>   	.get_msglevel		=3D rtl8169_get_msglevel,
