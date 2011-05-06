From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 34322] New: No ECN marking in IPv6
Date: Fri, 06 May 2011 17:04:52 +0200
Message-ID: <1304694292.3066.29.camel@edumazet-laptop>
References: <bug-34322-10286@https.bugzilla.kernel.org/>
	 <20110505144146.4bc1e744.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, sgunderson@bigfoot.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:34875 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756415Ab1EFPE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 11:04:58 -0400
Received: by wwk4 with SMTP id 4so507390wwk.1
        for <netdev@vger.kernel.org>; Fri, 06 May 2011 08:04:57 -0700 (PDT)
In-Reply-To: <20110505144146.4bc1e744.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 mai 2011 =C3=A0 14:41 -0700, Andrew Morton a =C3=A9crit :
> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>=20
> On Tue, 3 May 2011 20:05:00 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D34322
> >=20
> >            Summary: No ECN marking in IPv6
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 2.6.38.4
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: IPV6
> >         AssignedTo: yoshfuji@linux-ipv6.org
> >         ReportedBy: sgunderson@bigfoot.com
> >         Regression: No
> >=20
> >=20
> > Hi,
> >=20
> > I'm completely unable to get ECN to work for IPv6. /proc/sys/net/ip=
v4/tcp_ecn
> > is set to 1 on both sides, and ECN works just fine for IPv4 TCP con=
nections,
> > but when I connect over IPv6 tclass just stays at 0x0, and as far a=
s I'd
> > understood, there should be two bits here set to 10 (like in the di=
ffserv field
> > of IPv4), right?
> >=20
> > I do get ECN-echo bits in the TCP header, though (for the initial S=
YN and
> > SYN/ACK  packets).
> >=20
>=20
> and
>=20
> > I looked at the code, and although I don't understand all of it, it
> > looks like e9df2e8fd8fbc95c57dbd1d33dada66c4627b44c (which also bro=
ught
> > ECN for IPv6 SCTP) might be the culprit.  It seems like TCP_ECN_sen=
d()
> > calls INET_ECN_xmit(), which only sets the ECN bit in the IPv4 ToS
> > field (inet_sk(sk)->tos), but after the patch, what's checked is
> > inet6_sk(sk)->tclass, which is a completely different field.
> >=20
> > Is the analysis correct? Should the tclass be set as well?
>=20
> and
>=20
> > OK, as a quick hack, I did this:
> >=20
> > --- a/linux-2.6.38.5/include/net/inet_ecn.h    2011-04-14 22:03:56.=
000000000+0200
> > +++ b/linux-2.6.38.5/include/net/inet_ecn.h    2011-05-04 00:36:52.=
803377902+0200
> > @@ -38,7 +38,7 @@
> >      return outer;
> >  }
> >=20
> > -#define    INET_ECN_xmit(sk) do { inet_sk(sk)->tos |=3D INET_ECN_E=
CT_0; } while (0)
> > +#define    INET_ECN_xmit(sk) do { inet_sk(sk)->tos |=3D INET_ECN_E=
CT_0; if (inet6_sk(sk) !=3D NULL) inet6_sk(sk)->tclass |=3D INET_ECN_EC=
T_0; } while (0)
> >  #define    INET_ECN_dontxmit(sk) \
> >      do { inet_sk(sk)->tos &=3D ~INET_ECN_MASK; } while (0)
> >=20
> > and now my packets are properly marked with tclass 0x02 (ie.,
> > signalling ECN-capable transport, no congestion experienced yet).
> >=20
> > I guess this isn't the right way of doing it, but at least it confi=
rms
> > that the lack of setting tclass is part of the problem.
>=20

Cc YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Hello Steinar

Analysis seems fine, but you also need to change INET_ECN_dontxmit() fo=
r
retransmitted packets.

Any chance you can refine your patch ?

Thanks !


