From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: convert (struct ubuf_info)->refcnt to
 refcount_t
Date: Thu, 31 Aug 2017 16:15:21 -0700
Message-ID: <1504221321.15310.16.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170831203013.9219-1-edumazet@google.com>
         <20170831203013.9219-3-edumazet@google.com>
         <CAF=yD-KoztUEn-K5G9mvjE6wpq5+V9opAs5pim5cBr5cdvv3ig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33956 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751336AbdHaXPX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 19:15:23 -0400
Received: by mail-pf0-f194.google.com with SMTP id v22so616236pfk.1
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 16:15:23 -0700 (PDT)
In-Reply-To: <CAF=yD-KoztUEn-K5G9mvjE6wpq5+V9opAs5pim5cBr5cdvv3ig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-31 at 18:45 -0400, Willem de Bruijn wrote:
> On Thu, Aug 31, 2017 at 4:30 PM, Eric Dumazet <edumazet@google.com> wrote:
> > refcount_t type and corresponding API should be
> > used instead of atomic_t when the variable is used as
> > a reference counter. This allows to avoid accidental
> > refcounter overflows that might lead to use-after-free
> > situations.
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> >  include/linux/skbuff.h | 5 +++--
> >  net/core/skbuff.c      | 8 ++++----
> >  2 files changed, 7 insertions(+), 6 deletions(-)
> >
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 7594e19bce622a38dc39c054093c3da15b99b67b..316a92b45351f53709886ee0099cbc83b66f1b15 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -22,6 +22,7 @@
> >  #include <linux/cache.h>
> >  #include <linux/rbtree.h>
> >  #include <linux/socket.h>
> > +#include <linux/refcount.h>
> >
> >  #include <linux/atomic.h>
> >  #include <asm/types.h>
> > @@ -456,7 +457,7 @@ struct ubuf_info {
> >                         u32 bytelen;
> >                 };
> >         };
> > -       atomic_t refcnt;
> > +       refcount_t refcnt;
> >
> >         struct mmpin {
> >                 struct user_struct *user;
> > @@ -472,7 +473,7 @@ struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
> >
> >  static inline void sock_zerocopy_get(struct ubuf_info *uarg)
> >  {
> > -       atomic_inc(&uarg->refcnt);
> > +       refcount_inc(&uarg->refcnt);
> >  }
> >
> >  void sock_zerocopy_put(struct ubuf_info *uarg);
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 65b9ca3945f8fd2b1bef4aef5dd774be04e5d128..ed86ca9afd9d8d1ac47983acf6006c179285a612 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -963,7 +963,7 @@ struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
> >         uarg->len = 1;
> >         uarg->bytelen = size;
> >         uarg->zerocopy = 1;
> > -       atomic_set(&uarg->refcnt, 1);
> > +       refcount_set(&uarg->refcnt, 1);
> >         sock_hold(sk);
> >
> >         return uarg;
> > @@ -1086,7 +1086,7 @@ EXPORT_SYMBOL_GPL(sock_zerocopy_callback);
> >
> >  void sock_zerocopy_put(struct ubuf_info *uarg)
> >  {
> > -       if (uarg && atomic_dec_and_test(&uarg->refcnt)) {
> > +       if (uarg && refcount_dec_and_test(&uarg->refcnt)) {
> >                 if (uarg->callback)
> >                         uarg->callback(uarg, uarg->zerocopy);
> >                 else
> > @@ -1108,7 +1108,7 @@ void sock_zerocopy_put_abort(struct ubuf_info *uarg)
> >                  * avoid an skb send inside the main loop triggering uarg free.
> >                  */
> >                 if (sk->sk_type != SOCK_STREAM)
> > -                       atomic_inc(&uarg->refcnt);
> > +                       refcount_inc(&uarg->refcnt);
> 
> This would be a 0 -> 1 transition. It is taken only on the error path from
> a socket that does not take an explicit hold at the start of sendmsg.
> 

Arg.

> The code is vestigial, really, as the final patchset only includes tcp.
> It is safe to leave as is for now, or I can remove it.
> 

OK I probably should remove this chunk in patch 1/2 then.

> In 1f8b977ab32d ("sock: enable MSG_ZEROCOPY") I also updated
> other users of ubuf_info to initialize refcnt. We probably also want to
> convert the call in handle_tx in drivers/vhost/net.c.

Thanks ! :)
