From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Mon, 04 Aug 2003 15:17:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2E5CD6.4030500@hipac.org>
References: <200307141045.40999.nf@hipac.org>	 <1058328537.1797.24.camel@jzny.localdomain>  <3F16A0E5.1080007@hipac.org> <1059934468.1103.41.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1F772C011F16724D016A230F"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1059934468.1103.41.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1F772C011F16724D016A230F
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jamal

You wrote:
> Apologies for late response. Its funny how i thought i was going to have
> more time in the last 2 weeks but due to bad scheduling that wasnt the
> case.

No problemo ...

> I think i will have to look at your code to make comments.

Curious about it.

> Not entirely accurate. Depends which tc classifier. u32 hash tables are
> infact like iptables chains.

Hm, we don't think so. Unfortunately, there does not seem to be much
information about the inner workings of u32 and we currently don't have
the time to deduce the whole algorithm from the code.

Here is a short overview of our current view on u32:
      - each u32 filter "rule" consists of possibly several u32 matches,
        i.e. tc_u32_sel with nkeys tc_u32_key's
        => one rule is basically represented as a struct tc_u_knode
      - a set of u32 filter rules with same priority is in general a
        tree of hashes like for example:
                        hash1: |--|--|
                                /   \
                hash2: |--|--|--|    hash3: |--|--|--|--|
                         |  |  |              |  |  |  |
                        r1 r2 r3             r4 r5 r6 r7
        where the r_i are in fact lists of rules (-> hashing with
        chaining)
        => if there is more than one single filter with same prio
           there is always a tree of hashes (with possibly only 1 node
           (=hash))
      - within such a tree of u32 filters (with same prio) there is
        no concept of prioritizing them any further => the rules must
        be conflict free
      - there is no way of optimizing filters with different priorities
        since one cannot assume that the intermediate classifiers are all
        of the same type

If this is not the way it _really_ works we'd appreciate it if you could
describe the general principles behind u32.

> Note, the concept of priorities which is used for conflict resolution as
> well as further separating sets of rules doesnt exist in iptables.

Well, iptables rule position and tc filter priorities are just the
same apart from the fact that iptables does not allow multiple rules
to have the same priority (read: position). Therefore iptables rulesets
don't suffer from conflicts.

> You can also have them use different priorities and with the continue
> operator first clasify based on packet data then on metadata or on
> another packet header filter.

Ok but then you fall back to the linear approach. Since with u32 only
blocks of rules with same prio can be optimized one has to implement a
ruleset using as few different prioritized blocks of filters as possible
to achieve maximum performance.

>>One disadvantage of this concept is that the hashed filters
>>must be compact, i.e. there cannot be other classifiers in between.
> 
> I didnt understand this. Are you talking about conflict resolving of
> overlapping filters?

No, the issue is just that within a block of filters with same prio
there cannot be another type of filter, e.g. one cannot put a route
classifier inside a hash of u32 classifiers.

>>Another major disadvantage is caused by the hashing scheme.
>>If you use the hash for 1 dimension you have to make sure that
>>either all filters in a certain bucket are disjoint or you must have
>>an implicit ordering of the rules (according to the insertion order
>>or something). This scheme is not extendable to 2 or more dimensions,
>>i.e. 1 hash for src ip, #(src ip buckets) many dst ip hashes and so
>>on, because you simply cannot express arbitrary rulesets.
> 
> If i understood you - you are refering to a way to reduce the number of
> lookups by having disjoint hashes. I suppose for something as simple as 
> a five tuple lookup, this is almost solvable by hardcoding the different
> fields into multiway hashes. Its when you try to generalize that it
> becomes an issue. 

What do you mean exactly by "five tuple"? Do you refer to rules which
consist of 5 punctiform matches, i.e. no masks or ranges or wildcards
allowed, like (src ip 1.2.3.4, dst ip 3.4.5.6, proto tcp, src port 123,
dst port 456)?

Of course the scheme works for such cases (which consist of
non-conflicting rules) although the user must be aware of the
concrete hash function: divisor & u32_hash_fold(key, sel)
because the mask would be 0xffffffff for the ip's.

If ranges or overlapping masks are involved it gets really complicated
and we doubt that people are able to manage such scenarios.

>>Another general problem is of course that the user has to manually
>>setup the hash which is rather inconvenient.
> 
> Yes. Take a look at Werners tcng - he has a clever way to hide things
> from the user. I did experimentation on u32 with a kernel thread which
> rearranged things when they seemed out of balance but i havent
> experimented with a lot of rules.

We had a look at the tcng paper. Here it says that the u32 classifier
is not used in the optimal way. Since we didn't have a look at the
current tcng release it might well be that these problems are already
addressed. Is that the case?

BTW, why do you want to rearrange the tree of hashes and based on which
heuristics? Why is there a kernel thread needed? Isn't it possible to
arrange the tree directly after insert/delete operations?

