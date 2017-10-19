From: Timo Teras <timo.teras@iki.fi>
Subject: Re: Netlink XFRM socket subsystem NULL pointer dereference
Date: Thu, 19 Oct 2017 14:33:20 +0300
Message-ID: <20171019143320.00f787bd@vostro.util.wtbts.net>
References: <CAHqykcSO0vQvh0uXwDNgXr0ZpP8m4AGZ=ks9FNshJZw0=GWHpw@mail.gmail.com>
        <CANn89iLBO2RzqMzb61Qn=HFncsfYLnXLcUfSqFsDTPakQ2o4FQ@mail.gmail.com>
        <20171017061832.GA3323@secunet.com>
        <CANn89iJmtPQ=HV6xLjTaLS6WnVmiN+PgaObmWWnevcEzLitRTQ@mail.gmail.com>
        <20171018151159.GA5188@gondor.apana.org.au>
        <CANn89iL_QRZUTDXdci+Nsn=oM471N4r6im0zLgHkJANx_X6wbQ@mail.gmail.com>
        <20171019092625.GA12863@gondor.apana.org.au>
        <20171019095704.GA13459@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <edumazet@google.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:46829 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752881AbdJSLd0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 07:33:26 -0400
Received: by mail-lf0-f68.google.com with SMTP id g70so9225178lfl.3
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 04:33:25 -0700 (PDT)
In-Reply-To: <20171019095704.GA13459@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Oct 2017 17:57:04 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Oct 19, 2017 at 05:26:25PM +0800, Herbert Xu wrote:
> >
> > So it's an netlink API issue.  It is possible for cb->done to be
> > called without cb->dump ever being called.  And xfrm_user doesn't
> > deal with that.  Let me survey the others to see whether we should
> > fix this in netlink, xfrm, or both. =20
>=20
> OK it looks like an XFRM bug pure and simple.  Funnily enough
> the xfrm sa dump code which got changed by the same commit that
> added this bug isn't buggy.
>=20
> ---8<---
> Subject: ipsec: Fix aborted xfrm policy dump crash
>=20
> An independent security researcher, Mohamed Ghannam, has reported
> this vulnerability to Beyond Security's SecuriTeam Secure Disclosure
> program.
>=20
> The xfrm_dump_policy_done function expects xfrm_dump_policy to
> have been called at least once or it will crash.  This can be
> triggered if a dump fails because the target socket's receive
> buffer is full.
>=20
> This patch fixes it by using the cb->start mechanism to ensure that
> the initialisation is always done regardless of the buffer situation.
>=20
> Fixes: 4c563f7669c1 ("[XFRM]: Speed up xfrm_policy and xfrm_state...")

This is not correct. The original commit works just fine.

The bug was introduced later. And SA side had the same issue, it got
fixed in commit:
1ba5bf993c6a3142e18e "xfrm: fix crash in XFRM_MSG_GETSA netlink handler"

The commit introducing these issues is
12a169e7d8f4b1c95252 "ipsec: Put dumpers on the dump list".

where the walker state was modified to contain list entry instead of
pointer reference.

At that time there was no .start which got added just few years ago. I
suggest to do the same fix for SA side since it had same issue fixed on
the other commit. Your approach with defining the .start is cleaner.

With updated Fixed line, and preferably applying the same to SA side,
you can add:
 Acked-by: Timo Ter=C3=A4s <timo.teras@iki.fi>

Thanks,
Timo
