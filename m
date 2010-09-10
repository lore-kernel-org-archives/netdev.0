From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: af_packet: don't call tpacket_destruct_skb() until
 the skb is sent out
Date: Sat, 11 Sep 2010 00:47:18 +0800
Message-ID: <AANLkTi=ZzvCNef7r81WZdbZsiSquYhDrnYAY73r4mo+t@mail.gmail.com>
References: <1284124960-3266-1-git-send-email-xiaosuo@gmail.com> <1284128770.24675.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54606 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab0IJQr5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:47:57 -0400
Received: by wyf22 with SMTP id 22so3008127wyf.19
        for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 09:47:56 -0700 (PDT)
In-Reply-To: <1284128770.24675.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 10, 2010 at 10:26 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le vendredi 10 septembre 2010 =E0 21:22 +0800, Changli Gao a =E9crit =
:
>> Since skb->destructor() is used to account socket memory, and maybe =
called
>> before the skb is sent out, a corrupt skb maybe sent out finally.
>>
>> A new destructor is added into structure skb_shared_info(), and it w=
on't
>> be called until the last reference to the data of a skb is put. af_p=
acket
>> uses this destructor instead.
>>
>
> Hi Changli
>
>> =A0static void tpacket_destruct_skb(struct sk_buff *skb)
>> =A0{
>> - =A0 =A0 struct packet_sock *po =3D pkt_sk(skb->sk);
>> - =A0 =A0 void *ph;
>> -
>> - =A0 =A0 BUG_ON(skb =3D=3D NULL);
>> + =A0 =A0 struct tpacket_destructor_arg *arg =3D skb_shinfo(skb)->de=
structor_arg;
>> + =A0 =A0 struct packet_sock *po =3D pkt_sk(arg->sk);
>> + =A0 =A0 void *ph =3D arg->ph;
>>
>> =A0 =A0 =A0 if (likely(po->tx_ring.pg_vec)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 ph =3D skb_shinfo(skb)->destructor_arg;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(__packet_get_status(po, ph) !=3D =
TP_STATUS_SENDING);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(atomic_read(&po->tx_ring.pending)=
 =3D=3D 0);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_dec(&po->tx_ring.pending);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __packet_set_status(po, ph, TP_STATUS_AV=
AILABLE);
>> =A0 =A0 =A0 }
>>
>> + =A0 =A0 skb->sk =3D arg->sk;
>> =A0 =A0 =A0 sock_wfree(skb);
>
> Are you sure sock_wfree(skb) is still needed ?

sock_wfree(skb) is also used to wake up the users who sleep on
poll(2). If sock_wfree(skb) is moved into skb->destructor(), and
called before skb is sent out, pollers will be waked up without
POLLOUT, and since the later skb_shinfo(skb)->destructor() doesn't
wake up the pollers, POLLOUT events will be lost, and the poller will
be blocked forever.

>
>
>> + =A0 =A0 kfree(arg);
>
> this new kmalloc()/kfree() for each sent packet wont please the guys
> using af_packet/mmap interface...

Embed these two pointers into skb_shared_info? It may slow the others.

>
>> =A0}
>>
>> =A0static int tpacket_fill_skb(struct packet_sock *po, struct sk_buf=
f *skb,
>> @@ -862,7 +867,6 @@ static int tpacket_fill_skb(struct packet_sock *=
po, struct sk_buff *skb,
>> =A0 =A0 =A0 skb->dev =3D dev;
>> =A0 =A0 =A0 skb->priority =3D po->sk.sk_priority;
>> =A0 =A0 =A0 skb->mark =3D po->sk.sk_mark;
>> - =A0 =A0 skb_shinfo(skb)->destructor_arg =3D ph.raw;
>>
>> =A0 =A0 =A0 switch (po->tp_version) {
>> =A0 =A0 =A0 case TPACKET_V2:
>> @@ -884,9 +888,8 @@ static int tpacket_fill_skb(struct packet_sock *=
po, struct sk_buff *skb,
>> =A0 =A0 =A0 to_write =3D tp_len;
>>
>> =A0 =A0 =A0 if (sock->type =3D=3D SOCK_DGRAM) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 err =3D dev_hard_header(skb, dev, ntohs(pr=
oto), addr,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, tp_l=
en);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(err < 0))
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(dev_hard_header(skb, dev, nto=
hs(proto), addr,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0NULL, tp_len) < 0))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> =A0 =A0 =A0 } else if (dev->hard_header_len) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* net device doesn't like empty head */
>> @@ -897,8 +900,7 @@ static int tpacket_fill_skb(struct packet_sock *=
po, struct sk_buff *skb,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_push(skb, dev->hard_header_len);
>> - =A0 =A0 =A0 =A0 =A0 =A0 err =3D skb_store_bits(skb, 0, data,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->hard_=
header_len);
>> + =A0 =A0 =A0 =A0 =A0 =A0 err =3D skb_store_bits(skb, 0, data, dev->=
hard_header_len);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(err))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
>>
>> @@ -906,7 +908,6 @@ static int tpacket_fill_skb(struct packet_sock *=
po, struct sk_buff *skb,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 to_write -=3D dev->hard_header_len;
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 err =3D -EFAULT;
>> =A0 =A0 =A0 page =3D virt_to_page(data);
>> =A0 =A0 =A0 offset =3D offset_in_page(data);
>> =A0 =A0 =A0 len_max =3D PAGE_SIZE - offset;
>> @@ -994,6 +995,8 @@ static int tpacket_snd(struct packet_sock *po, s=
truct msghdr *msg)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_max =3D dev->mtu + reserve;
>>
>> =A0 =A0 =A0 do {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct tpacket_destructor_arg *arg;
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ph =3D packet_current_frame(po, &po->tx_=
ring,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TP_STATU=
S_SEND_REQUEST);
>>
>> @@ -1028,7 +1031,16 @@ static int tpacket_snd(struct packet_sock *po=
, struct msghdr *msg)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 skb->destructor =3D tpacket_destruct_skb;
>> + =A0 =A0 =A0 =A0 =A0 =A0 arg =3D kmalloc(sizeof(*arg), GFP_KERNEL);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(arg =3D=3D NULL)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOBUFS;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_status;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 arg->sk =3D &po->sk;
>> + =A0 =A0 =A0 =A0 =A0 =A0 arg->ph =3D ph;
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb_shinfo(skb)->destructor_arg =3D arg;
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb->destructor =3D NULL;
>
> why setting skb->destructor to NULL here ?

Let skb_shinfo(skb)->destructor() do all the things which used to be
done by skb->destructor().

>
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb_shinfo(skb)->destructor =3D tpacket_de=
struct_skb;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __packet_set_status(po, ph, TP_STATUS_SE=
NDING);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_inc(&po->tx_ring.pending);
>>
>
> I dont yet understand how this can prevent af_unix module being unloa=
ded
> while packets are in flight

This issue isn't addressed, and I think it should be fixed in a separat=
e patch.

>
> I believe sock_wfree() should be avoided (since early orphaning occur=
s),
> to reduce number of atomic ops to the minimum.
>
> af_packet/mmap users want fast operations, we should not use
> sock_wfree() for them, because max number of in flight packets is kno=
wn
> (tx ring buffer)
>
>

But the users rely on the kernel to inform them there is available
frame for use.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
