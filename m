From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] route:ip_rt_frag_needed always return unzero
Date: Wed, 19 Oct 2011 09:26:29 +0200
Message-ID: <20111019072628.GS1830@secunet.com>
References: <1318921469-25599-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1318929797.2657.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4E9E2929.7070701@cn.fujitsu.com>
 <1318996187.19139.8.camel@edumazet-laptop>
 <4E9E5E1C.5020603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60216 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142Ab1JSH0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 03:26:35 -0400
Content-Disposition: inline
In-Reply-To: <4E9E5E1C.5020603@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2011 at 01:20:28PM +0800, Gao feng wrote:
> =E4=BA=8E 2011=E5=B9=B410=E6=9C=8819=E6=97=A5 11:49, Eric Dumazet =E5=
=86=99=E9=81=93:
> > Le mercredi 19 octobre 2011 =C3=A0 09:34 +0800, Gao feng a =C3=A9cr=
it :
> >>
> >> I mean that the pmtu is update by inet_peer->pmtu_learned as I kno=
w.
> >> so in function ip_rt_frag_needed,
> >> if inet_peer is null or someting else make the setting of inet_pee=
r->pmtu_learned failed.
> >> there is no need to call function tcp_v4_err.
> >>
> >> the call stack is
> >> icmp_unreach
> >>   |
> >>   |--->ip_rt_frag_needed(fill inet_peer)
> >>   |
> >>   |--->raw_icmp_error()
> >>   |
> >>   |--->ipprot->err_handler(tcp_v4_err or something else)
> >> 	|
> >> 	|--->tcp_v4_err(frag need icmp is triggered by tcp packet)
> >> 		|
> >> 		|--->do_pmtu_discovery
> >> 		(in this function both __sk_dst_check or dst->ops->update_pmtu
> >> 		need struct inet_peer to update pmtu)
> >>
> >> so,I think when set inet_peer->pmtu_learned failed,
> >> in func icmp_unreach we should goto out immediately.
> >>
> >> And it's confuse me that why func ping_err and udp_err not update =
the pmtu?
> >> What I miss?

On udp and raw sockets, the user is responsible to adjust the packet
size according to the mtu value he may find in the socket's error queue=
=2E
So we shoud provide the user with this information, even in the unlikel=
y
case where we could not create an inet_peer.

> >=20
> > You dont answer my question : After your patch, we now dont call
> > raw_icmp_error() anymore. Why is is valid ?
>=20
> After my patch
> raw_icmp_error don't call only when setting inet_peer failed(ip_rt_fr=
ag_needed return zero).
> And I think it's unexpected,should goto out immediately.
>=20
> In orig ip_rt_frag_need,
> zero can be return only when pmtu(get from icmp packet) is zero and p=
eer is NULL.
> in this case,raw_icmp_error will not be call too.this is valid??
>=20

It is valid in the sense that we should not provide the user
with a mtu information if we know that the value we got from
the icmp packet ist bogus. But perhaps we can think about
making the check for a valid mtu unconditionally and let
ip_rt_frag_needed return a valid mtu in any case.
