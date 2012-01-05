From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net_sched: sfq: extend limits
Date: Thu, 05 Jan 2012 19:22:02 +0100
Message-ID: <1325787722.4759.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1325722718.2634.17.camel@edumazet-laptop>
	 <CAEas1LKV3USGX5wi6ucW2j_REzxKAeu3Rzj4Je5s92y33=kWDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41789 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757717Ab2AESWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:22:05 -0500
Received: by werm1 with SMTP id m1so585418wer.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 10:22:04 -0800 (PST)
In-Reply-To: <CAEas1LKV3USGX5wi6ucW2j_REzxKAeu3Rzj4Je5s92y33=kWDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 janvier 2012 =C3=A0 10:08 -0800, Laurent Chavey a =C3=A9cri=
t :

> >  /*
> > @@ -131,9 +143,9 @@ struct sfq_sched_data {
> >  */
> >  static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data =
*q, sfq_index val)
> >  {
> > -       if (val < SFQ_SLOTS)
>=20
>=20
> why not use q->maxflows here rather than SFQ_MAX_FLOWS ?
>=20

Debug-ability ? val indexes for dep[] array are not dependent on
q->maxflows : 0xFF80 -> 0xFFFF

> looking at sfq_change(), q->maxflows may be <=3D to SFQ_MAX_FLOWS

yep... but values between q->maxflows and SFQ_MAX_FLOWS wont be
possible.

>=20
> the initial creation of the slots array in sfq_init() uses q->maxflow=
s.
> q->maxflows is initialized to SFQ_DEFAULT_FLOWS which is / maybe less
> than SFQ_MAX_FLOWS
>=20

It really doesnt matter, and code is faster on most arches.

if (val < SFQ_MAX_FLOWS)
      return &q->slots[val].dep;
return &q->dep[val - SFQ_MAX_FLOWS];

faster than : (because of extra memory reference)

if (val < q->maxflows)
      return &q->slots[val].dep;
return &q->dep[val - q->maxflows];


As a matter of fact, maxflows could be moved at the end of struct
sfq_sched_data since its not used in fast path.
