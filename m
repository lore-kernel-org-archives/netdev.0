From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: af_packet: don't call tpacket_destruct_skb() until
 the skb is sent out
Date: Sat, 11 Sep 2010 08:19:39 +0800
Message-ID: <AANLkTinXxyVzvPWT_nnpos4-tVVj68T+7iHCvokHG+2m@mail.gmail.com>
References: <1284124960-3266-1-git-send-email-xiaosuo@gmail.com>
 <1284128770.24675.41.camel@edumazet-laptop> <AANLkTi=ZzvCNef7r81WZdbZsiSquYhDrnYAY73r4mo+t@mail.gmail.com>
 <1284137906.24675.97.camel@edumazet-laptop> <1284138733.24675.104.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36826 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755675Ab0IKAUA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 20:20:00 -0400
Received: by wwb13 with SMTP id 13so542878wwb.1
        for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 17:19:59 -0700 (PDT)
In-Reply-To: <1284138733.24675.104.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 11, 2010 at 1:12 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 10 septembre 2010 =E0 18:58 +0200, Eric Dumazet a =E9crit=
 :
>> Le samedi 11 septembre 2010 =E0 00:47 +0800, Changli Gao a =E9crit :
>> > On Fri, Sep 10, 2010 at 10:26 PM, Eric Dumazet <eric.dumazet@gmail=
=2Ecom> wrote:
>>
>>
>> > > Are you sure sock_wfree(skb) is still needed ?
>> >
>> > sock_wfree(skb) is also used to wake up the users who sleep on
>> > poll(2). If sock_wfree(skb) is moved into skb->destructor(), and
>> > called before skb is sent out, pollers will be waked up without
>> > POLLOUT, and since the later skb_shinfo(skb)->destructor() doesn't
>> > wake up the pollers, POLLOUT events will be lost, and the poller w=
ill
>> > be blocked forever.
>> >
>>
>> Then implement poll() to use the number of available slots.
>> (not use the default poll() that relies on generic sk / inet queues =
and
>> counters)
>>
>> Really, sock_wfree() cannot be used at all, or we also must disable
>> early orphaning of these skbs.
>>
>> Goal is to replace skb->destructor use in af_packet by
>> shinfo->destructor, not mix the two.
>
> Thinking again about this, we also might avoid taking references on
> pages and releasing references too.
>
> shinfo->destructor should replace the skb_release_data() logic,
> not complement it.
>
> if (shinfo->destructor) {
> =A0 =A0 =A0 =A0shinfo->destructor(skb);
> } else {
> =A0 =A0 =A0 =A0for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0put_page(skb_shinfo(skb)->frags[i].pag=
e);
> =A0 =A0 =A0 =A0if (skb_has_frag_list(skb))
> =A0 =A0 =A0 =A0....
> =A0 =A0 =A0 =A0kfree(skb->head);
> }
>
>
> As long as the mmap zone is correctly protected in af_packet code, of
> course (not releasing it as long as some packets are still in flight)
>

It touches too much internal implementation.

I think most of your ideas are about optimizations, and should be
addressed in separate patches. I'll avoid kmalloc/kfree in the next
version. Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
