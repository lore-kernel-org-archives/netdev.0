From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: 04 Aug 2003 11:51:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060012260.1103.380.camel@jzny.localdomain>
References: <200307141045.40999.nf@hipac.org>
	 <1058328537.1797.24.camel@jzny.localdomain>  <3F16A0E5.1080007@hipac.org>
	 <1059934468.1103.41.camel@jzny.localdomain>  <3F2E5CD6.4030500@hipac.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Bellion and Thomas Heinz <nf@hipac.org>
In-Reply-To: <3F2E5CD6.4030500@hipac.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Olla,

On Mon, 2003-08-04 at 09:17, Michael Bellion and Thomas Heinz wrote:

> > I think i will have to look at your code to make comments.
> 
> Curious about it.
> 

I promise i will. I dont think i will do it justice spending 5 minutes
on it. I take it you have written extensive docs too ;->

> > Not entirely accurate. Depends which tc classifier. u32 hash tables are
> > infact like iptables chains.
> 
> Hm, we don't think so. Unfortunately, there does not seem to be much
> information about the inner workings of u32 and we currently don't have
> the time to deduce the whole algorithm from the code.
> 

Unfortunately it is more exciting to write code than documents. I almost
got someone to document at least its proper usage but they backed away
at the last minute.

> Here is a short overview of our current view on u32:
>       - each u32 filter "rule" consists of possibly several u32 matches,
>         i.e. tc_u32_sel with nkeys tc_u32_key's
>         => one rule is basically represented as a struct tc_u_knode
>       - a set of u32 filter rules with same priority is in general a
>         tree of hashes like for example:
>                         hash1: |--|--|
>                                 /   \
>                 hash2: |--|--|--|    hash3: |--|--|--|--|
>                          |  |  |              |  |  |  |
>                         r1 r2 r3             r4 r5 r6 r7
>         where the r_i are in fact lists of rules (-> hashing with
>         chaining)
>         => if there is more than one single filter with same prio
>            there is always a tree of hashes (with possibly only 1 node
>            (=hash))
>       - within such a tree of u32 filters (with same prio) there is
>         no concept of prioritizing them any further => the rules must
>         be conflict free
>       - there is no way of optimizing filters with different priorities
>         since one cannot assume that the intermediate classifiers are all
>         of the same type
> 
> If this is not the way it _really_ works we'd appreciate it if you could
> describe the general principles behind u32.
> 

u32 is a swiss knife so to go into general principles requires some
time, motivation, and more importantly patience.I possess none of these
nice attributes at the moment. You are doing a good job keep reading the
code.
I dont wanna go in a lot of details, but one important detail is that
keynodes can also lead to other hash tables. So you can split the packet
parsing across multiple hashes - this is where the comparison with
chains comes in. There are several ways to do this. I'll show you the
brute force way and you can make it more usable with "hashkey" and
"sample" operator. Stealing from your example:

                        hash1: |--|--|
                                /   
                hash2: |--|--|--|   
                         |  |  |             
                        r1 r2 r3 
                         |     |
                        hash3  hash4
                                |  | 
                                r4 r5  
 
Example, you go into hash2 for all IP packets. The rules on the hash2
look at the protocol type and select a different hash table for TCP,
UDP, ICMP etc.

- so general rules is: Put your most hit rules at the highest priority
so they are found first.
Heres an example, i havent tested this (i can send you a tested example
if you cant get this to work):

-------
TCF=tc filter add dev eth0 parent ffff: protocol ip prio 10

# add hash table 1
$TCF handle 1::: u32 divisor 1
#add hash table 2
$TCF handle 2::: u32 divisor 1
#add your filter rules to specific tables: ICMP to table 1, TCP to table
#6 etc
.
.
#ICMP gets matched in table 1
$TCF match ip protocol 1 0xff link 1:0:0
.
.
----------

Makes sense?

Note, this doesnt say much about the user usability of u32 - it just
says can be done.

> > Note, the concept of priorities which is used for conflict resolution as
> > well as further separating sets of rules doesnt exist in iptables.
> 
> Well, iptables rule position and tc filter priorities are just the
> same apart from the fact that iptables does not allow multiple rules
> to have the same priority (read: position). Therefore iptables rulesets
> don't suffer from conflicts.
> 

