From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] net: solve a NAPI race
Date: Tue, 28 Feb 2017 09:47:17 -0800
Message-ID: <1488304037.9415.263.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKgT0UeSpxzgePoidJumQFvM5a2mOC5+rL8gCHqvX-HBvrn74A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35522 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751344AbdB1RrU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 12:47:20 -0500
Received: by mail-pg0-f54.google.com with SMTP id b129so8075819pgc.2
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 09:47:19 -0800 (PST)
In-Reply-To: <CAKgT0UeSpxzgePoidJumQFvM5a2mOC5+rL8gCHqvX-HBvrn74A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-28 at 09:20 -0800, Alexander Duyck wrote:
> On Mon, Feb 27, 2017 at 6:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > +bool napi_schedule_prep(struct napi_struct *n)
> > +{
> > +       unsigned long val, new;
> > +
> > +       do {
> > +               val = READ_ONCE(n->state);
> > +               if (unlikely(val & NAPIF_STATE_DISABLE))
> > +                       return false;
> > +               new = val | NAPIF_STATE_SCHED;
> > +               if (unlikely(val & NAPIF_STATE_SCHED))
> > +                       new |= NAPIF_STATE_MISSED;
> 
> You might want to consider just using a combination AND, divide,
> multiply, and OR to avoid having to have any conditional branches
> being added due to this code path.  Basically the logic would look
> like:


>     new = val | NAPIF_STATE_SCHED;
>     new |= (val & NAPIF_STATE_SCHED) / NAPIF_STATE_SCHED * NAPIF_STATE_MISSED;
> 
> In assembler that all ends up getting translated out to AND, SHL, OR.
> You avoid the branching, or MOV/OR/TEST/CMOV type code you would end
> up with otherwise.

Sure, I can try to optimize this a bit ;)


> > +       } while (cmpxchg(&n->state, val, new) != val);
> > +
> > +       if (unlikely(val & NAPIF_STATE_MISSED))
> > +               __napi_schedule(n);
> > +
> >         return true;
> >  }
> 
> If you rescheduled napi should you really be returning true?  Seems
> like you should be returning "!(val & NAPIF_STATE_MISSED)" to try to
> avoid letting this occur again.

Good idea.

Hmm... you mean that many drivers test napi_complete_done() return
value ?

;)

Thanks !
