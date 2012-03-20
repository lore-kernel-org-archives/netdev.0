From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/1] net: phylib: remove the length limitation of mii
 bus id
Date: Tue, 20 Mar 2012 15:06:57 +0100
Message-ID: <4F688F01.40604@openwrt.org>
References: <1332217386-3586-1-git-send-email-b29396@freescale.com> <CAAQ0ZWQEoPORMXsf3xV-KPP+hOHk2euj460fORyUALnfPn3Q8g@mail.gmail.com> <CAA+hA=Ttc9RDmK1fDPCtqLpf91DYDDFSf3E6zWQ6seyw7sNqTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@linaro.org>,
	Dong Aisheng <b29396@freescale.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <dongas86@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAA+hA=Ttc9RDmK1fDPCtqLpf91DYDDFSf3E6zWQ6seyw7sNqTg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Le 03/20/12 11:53, Dong Aisheng a =C3=A9crit :
> On Tue, Mar 20, 2012 at 1:32 AM, Shawn Guo<shawn.guo@linaro.org>  wro=
te:
>> On 20 March 2012 12:23, Dong Aisheng<b29396@freescale.com>  wrote:
>>> From: Dong Aisheng<dong.aisheng@linaro.org>
>>>
>>> When convert to dt, the length of old mii bus id (17 bytes) is not
>>> sufficent to use.
>>> For example, the bus id could be 800f0000.ethernet-1:00 in DT.
>>>
>>> This patch removes the bus id length limitation by changing the
>>> bus id to a const char pionter and user could dynamically set the
>>> bus id via kasprintf function call.
>>>
>>> Since then no users use MII_BUS_ID_SIZE any more, just remove it.
>>>
>>> Signed-off-by: Dong Aisheng<dong.aisheng@linaro.org>
>>> ---
>>> The simplest way may just change MII_BUS_ID_SIZE to a more bigger s=
ize,
>>> but i'm not sure that's gonna be accepted.
>>
>> The simplest fix has been applied on -next tree as below.
>>
> Oh, i missed it, seems my patch covers that change.
> But that patch only fixed wrong phy_name buffer length issue.
> My patch is totally remove the length limitation of bus id and phy_na=
me
> or the bus id name will be truncated if it's longer than MII_BUS_ID_S=
IZE
> which is not a comfortable limitation.

Then just increase the bus id size locally for your driver. Drivers tha=
t=20
can live with a static allocation are better of using it.

Your patch completely missed testing the return value of kasprintf(),=20
and its return value can be NULL, please fix this at least.

>
>> commit a7ed07d51c8abdb407be454c6cb6cfad613759d9
>> Author: Richard Zhao<richard.zhao@linaro.org>
>> Date:   Sun Jan 29 22:08:12 2012 +0000
>>
>>     net: fec: correct phy_name buffer length when init phy_name
>>
>>     Fix the bug that we got wrong phy_name on imx6q sabrelite board.
>>     snprintf used wrong length of phy_name.
>>     phy_name length is MII_BUS_ID_SIZE + 3 rather not MII_BUS_ID_SIZ=
E.
>>     I change it to sizeof(phy_name).
>>
>>     Signed-off-by: Richard Zhao<richard.zhao@linaro.org>
>>     Acked-by: Shawn Guo<shawn.guo@linaro.org>
>>     Acked-by: Florian Fainelli<florian@openwrt.org>
>>     Signed-off-by: David S. Miller<davem@davemloft.net>
>>
>> diff --git a/drivers/net/ethernet/freescale/fec.c
>> b/drivers/net/ethernet/freescale/fec.c
>> index 7b25e9c..1c7aad8 100644
>> --- a/drivers/net/ethernet/freescale/fec.c
>> +++ b/drivers/net/ethernet/freescale/fec.c
>> @@ -990,7 +990,7 @@ static int fec_enet_mii_probe(struct net_device =
*ndev)
>>                 phy_id =3D 0;
>>         }
>>
>> -       snprintf(phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id,=
 phy_id);
>> +       snprintf(phy_name, sizeof(phy_name), PHY_ID_FMT, mdio_bus_id=
, phy_id);
>>         phy_dev =3D phy_connect(ndev, phy_name,&fec_enet_adjust_link=
, 0,
>>                               fep->phy_interface);
>>         if (IS_ERR(phy_dev)) {
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
