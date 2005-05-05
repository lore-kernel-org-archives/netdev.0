From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] textsearch infrastructure + skb_find_text()
Date: Thu, 5 May 2005 16:12:22 +0200
Message-ID: <20050505141222.GA25977@postel.suug.ch>
References: <20050504234036.GH18452@postel.suug.ch> <1115296937.7680.52.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Pablo Neira <pablo@eurodev.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115296937.7680.52.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1115296937.7680.52.camel@localhost.localdomain> 2005-05-05 08:42
> How is this different from libqsearch? IIRC, it also kept pointers and
> callbacks.

The main difference is that my infrastructure is much simpler.

> BTW, I hope theres sync with libqsearch - at least some canibalization
> of ideas.

I read the libqsearch code but fixing up all the issues required
for my use would have taken up more time than writing up something new.

> Also hopefully, pluggin of ne algorithms is trivial (e.g boyer-moore
> could be included in addition to kmp etc)

Very simple, ts_kmp.c is 108 lines whereas simple.c in libqsearch
is over 500.

> I have a lot of questions:
> - does a string have to be terminated by \0?

All strings are length terminated.

> - do you keep state of the string from the begining? ex: how do you know
> that preceeding "hanky" was "Need a"?

I store the shift of a match in struct ts_state, add the length of
the pattern in the call to textsearch_next() and provide this shift
as offset to the get_text() callback.

> - all sorts of limits: how long is the string? etc

Both the length of a pattern and the length of a text block is
limited by INT_MAX. However, since there can be an arbitary number
of blocks there is no limit in the text length. Depending on the
search algorithm there might be more limits, for example kmp uses
unsigned int for each prefix table entry so this limits the length
of the pattern as well (theoretically).

> - what happens if a string spans multiple skbs or even multiple
> fragments?

This was the single most important requirement. Actually you can
compose the text out of anything. I already wrote some code to
handle paged skbs and multiple skbs can be implemented the same
way. You could for example store a ts_state per conntrack and
call textsearch_next continuously until you find a match. Would
require some magic in the get_text() but shouldn't be too hard.

> 
> > You might wonder about the 1 given to _prepare(),  it indicates whether
> > to autoload modules because the ematches will need it to be able to drop
> > rtnl sem.
> > 
> 
> do you really wanna leave that decision upto the user?

We have to, otherwise we can't use it in ematches without the risk
of deadlocks. There is no way around than have the caller drop its
locks and call prepare again with no locks held, at least I'm not
aware of one.

> It would be nice to have other utilities which could be loaded eg; case
> compare, regualr expressions, strchr after you match, etc

Indeed, I'm working on the regular expression thing but it has
some issues with textsearch_next() for patterns like .+abc.+ which
I want to resolve first.
