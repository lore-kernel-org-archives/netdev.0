From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: 03 Jan 2005 23:13:48 -0500
Message-ID: <1104812028.1085.50.camel@jzny.localdomain>
References: <20050103125635.GB26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050103125635.GB26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-03 at 07:56, Thomas Graf wrote:
> Jamal et al,
> 
> I attached 4 patches of a first ematch implementation. Comments
> and suggestions very much appreciated. Compiles but untested.
> 
> Patch 1: ematch API
> 
> API visible to classifier:
> 
> tcf_em_tree_validate(tp, tlv, tree)
>   tlv: ematches TLV
>   tree: temporary struct tcf_ematch_tree
> 
>   Validates the data in the TLV and builds the ematch tree
>   upon the temporary variable.

struct tcf_ematch_hdr
{
       __u16           handle;
       __u16           matchID;
       __u16           kind;
       __u8            flags;
       __u8            pad; /* currently unused */
};

you need both matchID and handle? 

struct tcf_ematch
{
       struct tcf_ematch_hdr   hdr;
       struct tcf_ematch_ops * ops;
       unsigned long           data;
};

Both tcf_ematch_ops and tcf_ematch_hdr have kind; 

Is data length stored somewhere?
Noticed indev still hanging there ;-> shouldnt that die by this patch?


> tcf_em_tree_change(tp, dst, src)
>   dst: destination ematch tree (from classifier private data)
>   src: source ematch tree (temporary tree from _validate)
> 
>   Replaces the ematch tree in the classifier with the temporary
>   tree.

Seems to assume some owner of the ematch other than mother classifier.
Recall the idea of ownership by classifier we discussed earlier
which should be default if the ematch doesnt implement a ->change()

BTW, Is the assumption i can have a u32:
match
ematch
match
match
ematch

now gone? I couldnt tell.

> tcf_em_tree_destroy(tp, tree)
>   Destroys an ematch tree
> 
> tcf_em_tree_dump(skb, tree, tlv_type)
>   tlv_type: T of ematches TLV (classifier specific)
> 
>   Dumps the ematch tree to the skb with given tlv_type.

Same comments as in ->change().
if ematch doesnt implement a destroy or dump then mother classifier is
responsible.

> tcf_em_tree_match(skb, tree, res)
>   res: struct tcf_result *
> 
>   Macro returning 1 if no ematches are configured, otherwise
>   the tree is evaulated and 1 is returned if the tree matches.

I think that looks valid for simplicty case. I wasnt so sure about 
the INVERT thing you had. It doesnt look like a bad idea, just different
from what i had in mind (where you let the ematch worry about
inversion).
 
> The complete API is also visible if ematch is not configured but
> will result in empty macros/structures. Those need to be
> improved though.
> 
> API visible to ematches:
> 
>   tcf_em_register(ops)
>   tcf_em_unregister(ops)
> 
>   ematches must at least provide the following callbacks:
> 
>   change, match
>  
>   Optional callbacks are: destroy, dump  
> 
>   kind must be set to a unique ID, i thought about declaring
>   1..2^16 to ematches within the mainline tree and have the
>   rest declared as to be used for private use to avoid collisions.

With std actions also this was an issue - at the moment dont have
anything in any headers just to make it free for all - This way you
could write a simple module that has zero dependency on an already
compiled kernel. There would be standard practise where say 11 would
mean something - but i suggest not to enforce it; the register()
should probably spit some helpful message of who already has the number.
you are trying to grab.

> Patch 2: u32 ematch
> 
>   Is an ematch based on the existing u32 match but allows to
>   specify the layer and is able to read u32 values if alignment
>   does not allow direct access. Additionally it supports
>   the operands, eq, lt, gt. It is a few ticks slower than the
>   existing match but worth it. However, it does not support
>   the neat nexthdr via hashing as u32 does which is the main
>   problem before u32 can make proper use of it.

It does emulate a u32 node but not the classifier - which is a _lot_
more sophisticated (with multilevel trees of hashes etc). Maybe you
should change its name to something like 32bit match. 

> Patch 3: nbyte ematch
> 
>   Compares n bytes at specified offset. To be used for IPv6
>   address matches to avoid 4 ANDed u32 matches.

This looks useful.
My recommendation would be to have the metamatch as the first thing
so we can kill indev and friends.

> Patch 4: Basic Classifier
> 
>   This is the most basic classifier possible doing nothing more
>   than executing extensions and ematches. It follows the
>   architecture of u32 and fw by storing a filter list in tp->root.
>   This eventually makes fw obsolete once meta ematch is available.
>   I didn't copy the u32/fw code but rather made use of the list.h.

Very inefficient, but serves the purpose of an example.
[Even if you go as basic a hash as fw classifier you will do better]

> pskbs are completely unhandled so far as I'm still not sure
> how to do it properly.

Given where we are doing these things (egress and ingress of stack)
we would mostly be fine (unlike netfilter). 

cheers,
jamal
