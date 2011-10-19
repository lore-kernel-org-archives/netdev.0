From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] route:ip_rt_frag_needed always return unzero
Date: Wed, 19 Oct 2011 05:49:47 +0200
Message-ID: <1318996187.19139.8.camel@edumazet-laptop>
References: <1318921469-25599-1-git-send-email-gaofeng@cn.fujitsu.com>
	 <1318929797.2657.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E9E2929.7070701@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64975 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470Ab1JSDtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:49:52 -0400
Received: by wyg36 with SMTP id 36so1282627wyg.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 20:49:51 -0700 (PDT)
In-Reply-To: <4E9E2929.7070701@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 octobre 2011 =C3=A0 09:34 +0800, Gao feng a =C3=A9crit :
> 2011.10.18 17:23, Eric Dumazet wrote:
> > Le mardi 18 octobre 2011 =C3=A0 15:04 +0800, Gao feng a =C3=A9crit =
:
> >> int function ip_rt_frag_need,if peer is null,
> >> there is no need to do ipprot->err_handler.
> >> I am right?
> >>
> >> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> >> ---
> >>  net/ipv4/route.c |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> >> index 075212e..6cde0fa 100644
> >> --- a/net/ipv4/route.c
> >> +++ b/net/ipv4/route.c
> >> @@ -1574,7 +1574,7 @@ unsigned short ip_rt_frag_needed(struct net =
*net, const struct iphdr *iph,
> >> =20
> >>  		atomic_inc(&__rt_peer_genid);
> >>  	}
> >> -	return est_mtu ? : new_mtu;
> >> +	return est_mtu;
> >>  }
> >> =20
> >>  static void check_peer_pmtu(struct dst_entry *dst, struct inet_pe=
er *peer)
> >=20
> > No idea why you want this, your changelog is a bit cryptic :)
> >=20
> > Wont this bypass the raw_icmp_error(skb, protocol, info);
> > call in icmp_unreach() as well ?
> >=20
> >=20
>=20
> thanks Eric!
>=20
> I mean that the pmtu is update by inet_peer->pmtu_learned as I know.
> so in function ip_rt_frag_needed,
> if inet_peer is null or someting else make the setting of inet_peer->=
pmtu_learned failed.
> there is no need to call function tcp_v4_err.
>=20
> the call stack is
> icmp_unreach
>   |
>   |--->ip_rt_frag_needed(fill inet_peer)
>   |
>   |--->raw_icmp_error()
>   |
>   |--->ipprot->err_handler(tcp_v4_err or something else)
> 	|
> 	|--->tcp_v4_err(frag need icmp is triggered by tcp packet)
> 		|
> 		|--->do_pmtu_discovery
> 		(in this function both __sk_dst_check or dst->ops->update_pmtu
> 		need struct inet_peer to update pmtu)
>=20
> so,I think when set inet_peer->pmtu_learned failed,
> in func icmp_unreach we should goto out immediately.
>=20
> And it's confuse me that why func ping_err and udp_err not update the=
 pmtu?
> What I miss?

You dont answer my question : After your patch, we now dont call
raw_icmp_error() anymore. Why is is valid ?

Not finding/create inet_peer is very unlikely : This occurs only under
high stress and out of memory condition. Is it really happening on your
machines ?
