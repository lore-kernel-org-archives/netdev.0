From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: 13 Aug 2004 08:51:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1092401484.1043.30.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey <kuznet@ms2.inr.ac.ru>, "David S. Miller" <davem@redhat.com>,
        devik@cdi.cz, shemminger@osdl.org, kaber@trash.net,
        rusty@rustcorp.com.au, Harald Welte <laforge@netfilter.org>,
        netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sandr8_NOSPAM_@crocetta.org
In-Reply-To: <411C0FCE.9060906@crocetta.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alessandro,

This summary applies to all your patches: Too many changes that seem
unnecessary. Take a deep breath.

1) You cant change the enqueue/dequeue API just because one qdisc
doesnt seem to use it right. Whats all that contrack stuff doing in 
dev.c and pkt sched areas?
2) incr/decrementing ref cnt is the right way to go. skbs are shared.
Try running tcpdump with your changes (and what i suspect your qdisc is
doing) to see the effect. If you want to make changes to an skb, get
your own copy (or copy of parts of the skb look at things like clone and
skb_expand and relatives)
3) I have a feeling what you are trying to do is best achieved by
using a tc action and not a qdisc. As an example (based on a
conversation with Harald at OLS) i plan on doing selective contracking
at the ingress/egress - but as a clean separate action and not touching
any other files. If this is what you are trying to do, i can help sit on
the sideline and cheer you own with advice. It is not complicated to do,
time is the issue.
Maybe what you are trying to do is use contracking for accounting?
In which case there will be two independent actions: one to track and
another to account.

cheers,
jamal

On Thu, 2004-08-12 at 20:48, sandr8 wrote:
> 2) The second patch eliminates the need for the deprecated __parent 
> field and eliminates some tricks such as the rx_class field...
> to do so it introduces a slight change in the interface of the enqueue() 
> and requeue() operations... the "struct sk_buff * skb" becomes now a 
> "struct sk_buff ** const skb". All the in-2.6.8-kernel packet schedulers 
> and the core/dev.c are updated consequently... changes are quite trivial 
> so there's no issue for out-of-the-kernel-tree schedulers.
> 
> in order to make it clearer i should give a broader insight... i hate to 
> describe the gory details but it's a bit delicate.
> 
> a) the socket buffer for a dropped packet is freed as late as possible 
> (lazy lazy lazy!). in other words, locally, a packet is _candidated_ to 
> be dropped, but the latest word is the most global one.
> 
> who's got the most global viewpoint? Elementary! My Dear Watson! the 
> most external enqueuing operation. Ok... now you get it... the stack is 
> your friend and will discriminate for free :) the pointer to the socket 
> buffer structure always stays at the same location, but is updated by 
> the enqueueing operations.
> 
> This means that whatever packet "Barabba" is choosen to be dropped 
> internally, it can be further saved by the caller, who can exchange it 
> with an other victim... (i think there's no need to say who)
> 
> b) the changes in (a) made it possible to remove the deprecated
> __parent field due to cbq. this is done by handling the reshape 
> operation from the outside (in a very stupid loop cycle), whoever
> drops whatever.
> 
> this way we also avoid saving the class in the rx_class field, calling a 
> function that retrieves it and doing complex tricks to cope with the old 
> byval api
> 
> c) now it's possible to have (almost) a single point (core/dev.c) where 
> packets are dropped. Though there are some other few places, the inline 
> function before_explicit_drop() easies the centralization of the 
> operations. this comes into great help for patch 4.
> 
> Also, the empty macro IMPLICIT_DROP() behaves as a marker for the 
> reader   and the coder, helping maintainance and readability.
> 
> d) yet the reshape_fail field is kept, and the code that handled it in 
> the leaf disciplines is kept as well (slightly reworked but kept). this 
> just in case some out-of-the-kernel classful schedulers use it: we don't 
> want to break them (for what concerns the in-kernel-schedulers, you can 
> wipe out all the code related to reshape_fail without any harm, it is 
> not any more needed... with regard to it, what about wrapping it in some 
> #ifdef CONFIG_TC_DONT_BREAK_OUT_OF_THE_KERNEL_CLASSFUL_SCHEDULERS ?)
> 
> NOTA BENE
> e) it is darn important that if a packet is dropped all the outmost 
> queueing discipline's enqueue()'s return value tells it!
> 
> NOTA BENE
> f) kfree_skb() for locally allocated socket buffers are still there and 
> must stay there
> 
> NOTA BENE
> g) kfree_skb() whose semantic is to just decrement the user count are 
> not a packet drop. furthermore, the same kfree_skb() could have a 
> different run-time semantic, and is hence splitted in two, as in the 
> following excerpt of code:
> 
>          }
>  
>          if (terminal) {
> -            kfree_skb(skb);
> +            if( any_dropped(*qres) ){
> +                before_explicit_drop(*skb);
> +                IMPLICIT_DROP();
> +            } else
> +                kfree_skb(*skb);
>              return NULL;
>          }
> 
