From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: add dev_close_many
Date: Mon, 13 Dec 2010 17:52:25 +0100
Message-ID: <1292259145.2759.55.camel@edumazet-laptop>
References: <1292249903-3865-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f45.google.com ([209.85.215.45]:61288 "EHLO
	mail-ew0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018Ab0LMQwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 11:52:31 -0500
Received: by ewy10 with SMTP id 10so4055264ewy.4
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 08:52:30 -0800 (PST)
In-Reply-To: <1292249903-3865-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 d=C3=A9cembre 2010 =C3=A0 16:18 +0200, Octavian Purdila a =C3=
=A9crit :
> Add dev_close_many and dev_deactivate_many to factorize another
> expensive sync-rcu operation in the netdevice unregister path.
>=20
> $ modprobe dummy numdummies=3D10000
> $ ip link set dev dummy* up
> $ time rmmod dummy
>=20
> Without the patch           With the patch
>=20
> real    0m 24.63s           real    0m 5.15s
> user    0m 0.00s            user    0m 0.00s
> sys     0m 6.05s            sys     0m 5.14s
>=20
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---

Hmm, I think this solves the "rmmod dummy" case, but not the "dismantle
devices one by one", which is the general one (on heavy duty tunnels/pp=
p
servers)

I think we could use a kernel thread (a workqueue presumably), handling
3 lists of devices to be dismantled, respecting one rcu grace period (o=
r
rcu_barrier()) before transfert of one item from one list to following
one.

This way, each device removal could post a device to this kernel thread
and return to user immediately. Time of RTNL hold would be reduced
(calls to synchronize_rcu() would be done with RTNL not held)



