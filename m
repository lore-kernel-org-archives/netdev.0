From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Fri, 10 Jun 2011 06:31:27 +0200
Message-ID: <1307680287.3210.2.camel@edumazet-laptop>
References: <1307600810.3980.85.camel@edumazet-laptop>
	 <1307664235.17300.44.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46960 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119Ab1FJEbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 00:31:32 -0400
Received: by wwa36 with SMTP id 36so2368134wwa.1
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2011 21:31:31 -0700 (PDT)
In-Reply-To: <1307664235.17300.44.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 juin 2011 =C3=A0 17:03 -0700, Tim Chen a =C3=A9crit :
> On Thu, 2011-06-09 at 08:26 +0200, Eric Dumazet wrote:
> > Profiles show false sharing in addr_compare() because refcnt/dtime
> > changes dirty the first inet_peer cache line, where are lying the k=
eys
> > used at lookup time. If many cpus are calling inet_getpeer() and
> > inet_putpeer(), or need frag ids, addr_compare() is in 2nd position=
 in
> > "perf top".
> >=20
>=20
> I've applied both inetpeer patches.  I also no longer have inet_getpe=
er
> and inet_putpeer and addr_compare in my profile.  Instead, neighbor
> lookup is now dominant.  See profile below.
>=20
> When I retest with original 3.0-rc2 kernel, inet_putpeer no longer sh=
ows
> up, wonder if dst->peer was not set for some reason.=20
>=20
> Tim
>=20
> -     27.06%     memcached  [kernel.kallsyms]             [k] atomic_=
add_unless.clone.34
>    - atomic_add_unless.clone.34
>       - 99.97% neigh_lookup
>            __neigh_lookup_errno.clone.17
>            arp_bind_neighbour
>            rt_intern_hash
>            __ip_route_output_key
>            ip_route_output_flow
>            udp_sendmsg
>            inet_sendmsg
>            __sock_sendmsg
>            sock_sendmsg
>            __sys_sendmsg
>            sys_sendmsg
>            system_call_fastpath
>            __sendmsg
> -     13.33%     memcached  [kernel.kallsyms]             [k] atomic_=
dec_and_test
>    - atomic_dec_and_test
>       - 99.89% dst_destroy
>          - dst_release
>             - 98.12% skb_dst_drop.clone.55
>                  dev_hard_start_xmit
>                + sch_direct_xmit
>             + 1.88% skb_release_head_state
> -      3.26%     memcached  [kernel.kallsyms]             [k] do_raw_=
spin_lock
>    - do_raw_spin_lock
>       - 92.24% _raw_spin_lock
>          + 41.39% sch_direct_xmit
>=20
>=20

Thanks Tim

I have some questions for further optimizations.

1) How many different destinations are used in your stress load ?
2) Could you provide a distribution of the size of packet lengthes ?
   Or maybe the average length would be OK