sure position could be used as a priority. It is easier/intuitive to
just have explicit priorities.

> > You can also have them use different priorities and with the continue
> > operator first clasify based on packet data then on metadata or on
> > another packet header filter.
> 
> Ok but then you fall back to the linear approach. Since with u32 only
> blocks of rules with same prio can be optimized one has to implement a
> ruleset using as few different prioritized blocks of filters as possible
> to achieve maximum performance.
> 

Read what i said above if you still hold the same opinion lets discuss.
What "optimizes" could be a user interface or the thread i was talking
about earlier.

> >>One disadvantage of this concept is that the hashed filters
> >>must be compact, i.e. there cannot be other classifiers in between.
> > 
> > I didnt understand this. Are you talking about conflict resolving of
> > overlapping filters?
> 
> No, the issue is just that within a block of filters with same prio
> there cannot be another type of filter, e.g. one cannot put a route
> classifier inside a hash of u32 classifiers.
> 

But you dont need to as i was pointing out earlier. You can have both
fwmark,tcindex,u32, rsvp etc being invoked one after the other.

> >>Another major disadvantage is caused by the hashing scheme.
> >>If you use the hash for 1 dimension you have to make sure that
> >>either all filters in a certain bucket are disjoint or you must have
> >>an implicit ordering of the rules (according to the insertion order
> >>or something). This scheme is not extendable to 2 or more dimensions,
> >>i.e. 1 hash for src ip, #(src ip buckets) many dst ip hashes and so
> >>on, because you simply cannot express arbitrary rulesets.
> > 
> > If i understood you - you are refering to a way to reduce the number of
> > lookups by having disjoint hashes. I suppose for something as simple as 
> > a five tuple lookup, this is almost solvable by hardcoding the different
> > fields into multiway hashes. Its when you try to generalize that it
> > becomes an issue. 
> 
> What do you mean exactly by "five tuple"? Do you refer to rules which
> consist of 5 punctiform matches, i.e. no masks or ranges or wildcards
> allowed, like (src ip 1.2.3.4, dst ip 3.4.5.6, proto tcp, src port 123,
> dst port 456)?
> 

above but with masks. "5 tuple" is a classical name for the above.

> Of course the scheme works for such cases (which consist of
> non-conflicting rules) although the user must be aware of the
> concrete hash function: divisor & u32_hash_fold(key, sel)
> because the mask would be 0xffffffff for the ip's.
> 
> If ranges or overlapping masks are involved it gets really complicated
> and we doubt that people are able to manage such scenarios.
> 

I was refering to the cascaded hash tables i was refering to earlier.
Depending on the rules, you could optimize differently.

> >>Another general problem is of course that the user has to manually
> >>setup the hash which is rather inconvenient.
> > 
> > Yes. Take a look at Werners tcng - he has a clever way to hide things
> > from the user. I did experimentation on u32 with a kernel thread which
> > rearranged things when they seemed out of balance but i havent
> > experimented with a lot of rules.
> 
> We had a look at the tcng paper. Here it says that the u32 classifier
> is not used in the optimal way. Since we didn't have a look at the
> current tcng release it might well be that these problems are already
> addressed. Is that the case?
> 

He doesnt fix the u32, rather if you use his wrappers he outputs
optimized u32 rules. All that is hidden from the user.

> BTW, why do you want to rearrange the tree of hashes and based on which
> heuristics? Why is there a kernel thread needed? Isn't it possible to
> arrange the tree directly after insert/delete operations?
> 

You can do that, but then you are adding delay to the insertion/deletion
rates which are very important metrics.
Another way to do it is to fire a netlink message every time a hash
table's keynodes exceed a threshold value and have user space compute a
rearrangement.
Essentially you have to weigh your tradeoffs. 

> >>Now, what are the implications on the matching performance:
> >>tc vs. nf-hipac? As long as the extended hashing stuff is not used
> >>nf-hipac is clearly superior to tc. 
> > 
> > You are refering to u32. You mean as long as u32 stored things in a
> > single linked list, you win - correct?
> 
> Yes, but this is not only true for u32. As long as the ruleset
> looks like: "n filters with n different priorities which can
> be translated into n nf-hipac rules" nf-hipac is clearly faster
> because in this case tc uses the linear approach.
> 

