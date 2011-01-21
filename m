From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v3] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 21 Jan 2011 13:03:18 +0800
Message-ID: <AANLkTi=b9ma=xV1ovbJmy94BrDT696VR4OcyR9vqwGtB@mail.gmail.com>
References: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
 <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com> <1295550009.28001.59.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, eric.dumazet@gmail.com,
	dilinger@queued.net, Po-Yu Chuang <ratbert@faraday-tech.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295550009.28001.59.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Joe,

On Fri, Jan 21, 2011 at 3:00 AM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2011-01-20 at 23:30 +0800, Po-Yu Chuang wrote:
>> =C2=A0drivers/net/ftmac100.c | 1243 ++++++++++++++++++++++++++++++++=
++++++++++++++++
>
> []
>
>> +/******************************************************************=
************
>> + * struct napi_struct functions
>> + ******************************************************************=
***********/
>> +static int ftmac100_poll(struct napi_struct *napi, int budget)
>> +{
>> + =C2=A0 =C2=A0 struct ftmac100 *priv =3D container_of(napi, struct =
ftmac100, napi);
>> + =C2=A0 =C2=A0 struct net_device *netdev =3D priv->netdev;
>> + =C2=A0 =C2=A0 unsigned int status;
>> + =C2=A0 =C2=A0 bool completed =3D true;
>> + =C2=A0 =C2=A0 int rx =3D 0;
>> +
>> + =C2=A0 =C2=A0 status =3D ioread32(priv->base + FTMAC100_OFFSET_ISR=
);
>> +
>> + =C2=A0 =C2=A0 if (status & (FTMAC100_INT_RPKT_FINISH | FTMAC100_IN=
T_NORXBUF)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* FTMAC100_INT_RPK=
T_FINISH:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=
=A0RX DMA has received packets into RX buffer successfully
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* FTMAC100_INT_NOR=
XBUF:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=
=A0RX buffer unavailable
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool retry;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 retry =3D ftmac100_rx_packet(priv, &rx);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (retry && rx < b=
udget);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (retry && rx =3D=3D b=
udget)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 completed =3D false;
>
> Is it useful to retry the NORXBUF case?

The idea is that if I miss packet finished interrupts (then rx buffers =
used up),
I should retrieve the received packets ASAP to free buffers to HW.
Maybe this is really unnecessary.
I am not quite sure, but I'll do your advice now.

>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 if (status & FTMAC100_INT_NORXBUF) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* RX buffer unavailable=
 */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (net_ratelimit())
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 netdev_info(netdev, "INT_NORXBUF\n");
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netdev->stats.rx_over_er=
rors++;
>> + =C2=A0 =C2=A0 }
>
> Perhaps this "if (status & FTMAC100_INT_NORXBUF)" block should be
> moved into the test block above it before the retry?

Since status is not changed in the function, it does not matter where
the test is.
But I agree that it is better to handle error cases earlier.

> It's possible to miss multiple states because of the ratelimit.
>
> If multiple ISR status bits are possible, it might be better to
> combine all netdev_info uses into a single call.
>
> Something like:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((status & (FTMAC100_INT_NORXBUF | FTMA=
C100_INT_RPKT_LOST |
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 FTMAC100_INT_AHB_ERR | FTMAC100_INT_PHYSTS_CHG)) &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0net_ratelimit())
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_info(ne=
tdev, "ISR status: %x%s%s%s%s\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0status & FTMAC100_INT_NORXBUF ? ": INT_NORX=
BUF" : "",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0status & FTMAC100_INT_RPKT_LOST ? ": INT_RP=
KT_LOST" : "",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0status & FTMAC100_INT_AHB_ERR ? ": INT_AHB_=
ERR" : "",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0status & FTMAC100_INT_PHYSTS_CHG ? " : INT_=
PHYSTS_CHG" : "");

Agree. Thanks.

best regards,
Po-Yu Chuang
