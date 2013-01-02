From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] epoll: prevent missed events on EPOLL_CTL_MOD
Date: Wed, 2 Jan 2013 19:32:27 +0000
Message-ID: <20130102193227.GA13566@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <1356960060-1263-1-git-send-email-normalperson@yhbt.net>
 <1357065750.21409.12527.camel@edumazet-glaptop>
 <20130101210033.GA13255@dcvr.yhbt.net>
 <20130101211728.GA13380@dcvr.yhbt.net>
 <CA+55aFwP3Tvmfh23KDDXhB3k=RS8pNhqasw5vuBUHw4TxrakOQ@mail.gmail.com>
 <20130101235605.GA17168@dcvr.yhbt.net>
 <1357148750.21409.17169.camel@edumazet-glaptop>
 <20130102184010.GA21780@dcvr.yhbt.net>
 <1357153416.21409.17488.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Jiri Olsa <jolsa@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Hans de Goede <hdegoede@redhat.com>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andreas Voellmy <andreas.voellmy@yale.edu>,
	"Junchang(Jason) Wang" <junchang.wang@yale.edu>,
	Network Development <netdev@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1357153416.21409.17488.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-01-02 at 18:40 +0000, Eric Wong wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > It seems the real problem is the epi->event.events = event->events;
> > > which is done without taking ep->lock
> > 
> > Yes.  I am hoping it is possible to do it without a lock there,
> > but your change is more obviously correct.
> > 
> > > While a smp_mb() could reduce the race window, I believe there is still
> > > a race, and the following patch would close it.
> > 
> > I'm not an experienced kernel hacker, can you describe where the race
> > would be?
> 
> It would be for example in ep_send_events_proc() doing :
> 
> if (epi->event.events & EPOLLONESHOT)
>     epi->event.events &= EP_PRIVATE_BITS;
> 
> And this could happen at the same time.

That modification in ep_send_events_proc() is protected by ep->mtx
(as is ep_modify()), though.  Maybe there are other places, but I
don't see it.
