From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] textsearch infrastructure + skb_find_text()
Date: Fri, 6 May 2005 14:36:39 +0200
Message-ID: <20050506123639.GE28419@postel.suug.ch>
References: <20050504234036.GH18452@postel.suug.ch> <427A51A2.8090600@eurodev.net> <20050505174224.GB25977@postel.suug.ch> <427AC96E.2020208@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <427AC96E.2020208@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Pablo Neira <427AC96E.2020208@eurodev.net> 2005-05-06 03:33
> >This is implemented in skb_find_text(), I just looked through rusty's
> >code and it's very simliar so we could make the args in ts_state a
> >union of long args[6] and char cb[XXX] so we can store skb_iter
> >in there.
> 
> Yes, we could just use one of those args in ts_state to store if we 
> found a partial match or not.

This is not required, I will elaborate the core logic to clarify this.
I guess you still think of the logic as:

function find-text(pattern)
  foreach text-segment do
    call search-bm(text-segment, pattern);
  done
end

This is what most people naturally think of when dealing with this
problem and it might be sufficient for many situations, however it
requires the searching algorithm to store its state in some persistent
memory which can be troublesome depending on the volume of these
variables.

My approach is to save the state of the text fetching progress
and have the algorithm handle the fetching of new data (if needed),
i.e:

function serch-bm(pattern, get-text-callback)
  while get-text-callback() returns more data do
    do the matching here...
  done
end

function find-text(pattern)
  call search-bm(pattern, get-text-callback);
end

This allows the searching algorithm to see the text as a continuous
byte stream. The get_text() callback is like a char device, altough
it returns data in variable sized blocks, there is no random access.

Why? Because it dramatically simplifies the searching algorithms
since they can decide when to fetch the next block which is
absolutely essential for cases like regular expression where the
state machine gets quite complex and a single entry point (i.e.
leaving the function and enter it again with new data) would make
things much more complex. Minor advantages are a) the get_text()
implementation is usually quite small and will hopefully not mess
up the cacheline optimizations of the actual searching loop and
b) it allows the searching algorithm to do prefetching.

<< coffee break >>

Now on to the subject of matching over multiple skbs, in a perfect
world we can try to do async searching by storing the partial match
state in the conntrack entry but then again what do we do when we
find a partial match in a skb? Drop it? We can't access the next
skb or fragment just now to see if the full pattern is present. So
what this would lead to is that we let the handshake and some
payload pass until we find the skb that successfully ends a partial
match. This is basically what IOS and JunOS do (correct me if I'm
wrong). A common use case for this is to filter out malicious HTTP
requests and other easy to identify data that might harm a service
that is vulnerable but has no fix available just yet. In order to
avoid DoS certain limits must be established such as maximum number
of skbs or maximum payload scanned before aborting but most of these
limits can be worked around for example by pretending huge HTTP
headers in front of the malicious header line and it will be very
hard to find a breakeven to actually be able to filter out some of
it while not allowing a DoS due to massive filtering.

Can we avoid letting through the initial handshake? Yes but it's
probably not worth the effort. Will we be able to ultimatively
solve the filtering facitily vs DoS vulnerability issue? No. Can
we avoid letting through previous skbs which could do harm as well
but only a partial match has been found? Not at this level or
without nasty hacks such as acking the data but not passing it up.
Worth it? Probably not. To my understanding it is not worth to
try too hard and be perfect, I see the textsearch filtering as
nice to have for filtering on the first few dozen bytes of the
initial payload skb typically carrying enough headers to classify
on layer7 basis. If someone thinks the small probability of
having a match just between 2 fragments is important then please
go ahead and put the matching state into ts_state as well.

> Sure, your approach is definitely more generic because I just thought 
> about using such string matching framework for net apps, it's different 
> from that point of view, but I still see things that reminds me to my 
> proposed framework, say that ts_state thing ;).

Note that your state variable stores the matching state and ts_state
stores the state of the get_text() progress.

> No problem mate. Just curious about something, since this stuff will 
> live under lib, what kind of applications in kernel space could use this 
> string matching framework ? I bet that non-net kernel guys will surely 
> ask about it ;->

It definitely belongs into lib/ to my understanding, nobody gets
hurt by adding it there and the chances that someone other
subsystem having need for it are not that low.

One example (silly one though) that I did out of curiosity is a
sys_findtext taking an inode returning the first match. It simply
iterates over all blocks belonging to the file making use of the
buffer cache if possible. It's really fast. ;->
