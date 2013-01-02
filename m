From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] epoll: prevent missed events on EPOLL_CTL_MOD
Date: Wed, 2 Jan 2013 18:40:10 +0000
Message-ID: <20130102184010.GA21780@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <1356960060-1263-1-git-send-email-normalperson@yhbt.net>
 <1357065750.21409.12527.camel@edumazet-glaptop>
 <20130101210033.GA13255@dcvr.yhbt.net>
 <20130101211728.GA13380@dcvr.yhbt.net>
 <CA+55aFwP3Tvmfh23KDDXhB3k=RS8pNhqasw5vuBUHw4TxrakOQ@mail.gmail.com>
 <20130101235605.GA17168@dcvr.yhbt.net>
 <1357148750.21409.17169.camel@edumazet-glaptop>
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
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1357148750.21409.17169.camel@edumazet-glaptop>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> First, thanks for working on this issue.

No problem!

> It seems the real problem is the epi->event.events = event->events;
> which is done without taking ep->lock

Yes.  I am hoping it is possible to do it without a lock there,
but your change is more obviously correct.

> While a smp_mb() could reduce the race window, I believe there is still
> a race, and the following patch would close it.

I'm not an experienced kernel hacker, can you describe where the race
would be?

> diff --git a/fs/eventpoll.c b/fs/eventpoll.c
> index be56b21..25e5c53 100644
> --- a/fs/eventpoll.c
> +++ b/fs/eventpoll.c
> @@ -1313,7 +1313,10 @@ static int ep_modify(struct eventpoll *ep, struct epitem *epi, struct epoll_even
>  	 * otherwise we might miss an event that happens between the
>  	 * f_op->poll() call and the new event set registering.
>  	 */
> +	spin_lock_irq(&ep->lock);
>  	epi->event.events = event->events;
> +	spin_unlock_irq(&ep->lock);
> +
>  	pt._key = event->events;
>  	epi->event.data = event->data; /* protected by mtx */
>  	if (epi->event.events & EPOLLWAKEUP) {
