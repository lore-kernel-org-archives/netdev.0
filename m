From: "LeoY" <multisyncfe991@hotmail.com>
Subject: Re: Is this skb recycle buffer helpful to improve Linux network stack performance?
Date: Sat, 8 Oct 2005 14:59:13 -0700
Message-ID: <BAY108-DAV140650CDA8608152927C4E93870@phx.gbl>
References: <BAY108-DAV4CDAEF052852412160A0893870@phx.gbl> <43483E57.1040205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
	format=flowed	reply-type=response
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932184AbVJHV7P@vger.kernel.org>
To: "Eric Dumazet" <dada1@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is the modifications I made:
//skbuff.h
//I added the folloing definitions
#define MAX_POOL_SIZE 4096
unsigned char *skbuff_data_pool[MAX_POOL_SIZE];
int skbPoolHead, skbPoolTail;


//skb_init()
//I add the following codes:
 for(i=3D0;i<MAX_POOL_SIZE;i++)
         skbuff_data_pool[i] =3D NULL;
 skbPoolHead =3D skbPoolTail =3D 0;


//alloc_skb()
//I made the following changes
if (skbuff_data_pool[skbPoolHead])
 {
   data =3D skbuff_data_pool[skbPoolHead];
  skbuff_data_pool[skbPoolHead] =3D NULL;
  if (++skbPoolHead =3D=3D MAX_POOL_SIZE)
   skbPoolHead =3D 0;
 }
 else{ //Original path
  size =3D SKB_DATA_ALIGN(size);
  data =3D kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
  }

//skb_release_data()
//I made the following changes:
  if ((skbPoolHead =3D=3D skbPoolTail) && (skbuff_data_pool[skbPoolHead=
] !=3D=20
NULL))
  //Original path
   kfree(skb->head);
                else{
   if (skbuff_data_pool[skbPoolTail])
    panic("Tail pointer must be null");

   skbuff_data_pool[skbPoolTail] =3D skb->head;
                        if (++skbPoolTail =3D=3D MAX_POOL_SIZE)
    skbPoolTail =3D 0;
  }

----- Original Message -----=20
=46rom: "Eric Dumazet" <dada1@cosmosbay.com>
To: "LeoY" <multisyncfe991@hotmail.com>
Cc: <netdev@vger.kernel.org>
Sent: Saturday, October 08, 2005 2:47 PM
Subject: Re: Is this skb recycle buffer helpful to improve Linux networ=
k=20
stack performance?


> LeoY a =E9crit :
>> Hi,
>>
>> Motivation: we noticed alloc_skb()/kfree() used lots of clock ticks =
when
>> handling heavy network traffic. As Linux kernel always need to call
>> kmalloc()/kfree() to allocate and deallocate a skb DATA buffer(not=20
>> sk_buff)
>> for each incoming/outgoing packet, we try to reduce the frequence of=
=20
>> calling
>> these memory functions.
>>
>> I wangt to set up a ring buffer in Linux kernel(skbuff.c) and recycl=
e=20
>> those
>> skb data buffers. The basic idea is as follows:
>> 1. Create a ring buffer. This ring buffer has a head pointer which p=
oints=20
>> to
>> the virtual address of the data buffer to be reused; It also has a t=
ail
>> pointer, which can be used to store the virutal address of skb data=20
>> buffer
>> for those transmitted packets.
>> 2. If the ring buffer is full, just use normal kmalloc()/kfree()=20
>> operation
>> to manager those skb data buffers instead of recycling them.
>> 3. if any DATA buffer is available, Instead of calling kmalloc(), as=
sign=20
>> a
>> skb data buffer directly from ring buffer to the incoming packets.
>> 4. If ring buffer still has space, Instead of calling kfree(), store=
 the=20
>> skb
>> data buffer into the ring buffer.
>> 5. if the head and tail pointer overlap and head pointer is not empt=
y,=20
>> just
>> stop accpeting more DATA buffer until some DATA buffer is used for t=
he
>> incoming packets.
>>
>> I tested my method on the latest Linux kernel 2.6.13.3, it works wit=
h the
>> normal traffic; However, the Linux kernel crashed under the heavy ne=
twork
>> traffic.
>>
>> Any idea to make this ring bufer work under the heavy network traffi=
c?
>
> Your idea seems interesting, but you forgot to post a link to the cod=
e you=20
> wrote. How do you want us to help you ?
>
> Eric
>=20
