From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Thu, 01 Dec 2011 05:17:12 +0100
Message-ID: <1322713032.2577.7.camel@edumazet-laptop>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
	 <1322710962.2577.3.camel@edumazet-laptop>
	 <CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34109 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647Ab1LAERQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:17:16 -0500
Received: by eaak14 with SMTP id k14so1605926eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 20:17:15 -0800 (PST)
In-Reply-To: <CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 20:06 -0800, Tom Herbert a =C3=A9cr=
it :
> On Wed, Nov 30, 2011 at 7:42 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le mercredi 30 novembre 2011 =C3=A0 17:48 -0800, Tom Herbert a =C3=A9=
crit :
> >> I believe that skb->data_len might no be computed correctly in
> >> tcp_sendmsg.  Specifically, when skb_add_data_nocache (or
> >> skb_add_data) is called skb->data_len is not updated (skb_put only
> >> updates skb->len).  This results in the datalen in the head skbuf
> >> being zero so any subsequent uses of the value lead to incorrect
> >> results.  For instance, skb_headlen returns the length of the head
> >> skbu data and not just that of the headers.  If I'm reading this
> >> correctly, it's a pretty fundamental bug.
> >>
> >> I don't have a fix for this yet.
> >>
> >> Tom
> >
> > On which tree do you see a problem ?
> >
> > For example net-next seems fine to me :
> >
> >
>=20
> On net-next.  Look at skb_add_data_nocache.  This doesn't touch
> data_len, and really can't since skb_put wants skb linearized.
>=20
> Actually, I think I am misinterpreting the meaning of data_len, looks
> like it is intended to return the number of bytes in the page buffer
> area (comment on the function would be have been nice ;-) ).  It woul=
d
> seem that e1000e driver might be misinterpreting it also:
>=20
>         segs =3D skb_shinfo(skb)->gso_segs ? : 1;
>         /* multiply data chunks by size of headers */
>         bytecount =3D ((segs - 1) * skb_headlen(skb)) + skb->len;
>=20
> So maybe the bug is  that e1000e is misusing the function (and it
> looks like some other drivers would be too)?.

Or the "bug" was to assume that skb was headless.
It was true until recently.

We recently added commit f07d960df33c5aef
(tcp: avoid frag allocation for small frames)

to avoid page allocation for small frames.

So now, skb can contain in head part of tcp data.
