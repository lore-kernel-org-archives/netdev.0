From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race
Date: Mon, 04 Jan 2010 14:07:03 +0100
Message-ID: <4B41E7F7.2030003@gmail.com>
References: <1262183005-28406-1-git-send-email-fleitner@redhat.com> <20100103.215441.43026709.davem@davemloft.net> <20100104112957.GA2573@sysclose.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Flavio Leitner <fbl@sysclose.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42528 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860Ab0ADNHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 08:07:10 -0500
In-Reply-To: <20100104112957.GA2573@sysclose.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/01/2010 12:29, Flavio Leitner a =E9crit :
=20
> Then, I tried using call_rcu() to avoid the problem you are saying,
> but when you stop the reproducer, sk_free() will warn printing=20
> "optmem leakage.." because the rcu callback didn't run yet.
>=20
>=20

This is probably because your call_rcu() callback was trying to call so=
ck_kfree_s() ?

 		rtnl_unlock();
		call_rcu(&iml->lock, callback_func)

callback_func()
{
	sock_kfree_s(sk, iml, sizeof(*iml));
}



Take a look at sock_kfree_s() definition :

void sock_kfree_s(struct sock *sk, void *mem, int size)
{
        kfree(mem);
        atomic_sub(size, &sk->sk_omem_alloc);
}


You can certainly try :

	rtnl_unlock();
	atomic_sub(sizeof(*iml), sk->sk_omem_alloc);
	call_rcu(&iml->rcu, kfree);

(immediate sk_omem_alloc handling, but deferred kfree())

