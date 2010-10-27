From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tunnels: Fix tunnels change rcu protection
Date: Wed, 27 Oct 2010 21:02:52 +0200
Message-ID: <1288206172.2658.11.camel@edumazet-laptop>
References: <4CC848B9.1060406@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54977 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755303Ab0J0TC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:02:57 -0400
Received: by wyf28 with SMTP id 28so1046012wyf.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 12:02:55 -0700 (PDT)
In-Reply-To: <4CC848B9.1060406@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 octobre 2010 =C3=A0 19:43 +0400, Pavel Emelyanov a =C3=A9=
crit :
> After making rcu protection for tunnels (ipip, gre, sit and ip6) a bu=
g
> was introduced into the SIOCCHGTUNNEL code.
>=20
> The tunnel is first unlinked, then addresses change, then it is linke=
d
> back probably into another bucket. But while changing the parms, the
> hash table is unlocked to readers and they can lookup the improper tu=
nnel.
>=20
> Respective commits are b7285b79 (ipip: get rid of ipip_lock), 1507850=
b
> (gre: get rid of ipgre_lock), 3a43be3c (sit: get rid of ipip6_lock) a=
nd
> 94767632 (ip6tnl: get rid of ip6_tnl_lock).
>=20
> The quick fix is to wait for quiescent state to pass after unlinking,
> but if it is inappropriate I can invent something better, just let me
> know.
>=20
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Good catch, I missed a change was possible at all :(

I guess some setups could scream with this fix, since this adds a
synchronize_net() call while holding RTNL ...

Hmm, maybe we should allocate a "struct ip_tunnel_parm" instead of usin=
g
an embedded one (in struct ip_tunnel), and stick an rcu_head in it to
delay its freeing...




