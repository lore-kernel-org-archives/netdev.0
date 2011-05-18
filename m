From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and
 sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 10:29:18 +0200
Message-ID: <1305707358.2983.14.camel@edumazet-laptop>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>
	 <1305704885.2983.4.camel@edumazet-laptop>
	 <BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: Jacek Luczak <difrost.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33501 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755862Ab1ERI3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 04:29:21 -0400
Received: by fxm17 with SMTP id 17so1012814fxm.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 01:29:20 -0700 (PDT)
In-Reply-To: <BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 mai 2011 =C3=A0 10:06 +0200, Jacek Luczak a =C3=A9crit :
> 2011/5/18 Eric Dumazet <eric.dumazet@gmail.com>:

> > If you're removing items from this list, you must be a writer here,=
 with
> > exclusive access. So rcu_read_lock()/rcu_read_unlock() is not neces=
sary.
>=20
> I could agree to some extend ... but strict RCU section IMO is needed=
 here.
> I can check this if the issue exists.
>=20

I can tell you for sure rcu_read_lock() is not needed here. Its only
showing confusion from code's author.

Please read Documentation/RCU/listRCU.txt for concise explanations,
line 117.


> > Therefore, I guess following code is better :
> >
> > list_for_each_entry(addr, &bp->address_list, list) {
> >        list_del_rcu(&addr->list);
> >        call_rcu(&addr->rcu, sctp_local_addr_free);
> >        SCTP_DBG_OBJCNT_DEC(addr);
> > }
> >
> > Then, why dont you fix sctp_bind_addr_clean() instead ?
> >
> > if 'struct sctp_sockaddr_entry' is recu protected, then all frees s=
hould
> > be protected as well.
>=20
> The _clean() as claimed by Vlad is called many times from various pla=
ces
> in code and this could give a overhead. I guess Vlad would need to co=
mment.

I guess a full review of this code is needed. You'll have to prove
sctp_bind_addr_clean() is always called after one RCU grace period if
you want to leave it as is.

You cant get RCU for free, some rules must be followed or you risk
crashes.



