From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: Re: [PATCH] gianfar: fix size of fragmented frames
Date: Fri, 19 Aug 2016 21:12:52 +0000
Message-ID: <AM5PR0401MB25619ACF2F6D5B380E478AD396160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
References: <1471598156-16875-1-git-send-email-zefir.kurtisi@neratec.com>
 <AM5PR0401MB25613B657270085A3EE4324F96160@AM5PR0401MB2561.eurprd04.prod.outlook.com>,<f3ec9590-766b-ac5f-d793-ebc134366d09@neratec.com>,<AM5PR0401MB2561233A47F3A64710D2293096160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev list <netdev@vger.kernel.org>
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0047.outbound.protection.outlook.com ([104.47.2.47]:8544
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755568AbcHSVrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 17:47:25 -0400
In-Reply-To: <AM5PR0401MB2561233A47F3A64710D2293096160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Zefir,

[sorry if the message indentation is wrong ... webmail]


From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Sent: Friday, August 19, 2016 8:11 PM
To: Claudiu Manoil
Subject: Re: [PATCH] gianfar: fix size of fragmented frames
=A0=A0=A0=20
Hi Claudiu,

On 08/19/2016 06:46 PM, Claudiu Manoil wrote:
>> -----Original Message-----
>> From: Zefir Kurtisi [mailto:zefir.kurtisi@neratec.com]
>> Sent: Friday, August 19, 2016 12:16 PM
>> To: netdev@vger.kernel.org
>> Cc: claudiu.manoil@freescale.com
>> Subject: [PATCH] gianfar: fix size of fragmented frames
>>
>> The eTSEC RxBD 'Data Length' field is context depening:
>> for the last fragment it contains the full frame size,
>> while fragments contain the fragment size, which equals
>> the value written to register MRBLR.
>>
>=20
> According to RM the last fragment has the whole packet length indeed,
> and this should apply to fragmented frames too:
>=20
> " Data length, written by the eTSEC.
> Data length is the number of octets written by the eTSEC into this BD's d=
ata buffer if L is cleared
> (the value is equal to MRBLR), or, if L is set, the length of the frame i=
ncluding CRC, FCB (if
> RCTRL[PRSDEP > 00), preamble (if MACCFG2[PreAmRxEn]=3D1), time stamp (if =
RCTRL[TS] =3D 1)
> and any padding (RCTRL[PAL]). "
>=20
>> This differentiation is missing in the gianfar driver,
>> which causes data corruption as soon as the hardware
>> starts to fragment receiving frames. As a result, the
>> size of fragmented frames is increased by
>> (nr_frags - 1) * MRBLR
>>
>> We first noticed this issue working with DSA, where a
>> 1540 octet frame is fragmented by the hardware and
>> reconstructed by the driver as 3076 octet frame.
>>
>> This patch fixes the problem by adjusting the size of
>> the last fragment.
>>
>> Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
>> ---
>> drivers/net/ethernet/freescale/gianfar.c | 19 +++++++++++++------
>> 1 file changed, 13 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/gianfar.c
>> b/drivers/net/ethernet/freescale/gianfar.c
>> index d20935d..4187280 100644
>> --- a/drivers/net/ethernet/freescale/gianfar.c
>> +++ b/drivers/net/ethernet/freescale/gianfar.c
>> @@ -2922,17 +2922,24 @@ static bool gfar_add_rx_frag(struct gfar_rx_buff=
 *rxb,
>> u32 lstatus,
>> {
>>=A0=A0=A0=A0=A0=A0 unsigned int size =3D lstatus & BD_LENGTH_MASK;
>>=A0=A0=A0=A0=A0=A0 struct page *page =3D rxb->page;
>> +=A0=A0=A0 bool last =3D !!(lstatus & BD_LFLAG(RXBD_LAST));
>>
>>=A0=A0=A0=A0=A0=A0 /* Remove the FCS from the packet length */
>> -=A0=A0=A0 if (likely(lstatus & BD_LFLAG(RXBD_LAST)))
>> +=A0=A0=A0 if (last)
>>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 size -=3D ETH_FCS_LEN;
>>
>> -=A0=A0=A0 if (likely(first))
>> +=A0=A0=A0 if (likely(first)) {
>>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 skb_put(skb, size);
>> -=A0=A0=A0 else
>> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 skb_add_rx_frag(skb, skb_shinfo(skb)-=
>nr_frags, page,
>> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 rxb->page_offset + RXBUF_ALIGNMENT,
>> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 size, GFAR_RXB_TRUESIZE);
>> +=A0=A0=A0 } else {
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /* the last fragments' length contain=
s the full frame length */
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (last)
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 size -=3D skb=
->len;
>=20
> While I agree with your finding, I don't think this works for packets hav=
ing more
> than 2 buffers (head + 1 fragment).
> How's this supposed to work for a skb with 2 fragments, for instance?
> I think this needs more thoughtful consideration.
>=20
In fact, this works and I tested it by setting GFAR_RXB_SIZE to 256. Receiv=
ing a
1000 byte frame then results in 4 fragments, 3*256 plus the last one sized =
1000.
The driver then combines 256+256+256+232 (=3D1000-768) back to a 1000 bytes=
 frame.

I don't see why it should not, because skb->len is exactly the size of the
fragments added before the last one, so subtracting them from the total fra=
me size
should give the size of the last fragment, no?

[Claudiu]
Thanks for the details. I didn't have much time to look into it (I still do=
n't), and you can
never be too careful with this kind of changes. But I agree with your asses=
sment.
I'm surprised this didn't come out earlier, like a warning from the stack, =
since the
truesize can be easily exceeded in this case.

>> +
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (size > 0 && size <=3D GFAR_RXB_SI=
ZE)
>=20
> Why do you need this check?
> The h/w ensures that the buffers won't exceed GFAR_RXB_SIZE
> (which is MRBL), size 0 is also not possible.
>=20
Do you question the first part? In cases where the last fragment consists o=
f only
the FCS, adding a zero size fragment would falsify skb->truesize.

The second expression is fail-safe only - it should never happen given the
hardware specs - but if it did, not checking for a sane frame size might ca=
use
serious trouble (not sure what skb_add_rx_frag() does with an insanely high=
 size
value). If you prefer, I will leave it out in v2 of the patch.

[Claudiu]
Nice catch with the size > 0 part too.=A0 The second part is debatable inde=
ed, it may case
confusion implying that size may exceed that limit, which is false, since t=
he point of RX
S/G is that a buffer doesn't exceed GFAR_RXB_SIZE.=A0 So I'd drop the secon=
d check.
Other than that,
Acked-by: <claudiu.manoil@nxp.com>

Thanks,
Claudiu    =
