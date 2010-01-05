From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race [v3]
Date: Tue, 05 Jan 2010 23:36:47 +0100
Message-ID: <4B43BEFF.3030401@gmail.com>
References: <4B42E252.1080405@gmail.com> <1262724742-5232-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34968 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754670Ab0AEWhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 17:37:21 -0500
In-Reply-To: <1262724742-5232-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/01/2010 21:52, Flavio Leitner a =E9crit :
> Almost all igmp functions accessing inet->mc_list are protected by
> rtnl_lock(), but there is one exception which is ip_mc_sf_allow(),
> so there is a chance of either ip_mc_drop_socket or ip_mc_leave_group
> remove an entry while ip_mc_sf_allow is running causing a crash.
>=20
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Small notes : in ip_mc_drop_socket()


// rcu_read_lock()/unlock() seems not really needed here, we only want =
to avoid
//the fill rtnl=E7lock() in case this socket have a NULL mc_list.

rcu_read_lock();
if (rcu_dereference(inet->mc_list) =3D=3D NULL) {
	rcu_read_unlock();
	return;
}
rcu_read_unlock();


rtnl_lock();
while ((iml =3D rcu_dereference(inet->mc_list)) !=3D NULL) {

rcu_dereference() is not really needed here, since you own RTNL

