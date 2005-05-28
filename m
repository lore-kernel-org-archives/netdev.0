From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] textsearch infrastructure et al v2
Date: Sat, 28 May 2005 15:58:13 +0200
Message-ID: <20050528135813.GS15391@postel.suug.ch>
References: <20050527224725.GG15391@postel.suug.ch> <1117281581.6251.68.camel@localhost.localdomain> <20050528123542.GR15391@postel.suug.ch> <42986A85.9060001@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <42986A85.9060001@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Pablo Neira <42986A85.9060001@eurodev.net> 2005-05-28 14:56
> hm, i don't understand quite well, i bet that libqsearch was already 
> fragment-aware.

I'll rephrase, libqsearch, according to my understanding, is not able
to do optimized scanning over borders, i.e. it uses the same naive
approach as your proposal. This isn't necessarly a weakness, it
heavly depends on the length of the pattern and the amount of
fragments.

One of the major differences between libqsearch and the textsearch
I propose is that libqsearch implements "jokers", a subset of
what ts_regexp.c does. This heavly complicates their reference
implementation of bm. Again, this isn't necessarly a weakness, since
the framework doesn't require the algorithm to actually implement
these.

I cannot really tell which of the proposals we have right now
is the best/fastest/cleanest/fanciest/whatever. For that reason
I decided to transfer as much responsibility as possibly away
from the core into the actual algorithms, respectively made
it configureable via callback functions. It is still possible
to write a ts_(kmp|bm)_state.c which saves the state of the
scanning progress but other than in libqsearch this is not
a requirement.

> For small pattern and long packets, such pattern searching on the 
> fragment borders doesn't really hurt the performance.

Exactly.

> boyer-moore (BM) and other variants are definitely a must to have. I'm 
> still reading some papers about string matching and practical 
> applications (p2p traffic recognition based on string matching, ids, etc 
> etc) and the most interesting practical results come always from the use 
> of BM friends.

Absolultely, I implemented KMP because it doesn't require random
access to the text and thus serves well as a reference implementation.
I'll be glad to see your BM ported.

> I'm not familiar with those problems jamal has mentioned though, could 
> they really affect the string matching infrastructure in some way? I 
> truly prefer avoiding linearizing skb's.

I think we have to differ between non-linear skbs which we should have
without linearization and the scanning through real fragments.

In order to make some progress we have to answer these questions:

 * Do we want to be able to search on non-linear data in general?
   I say: yes

 * Do we want to be able to search on non-linear data which is
   not completely available and/or present at the time the search
   starts? In other words, do we want a search to be interruptable
   to continue later on. e.g. search over multiple skbs without
   queueing them up.
   I say: no

 * Do we want to provide random access to the text to be searched?
   If so, optionally or as a requirement? This merely has impact
   on a) BM could be efficiently implemented w/o naive scanning
   around the borders and b) requires the text segments to be
   completely maped/prepare at the risk they'll never be used. [0]
   I say: probably no

 [0] This impact can be limited by having the user specify strict
     searching area limits.

 
