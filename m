From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Tue, 22 Mar 2016 00:56:49 +0300
Message-ID: <56F06E21.7010507@cogentembedded.com>
References: <56E99727.9040702@laposte.net>
 <56F05651.3030706@cogentembedded.com> <20160321204111.GB6191@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastian Frias <sf84@laposte.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Daniel Mack <zonque@gmail.com>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160321204111.GB6191@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/21/2016 11:41 PM, Uwe Kleine-K=F6nig wrote:

>>> Commit 687908c2b649 ("net: phy: at803x: simplify using
>>> devm_gpiod_get_optional and its 4th argument") introduced a depende=
ncy
>>> on GPIOLIB that was not there before.
>>>
>>> This commit removes such dependency by checking the return code and
>>> comparing it against ENOSYS which is returned when GPIOLIB is not
>>> selected.
>>>
>>> Fixes: 687908c2b649 ("net: phy: at803x: simplify using
>>> devm_gpiod_get_optional and its 4th argument")
>>>
>>> Signed-off-by: Sebastian Frias <sf84@laposte.net>
>>
>>     Do you have the PHY that requires the GPIO reset workaround?
>> Askinjg because I have the patch adding the "reset-gpios" prop handl=
ing to
>> phylib and your patch made me aware that I'll have to modify this dr=
iver in
>> order to do that...
>>
>>> ---
>>>   drivers/net/phy/at803x.c | 4 +++-
>>>   1 file changed, 3 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
>>> index 2174ec9..88b7ff3 100644
>>> --- a/drivers/net/phy/at803x.c
>>> +++ b/drivers/net/phy/at803x.c
>>> @@ -252,7 +252,9 @@ static int at803x_probe(struct phy_device *phyd=
ev)
>>>   		return -ENOMEM;
>>>
>>>   	gpiod_reset =3D devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_=
HIGH);
>>> -	if (IS_ERR(gpiod_reset))
>>> +	if (PTR_ERR(gpiod_reset) =3D=3D -ENOSYS)
>>> +		gpiod_reset =3D NULL;
>>> +	else if (IS_ERR(gpiod_reset))
>>     		return PTR_ERR(gpiod_reset);
>>
>>     My patch basically gets rid of all this code. The thing that wor=
ries me
>> is that the driver assumes that the reset singal is active low, desp=
ite what
>> the GPIO specifier in the device tree has for the GPIO polarity. In =
fact, it
>> will only work correctly if the specified has GPIO_ACTIVE_HIGH -- wh=
ich is
>> wrong because the reset signal is active low!
>
> Note that gpio descriptors handle the polarity just fine (i.e. the pi=
n
> is set to 0 after doing gpiod_set_value(1) if the gpio is active low)=
=2E

    I know. :-)

> But having said that, the driver gets it wrong.
>
> The right sequence to reset a device using a gpio is:
>
> 	gpiod_set_value(priv->gpiod_reset, 1);
> 	msleep(some_time);
> 	gpiod_set_value(priv->gpiod_reset, 0);
>
> and if the gpio is active low, this should be specified in the device
> tree. This was done wrong in 13a56b449325 (net: phy: at803x: Add supp=
ort
> for hardware reset).

    I wonder if that was done before GPIO_ACTIVE_* thing was introduced=
=2E..=20
there are precedents in other MAC drivers that want a separate=20
"phy-reset-active-low" or even -"high" prop...

> Best regards
> Uwe

MBR, Sergei
