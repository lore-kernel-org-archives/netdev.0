From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Is this skb recycle buffer helpful to improve Linux network stack
 performance?
Date: Sun, 09 Oct 2005 00:09:57 +0200
Message-ID: <434843B5.3020306@cosmosbay.com>
References: <BAY108-DAV4CDAEF052852412160A0893870@phx.gbl> <43483E57.1040205@cosmosbay.com> <BAY108-DAV140650CDA8608152927C4E93870@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751166AbVJHWKB@vger.kernel.org>
To: LeoY <multisyncfe991@hotmail.com>
In-Reply-To: <BAY108-DAV140650CDA8608152927C4E93870@phx.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

LeoY a =E9crit :
> Here is the modifications I made:
> //skbuff.h
> //I added the folloing definitions
> #define MAX_POOL_SIZE 4096
> unsigned char *skbuff_data_pool[MAX_POOL_SIZE];
> int skbPoolHead, skbPoolTail;
>=20
>=20
> //skb_init()
> //I add the following codes:
> for(i=3D0;i<MAX_POOL_SIZE;i++)
>         skbuff_data_pool[i] =3D NULL;
> skbPoolHead =3D skbPoolTail =3D 0;
>=20
>=20
> //alloc_skb()
> //I made the following changes
> if (skbuff_data_pool[skbPoolHead])
> {
>   data =3D skbuff_data_pool[skbPoolHead];
>  skbuff_data_pool[skbPoolHead] =3D NULL;
>  if (++skbPoolHead =3D=3D MAX_POOL_SIZE)
>   skbPoolHead =3D 0;
> }
> else{ //Original path
>  size =3D SKB_DATA_ALIGN(size);
>  data =3D kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
>  }
>=20
> //skb_release_data()
> //I made the following changes:
>  if ((skbPoolHead =3D=3D skbPoolTail) && (skbuff_data_pool[skbPoolHea=
d] !=3D=20
> NULL))
>  //Original path
>   kfree(skb->head);
>                else{
>   if (skbuff_data_pool[skbPoolTail])
>    panic("Tail pointer must be null");
>=20
>   skbuff_data_pool[skbPoolTail] =3D skb->head;
>                        if (++skbPoolTail =3D=3D MAX_POOL_SIZE)
>    skbPoolTail =3D 0;
>  }
>=20

Hum... Lot of problems I think

Are you aware that skb_alloc() / skb_free() can handle data buffers of=20
different sizes ?

So if you kmalloc() a small buffer, and store it later in your ring buf=
fer,=20
you should not give it back to a caller that need a biger buffer.

If you want your 'ring buffer'to work, I suspect you should ignore the =
'size'=20
and let it be the max possible size handled in your machine.

Then, dont forget about SMP and IRQs : I dont see in your code how you =
protect=20
against concurrent processors accessing your ring buffers, and how you =
protect=20
against IRQ (since a nic handler can runs on IRQ or softirq context)

kmalloc()/kfree() are SMP safe.

> ----- Original Message ----- From: "Eric Dumazet" <dada1@cosmosbay.co=
m>
> To: "LeoY" <multisyncfe991@hotmail.com>
> Cc: <netdev@vger.kernel.org>
> Sent: Saturday, October 08, 2005 2:47 PM
> Subject: Re: Is this skb recycle buffer helpful to improve Linux netw=
ork=20
> stack performance?
>=20
>=20
>> LeoY a =E9crit :
>>
>>> Hi,
>>>
>>> Motivation: we noticed alloc_skb()/kfree() used lots of clock ticks=
 when
>>> handling heavy network traffic. As Linux kernel always need to call
>>> kmalloc()/kfree() to allocate and deallocate a skb DATA buffer(not=20
>>> sk_buff)
>>> for each incoming/outgoing packet, we try to reduce the frequence o=
f=20
>>> calling
>>> these memory functions.
>>>
>>> I wangt to set up a ring buffer in Linux kernel(skbuff.c) and recyc=
le=20
>>> those
>>> skb data buffers. The basic idea is as follows:
>>> 1. Create a ring buffer. This ring buffer has a head pointer which=20
>>> points to
>>> the virtual address of the data buffer to be reused; It also has a =
tail
>>> pointer, which can be used to store the virutal address of skb data=
=20
>>> buffer
>>> for those transmitted packets.
>>> 2. If the ring buffer is full, just use normal kmalloc()/kfree()=20
>>> operation
>>> to manager those skb data buffers instead of recycling them.
>>> 3. if any DATA buffer is available, Instead of calling kmalloc(),=20
>>> assign a
>>> skb data buffer directly from ring buffer to the incoming packets.
>>> 4. If ring buffer still has space, Instead of calling kfree(), stor=
e=20
>>> the skb
>>> data buffer into the ring buffer.
>>> 5. if the head and tail pointer overlap and head pointer is not=20
>>> empty, just
>>> stop accpeting more DATA buffer until some DATA buffer is used for =
the
>>> incoming packets.
>>>
>>> I tested my method on the latest Linux kernel 2.6.13.3, it works wi=
th=20
>>> the
>>> normal traffic; However, the Linux kernel crashed under the heavy=20
>>> network
>>> traffic.
>>>
>>> Any idea to make this ring bufer work under the heavy network traff=
ic?
>>
>>
>> Your idea seems interesting, but you forgot to post a link to the co=
de=20
>> you wrote. How do you want us to help you ?
>>
>> Eric
>>

>=20
