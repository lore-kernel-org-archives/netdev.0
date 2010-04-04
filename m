From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v4 00/14] l2tp: Introduce L2TPv3 support
Date: Sun, 04 Apr 2010 10:14:06 +0200
Message-ID: <1270368846.1971.7.camel@edumazet-laptop>
References: <20100402161822.11367.70454.stgit@bert.katalix.com>
	 <20100403.142522.01040744.davem@davemloft.net>
	 <1270367668.1971.3.camel@edumazet-laptop>
	 <20100404.010259.161188935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:48613 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537Ab0DDIOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 04:14:12 -0400
Received: by bwz1 with SMTP id 1so2276802bwz.21
        for <netdev@vger.kernel.org>; Sun, 04 Apr 2010 01:14:10 -0700 (PDT)
In-Reply-To: <20100404.010259.161188935.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 04 avril 2010 =C3=A0 01:02 -0700, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 04 Apr 2010 09:54:28 +0200
>=20
> > [PATCH net-next-2.6] l2tp: unmanaged L2TPv3 tunnels fixes
> >=20
> > Followup to commit 789a4a2c=20
> > (l2tp: Add support for static unmanaged L2TPv3 tunnels)
> >=20
> > One missing init in l2tp_tunnel_sock_create() could access random k=
ernel
> > memory, and a bit field should be unsigned.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, thanks Eric.

I am going to work on net/l2tp/l2tp_core.c, since RCU conversion is
wrong (but original code was wong too...)

Example :

There is no real protection in following code, since no refcount is
taken on session before releasing rcu_read_lock :

static struct l2tp_session *l2tp_session_find_2(struct net *net, u32 se=
ssion_id)
{
        struct l2tp_net *pn =3D l2tp_pernet(net);
        struct hlist_head *session_list =3D
                l2tp_session_id_hash_2(pn, session_id);
        struct l2tp_session *session;
        struct hlist_node *walk;

        rcu_read_lock_bh();
        hlist_for_each_entry_rcu(session, walk, session_list, global_hl=
ist) {
                if (session->session_id =3D=3D session_id) {
                        rcu_read_unlock_bh();
                        return session;
                }
        }
        rcu_read_unlock_bh();

        return NULL;
}


