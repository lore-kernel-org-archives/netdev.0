From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Sat, 28 Apr 2012 01:27:24 -0700
Message-ID: <CAKgT0Uc9B0Zrocw=mtb1oS2tHL73tdB4Vj7rKdb7xcikeJxp2g@mail.gmail.com>
References: <1335522818.2775.227.camel@edumazet-glaptop>
	<4F9B3980.1080605@intel.com>
	<1335597403.2900.29.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:57264 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015Ab2D1I1Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 04:27:25 -0400
Received: by pbbrp8 with SMTP id rp8so1429254pbb.19
        for <netdev@vger.kernel.org>; Sat, 28 Apr 2012 01:27:24 -0700 (PDT)
In-Reply-To: <1335597403.2900.29.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 28, 2012 at 12:16 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> On Fri, 2012-04-27 at 17:27 -0700, Alexander Duyck wrote:
>> On 04/27/2012 03:33 AM, Eric Dumazet wrote:
>> > From: Eric Dumazet <edumazet@google.com>
>> >
>
>> > +struct sk_buff *build_skb(void *data, unsigned int frag_size)
>> > =A0{
>> > =A0 =A0 struct skb_shared_info *shinfo;
>> > =A0 =A0 struct sk_buff *skb;
>> > - =A0 unsigned int size;
>> > + =A0 unsigned int size =3D frag_size ? : ksize(data);
>> >
>> > =A0 =A0 skb =3D kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
>> > =A0 =A0 if (!skb)
>> > =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> >
>> > - =A0 size =3D ksize(data) - SKB_DATA_ALIGN(sizeof(struct skb_shar=
ed_info));
>> > + =A0 size -=3D SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
>> >
>> > =A0 =A0 memset(skb, 0, offsetof(struct sk_buff, tail));
>> > =A0 =A0 skb->truesize =3D SKB_TRUESIZE(size);
>> > + =A0 skb->head_frag =3D frag_size !=3D 0;
>> > =A0 =A0 atomic_set(&skb->users, 1);
>> > =A0 =A0 skb->head =3D data;
>> > =A0 =A0 skb->data =3D data;
>>
>> This doesn't seem right to me. =A0You are only counting the piece of=
 the
>> page that got filled with data and the piece that will get overwritt=
en
>> with the shared info. =A0What about the rest of the page? =A0It look=
s like
>> in the tg3 patch you have the driver using a half page. =A0Based on =
this
>> function I suspect the resultant truesize would be something like 64=
 +
>> 256 + 320 for an ack. =A0Shouldn't your truesize in that case be 204=
8 + 256?
>
> Re-reading your mail, I think you missed fact that tg3 driver current=
ly
> uses a kmalloc(64+1500+14+SKB_DATA_ALIGN(sizeof(struct
> skb_shared_info)) , so basically does a kmalloc(2048). But this is do=
ne
> before NIC fills the frame in it, so we cant know what will be the fr=
ame
> length...
>
> So build_skb() does later a ksize(data) and this gives 2048, even for=
 a
> small ACK packet ...
>
> So the spirit of this patch is not to change any truesize.
>
> tg3 for example splits a PAGE_SIZE into 2048 bytes frags (2 frags on =
x86
> for example). Its done about the same in Intel IGB driver (IGB assume=
s
> PAGE_SIZE is 4096 since it uses PAGE_SIZE/2)
>
> The only thing that is changed here is where skb->head is allocated
> from : kmalloc() caches or a frag from a page (and one reference to
> page->_count)
>
> Hope this clears your concern ?

I had misread what was happening here.  I didn't fully understand what
build_skb was doing before reading the patch and that is what led me
astray.

I was thinking there would be a bigger gain with a change like this
but essentially all you are doing is making the packets more mergable
resulting in you being able to drop the 256 bytes for the sk_buff in
either GRO or when it gets queued for the socket.

What caught my eye about all this is that I could probably cut a lot
of work out of the ixgbe driver and FCoE path by modifying things so
that FCoE packets could be received as a page, and then treated as a
linear skb without needing calls to skb_linearize.

Thanks,

Alex
