From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] textsearch infrastructure et al v2
Date: Sat, 28 May 2005 14:35:42 +0200
Message-ID: <20050528123542.GR15391@postel.suug.ch>
References: <20050527224725.GG15391@postel.suug.ch> <1117281581.6251.68.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117281581.6251.68.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117281581.6251.68.camel@localhost.localdomain> 2005-05-28 07:59
> I dont have  opinions on this since you and Pablo seem to agree on it.
> What I remember is that libssearch (or whatever that thing Harald was
> looking at) did it differently (callback invoked and it return a code
> which said to continue or not).

Same for my infrastructure with the difference that libqsearch uses
a single input buffer so no chance for non-linear data.

> Also the design should (I think you do already, just double checking) -
> should be wary of optimizing for a specific algorithmn; i see you have
> KMP but not Boyer-Moore for example and i am not sure what the
> repurcassions of above approach are etc etc.

This is a weakness of the current implementation, it could be
addresses via the other method that I proposed. The current patch
doesn't allow for random access over fragment borders which means
that Boyer-Moore would require a temporary buffer with a size of
the pattern length in order to do random access over multiple
fragments. However, I haven't seen any infrastructure yet that can
handle non-linear data with bm wihout a complete prefetch in the
beginning though. You could still implement a bm by either using a
naive search at the borders or simply define the limitation that you
can only look at the first fragment so you'd have to linearize.

> > So basically we save the state of the segment fetching
> > instead of saving the state of the search algorithm which
> > would be way too complex for things like regular expression
> > string matching.
> > 
> 
> Can you explain this a little more. Didnt quiet understand.
> If you are going across skbs, dont you need to save state?

Most people look at it from the angle of iterate over text segments
and apply a text search algorithm. I inverted this and said,
start the text search algorithm and iterate over all text
segments inside the algorithm. This makes many things a lot
easier because we only have to save the state of the iterator.
This brings up another limitation though, we cannot stop a search
in progress and continue later on.

> I think the best approach would be to first linearize then search. 

This is what I'm trying to avoid. ;->

> On ingress as well you are also better off to assemble fragments first
> on that side before doing text searches. 

We can still do this optionally, just because we support it doesn't
mean we have to use it.

> Perhaps implementing an action like the one used by openbsd to
> "normalize" packets before a string match.
> i.e 
> classifier (pkt header) --> normalize --> classifier(string match)-> ?

> Infact one could argue that if you are to scan a virus you may need
> to assemble more than one skb on ingress (essentially a message).

http://oss.sgi.com/archives/netdev/2005-05/msg00298.html

See the section after <<coffee break>>

> The only other comment i have is on the patch you called naive regexp;
> I think you should probably call it something else instead of regexp
> since you invented it.

I was never good at names, any suggestions?
