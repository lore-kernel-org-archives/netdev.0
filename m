From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: Fri, 13 Aug 2004 16:09:28 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <411CCB98.4080904@crocetta.org>
References: <411C0FCE.9060906@crocetta.org> <1092401484.1043.30.camel@jzny.localdomain>
Reply-To: sandr8_NOSPAM_@crocetta.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey <kuznet@ms2.inr.ac.ru>, "David S. Miller" <davem@redhat.com>,
 devik@cdi.cz,  shemminger@osdl.org,  kaber@trash.net,
 rusty@rustcorp.com.au, Harald Welte <laforge@netfilter.org>,
 netdev@oss.sgi.com,  netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: hadi@cyberus.ca
In-Reply-To: <1092401484.1043.30.camel@jzny.localdomain>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

jamal wrote:

>Alessandro,
>
>This summary applies to all your patches: Too many changes that seem
>unnecessary. Take a deep breath.
>
>1) You cant change the enqueue/dequeue API just because one qdisc
>doesnt seem to use it right. Whats all that contrack stuff doing in 
>dev.c and pkt sched areas?
>
the conntrack stuff (actually that little part of code that adds unbilling to ACCT in case of a drop) is something that comes later (patch 4) and is not in the pkt sched part. please, don't let it divert your mind from the real point. just forget it for the moment... [in any case it is _not_ in the pkt sched area and as i said in mail 4/4 i don't like to put the variables into dev.c, that's why i am there asking for alternatives]

the api change is there to tell the outside which packet was dropped from the qdisc queue as a consequence of the enqueueing operation. the very first and most important consequence is that instead of having to call the callback function reshape_fail() from the inside of the inner qdisc and having to save information about the last visited class into rx_class and the parent qdisc into __parent you just have to *use one only line* inside a loop in the outer qdisc, isn't it neat?

the main aim of all those changes in the API is not this accounting
stuff but having less and simpler code, which imho is more
straightforward, but this is just my viewpoint.

have a look at how many lines disappeared from sch_cbq.c.... as i said,
in all the other sources all code that has to do with the reshape_fail
can immediatly disappear. just immagine how many lines (and ifdef
blocks!) can disappear from all the inner queueing policies that use
the reshape_fail(). asking the mantainer of an inner qdisc to add some
(furthermore conditionally compiled) code to help the outer qdisc makes
it harder to write and mantain, isn't it?

yes, the patch looks big but there are many changes just because i wanted
to update every single scheduler so that they complies with the slightly
changed API. but now everything is ready to go and much code and overehead
has become unnecessary. i mean, if what i have just written above is not a
rave, then i'd say

"it is better not to overcomplicate the code of any non-root policy just
because one classful qdisc doesnt seem to use the API right"

rather than

"You cant change the enqueue/dequeue API just because one qdisc
doesnt seem to use it right."

and similarly i'd say

"Too many things have now become unnecessary."

rather than

"Too many changes that seem unnecessary"

...isn't this simply amazing?

>2) incr/decrementing ref cnt is the right way to go. skbs are shared.
>Try running tcpdump with your changes (and what i suspect your qdisc is
>doing) to see the effect. If you want to make changes to an skb, get
>your own copy (or copy of parts of the skb look at things like clone and
>skb_expand and relatives)
>  
>
i'm not making changes to any socket buffer... sorry i can't get the 
point about "If you want to make changes to an skb"

i could interpret your suggestion as to increment the user count when 
passing a skb to the enqueue() of a qdisc so that the kfree_skb() inside 
will just decrement the counter, but still there's the problem of 
always: how can you know from the outside which packet did the 
kfree_skb() apply to?

>3) I have a feeling what you are trying to do is best achieved by
>using a tc action and not a qdisc. As an example (based on a
>conversation with Harald at OLS) i plan on doing selective contracking
>at the ingress/egress - but as a clean separate action and not touching
>any other files. If this is what you are trying to do, i can help sit on
>the sideline and cheer you own with advice. It is not complicated to do,
>time is the issue.
>Maybe what you are trying to do is use contracking for accounting?
>In which case there will be two independent actions: one to track and
>another to account.
>  
>
this is what that conntrack stuff in patch 4 was there for... better to 
say: patch 4 is there to unbill in case of a drop due to traffic 
control. the billing is already done by the patch 3 by Harald Welte, 
that as far as i understood was already on the way for inclusion.
packet action was not there in 2.6.7 when i started coding this patch. 
now i might as well try to dig into it and see if it can help. but, i 
repeat, in any case the main aim of  all those changes in the API is not 
this accounting stuff but having less and simpler code.

