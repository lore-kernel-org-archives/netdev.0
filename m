From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Wed, 5 Jan 2005 15:45:14 +0100
Message-ID: <20050105144514.GQ26856@postel.suug.ch>
References: <20050103125635.GB26856@postel.suug.ch> <20050104223612.GN26856@postel.suug.ch> <1104894728.1117.56.camel@jzny.localdomain> <20050105110048.GO26856@postel.suug.ch> <1104931991.1117.152.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104931991.1117.152.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104931991.1117.152.camel@jzny.localdomain> 2005-01-05 08:33
> On Wed, 2005-01-05 at 06:00, Thomas Graf wrote:
> > * jamal <1104894728.1117.56.camel@jzny.localdomain> 2005-01-04 22:12
> 
> > > Why do i need to signal something as simple? AND why does it have to be
> > > 32 bit type - what edge does that give you?
> > 
> > You don't have to, providing a 32bit data chunk without TCF_EM_SIMPLE
> > set will simply result in allocating & copy. It's an optimization,
> > nothing more.
> 
> Sorry i missed that. Isnt it still unecessary though? You should be able
> to pass L=4 and not need the speacial treatment, no?

Agreed, but the ematch might expect an allocated block. Assuming the
data is variable and sometimes is L=4, sometimes L=16 the ematch
requires special handling because m->data might hold the value directly
or a pointer depending on datalen.


> >   1) We make u32 hold multiple ematch trees, a u32 key can be of 3
> >      kinds: u32/ematch/container. It's kind of a hack and not very
> >      fast due to a lot of stack movement.
> 
> Indeed this is what i was thinking of. 
> The only added overhead I can think of is when processing a series of
> u32 keys _within the same selector_ (not across selectors), you check if
> its u32 native and execute localy (as is done now) or transfer the check
> to the ematch defined in that key and continue to next key based on the
> ematchs return code + the logical operation.

Exactly, does the performance gap come with any advantage? No. That's
why I don't like it.


> >   2) We make the existing u32 match be an ematch which I already did
> >      expect for the nexthdr bits. That is the select will simply be
> >      replaced by an ematch tree. I'll take a look into how we could
> >      have the classifier take influence on the ematches config data.
> >      One possibiliy is to have a struct transfered via map which
> >      contains useful data such as offset to next header (u32/rsvp).
> >      I have to think about this a little more though.
> 
> This could be done in addition to #1. I see #1 as more important for u32
> but not so for things like fwmark, tcindex which should fizzle away with
> meta ematch. I think the danger is in trying to replicate u32 as an
> ematch; if somehow you can loop back and use the real u32 code, then
> fine. I feel it being non-trivial to do so.
> Like i said earlier, theres a lot of power in u32 other than in basic
> matching.

Most importantly I don't want to touch any of the hashing code in u32.
I really like and it should stay as it is. The existing u32 match can
be easly made an ematch so this would safe us the extra work in u32 to
implement logic relations again and to fiddle with complicated selector
TLVs. The only problem with this is the nexthdr bits because it relies
on the hashing code. So we have to make this data available to the
ematch which is actually not a bad idea anyway. So I'm thinking about
introducing a new structure tcf_em_pkt_info or alike which carries
some additional information found out by the classifiers which can be
used by ematches. This can be information about the next header,
already extracted dscp values, etc.

This would give us the chance to add a very small em_u32.c (~40 lines)
doing exactly the same as the current u32 match and have the u32
selector replaced with an ematch tree at no additional cost. Backward
compatibility is as easy as creating a flat ANDed ematch tree.

Note: The u32 ematch I'm talking about is not the cmp ematch, cmp is
more advanced but also slightly slower.

Thoughts?

> I think #2 is better for other classifiers which were already doomed
> anyways. #1 is important for u32 and perhaps other classifiers like rsvp
> and route. And yes, #1 is more work ;->

Why is it better? What's the advantage?

> hang on:-> No dont rewrite u32 please. Your cmp is good for the basic
> matches that u32 does, but is _nowhere_ close to being able to do what
> u32 can when used properly.

Right, that's why I now call it cmp and the existing u32 match becomes
the u32 ematch.

> I Should be able to compile a new ematch as a module in an already
> running kernel. So, other than generic stuff for ematches, things like 
> TCF_EM_CMP should not be in that enumeration.

It's not a requirement to put it there but we need to manage the
assigned types for ematches in mainline anyway.

> Which means the above should go in its own file; probably create a
> include/linux/tc_ematch directory with a file of sort tcf_em_cmp.h
> which holds all the above.

This one I can agree.

> And all this also goes in that header file as well.

I put it here because it might be very useful for other ematches
or further classifiers, you name it. tcf_get_base_ptr is used by
nbyte ematch for example.
