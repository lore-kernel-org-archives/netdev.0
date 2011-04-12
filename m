From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 15:15:45 +0200
Message-ID: <1302614145.3233.47.camel@edumazet-laptop>
References: <4D9E62D9.5010400@scotdoyle.com>
	 <20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com>
	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>
	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop>
	 <1302582172.3603.18.camel@edumazet-laptop> <4DA3E074.5090603@scotdoyle.com>
	 <1302587490.3603.22.camel@edumazet-laptop> <4DA3F909.5020609@scotdoyle.com>
	 <1302608951.3233.33.camel@edumazet-laptop>
	 <1302613353.30934.22.camel@polaris.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scot Doyle <lkml@scotdoyle.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Jan =?ISO-8859-1?Q?L=FCbbe?= <jluebbe@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58549 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab1DLNPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 09:15:49 -0400
Received: by wwa36 with SMTP id 36so7882839wwa.1
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 06:15:48 -0700 (PDT)
In-Reply-To: <1302613353.30934.22.camel@polaris.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 avril 2011 =C3=A0 15:02 +0200, Jan L=C3=BCbbe a =C3=A9crit =
:
> Hi!=20
>=20
> On Tue, 2011-04-12 at 13:49 +0200, Eric Dumazet wrote:
> > Considering recent changes in ip_options_echo() I would suggest to =
add
> > following patch and/or revert commit 8628bd8af7c4c14f40
> > (ipv4: Fix IP timestamp option (IPOPT_TS_PRESPEC) handling in
> > ip_options_echo())
>=20
> I've read this thread, but I'm not sure why my patch is related to th=
ese
> kernel panics. The behavior is only changed for packets with the
> timestamp option in prespecified addresses mode. Even then, it should=
n't
> cause ip_options_build to write to unallocated memory later.
>=20
> > diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
> > index 28a736f..35f2bf9 100644
> > --- a/net/ipv4/ip_options.c
> > +++ b/net/ipv4/ip_options.c
> > @@ -200,6 +200,11 @@ int ip_options_echo(struct ip_options * dopt, =
struct sk_buff * skb)
> >                 *dptr++ =3D IPOPT_END;
> >                 dopt->optlen++;
> >         }
> > +       if (unlikely(dopt->optlen > 40)) {
> > +               pr_err("ip_options_echo() fatal error optlen=3D%u >=
 40\n", dopt->optlen);
> > +               print_hex_dump(KERN_ERR, "ip options: ", DUMP_PREFI=
X_OFFSET,
> > +                       16, 1, dopt->__data, dopt->optlen, false);
> > +       }
> >         return 0;
> >  }
>=20
> Here you check dopt->optlen, which certainly should be 40 at most. Th=
e
> calculation of dopt->optlen wasn't changed by my patch, though.

Check again the thread Jan.

Scot is using a tool (IP Stack Checker's tcpsic) to forge random tcp
packets.

Maybe your patch is fine but requires a change in a previous function,
to make sure we deny some crazy packet before generating an ip_options
with more than 40 bytes, in an icmp_send() reply.

I took a look at this ip_options stuff and must say its really hard to
even _read_ the code. Understanding it might need several days or a new
brain ?

I cannot Ack or Nack your patch, I must admit it. Isnt it frightening ?



