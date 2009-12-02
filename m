From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Fix a connect() race with timewait sockets
Date: Wed, 02 Dec 2009 10:23:50 +0100
Message-ID: <4B163226.50801@gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>	<4B152F97.1090409@gmail.com> <20091202.005937.177088443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kdakhane@gmail.com, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, zbr@ioremap.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34557 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbZLBJXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 04:23:55 -0500
In-Reply-To: <20091202.005937.177088443.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 01 Dec 2009 16:00:39 +0100
>=20
>> [PATCH] tcp: Fix a connect() race with timewait sockets
>=20
> This condition would only trigger if the timewait recycling sysctl is
> enabled.
>=20
> It is off by default, and I can't find any mention in this bug report
> that it has been turned on.

Very true. I know nothing about context of the reporter, he didnt
answered to my queries.

Yes, if sysctl_tw_reuse is set, bug can triggers without any extra cond=
itions.

But even if sysctl_tw_reuse is cleared, we might trigger the bug if
local port is bound to a value.

[User application called bind( port=3DXXX) before connect() ]


__inet_hash_connect() can indeed call check_established(... twp =3D NUL=
L)

=2E..
        head =3D &hinfo->bhash[inet_bhashfn(net, snum, hinfo->bhash_siz=
e)];
        tb  =3D inet_csk(sk)->icsk_bind_hash;
        spin_lock_bh(&head->lock);
        if (sk_head(&tb->owners) =3D=3D sk && !sk->sk_bind_node.next) {
                hash(sk);
                spin_unlock_bh(&head->lock);
                return 0;
        } else {
                spin_unlock(&head->lock);
                /* No definite answer... Walk to established hash table=
 */
                ret =3D check_established(death_row, sk, snum, NULL);  =
       <<< HERE >>>
out:
                local_bh_enable();
                return ret;
        }



In this case, we call tcp_twsk_unique() with twp =3D NULL,
this bypass the sysctl_tcp_tw_reuse test.


int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
{
        const struct tcp_timewait_sock *tcptw =3D tcp_twsk(sktw);
        struct tcp_sock *tp =3D tcp_sk(sk);

        /* With PAWS, it is safe from the viewpoint
           of data integrity. Even without PAWS it is safe provided seq=
uence
           spaces do not overlap i.e. at data rates <=3D 80Mbit/sec.

           Actually, the idea is close to VJ's one, only timestamp cach=
e is
           held not per host, but per port pair and TW bucket is used a=
s state
           holder.

           If TW bucket has been already destroyed we fall back to VJ's=
 scheme
           and use initial timestamp retrieved from peer table.
         */
        if (tcptw->tw_ts_recent_stamp &&
<<HERE>>       (twp =3D=3D NULL || (sysctl_tcp_tw_reuse &&
                             get_seconds() - tcptw->tw_ts_recent_stamp =
> 1))) {
