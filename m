From: enh <enh@google.com>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Mon, 3 May 2010 20:58:26 -0700
Message-ID: <AANLkTiljqyMDG-32GO8BGGhWVjKb7kVQumz0KAXXaakv@mail.gmail.com>
References: <AANLkTikUArEWFhsxpJGCbOPtvQATBKztP0jhZTTsdx7-@mail.gmail.com>
	 <4BDF8387.4000303@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:40873 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756988Ab0EDD6d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 23:58:33 -0400
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [10.3.21.13])
	by smtp-out.google.com with ESMTP id o443wVKK003447
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 20:58:31 -0700
Received: from gwb17 (gwb17.prod.google.com [10.200.2.17])
	by hpaq13.eem.corp.google.com with ESMTP id o443wTar014923
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 20:58:30 -0700
Received: by gwb17 with SMTP id 17so1308897gwb.40
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 20:58:29 -0700 (PDT)
In-Reply-To: <4BDF8387.4000303@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 3, 2010 at 19:16, Brian Haley <brian.haley@hp.com> wrote:
> enh wrote:
>> RFC 3493 (http://tools.ietf.org/rfc/rfc3493.txt) says:
>>
>> =C2=A0 =C2=A0 =C2=A0 IPV6_MULTICAST_HOPS
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Set the hop limit to use for outgo=
ing multicast packets. =C2=A0(Note
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0a separate option - IPV6_UNICAST_H=
OPS - is provided to set the
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hop limit to use for outgoing unic=
ast packets.)
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0The interpretation of the argument=
 is the same as for the
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0IPV6_UNICAST_HOPS option:
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 x < -1: =C2=A0 =C2=A0 =C2=A0=
 =C2=A0return an error of EINVAL
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 x =3D=3D -1: =C2=A0 =C2=A0=
 =C2=A0 use kernel default
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 <=3D x <=3D 255: use x
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 x >=3D 256: =C2=A0 =C2=A0 =
=C2=A0return an error of EINVAL
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 If IPV6_MULTICAST_HOPS is =
not set, the default is 1
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (same as IPv4 today)
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Argument type: int
>>
>> but if i create a socket and call getsockopt, i get 64, not 1. this
>> happens both on Android (2.6.32) and on Ubuntu 8.04 (2.6.24).
>
> <snip>
>
>> is this a bug? is this the right place to report it? thanks!
>
> It looks like a bug to me, feel free to send along a patch :)

a grep for IPV6_DEFAULT_MCASTHOPS suggests it isn't used:

http://git.kernel.org/?p=3Dlinux%2Fkernel%2Fgit%2Fnext%2Flinux-next.git=
&a=3Dsearch&h=3DHEAD&st=3Dgrep&s=3DIPV6_DEFAULT_MCASTHOPS

i assumed IPV6_DEFAULT_HOPLIMIT (the unicast hop limit) was being used
by accident where IPV6_DEFAULT_MCASTHOPS should be used.

looking at net/ipv6/ipv6_sockglue.c, i see that getsockopt for both
unicast and multicast hop limits defaults to the device's hop_limit:

1109         case IPV6_UNICAST_HOPS:
1110         case IPV6_MULTICAST_HOPS:
1111         {
1112                 struct dst_entry *dst;
1113
1114                 if (optname =3D=3D IPV6_UNICAST_HOPS)
1115                         val =3D np->hop_limit;
1116                 else
1117                         val =3D np->mcast_hops;
1118
1119                 if (val < 0) {
1120                         rcu_read_lock();
1121                         dst =3D __sk_dst_get(sk);
1122                         if (dst)
1123                                 val =3D ip6_dst_hoplimit(dst);
1124                         rcu_read_unlock();
1125                 }
1126
1127                 if (val < 0)
1128                         val =3D sock_net(sk)->ipv6.devconf_all->ho=
p_limit;
1129                 break;
1130         }

and look how net/ipv6/af_inet6.c initializes the two fields:

 202         np->hop_limit   =3D -1;
 203         np->mcast_hops  =3D -1;

so the easiest fix would be to change net/ipv6/af_inet6.c to:

 202         np->hop_limit   =3D -1; /* Use the configured device defau=
lt. */
 203         np->mcast_hops  =3D IPV6_DEFAULT_MCASTHOPS; /* Use RFC 349=
3
default. */

userspace programmers still have the ability to ask for the device's
default by calling setsockopt with the value -1 (as mentioned in the
RFC). in practice, i'd imagine anyone who actually wanted to use that
feature would want a separate tunable from the existing unicast one.

> -Brian
>
>



--=20
Elliott Hughes - http://who/enh - http://jessies.org/~enh/