>cheers,
>jamal
>
>  
>
ciao and thank you for the attention!
sandr8)

>On Thu, 2004-08-12 at 20:48, sandr8 wrote:
>  
>
>>2) The second patch eliminates the need for the deprecated __parent 
>>field and eliminates some tricks such as the rx_class field...
>>to do so it introduces a slight change in the interface of the enqueue() 
>>and requeue() operations... the "struct sk_buff * skb" becomes now a 
>>"struct sk_buff ** const skb". All the in-2.6.8-kernel packet schedulers 
>>and the core/dev.c are updated consequently... changes are quite trivial 
>>so there's no issue for out-of-the-kernel-tree schedulers.
>>
>>in order to make it clearer i should give a broader insight... i hate to 
>>describe the gory details but it's a bit delicate.
>>
>>a) the socket buffer for a dropped packet is freed as late as possible 
>>(lazy lazy lazy!). in other words, locally, a packet is _candidated_ to 
>>be dropped, but the latest word is the most global one.
>>
>>who's got the most global viewpoint? Elementary! My Dear Watson! the 
>>most external enqueuing operation. Ok... now you get it... the stack is 
>>your friend and will discriminate for free :) the pointer to the socket 
>>buffer structure always stays at the same location, but is updated by 
>>the enqueueing operations.
>>
>>This means that whatever packet "Barabba" is choosen to be dropped 
>>internally, it can be further saved by the caller, who can exchange it 
>>with an other victim... (i think there's no need to say who)
>>
>>b) the changes in (a) made it possible to remove the deprecated
>>__parent field due to cbq. this is done by handling the reshape 
>>operation from the outside (in a very stupid loop cycle), whoever
>>drops whatever.
>>
>>this way we also avoid saving the class in the rx_class field, calling a 
>>function that retrieves it and doing complex tricks to cope with the old 
>>byval api
>>
>>c) now it's possible to have (almost) a single point (core/dev.c) where 
>>packets are dropped. Though there are some other few places, the inline 
>>function before_explicit_drop() easies the centralization of the 
>>operations. this comes into great help for patch 4.
>>
>>Also, the empty macro IMPLICIT_DROP() behaves as a marker for the 
>>reader   and the coder, helping maintainance and readability.
>>
>>d) yet the reshape_fail field is kept, and the code that handled it in 
>>the leaf disciplines is kept as well (slightly reworked but kept). this 
>>just in case some out-of-the-kernel classful schedulers use it: we don't 
>>want to break them (for what concerns the in-kernel-schedulers, you can 
>>wipe out all the code related to reshape_fail without any harm, it is 
>>not any more needed... with regard to it, what about wrapping it in some 
>>#ifdef CONFIG_TC_DONT_BREAK_OUT_OF_THE_KERNEL_CLASSFUL_SCHEDULERS ?)
>>
>>NOTA BENE
>>e) it is darn important that if a packet is dropped all the outmost 
>>queueing discipline's enqueue()'s return value tells it!
>>
>>NOTA BENE
>>f) kfree_skb() for locally allocated socket buffers are still there and 
>>must stay there
>>
>>NOTA BENE
>>g) kfree_skb() whose semantic is to just decrement the user count are 
>>not a packet drop. furthermore, the same kfree_skb() could have a 
>>different run-time semantic, and is hence splitted in two, as in the 
>>following excerpt of code:
>>
>>         }
>> 
>>         if (terminal) {
>>-            kfree_skb(skb);
>>+            if( any_dropped(*qres) ){
>>+                before_explicit_drop(*skb);
>>+                IMPLICIT_DROP();
>>+            } else
>>+                kfree_skb(*skb);
>>             return NULL;
>>         }
>>
>>    
>>
>
>
>
>
>
>  
>