>>Now, what are the implications on the matching performance:
>>tc vs. nf-hipac? As long as the extended hashing stuff is not used
>>nf-hipac is clearly superior to tc. 
> 
> You are refering to u32. You mean as long as u32 stored things in a
> single linked list, you win - correct?

Yes, but this is not only true for u32. As long as the ruleset
looks like: "n filters with n different priorities which can
be translated into n nf-hipac rules" nf-hipac is clearly faster
because in this case tc uses the linear approach.

>>When hashing is used it _really_
>>depends. If there is only one classifier (with hashing) per interface
>>and the number of rules per bucket is very small the performance should
>>be comparable. As soon as you add other classifiers nf-hipac will
>>outperform tc again.
> 
> If we take a simple user interface abstraction like tcng which hides the
> evil of u32 and then take simple 5 tuple rules - i doubt you will see
> any difference. For more generic setup, the kernel thread i refer to
> would work - but may slow insertion. 

For the simple punctiform examples like described above you may be right
that nf-hipac and tc should perform similar but it's not clear to us
how you want to achieve universality (including mask, ranges and
wildcards) by this kernel thread rearranging approach. Basically you
have to address the following problem: Given an arbitrary set of u32
rules with different priorities you have to compute an semantically
equivalent representation with a tree of hashes.

>>So, basically HIPAC is just a normal classifier like any other
>>with two exceptions:
>>   a) it can occur only once per interface
>>   b) the rules within the classifier can contain other classifiers,
>>      e.g. u32, fw, tc_index, as matches
> 
> But why restriction a)? 

Well, the restriction is necessary because of the new hipac design in
which nf-hipac (i.e. firewalling), routing and cls_hipac (i.e. tc) are
just applications for the classification framework. The basic idea is
to reduce the number of classifications on the forwarding path to a
single one (in the best case). In order to truly understand the
requirement it would be necessary to explain the idea behind the new
stage concept which is beyond the scope of this e-mail :-/.

> Also why should we need hipac to hold other filters when the
> infrastructure itself can hold the extended filters just fine?
> I think you may actually be trying to say why somewhere in the email,
> but it must not be making a significant impression on my brain.

The idea is to reduce the embedded classifiers to a match, i.e.
their return value is ignored. This offers the possibility of
expressing a conjunction of native matches and classifiers in the
very same way nf-hipac rules support iptables matches. This enhances
the expressiveness of classification rules.
A rule |nat. match 1|...|nat. match n|emb. cls 1|...|emb. cls m|
matches if nat. match 1-n and emb. cls 1-m match.

>>There is just one problem with the current tc framework. Once
>>a new filter is inserted into the chain it is not removed even
>>if the change function of the classifier returns < 0
>>(2.6.0-test1: net/sched/cls_api.c: line 280f).
>>This should be changed anyway, shouldn't it?
> 
> Are you refering to this piece of code?:
> ----
>         err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
>         if (err == 0)
>                 tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
> 
> errout:
>         if (cl)
>                 cops->put(q, cl);
>         return err;
> ---

Yes.

> change() should not return <0 if it has installed the filter i think.
> Should the top level code be responsible for removing filters?

The top level code (cls_hipac.c:tc_ctl_filter) is responsible for
creating new tcf_proto structs (if not existent) and enqueuing the
struct into the chain. Therefore it is also responsible for taking
the stuff out of the chain again if necessary. In case we have just
created a new tcf_proto and change fails it would be better if the new
tcf_proto is removed afterwards, i.e.
                     write_lock(&qdisc_tree_lock);
                     spin_lock_bh(&dev->queue_lock);
                     *back = tp->next;
                     spin_unlock_bh(&dev->queue_lock);
                     write_unlock(&qdisc_tree_lock);
                     tp->ops->destroy(tp);
                     module_put(tp->ops->owner);
                     kfree(tp);
is issued.
Do you agree?

> Consider what i said above. I'll try n cobble together some examples to
> demonstrate (although it seems you already know this).
> To allow for anyone to install classifiers-du-jour without being
> dependet on hipac would be very useful. So ideas that you have for
> enabling this cleanly should be moved to cls_api.

Nobody will be forced to use hipac :-). It's just another classifier
like u32. We don't even had to modify cls_api so far. Everything
integrates just fine.


Regards,

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
|    High Performance Packet Classification    |
|       nf-hipac: http://www.hipac.org/        |
+----------------------------------------------+


--------------enig1F772C011F16724D016A230F
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Using GnuPG with Debian - http://enigmail.mozdev.org

iD8DBQE/LlzdtXh2AYIMjggRAtcvAKCUZykozfMnI5MmRMo0j/zH6TDg7gCdGl20
ngF9kmhPF45vfAYjTq6sd/U=
=qy5Z
-----END PGP SIGNATURE-----

--------------enig1F772C011F16724D016A230F--
