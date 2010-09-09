From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Thu, 09 Sep 2010 14:57:38 +0200
Message-ID: <1284037058.2589.169.camel@edumazet-laptop>
References: <20100909064222.GA6951@ff.dom.local>
	 <1284015345.2428.37.camel@edumazet-laptop>
	 <20100909070926.GB6951@ff.dom.local> <20100909072453.GA7383@ff.dom.local>
	 <20100909090816.GA7450@ff.dom.local>
	 <1284024237.2589.15.camel@edumazet-laptop>
	 <20100909095920.GB8404@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44237 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab0IIM5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 08:57:43 -0400
Received: by fxm16 with SMTP id 16so816845fxm.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 05:57:42 -0700 (PDT)
In-Reply-To: <20100909095920.GB8404@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 septembre 2010 =C3=A0 09:59 +0000, Jarek Poplawski a =C3=A9=
crit :

> Btw, I wonder if for readability and debuging it shouldn't be made
> generic as rcu_cmpxchg_pointer() etc.?

There are a lot of things to do in this area (with proper __rcu sparse
annotations, this can be not very readable ...)


/**
 * rcu_cmpxchg - atomic compare and exchange, SMP & rcu safe
 * @p: pointer to value
 * @old: old value
 * @new: new value
 *
 * Equivalent to :
 *    ATOMIC_BEGIN
 *     ret =3D *p;
 *     if (ret =3D=3D old)
 *             rcu_assign_pointer(*p, new);
 *    ATOMIC_END
 *    return ret;
 *
 * cmpxpchg() contains full memory barriers, so can be used
 * in rcu write side without additional smp_wmb() barrier
 */
#define rcu_cmpxchg(p, old, new) cmpxchg(p, old, new)


const struct net_protocol __rcu *
        inet_protos[MAX_INET_PROTOS] __read_mostly;

=2E..

return !rcu_cmpxchg(&inet_protos[hash],=20
                    NULL,
                    (const struct net_protocol __force __rcu *)prot) ?
		0 : -1;

=2E..


