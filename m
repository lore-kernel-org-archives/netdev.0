From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Tue, 4 Jan 2005 13:03:33 +0100
Message-ID: <20050104120333.GF26856@postel.suug.ch>
References: <20050103125635.GB26856@postel.suug.ch> <1104812028.1085.50.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104812028.1085.50.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104812028.1085.50.camel@jzny.localdomain> 2005-01-03 23:13
> struct tcf_ematch_hdr
> {
>        __u16           handle;
>        __u16           matchID;
>        __u16           kind;
>        __u8            flags;
>        __u8            pad; /* currently unused */
> };
> 
> you need both matchID and handle? 

No, handle is yet unused and I think we can screw it again.

> Both tcf_ematch_ops and tcf_ematch_hdr have kind; 

Correct, I wanted to avoid having to do transformations
but it would save us a few bits.

> Is data length stored somewhere?

Not in this patch as it wasn't needed, I added it to my local
tree yesterday though. It is indeed required if we allocate
in the ematch api instead of having the ematch doing it.

> Noticed indev still hanging there ;-> shouldnt that die by this patch?

As soon as I find the time to write the meta ematch.

> > tcf_em_tree_change(tp, dst, src)
> >   dst: destination ematch tree (from classifier private data)
> >   src: source ematch tree (temporary tree from _validate)
> > 
> >   Replaces the ematch tree in the classifier with the temporary
> >   tree.
> 
> Seems to assume some owner of the ematch other than mother classifier.
> Recall the idea of ownership by classifier we discussed earlier
> which should be default if the ematch doesnt implement a ->change()

The classifier must always be the owner. Splitting the vaildation
and changing into 2 separate functions makes it easy for the classifier
to stay consistent while changing without doing expensive error
recovery. 


> BTW, Is the assumption i can have a u32:
> match
> ematch
> match
> match
> ematch
> 
> now gone? I couldnt tell.

I can't tell you either but not really. It's still possible
but I'm not sure if it makes sense. My idea was to replace match
with ematch so it would benefit from logic relations. The problem
arises when we get to the nexthdr offset mangling.

I have to look into this but I might have to drop my idea and
do as you state above.

> > tcf_em_tree_destroy(tp, tree)
> >   Destroys an ematch tree
> > 
> > tcf_em_tree_dump(skb, tree, tlv_type)
> >   tlv_type: T of ematches TLV (classifier specific)
> > 
> >   Dumps the ematch tree to the skb with given tlv_type.
> 
> Same comments as in ->change().
> if ematch doesnt implement a destroy or dump then mother classifier is
> responsible.

Right, I changed this already. change/dump/destroy are fully
optional. Here's the latest API to the classifier:

 change() (Optional)
   Called if provided, otherwise ematch api allocates the data, stores
   it in m->data and sets m->datalen. Special Case: If TCF_EM_SIMPLE
   is set the ematch data consists of a simple u32 which means no
   allocation is required and the value is stored in m->data directly.

   Note: I might add a special field to ematch_ops which can be set to
   the expected length of the ematch data so we have at least some basic
   sanity check. Thoughts?

 match() (Must)
   ...

 destroy() (Optional)
   Called if provided, otheriwse m->data is freed in ematch api unless
   TCF_EM_SIMPLE is set.

 dump() (Optional)
   Called if provided, otherwise m->data is dumped onto the skb with
   m->datalen as L. Special handling again for TCF_EM_SIMPLE.

I think this makes it as simple as it can get while keeping the door
open for complex ematches such as meta ematch.
 
> With std actions also this was an issue - at the moment dont have
> anything in any headers just to make it free for all - This way you
> could write a simple module that has zero dependency on an already
> compiled kernel. There would be standard practise where say 11 would
> mean something - but i suggest not to enforce it; the register()
> should probably spit some helpful message of who already has the number.
> you are trying to grab.

The warning is a good idea. I don't want to enforce it, a comment
is just fine and it's up to you whehter you want to fix your ematch
everyime a new ematch makes it into the kernel. I added this comment:

/* Ematch type assignments
 *   1..32767		Reserved for ematches inside kernel tree
 *   32768..65535	Free to use, not reliable
 */


> > Patch 2: u32 ematch
> 
> It does emulate a u32 node but not the classifier - which is a _lot_
> more sophisticated (with multilevel trees of hashes etc). Maybe you
> should change its name to something like 32bit match. 

Agreed. Note: With the latest API everything except for match can
be screwed. Same for em_nbyte.

> > Patch 3: nbyte ematch
> > 
> >   Compares n bytes at specified offset. To be used for IPv6
> >   address matches to avoid 4 ANDed u32 matches.
> 
> This looks useful.
> My recommendation would be to have the metamatch as the first thing
> so we can kill indev and friends.

Right, but those were easy to write in in interruptive working enviroment
and somewhat validated the API.  meta ematch will take some time to write
but it sure has top priority.

> > Patch 4: Basic Classifier
> 
> Very inefficient, but serves the purpose of an example.
> [Even if you go as basic a hash as fw classifier you will do better]

Fully agreed, nevertheless I think something like this is
required to fill the gaps of u32 and fw.
