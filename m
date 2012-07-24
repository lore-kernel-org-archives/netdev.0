From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] r8169: revert "add byte queue limit support".
Date: Tue, 24 Jul 2012 07:09:16 +0200
Message-ID: <1343106556.2626.11039.camel@edumazet-glaptop>
References: <20120723205555.GA4392@electric-eye.fr.zoreil.com>
	 <1343106407.2626.11038.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hayeswang@realtek.com,
	netdev@vger.kernel.org,
	Alex =?ISO-8859-1?Q?Villac=EDs?= Lasso
	<a_villacis@palosanto.com>, Josh Boyer <jwboyer@redhat.com>,
	Tom Herbert <therbert@google.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:49707 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990Ab2GXFJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 01:09:20 -0400
Received: by wibhm11 with SMTP id hm11so3603777wib.1
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 22:09:19 -0700 (PDT)
In-Reply-To: <1343106407.2626.11038.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-24 at 07:06 +0200, Eric Dumazet wrote:
> On Mon, 2012-07-23 at 22:55 +0200, Francois Romieu wrote:
> > This reverts commit 036dafa28da1e2565a8529de2ae663c37b7a0060.
> >=20
> > First it appears in bisection, then reverting it solves the usual
> > netdev watchdog problem for different people. I don't have a proper
> > fix yet so get rid of it.
> >=20
> > Bisected-and-reported-by: Alex Villac=C3=ADs Lasso <a_villacis@palo=
santo.com>
> > Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> > Cc: Josh Boyer <jwboyer@redhat.com>
> > Cc: Hayes Wang <hayeswang@realtek.com>
> > ---
>=20
> bisection is not always the right way to qualify a problem.
>=20
> BQL in itself had some fixes coming _after_ commit 036dafa28da1e2565
>=20
> Is there an easy way to reproduce the problem ?
>=20
> Thanks
>=20

BQL fixes are :

commit 914bec1011a25f65cdc94988a6f974bfb9a3c10d
Author: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date:   Wed May 30 12:25:37 2012 +0000

    bql: Avoid possible inconsistent calculation.
   =20
    dql->num_queued could change while processing dql_completed().
    To provide consistent calculation, added an on stack variable.
   =20
    Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
    Cc: Tom Herbert <therbert@google.com>
    Cc: Eric Dumazet <eric.dumazet@gmail.com>
    Cc: Denys Fedoryshchenko <denys@visp.net.lb>
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 25426b794efdc70dde7fd3134dc56fac3e7d562d
Author: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date:   Wed May 30 12:25:19 2012 +0000

    bql: Avoid unneeded limit decrement.
   =20
    When below pattern is observed,
   =20
                                                   TIME
           dql_queued()         dql_completed()     |
          a) initial state                          |
                                                    |
          b) X bytes queued                         V
   =20
          c) Y bytes queued
                               d) X bytes completed
          e) Z bytes queued
                               f) Y bytes completed
   =20
    a) dql->limit has already some value and there is no in-flight
packet.
    b) X bytes queued.
    c) Y bytes queued and excess limit.
    d) X bytes completed and dql->prev_ovlimit is set and also
       dql->prev_num_queued is set Y.
    e) Z bytes queued.
    f) Y bytes completed. inprogress and prev_inprogress are true.
   =20
    At f), according to the comment, all_prev_completed becomes
    true and limit should be increased. But POSDIFF() ignores
    (completed =3D=3D dql->prev_num_queued) case, so limit is decreased=
=2E
   =20
    Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
    Cc: Tom Herbert <therbert@google.com>
    Cc: Eric Dumazet <eric.dumazet@gmail.com>
    Cc: Denys Fedoryshchenko <denys@visp.net.lb>
    Acked-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 0cfd32b736ae0c36b42697584811042726c07cba
Author: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date:   Wed May 30 12:24:39 2012 +0000

    bql: Fix POSDIFF() to integer overflow aware.
   =20
    POSDIFF() fails to take into account integer overflow case.
   =20
    Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
    Cc: Tom Herbert <therbert@google.com>
    Cc: Eric Dumazet <eric.dumazet@gmail.com>
    Cc: Denys Fedoryshchenko <denys@visp.net.lb>
    Acked-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
