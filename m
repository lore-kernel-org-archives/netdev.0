From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net/sctp: list double add warning in sctp_endpoint_add_asoc
Date: Tue, 4 Apr 2017 18:14:54 -0300
Message-ID: <20170404211454.GA911@localhost.localdomain>
References: <CAAeHK+zwbeT=jBRRSf2KYXWM=eUZAEe5QHvKPYGG5qWh6A0JGQ@mail.gmail.com>
 <CADvbK_f1FEGRnucuMkQT6RKm0G1tKcfHyj=-GqxgzQ4iQoBLCg@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CADvbK_f1FEGRnucuMkQT6RKm0G1tKcfHyj=-GqxgzQ4iQoBLCg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 05, 2017 at 01:29:19AM +0800, Xin Long wrote:
> On Tue, Apr 4, 2017 at 9:28 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > Hi,
> >
> > I've got the following error report while fuzzing the kernel with syzkaller.
> >
> > On commit a71c9a1c779f2499fb2afc0553e543f18aff6edf (4.11-rc5).
> >
> > A reproducer and .config are attached.
> The script is pretty hard to reproduce the issue in my env.

I didn't try running it but I also found the reproducer very complicated
to follow. Do you have any plans on having some PoC optimizer, so we can
have a more readable code?
strace is handy for filtering the noise, yes, but sometimes it doesn't
cut it.

> But there seems a case to cause a use-after-free when out of snd_buf.
> 
> the case is like:
> -----------
> one thread:                       another thread:
>                                   sctp_rcv hold asoc (hold transport)
>                                   enqueue the chunk to backlog queue
>                                   [refcnt=2]
> 
> sctp_close free assoc
> [refcnt=1]
> 
> sctp_sendmsg find asoc
> but not hold it
> 
> out of snd_buf
> hold asoc, schedule out
> [refcnt = 2]
> 
>                                   process backlog and put asoc/transport
>                                   [refcnt=1]
> 
> schedule in, put asoc
> [refcnt=0] <--- destroyed
> 
> sctp_sendmsg continue

It shouldn't be continuing here because sctp_wait_for_sndbuf and
sctp_wait_for_connect functions are checking if the asoc is dead
already when it schedules in, even though sctp_wait_for_connect return
value is ignored and sctp_sendmsg() simply returns after that.
Or the checks for dead asocs in there aren't enough somehow.

> using asoc, panic
