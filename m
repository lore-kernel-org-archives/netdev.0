From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net/sctp: use-after-free in __sctp_connect
Date: Fri, 4 Nov 2016 11:03:07 -0200
Message-ID: <20161104130307.GI8514@localhost.localdomain>
References: <CAAeHK+wX8yxVTpmg-Ps7MKTD-x_HS3GgpzX6yfGh51cQE0oPjA@mail.gmail.com>
 <20161019165754.GD2958@localhost.localdomain>
 <CAAeHK+xaBVcZp7PfH-tYWaxs6rCiaNAivZj4xZLcawFShi6C1Q@mail.gmail.com>
 <CAAeHK+xxcV8XV1Pc2_eBrQWTDSp3ooc1LLX81jhCTCvk7hhaVg@mail.gmail.com>
 <20161103175220.GG8514@localhost.localdomain>
 <CAAeHK+yHVYmyA4hNKNKyVrZQXkUmMNDF=WFz3F1VWMAA0gqwZA@mail.gmail.com>
 <20161103183533.GH8514@localhost.localdomain>
 <20161104125958.GA13691@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Konovalov <andreyknvl@google.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161104125958.GA13691@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 04, 2016 at 08:59:58AM -0400, Neil Horman wrote:
> On Thu, Nov 03, 2016 at 04:35:33PM -0200, Marcelo Ricardo Leitner wrote:
> > On Thu, Nov 03, 2016 at 07:02:47PM +0100, Andrey Konovalov wrote:
> > > On Thu, Nov 3, 2016 at 6:52 PM, Marcelo Ricardo Leitner
> > > <marcelo.leitner@gmail.com> wrote:
> > > > On Thu, Nov 03, 2016 at 06:11:01PM +0100, Andrey Konovalov wrote:
> > > >> On Wed, Nov 2, 2016 at 11:42 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > > >> > On Wed, Oct 19, 2016 at 6:57 PM, Marcelo Ricardo Leitner
> > > >> > <marcelo.leitner@gmail.com> wrote:
> > > >> >> On Wed, Oct 19, 2016 at 02:25:24PM +0200, Andrey Konovalov wrote:
> > > >> >>> Hi,
> > > >> >>>
> > > >> >>> I've got the following error report while running the syzkaller fuzzer:
> > > >> >>>
> > > >> >>> ==================================================================
> > > >> >>> BUG: KASAN: use-after-free in __sctp_connect+0xabe/0xbf0 at addr
> > > >> >>> ffff88006b1dc610
> > > >> >>
> > > >> >> Seems this is the same that Dmitry Vyukov had reported back in Jan 13th.
> > > >> >> So far I couldn't identify the reason.
> > > >> >> "Good" to know it's still there, thanks for reporting it.
> > > >>
> > > >> Hi Marcelo,
> > > >>
> > > >
> > > > Hi
> > > >
> > > >> So I've looked at the code.
> > > >> As far as I understand, the problem is a race condition between
> > > >> setsockopt(SCTP_SOCKOPT_CONNECTX) and shutdown on an sctp socket.
> > > >> setsockopt() calls sctp_wait_for_connect(), which exits the for loop
> > > >> on the sk->sk_shutdown & RCV_SHUTDOWN if clause, and then frees asoc
> > > >> with sctp_association_put() and returns err = 0.
> > > >> Then __sctp_connect() checks that err == 0 and reads asoc->assoc_id
> > > >> from the freed asoc.
> > > >
> > > > Suddenly this seems familiar. Your description makes sense, thanks for
> > > > looking deeper into this, Andrey.
> > > >
> > > > This fix should do it, can you please try it? I'll post it properly
> > > > if it works.
> > > 
> > > Yes, it fixes the issue.
> > > 
> > > Tested-by: Andrey Konovalov <andreyknvl@google.com>
> > > 
> > > Thanks for the fix!
> > 
> > Ahm this other fix looks better: do the read before calling
> > sctp_wait_for_connect() as that id won't change in this call and the
> > application shouldn't trust this number if an error is returned, so
> > there should be no issues by returning it in such situation.
> > 
> > Can you please confirm this one also works? Thanks!
> > 
> > ---8<---
> > 
> > diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> > index 6cdc61c21438..be1d9bb98230 100644
> > --- a/net/sctp/socket.c
> > +++ b/net/sctp/socket.c
> > @@ -1214,9 +1214,12 @@ static int __sctp_connect(struct sock *sk,
> >  
> >  	timeo = sock_sndtimeo(sk, f_flags & O_NONBLOCK);
> >  
> > -	err = sctp_wait_for_connect(asoc, &timeo);
> > -	if ((err == 0 || err == -EINPROGRESS) && assoc_id)
> > +	if (assoc_id)
> >  		*assoc_id = asoc->assoc_id;
> > +	err = sctp_wait_for_connect(asoc, &timeo);
> > +	/* Note: the asoc may be freed after the return of
> > +	 * sctp_wait_for_connect.
> > +	 */
> >  
> >  	/* Don't free association on exit. */
> >  	asoc = NULL;
> > 
> Agreed, this version looks better.  Please repost it with a proper changelog and
> I'll ack it.
> Neil

It already is. :-)
Please look for
Subject: [PATCH net] sctp: assign assoc_id earlier in __sctp_connect            

Thanks,
Marcelo
