From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCH] Structure icmp6hdr (IPv6/ICMPv6) with bug in the bitfields!
Date: Tue, 14 Oct 2008 14:58:41 +0200
Message-ID: <87y70rxri6.fsf@natisbad.org>
References: <159769323.20081014120620@net.ipl.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pedro Ribeiro <pribeiro-bulk@net.ipl.pt>,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:54878 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754383AbYJNNAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 09:00:44 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1KpjVw-0001ng-LL
	for netdev@vger.kernel.org; Tue, 14 Oct 2008 13:00:40 +0000
Received: from cct.net8.nerim.net ([213.41.184.223])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 13:00:40 +0000
Received: from arno by cct.net8.nerim.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 13:00:40 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Pedro Ribeiro <pribeiro-bulk@net.ipl.pt> writes:

> Deep analysis in the sources of Linux revealed that the value of
> =E2=80=9Cpref=E2=80=9D passed to rt6_add_dflt_router(...) in the file=
 net/ipv6/route.c
> isn=E2=80=99t consistent with the one sent by the routers and observe=
d with
> wireshark. Seeking the roots of the problem I=E2=80=99ve detected a b=
ug in the
> definitions of the bitfield that includes the router preference in th=
e
> router advertisement message that are resulting in retrieving the
> wrong bits from the structure defined in =E2=80=9Cinclude/linux/icmpv=
6.h=E2=80=9D. The
> struct is the base one from ICMPv6 (icmp6hdr) and was lacking the bit
> field =E2=80=9Chome_agent=E2=80=9D between =E2=80=9Crouter_pref=E2=80=
=9D and =E2=80=9Cother=E2=80=9D and the reserved
> bits are only 3, not 4 as in the structure (according to RFC4191)

+1

> Follows a =E2=80=9Cdiff=E2=80=9D with the changes I=E2=80=99ve made t=
o correct this problem
> (I=E2=80=99ve made it against kernel 2.6.23, but I=E2=80=99ve confirm=
ed that the
> problem still exists in 2.6.25)
>
> --- /usr/src/linux-2.6.23-gentoo-r9orig/include/linux/icmpv6.h      2=
007-10-09 21:31:38.000000000 +0100
> +++ /usr/src/linux-2.6.23-gentoo-r9/include/linux/icmpv6.h      2008-=
10-13 17:42:56.000000000 +0100
> @@ -40,16 +40,18 @@
>                  struct icmpv6_nd_ra {
>                         __u8            hop_limit;
>  #if defined(__LITTLE_ENDIAN_BITFIELD)
> -                       __u8            reserved:4,
> +                       __u8            reserved:3,
>                                         router_pref:2,
> +                                       home_agent:1,
>                                         other:1,
>                                         managed:1;
> =20
>  #elif defined(__BIG_ENDIAN_BITFIELD)
>                         __u8            managed:1,
>                                         other:1,
> +                                       home_agent:1,
>                                         router_pref:2,
> -                                       reserved:4;
> +                                       reserved:3;
>  #else
>  #error "Please fix <asm/byteorder.h>"
>  #endif

Changes look ok to me.

> Even after this fix, the problem of deterministic and preference
> aware default route selection, remains. I have not figured until now
> how the preference affects the selection, maybe it is a missing
> feature.

can you confirm that you already activated CONFIG_IPV6_ROUTER_PREF in
your kernel configuration?

What are the values of following parameters on your system?:

  /proc/sys/net/ipv6/conf/*/accept_ra_rtr_pref
  /proc/sys/net/ipv6/conf/*/accept_ra_pinfo
  /proc/sys/net/ipv6/conf/*/accept_ra
  /proc/sys/net/ipv6/conf/*/autoconf

> Developers on this area please clarify me this subject; does the
> preference present in the RAs is supposed to influence the decision?

Looking at the code in ndisc.c (ndisc_router_discovery()), it should,
but I may have missed something.

> In addition, what is the criterion for selecting the default route in
> the presence of multiple candidates with the same preference?

Don't know.

=46unny it was not detected sooner. In patches I have for UMIP (userlan=
d
MIPv6 Daemon for Linux), access to router preferences field is done by
shifting bits (correctly, AFAICT) and routes are set from userspace
using that info. radvd also fills its RA that way, i.e. by shifting bit=
s
(it uses struct nd_router_advert from netinet/icmp6.h, which does not
have anything for router preference). That would explain why I never hi=
t
the bug.

Cheers,

a+

ps: added YOSHIFUJI Hideaki in CC.

