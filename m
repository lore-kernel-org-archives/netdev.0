From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: 07 Jan 2005 08:45:12 -0500
Message-ID: <1105105511.1046.77.camel@jzny.localdomain>
References: <20050103125635.GB26856@postel.suug.ch>
	 <20050104223612.GN26856@postel.suug.ch>
	 <1104894728.1117.56.camel@jzny.localdomain>
	 <20050105110048.GO26856@postel.suug.ch>
	 <1104931991.1117.152.camel@jzny.localdomain>
	 <20050105144514.GQ26856@postel.suug.ch>
	 <1105019225.2312.7.camel@jzny.localdomain>
	 <20050106194102.GW26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050106194102.GW26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-01-06 at 14:41, Thomas Graf wrote:
> * jamal <1105019225.2312.7.camel@jzny.localdomain> 2005-01-06 08:47
[..]
> If we do everything as ref we'll be allocating 4 byte chunks or we
> introduce a storage u32 which pollutes the structure. I don't
> like that given that the transfer of a single u32 is probably the
> most common for all those smallish ematches for a specific thing.
> For simplicity, you don't even notice if you're not aware of that
> it can be of help so I don't think we're losing any simplicity here.

I am not sure the optimization for a single u32 as the ematch data is
valid ;-> But this is not a show stopper, i will wait for the code to
see if its an annoyance or tolerable.

> Missunderstanding here, I meant is there any advantage in having
> multiple ematch trees (interleaved) over just making the existing
> u32 key an ematch and have the selector (with the hashing bits
> extracted) with one ematch tree.

Misunderstanding is the right description.
If you did a s/ematch/match for the u32 part then we'd be shooting for
the same thing;-> So i take back what i said, you are not gonna mess up
the u32 tree logic.

> 1) extract hashing bits out of selector and move it into a new
>    TLV.
> 2) Replace the foreach key match loop with an ematch_tree match

This is our contention point.

> 3) Fill out a pkt_info struct with ptr and off2 so we don't lose
>    hashing capabilities

And this is why i dont like it. 

> 4) Add backward compat code. Old selector must be transformed
>    into a flat ematch tree and the hashing bits must be extracted
>    and stored in the new struct.

I think the u32 changes are one-shot if you want to avoid lotsa #ifdefs.
Someone sends you a old sel, then convert it to a new one for storage.
Dumping is a little trickier, need some way to recognize old style
request. 

> The most difficult part is to do the Kconfig dependencies in a smart way ;->

The trick would be to always use sel2 and present no kconfig options for back 
compat. We need to figure out how to recognize an old style dump and we are
set.

> > Again, u32 classifier is not just matches; the more interesting thing
> > is  the layout of the rules that it can be taught to do.
> > I think the ematch which emulates the std u32 match is of course
> > valuable to have but it _doesnt_ deserve the same name.
> 
> Stupid terms, em_u32.c is a replacement for the u32 key and it has exactly
> the same behaviour. I'll be happy to rename it but as you know I really
> suck at naming things ;->

em_u32 sounds better ;->
Above you are trying to insert off2 into the info (what i said i didnt
like) - how are you going to achieve the same with a standalone en_u32
from say you basic classifier?

> > Thinking more about it; not sure why you would even bother managing
> > them. Everything runs at the same kernel privilege level. I am not sure
> > you want to have certain things that can only be built when recompiling
> > the kernel
> 
> Well, we have exactly the same issues as with TLV types. I don't see
> why one would need to recompile things. The enumeration is for ematches
> included in the kernel tree.

Your call. Actions do it the way i described it. It is more flexible in
my opionion, nothing reserved. Good practise is to know who uses what
(not hardcoding in headers) and the register will catch any discrepancy.

cheers,
jamal
