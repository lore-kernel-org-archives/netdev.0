From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Fri, 02 Dec 2011 12:59:48 +0100
Message-ID: <1322827188.2607.19.camel@edumazet-laptop>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
	 <1322710962.2577.3.camel@edumazet-laptop>
	 <CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
	 <1322713032.2577.7.camel@edumazet-laptop>
	 <CAGK4HS8fLWwdPsrag6+Mz93_ZNg2B5JRjx2s=Re8_Qiv4V=T=w@mail.gmail.com>
	 <1322778621.2750.48.camel@edumazet-laptop>
	 <CAGK4HS84vepB-cOnjOASqXy2gLWGwx=RHnQ3PbbMPezxJ5m3QQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59694 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931Ab1LBL7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 06:59:53 -0500
Received: by vbbfc26 with SMTP id fc26so2210433vbb.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 03:59:52 -0800 (PST)
In-Reply-To: <CAGK4HS84vepB-cOnjOASqXy2gLWGwx=RHnQ3PbbMPezxJ5m3QQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 22:18 -0800, Vijay Subramanian a =
=C3=A9crit :
> >> I am looking at tcp_mtu_probe() and was wondering if this commit a=
lso
> >> impacts this function. Once the data are copied from skbs in the w=
rite
> >> queue to the probe skb, copied data are cleared from the original =
skbs
> >> in the write queue.
> >>
> >> It looks like the code assumes that the original skb will have dat=
a
> >> either in linear part or in paged part.  The call to
> >> __pskb_trim_head(skb, copy) for example does not clear linear part=
=2E
> >>
> >> Can someone more familiar with the code take a look? Apologies if =
I
> >> have read this wrong.
> >>
> >
> > tcp_mtu_probe() builds a linear skb, and populate it using
> > skb_copy_bits() [ this is frag aware, and aware of payload in heade=
r as
> > well ]
> >
> > I see no problem in it.
> >
>=20
> Eric,
> I think you may have misunderstood me (I think my post was not very
> clear). Let me try again.
>=20
> The MTU probe is built  correctly as a linear skb. As you point out,
> skb_copy_bits() is frag aware and copies data from both the header an=
d
> pages.
> The issue is with the way the data is cleared from the write queue
> later in the function tcp_mtu_probe().
>=20
> For example, if the MTU probe size was N bytes, then the probe is
> inserted at the front of the write_queue and N bytes are copied from
> the original write-queue skbs.
> As these N bytes are copied, if an skb is completely consumed, it is
> unlinked from the write_queue and freed. If an skb is only partially
> consumed, then the pointers are adjusted
> accordingly to erase the data. For a paged skb, fully consumed pages
> are unreferenced.
>=20
> This is done as follows in tcp_mtu_probe()
>=20
>            if (!skb_shinfo(skb)->nr_frags) {
>                skb_pull(skb, copy);
>                if (skb->ip_summed !=3D CHECKSUM_PARTIAL)
>                    skb->csum =3D csum_partial(skb->data,
>                                 skb->len, 0);
>            } else {
>                __pskb_trim_head(skb, copy);
>                tcp_set_skb_tso_segs(sk, skb, mss_now);
>            }
>=20
> It appears that the code assumes the data will either be in the linea=
r
> part (the if condition) or in the paged part (else condition) but not
> both. Is this a correct assumption after the
> recent commit f07d960df33c5aef (tcp: avoid frag allocation for small =
frames)?
>=20
> Since __pskb_trim_head() only only removes data from the non-linear
> part, the data in the linear part is never removed. Maybe for paged
> skbs, we need something like
> headlen =3D skb_headlen(skb);
> skb_pull(skb, headlen);
> __pskb_trim_head(skb, copy - headlen);
>=20
> Thanks for your patience and hope this makes more sense than my previ=
ous post.
>=20

Thanks for this detailed explanation !

And yes, you're probably right.

Are you willing to submit a patch to fix this ?

(If not, I can do it myself of course)
