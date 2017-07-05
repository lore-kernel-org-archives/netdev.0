From: =?UTF-8?Q?Mika_Penttil=c3=a4?= <mika.penttila@nextfour.com>
Subject: Re: [PATCH RFC] inetpeer: remove AVL implementation in favor of RB
 tree
Date: Wed, 5 Jul 2017 20:54:47 +0300
Message-ID: <9e86e8e1-4051-dd9d-8a21-32a28ef8d0d7@nextfour.com>
References: <1499270405.16045.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <fc780727-897c-13c1-30f6-ab2e3f21f321@nextfour.com>
 <CAHTyZGz+vL0A9vJAuqFv88t1mZhgjSdZrX=n8_wCtOZfJBSA5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, pablo neira ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>
To: ericnetdev dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00076.outbound.protection.outlook.com ([40.107.0.76]:19675
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751696AbdGERyx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Jul 2017 13:54:53 -0400
In-Reply-To: <CAHTyZGz+vL0A9vJAuqFv88t1mZhgjSdZrX=n8_wCtOZfJBSA5A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05.07.2017 19:48, ericnetdev dumazet wrote:
>
>
> On Jul 5, 2017 5:39 PM, "Mika Penttilä" <mika.penttila@nextfour.com <mailto:mika.penttila@nextfour.com>> wrote:
>
>     Hi!
>
>
>     On 05.07.2017 19:00, Eric Dumazet wrote:
>     > From: Eric Dumazet <edumazet@google.com <mailto:edumazet@google.com>>
>     >
>     > As discussed in Faro during Netfilter Workshop 2017, RB trees can be
>     > used with RCU, using a seqlock.
>     >
>     > Note that net/rxrpc/conn_service.c is already using this.
>     >
>     > This patch converts inetpeer from AVL tree to RB tree, since it allows
>     > to remove private AVL code in favor of shared RB code.
>     >
>     > $ size net/ipv4/inetpeer.before net/ipv4/inetpeer.after
>     >    text          data     bss     dec     hex filename
>     >    3195            40     128    3363     d23 net/ipv4/inetpeer.before
>     >    1562            24       0    1586     632 net/ipv4/inetpeer.after
>     >
>     > The same technique can be used to speed up
>     > net/netfilter/nft_set_rbtree.c
>     >
>     > Signed-off-by: Eric Dumazet <edumazet@google.com <mailto:edumazet@google.com>>
>     > ---
>     >
>     >       return p;
>     > @@ -467,8 +231,9 @@ EXPORT_SYMBOL_GPL(inet_getpeer);
>     >  void inet_putpeer(struct inet_peer *p)
>     >  {
>     >       p->dtime = (__u32)jiffies;
>     > -     smp_mb__before_atomic();
>     > -     refcount_dec(&p->refcnt);
>     > +
>     > +     if (refcount_dec_and_test(&p->refcnt))
>
>     Missing rb_erase() here...
>
>
>
> I am pretty sure it is not missing. Have you tested your suggestion ? Thanks !
Sorry I missed the fact the tree holds one reference.

>
>     > +             call_rcu(&p->rcu, inetpeer_free_rcu);
>     >  }
>     >  EXPORT_SYMBOL_GPL(inet_putpeer);
>     >
>     >
>     --Mika
>
>
>
Thanks,
Mika
