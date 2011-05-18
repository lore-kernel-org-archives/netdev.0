From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug, kernel panic, NULL dereference , cleanup_once /
 icmp_route_lookup.clone.19.clone / nat , 2.6.39-rc7-git11
Date: Wed, 18 May 2011 11:37:51 +0200
Message-ID: <1305711471.2983.27.camel@edumazet-laptop>
References: <54ec5cd14e5e5c76aa06c2e6899299ce@visp.net.lb>
	 <41a1892fed59b411bb08d3ecb0d8cda5@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64066 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932507Ab1ERJhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 05:37:54 -0400
Received: by fxm17 with SMTP id 17so1049459fxm.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 02:37:53 -0700 (PDT)
In-Reply-To: <41a1892fed59b411bb08d3ecb0d8cda5@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 mai 2011 =C3=A0 12:27 +0300, Denys Fedoryshchenko a =C3=A9=
crit :
> On Wed, 18 May 2011 01:16:29 +0300, Denys Fedoryshchenko wrote:
> > Just got recently. 32Bit, PPPoE NAS, shapers, firewall, NAT
> > Kernel i mention in subject, 2.6.39-rc7-git11
> > If required i can give more information
> >
> > sharanal (sorry for ugly name) is libpcap based traffic analyser,
> > sure userspace
> >
>  Here is some info, i hope it will be a little useful
>=20
>  (gdb)  l *(cleanup_once + 0x49)
>  0xc02e85cc is in cleanup_once (include/linux/list.h:88).
>  83       * This is only for internal list manipulation where we know
>  84       * the prev/next entries already!
>  85       */
>  86      static inline void __list_del(struct list_head * prev, struc=
t=20
>  list_head * next)
>  87      {
>  88              next->prev =3D prev;
>  89              prev->next =3D next;
>  90      }
>  91
>  92      /**
>=20
>  (gdb)  l *(inet_getpeer + 0x2ab)
>  0xc02e8ae8 is in inet_getpeer (net/ipv4/inetpeer.c:530).
>  525             if (base->total >=3D inet_peer_threshold)
>  526                     /* Remove one less-recently-used entry. */
>  527                     cleanup_once(0, stack);
>  528
>  529             return p;
>  530     }
>  531
>  532     static int compute_total(void)
>  533     {
>  534             return v4_peers.total + v6_peers.total;
>=20

I really begin to think we have a bug here...

In previous reports, I suggested to use slub_nomerge because I thought
one corruption from another kernel layer was going on.

(inetpeer was using 64 bytes objects). But now that inetpeer objects ar=
e
bigger and sit in another kmemcache, its bad news.

Could you try this, and eventually add some SLUB debugging stuff as
well ?



