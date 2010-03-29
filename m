From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] NETLABEL: Fix an RCU warning
Date: Mon, 29 Mar 2010 22:19:05 +0200
Message-ID: <1269893945.1958.72.camel@edumazet-laptop>
References: <20100325110621.5348.32020.stgit@warthog.procyon.org.uk>
	 <201003291130.10752.paul.moore@hp.com>
	 <20100329155857.GG2569@linux.vnet.ibm.com>
	 <201003291605.48605.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, David Howells <dhowells@redhat.com>,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:62395 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312Ab0C2UTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 16:19:13 -0400
Received: by bwz1 with SMTP id 1so3881081bwz.21
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 13:19:11 -0700 (PDT)
In-Reply-To: <201003291605.48605.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 mars 2010 =C3=A0 16:05 -0400, Paul Moore a =C3=A9crit :

> Okay, is there a recommended approach towards accessing RCU-protected=
 pointers=20
> both under a RCU read lock and under only a spinlock (or similar lock=
=20
> construct)?  I know I could do something based on querying the state =
of the=20
> RCU/etc. locks but that seems like a hack and could interfere with so=
me of the=20
> logic used to detect coding problems.
>=20

Say you use a common function func1(), that use RCU protection, from a
pure reader, and from a pure writer.

pure_reader()
{
	rcu_read_lock();
	res =3D func1();
	rcu_read_unlock();
}

pure_writer()
{
	spin_lock(&some_lock);
	res =3D func1();
	spin_unlock(&some_lock);
}

then, func1 could use

func1()
{
 ..... ptr =3D rcu_dereference_check(xxx->ptr,
				   rcu_read_lock_held() ||=20
				   lockdep_is_held(&some_lock));
=2E..
}


They are numerous examples in tree.
If some iterators use implicit rcu_dereference(), you'll probably need
to define new iterators, so that full condition can be tested.

rcu_dereference() is a shorthand for=20
	rcu_dereference_check(p, rcu_read_lock_held())

This only deals for pure readers, not potential pure writer :)



