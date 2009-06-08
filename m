From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Security, resend] Instant crash with rtl8169 and large packets
Date: Mon, 08 Jun 2009 17:06:46 +0200
Message-ID: <4A2D2906.6090002@gmail.com>
References: <4A2D1147.8020101@msgid.tls.msk.ru> <4A2D1FE4.5030100@gmail.com> <4A2D25F6.9080300@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55184 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905AbZFHPGt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 11:06:49 -0400
In-Reply-To: <4A2D25F6.9080300@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Tokarev a =E9crit :
> Thank you Eric for the reply.
>=20
> Eric Dumazet wrote:
>> Michael Tokarev a =E9crit :
> []
>>> The situation is very simple: with an RTL8169 (probably
>>> onboard) GigE card which, by default, is configured to
>>> have MTU (maximal transmission unit) to be 1500 bytes,
>>> it's *trivial* to instantly crash the machine by sending
>>> it a *single* packet of size >1500 bytes (provided the
>>> network switch can handle jumbo frames).
> []
>>>  http://www.corpit.ru/mjt/r8169-mtu-oops.jpg
>=20
>> I suppose you use a recent kernel ?
>=20
> http://marc.info/?t=3D123462473200002 -- here's my first attempt,
> at Feb this year.  It was 2.6.27 or so.  Right now I'm running
> 2.6.29[.4].  So I think yes, I use a recent kernel.
>=20
>> Could you please try following patch ?
> []
>> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
>> index e94316b..c08b97a 100644
>> --- a/drivers/net/r8169.c
>> +++ b/drivers/net/r8169.c
>> @@ -3468,7 +3468,7 @@ static int rtl8169_rx_interrupt(struct
>> net_device *dev,
>> =20
>>          if (status & DescOwn)
>>              break;
>> -        if (unlikely(status & RxRES)) {
>> +        if (unlikely(status & (RxRES | RxRWT | RxRUNT | RxCRC |
>> RxFOVF))) {
>>              if (netif_msg_rx_err(tp)) {
>>                  printk(KERN_INFO
>>                         "%s: Rx ERROR. status =3D %08x\n",
>=20
> Tried that one, got no printk (at least not a visible one) and exactl=
y
> the same OOPS as before.  Trivial test with
>=20
>   ping -c1 -s3000 $my_ip_addr
>=20
> (learned to add -c1 because the previous time my machine crashed seve=
ral
> times
> in a row till I figured out what's going on and unplugged the etherne=
t
> cord --
> even if ping were running from an xterm executed from the machine to
> which I
> were pinging to! :)
>=20
> Also got ext4fs corruption when rebooted (it's a staging area so noth=
ing
> important
> is there but still.. "interesting").
>=20
> Also tried 32bit kernel (were using 64bits -- exactly the same result=
).
>=20
> I wish I had a serial cable or even a serial port on this machine....
> But I guess
> it'd not help anyway, because the machine locks hard.
>=20
> Thanks!
>=20
> /mjt

OK, 2nd try then :)

Thanks

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index e94316b..9080b08 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3495,7 +3495,8 @@ static int rtl8169_rx_interrupt(struct net_device=
 *dev,
 			 * frames. They are seen as a symptom of over-mtu
 			 * sized frames.
 			 */
-			if (unlikely(rtl8169_fragmented_frame(status))) {
+			if (unlikely(rtl8169_fragmented_frame(status) ||
+				     (unsigned int)pkt_size > tp->rx_buf_sz)) {
 				dev->stats.rx_dropped++;
 				dev->stats.rx_length_errors++;
 				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);


