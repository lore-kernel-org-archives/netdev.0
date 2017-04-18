From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ney/key: slab-out-of-bounds in parse_ipsecrequests
Date: Tue, 18 Apr 2017 13:34:12 +0200
Message-ID: <20170418113412.GA15917@secunet.com>
References: <CAAeHK+yuQZ1v-BBLoeGxfuXg-5uFe6sS5qC-gagaVkq4YroS8g@mail.gmail.com>
 <CAM_iQpXC03OpCxMQd3VoaVuDHma0Z6h=BuDUf63qc5x1aZvdww@mail.gmail.com>
 <20170413103559.GA23263@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Eric Dumazet <edumazet@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50088 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751228AbdDRLeX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 07:34:23 -0400
Content-Disposition: inline
In-Reply-To: <20170413103559.GA23263@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 06:35:59PM +0800, Herbert Xu wrote:
> On Wed, Apr 12, 2017 at 05:39:22PM -0700, Cong Wang wrote:
> > On Wed, Apr 12, 2017 at 8:02 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > > Hi,
> > >
> > > I've got the following error report while fuzzing the kernel with syzkaller.
> > >
> > > On commit 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).
> > >
> > > A reproducer and .config are attached.
> > >
> > > When subtracting rq->sadb_x_ipsecrequest_len from len it can become
> > > negative and the while loop condition remains true.
> > 
> > Good catch! Seems the fix is pretty straight forward:
> > 
> > diff --git a/net/key/af_key.c b/net/key/af_key.c
> > index c6252ed..cbce595 100644
> > --- a/net/key/af_key.c
> > +++ b/net/key/af_key.c
> > @@ -1945,7 +1945,7 @@ parse_ipsecrequests(struct xfrm_policy *xp,
> > struct sadb_x_policy *pol)
> >         if (pol->sadb_x_policy_len * 8 < sizeof(struct sadb_x_policy))
> >                 return -EINVAL;
> > 
> > -       while (len >= sizeof(struct sadb_x_ipsecrequest)) {
> > +       while (len >= (int)sizeof(struct sadb_x_ipsecrequest)) {
> >                 if ((err = parse_ipsecrequest(xp, rq)) < 0)
> >                         return err;
> >                 len -= rq->sadb_x_ipsecrequest_len;
> > 
> > But pol->sadb_x_policy_len and rq->sadb_x_ipsecrequest_len
> > are controllable by user (fortunately root), I am feeling there might
> > be other problem I miss too.
> 
> Well the fact that it is negative means that you've already parsed
> crap in the previous loop.  This interface really needs to die.

Do you see a chance to remove this? I guess it is not used frequently
anymore, but distros still ship the old ipsec tools.

> 
> ---8<---
> Subject: af_key: Fix sadb_x_ipsecrequest parsing
> 
> The parsing of sadb_x_ipsecrequest is broken in a number of ways.
> First of all we're not verifying sadb_x_ipsecrequest_len.  This
> is needed when the structure carries addresses at the end.  Worse
> we don't even look at the length when we parse those optional
> addresses.
> 
> The migration code had similar parsing code that's better but
> it also has some deficiencies.  The length is overcounted first
> of all as it includes the header itself.  It also fails to check
> the length before dereferencing the sa_family field.
> 
> This patch fixes those problems in parse_sockaddr_pair and then
> uses it in parse_ipsecrequest.
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to the ipsec tree, thanks Herbert!
