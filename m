From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3] net: dynamic ingress_queue allocation
Date: Mon, 04 Oct 2010 10:42:09 +0200
Message-ID: <1286181729.18293.8.camel@edumazet-laptop>
References: <1285689517.3154.76.camel@edumazet-laptop>
	 <20100928180447.GA1880@del.dom.local> <1285757817.3561.2.camel@bigi>
	 <1285887509.2705.33.camel@edumazet-laptop> <1285933506.3553.176.camel@bigi>
	 <1285941388.2641.175.camel@edumazet-laptop>
	 <20101002093255.GA2049@del.dom.local>
	 <1286035915.2582.2472.camel@edumazet-laptop>
	 <20101003094221.GA2028@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36146 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414Ab0JDImO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 04:42:14 -0400
Received: by fxm14 with SMTP id 14so1549612fxm.19
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 01:42:13 -0700 (PDT)
In-Reply-To: <20101003094221.GA2028@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 03 octobre 2010 =C3=A0 11:42 +0200, Jarek Poplawski a =C3=A9=
crit :

> I'd consider rcu_dereference_rtnl(). Btw, technically qdisc_lookup()
> doesn't require rtnl, and there was time it was used without it
> (on xmit path).


Hmm, for me, rcu_dereference_rtnl() is a bit lazy.

Either we are a reader and should use rcu_dereference(), or a writer an=
d
RTNL should be held.

Mixing two conditions in a "super macro" is a workaround that we used t=
o
promptly shutup some lockdep splats. Real fix would be to use strict
lockdep conditions, because this better documents the code and the
locking invariants.

BTW, rtnl_dereference() should be changed to use
rcu_dereference_protected() instead of rcu_dereference_check() :
If RTBL is held, there is no need to force a barrier.


> I think you should also add a comment here why this rcu is used, and
> that it changes only once in dev's liftime.
>=20

This comment was needed in the previous version of the patch, with the
smb_wmb() barrier. Now I switched to regular rcu use, nothing prevents
us to change dev->ingress_queue in flight. Of course there is no curren=
t
interest doing so.



