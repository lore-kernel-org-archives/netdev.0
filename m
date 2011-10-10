From: danborkmann@iogearbox.net
Subject: Re: [PATCH] af_packet: tpacket_destruct_skb, deref skb after
 BUG_ON assertion
Date: Mon, 10 Oct 2011 10:02:03 +0200
Message-ID: <20111010100203.15066m7nvqod58cb@webmail.your-server.de>
References: <20111009171919.10922hrx8qjm2f7b@webmail.your-server.de>
 <1318193866.21116.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60402 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455Ab1JJIFA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 04:05:00 -0400
In-Reply-To: <1318193866.21116.3.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Quoting Eric Dumazet <eric.dumazet@gmail.com>:
> Le dimanche 09 octobre 2011 =C3=A0 17:19 +0200, danborkmann@iogearbox=
=2Enet a
> =C3=A9crit :
>> This tiny patch derefs the skb only after BUG_ON(skb=3D=3DNULL) was =
evaluated
>> and not before. Patched against latest Linus tree.
>>
>> Thanks,
>> Daniel
>>
>> Signed-off-by: Daniel Borkmann <danborkmann@iogearbox.net>
>>
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index fabb4fa..d9d833b 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -1167,11 +1167,12 @@ ring_is_full:
>>
>>   static void tpacket_destruct_skb(struct sk_buff *skb)
>>   {
>> -	struct packet_sock *po =3D pkt_sk(skb->sk);
>> +	struct packet_sock *po;
>>   	void *ph;
>>
>>   	BUG_ON(skb =3D=3D NULL);
>>
>> +	po =3D pkt_sk(skb->sk);
>>   	if (likely(po->tx_ring.pg_vec)) {
>>   		ph =3D skb_shinfo(skb)->destructor_arg;
>>   		BUG_ON(__packet_get_status(po, ph) !=3D TP_STATUS_SENDING);
>>
>>
>
> Well, to be honest, this BUG_ON(!skb) is absolutely useless for two
> reasons.
>
> 1) If skb happens to be NULL, the NULL dereference is trapped and sta=
ck
> trace dumped as well.
>
> 2) Of course, tpacket_destruct_skb() being an skb destructor, skb can=
not
> be NULL at this point by design.
>
> Please remove the BUG_ON() instead of trying to move it ;)

Thanks, you're absolutely right! Here's the trivial patch:

af_packet: removed unnecessary BUG_ON assertion in tpacket_destruct_skb

If skb is NULL, then stack trace is thrown on anyway on dereference. =20
Therefore,
the stack trace triggered by BUG_ON is duplicate.

Signed-off-by: Daniel Borkmann <danborkmann@googlemail.com>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index fabb4fa..886ae50 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1170,8 +1170,6 @@ static void tpacket_destruct_skb(struct sk_buff *=
skb)
  	struct packet_sock *po =3D pkt_sk(skb->sk);
  	void *ph;

-	BUG_ON(skb =3D=3D NULL);
-
  	if (likely(po->tx_ring.pg_vec)) {
  		ph =3D skb_shinfo(skb)->destructor_arg;
  		BUG_ON(__packet_get_status(po, ph) !=3D TP_STATUS_SENDING);
