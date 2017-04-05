From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net/sctp: list double add warning in sctp_endpoint_add_asoc
Date: Wed, 5 Apr 2017 09:44:15 -0300
Message-ID: <20170405124415.GC911@localhost.localdomain>
References: <CAAeHK+zwbeT=jBRRSf2KYXWM=eUZAEe5QHvKPYGG5qWh6A0JGQ@mail.gmail.com>
 <CADvbK_f1FEGRnucuMkQT6RKm0G1tKcfHyj=-GqxgzQ4iQoBLCg@mail.gmail.com>
 <20170404211454.GA911@localhost.localdomain>
 <CADvbK_dgD65mygqkGuA85ShBnHrD3y4u_P=XoREyEn7y0J4_+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Konovalov <andreyknvl@google.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58045 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753948AbdDEMoV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 08:44:21 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_dgD65mygqkGuA85ShBnHrD3y4u_P=XoREyEn7y0J4_+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 05, 2017 at 06:48:45PM +0800, Xin Long wrote:
> On Wed, Apr 5, 2017 at 5:14 AM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
> > On Wed, Apr 05, 2017 at 01:29:19AM +0800, Xin Long wrote:
> >> On Tue, Apr 4, 2017 at 9:28 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> >> > Hi,
> >> >
> >> > I've got the following error report while fuzzing the kernel with syzkaller.
> >> >
> >> > On commit a71c9a1c779f2499fb2afc0553e543f18aff6edf (4.11-rc5).
> >> >
> >> > A reproducer and .config are attached.
> >> The script is pretty hard to reproduce the issue in my env.
> >
> > I didn't try running it but I also found the reproducer very complicated
> > to follow. Do you have any plans on having some PoC optimizer, so we can
> > have a more readable code?
> > strace is handy for filtering the noise, yes, but sometimes it doesn't
> > cut it.
> I got the script now:
> 1. create sk
> 2. set sk->sndbuf = x
> 3. sendmsg with size s1 (s1 < x)
> 4. sendmsg with size s2 (s1+s2 > x)
> 5. sendmsg with size s3 (wspace < 0), wait sndbuf, schedule out.
> 6. listen sk (abnormal operation on sctp client)
> 7. accept sk.
> 
> In step 6, sk->sk_state = listening, then step 7 could get the first asoc
> from ep->asoc_list and alloc a new sk2, attach the asoc to sk2.
> 
> after a while, sendmsg schedule in, but asoc->sk is sk2, !=sk.
> the same issue we fix for peeloff on commit dfcb9f4f99f1 ("sctp: deny
> peeloff operation on asocs with threads sleeping on it") happens.

Yes. That explains why the asoc isn't dead by when sendmsg comes back,
and avoid that dead check.

> 
> But we should not fix it by the same way as for peeloff. the real reason
> causes this issue is on step 6, it should disallow listen on the established sk.

Agreed.

> 
> The following fix should work for this, just similar with what
> inet_listen() did.
> 
> @@ -7174,6 +7175,9 @@ int sctp_inet_listen(struct socket *sock, int backlog)
>         if (sock->state != SS_UNCONNECTED)
>                 goto out;
> 
> +       if (!sctp_sstate(sk, LISTENING) && !sctp_sstate(sk,CLOSED))
> +               goto out;
> +
> 
> what do you think ?

Yes, agreed.
Thanks!

  Marcelo