If you still hold this opinion after my explanation on cascaded hash
tables, then lets discuss again.

> >>When hashing is used it _really_
> >>depends. If there is only one classifier (with hashing) per interface
> >>and the number of rules per bucket is very small the performance should
> >>be comparable. As soon as you add other classifiers nf-hipac will
> >>outperform tc again.
> > 
> > If we take a simple user interface abstraction like tcng which hides the
> > evil of u32 and then take simple 5 tuple rules - i doubt you will see
> > any difference. For more generic setup, the kernel thread i refer to
> > would work - but may slow insertion. 
> 
> For the simple punctiform examples like described above you may be right
> that nf-hipac and tc should perform similar but it's not clear to us
> how you want to achieve universality (including mask, ranges and
> wildcards) by this kernel thread rearranging approach. Basically you
> have to address the following problem: Given an arbitrary set of u32
> rules with different priorities you have to compute an semantically
> equivalent representation with a tree of hashes.
> 

yes - that is the challenge to resolve;->

> >>So, basically HIPAC is just a normal classifier like any other
> >>with two exceptions:
> >>   a) it can occur only once per interface
> >>   b) the rules within the classifier can contain other classifiers,
> >>      e.g. u32, fw, tc_index, as matches
> > 
> > But why restriction a)? 
> 
> Well, the restriction is necessary because of the new hipac design in
> which nf-hipac (i.e. firewalling), routing and cls_hipac (i.e. tc) are
> just applications for the classification framework. The basic idea is
> to reduce the number of classifications on the forwarding path to a
> single one (in the best case). In order to truly understand the
> requirement it would be necessary to explain the idea behind the new
> stage concept which is beyond the scope of this e-mail :-/.
> 

Ok - maybe when you explain the concept later i will get it. Is your
plan to put this in other places other than Linux?

> > Also why should we need hipac to hold other filters when the
> > infrastructure itself can hold the extended filters just fine?
> > I think you may actually be trying to say why somewhere in the email,
> > but it must not be making a significant impression on my brain.
> 
> The idea is to reduce the embedded classifiers to a match, i.e.
> their return value is ignored. This offers the possibility of
> expressing a conjunction of native matches and classifiers in the
> very same way nf-hipac rules support iptables matches. This enhances
> the expressiveness of classification rules.
> A rule |nat. match 1|...|nat. match n|emb. cls 1|...|emb. cls m|
> matches if nat. match 1-n and emb. cls 1-m match.
> 

So you got this thought from iptables and took it to the next level?
I am still not sure i understand why not use what already exists - but
i'll just say i dont see it right now.


> 
> The top level code (cls_hipac.c:tc_ctl_filter) is responsible for
> creating new tcf_proto structs (if not existent) and enqueuing the
> struct into the chain. Therefore it is also responsible for taking
> the stuff out of the chain again if necessary. In case we have just
> created a new tcf_proto and change fails it would be better if the new
> tcf_proto is removed afterwards, i.e.
>                      write_lock(&qdisc_tree_lock);
>                      spin_lock_bh(&dev->queue_lock);
>                      *back = tp->next;
>                      spin_unlock_bh(&dev->queue_lock);
>                      write_unlock(&qdisc_tree_lock);
>                      tp->ops->destroy(tp);
>                      module_put(tp->ops->owner);
>                      kfree(tp);
> is issued.
> Do you agree?
> 

It doesnt appear harmful to leave it there without destroying it.
The next time someome adds a filter of the same protocol + priority, it
will already exist. If you want to be accurate (because it does get
destroyed when the init() fails), then destroy it but you need to put
checks for "incase we have added a new tcf_proto" which may not look
pretty. Is this causing you some discomfort?

> > Consider what i said above. I'll try n cobble together some examples to
> > demonstrate (although it seems you already know this).
> > To allow for anyone to install classifiers-du-jour without being
> > dependet on hipac would be very useful. So ideas that you have for
> > enabling this cleanly should be moved to cls_api.
> 
> Nobody will be forced to use hipac :-). It's just another classifier
> like u32. We don't even had to modify cls_api so far. Everything
> integrates just fine.
> 

cool. Keep up the good work.

cheers,
jamal
