From: =?UTF-8?Q?Ernst_Sj=C3=B6strand?= <ernstp@gmail.com>
Subject: Re: [Bugme-new] [Bug 29252] New: IPv6 doesn't work in a kvm guest.
Date: Fri, 11 Mar 2011 20:44:39 +0100
Message-ID: <AANLkTi=T35ghBWJKu+fimXnJczRjy9GzY+H_6GiNbgHE@mail.gmail.com>
References: <20110217142517.b9919481.akpm@linux-foundation.org>
	<20110309.155818.212679516.davem@davemloft.net>
	<20110309.192012.193710171.davem@davemloft.net>
	<20110309.200437.226773227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, slash@ac.auone-net.jp
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:41462 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987Ab1CKTol convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 14:44:41 -0500
Received: by vxi39 with SMTP id 39so2886623vxi.19
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2011 11:44:40 -0800 (PST)
In-Reply-To: <20110309.200437.226773227.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch solved the issue I reported. Applied the patch on -rc8.

Regards
//Ernst

On Thu, Mar 10, 2011 at 05:04, David Miller <davem@davemloft.net> wrote=
:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 09 Mar 2011 19:20:12 -0800 (PST)
>
>> From: David Miller <davem@davemloft.net>
>> Date: Wed, 09 Mar 2011 15:58:18 -0800 (PST)
>>
>>> Ok, the following should address both bugs, #29252 and #30462, plea=
se
>>> give it some testing.
>>>
>>> --------------------
>>> ipv6: Don't create clones of nonexthop routes forever.
>>
>> Nevermind, this patch has problems, I'm still debugging and trying t=
o
>> come up with a proper fix.
>>
>> Thanks in advance for your patience.
>
> Ok, I'm more confident in this version of the fix. =C2=A0It passes al=
l of
> my tests, and I've added instrumentation to make sure various cases
> are performing the operations the way I expect them to.
>
> --------------------
> ipv6: Don't create clones of host routes.
> MIME-Version: 1.0
> Content-Type: text/plain; charset=3DUTF-8
> Content-Transfer-Encoding: 8bit
>
> Addresses https://bugzilla.kernel.org/show_bug.cgi?id=3D29252
> Addresses https://bugzilla.kernel.org/show_bug.cgi?id=3D30462
>
> In commit d80bc0fd262ef840ed4e82593ad6416fa1ba3fc4 ("ipv6: Always
> clone offlink routes.") we forced the kernel to always clone offlink
> routes.
>
> The reason we do that is to make sure we never bind an inetpeer to a
> prefixed route.
>
> The logic turned on here has existed in the tree for many years,
> but was always off due to a protecting CPP define. =C2=A0So perhaps
> it's no surprise that there is a logic bug here.
>
> The problem is that we canot clone a route that is already a
> host route (ie. has DST_HOST set). =C2=A0Because if we do, an identic=
al
> entry already exists in the routing tree and therefore the
> ip6_rt_ins() call is going to fail.
>
> This sets off a series of failures and high cpu usage, because when
> ip6_rt_ins() fails we loop retrying this operation a few times in
> order to handle a race between two threads trying to clone and insert
> the same host route at the same time.
>
> Fix this by simply using the route as-is when DST_HOST is set.
>
> Reported-by: slash@ac.auone-net.jp
> Reported-by: Ernst Sj=C3=B6strand <ernstp@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> =C2=A0net/ipv6/route.c | =C2=A0 =C2=A04 +++-
> =C2=A01 files changed, 3 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 904312e..e7db701 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -739,8 +739,10 @@ restart:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!rt->rt6i_nexthop && !(rt->rt6i_flags =
& RTF_NONEXTHOP))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nrt =3D rt6_al=
loc_cow(rt, &fl->fl6_dst, &fl->fl6_src);
> - =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 else if (!(rt->dst.flags & DST_HOST))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nrt =3D rt6_al=
loc_clone(rt, &fl->fl6_dst);
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out2;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dst_release(&rt->dst);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rt =3D nrt ? : net->ipv6.ip6_null_entry;
> --
> 1.7.4.1
>
>
