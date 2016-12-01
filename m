From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net] fib_trie: Avoid expensive update of suffix length
 when not required
Date: Thu, 1 Dec 2016 10:29:29 -0800
Message-ID: <CAKgT0Uep40bYFQtToVBdmez5sPoyzapXNTUU10m9x6pyTj=Etg@mail.gmail.com>
References: <1480441605-27855-1-git-send-email-rshearma@brocade.com>
 <CAKgT0UcK-+t3DK=TtxY14y6XB8nqtgdv57E53QkOAjmdB36-vw@mail.gmail.com> <50c4f236-c486-1224-e3b0-c3e322d68d58@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35183 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755513AbcLAS3b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 13:29:31 -0500
Received: by mail-io0-f194.google.com with SMTP id h133so3379979ioe.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 10:29:30 -0800 (PST)
In-Reply-To: <50c4f236-c486-1224-e3b0-c3e322d68d58@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 4:27 PM, Robert Shearman <rshearma@brocade.com> wrote:
> On 29/11/16 23:14, Alexander Duyck wrote:
>>
>> On Tue, Nov 29, 2016 at 9:46 AM, Robert Shearman <rshearma@brocade.com>
>> wrote:
>>>
>>> With certain distributions of routes it can take a long time to add
>>> and delete further routes at scale. For example, with a route for
>>> 10.37.96.0/20 present it takes 47s to add ~200k contiguous /24 routes
>>> from 8.0.0.0/24 through to 11.138.207.0/24. Perf shows the bottleneck
>>> is update_suffix:
>>>
>>>       40.39%  [kernel]                      [k] update_suffix
>>>        8.02%  libnl-3.so.200.19.0           [.] nl_hash_table_lookup
>>
>>
>> Well yeah, it will be expensive when you have over 512K entries in a
>> single node.  I'm assuming that is the case based on the fact that
>> 200K routes will double up in the trie node due to broadcast and the
>> route ending up in adjacent key vectors.
>
>
> The example scenario was in fact using a large scale of just routes rather
> than addresses so there are no broadcast leafs (nor local leafs):
>
>         +-- 8.0.0.0/6 18 2 52436 suffix/20
>            |-- 8.0.0.0
>               /24 universe UNICAST
>            |-- 8.0.1.0
>               /24 universe UNICAST
>            |-- 8.0.2.0
>               /24 universe UNICAST
>
> (the "suffix/20" is for test purposes as per below). In this case the
> 8.0.0.0/6 node has a child array of size 2^18 = 262144.
>
>>
>>> With these changes, the time is reduced to 4s for the same scale and
>>> distribution of routes.
>>>
>>> The issue is that update_suffix does an O(n) walk on the children of a
>>> node and the with a dense distribtion of routes the number of children
>>> in a node tends towards the number of nodes in the tree.
>>
>>
>> Other than the performance I was just wondering if you did any other
>> validation to confirm that nothing else differs.  Basically it would
>> just be a matter of verifying that /proc/net/fib_trie is the same
>> before and after your patch.
>
>
> Yes, to verify these changes I applied some local changes to dump the slen
> field of trie nodes from /proc/net/fib_trie. I presumed that the format of
> /proc/net/fib_trie is a public API that we can't break so I intend to submit
> this as a patch. I verified by inspection that the suffix length listed in
> the nodes was as expected when exercising the insert and remove functions
> for routes with both larger and smaller suffixes than in the current nodes,
> and then for the inflate, halve and flush cases.
>
> I've now verified that a diff of /proc/net/fib_trie before and after my
> patch with all the routes added of my example scenario shows no changes.
>
>>
> ...
>>>
>>> Fixes: 5405afd1a306 ("fib_trie: Add tracking value for suffix length")
>>> Signed-off-by: Robert Shearman <rshearma@brocade.com>
>>
>>
>> So I am not entirely convinced this is a regression, I was wondering
>> what your numbers looked like before the patch you are saying this
>> fixes?  I recall I fixed a number of issues leading up to this so I am
>> just curious.
>
>
> At commit 21d1f11db0e2f20a549ad8322879507850544670 ("fib_trie: Remove checks
> for index >= tnode_child_length from tnode_get_child") which is the parent
> of 5405afd1a306:
>
> $ time sudo ip route restore < ~/allroutes
> RTNETLINK answers: File exists
> RTNETLINK answers: File exists
> RTNETLINK answers: File exists
> RTNETLINK answers: File exists
>
> real    0m3.451s
> user    0m0.184s
> sys     0m2.004s
>
>
> At commit 5405afd1a30620de8601436bae739c67c0bc7324 ("fib_trie: Add tracking
> value for suffix length"):
>
> $ time sudo ip route restore < ~/allroutes
> RTNETLINK answers: File exists
> RTNETLINK answers: File exists
> RTNETLINK answers: File exists
> RTNETLINK answers: File exists
>
> real    0m48.624s
> user    0m0.360s
> sys     0m46.960s
>
> So does that warrant a fixes tag for this patch?

Yes, please include it in the patch description next time.

I've been giving it thought and the fact is the patch series has
merit.  I just think it was being a bit too aggressive in terms of
some of the changes.  So placing any changes in put_child seem to be
the one piece in this that make this a bit ugly.  I'll submit a
counter proposal, if you could try testing it I would appreciate it,
or if you could look at incorporating some of it into your patch it
would be useful.

>>
>> My thought is this seems more like a performance optimization than a
>> fix.  If that is the case this probably belongs in net-next.
>>
>> It seems to me we might be able to simplify update_suffix rather than
>> going through all this change.  That might be something that is more
>> acceptable for net.  Have you looked at simply adding code so that
>> there is a break inside update_suffix if (slen == tn->slen)?  We don't
>> have to call it for if a leaf is added so it might make sense to add
>> that check.
>
>
> That doesn't really help since the search always starts from the smallest
> suffix length and thus could potentially require visiting a large number of
> children before finding the node that makes slen == tn->slen.
>
> In the example above, 10.37.96.0/20 would be child number 140640 in node
> 8.0.0.0/6 18. Since the loop starts out with stride = 2 this means that it
> requires 70320 iterations round to find 10.37.96.0/20 which contributes the
> largest suffix length to the node.

Yes, however that is still 60K fewer iterations we would have to do.

> Now it may be possible to improve the algorithm by starting the search from
> the largest suffix length towards the smallest suffix length instead of the
> current smallest to largest, but there would still be distributions of
> routes that would lead to needing to visit a large number of nodes only to
> find that nothing has changed.

The largest possible suffix always starts at 0.  Any bits in the index
mean that the suffix has to stop before that bit since suffix
represents the number of bits that are 0.  By starting at 0 and
increasing the stride as we hit bigger values we should be about as
optimal there as we can be.

>>
>>> ---
>>>  net/ipv4/fib_trie.c | 86
>>> ++++++++++++++++++++++++++++++++++++++---------------
>>>  1 file changed, 62 insertions(+), 24 deletions(-)
>>>
>>> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>>> index 026f309c51e9..701cae8af44a 100644
>>> --- a/net/ipv4/fib_trie.c
>>> +++ b/net/ipv4/fib_trie.c
>>> @@ -421,8 +421,22 @@ static inline int tnode_full(struct key_vector *tn,
>>> struct key_vector *n)
>>>         return n && ((n->pos + n->bits) == tn->pos) && IS_TNODE(n);
>>>  }
>>>
>>> +static void node_push_suffix(struct key_vector *tn, struct key_vector
>>> *l)
>>> +{
>>> +       while (tn->slen < l->slen) {
>>> +               tn->slen = l->slen;
>>> +               tn = node_parent(tn);
>>> +               if (!tn)
>>> +                       break;
>>
>>
>> I don't think the NULL check is necessary, at least it wasn't with the old
>> code.
>
>
> It wasn't necessary before because the root node had the largest possible
> suffix length of KEYLENGTH. This isn't the case for the nodes this is now
> called on since they're either nodes without parents or sub-tries that end
> up in node without a parent, where they're initialised to have the smallest
> possible suffix length for the node (equal to their position).
>
>>
>>> +       }
>>> +}
>>> +
>>>  /* Add a child at position i overwriting the old value.
>>>   * Update the value of full_children and empty_children.
>>> + *
>>> + * The suffix length of the parent node and the rest of the tree is
>>> + * updated (if required) when adding/replacing a node, but is caller's
>>> + * responsibility on removal.
>>>   */
>>>  static void put_child(struct key_vector *tn, unsigned long i,
>>>                       struct key_vector *n)
>>> @@ -447,8 +461,8 @@ static void put_child(struct key_vector *tn, unsigned
>>> long i,
>>>         else if (!wasfull && isfull)
>>>                 tn_info(tn)->full_children++;
>>>
>>> -       if (n && (tn->slen < n->slen))
>>> -               tn->slen = n->slen;
>>> +       if (n)
>>> +               node_push_suffix(tn, n);
>>
>>
>> This is just creating redundant work if we have to perform a resize.
>
>
> The only real redundant work is the assignment of slen in tn, since the
> propagation up the trie has to happen regardless and if a subsequent resize
> results in changes to the trie then the propagation will stop at tn's parent
> since the suffix length of the tn's parent will not be less than tn's suffix
> length.


This isn't going to work.  We want to avoid trying to push the suffix
when we place a child.  There are scenarios where we are placing
children in nodes that don't have parents yet because we are doing
rebalances and such.  I suspect this could be pretty expensive on a
resize call.

We want to pull the suffix pushing out of the resize completely.  The
problem is this is going to cause us to start pushing suffixes for
every node moved as a part of resize.

>>
>>>         rcu_assign_pointer(tn->tnode[i], n);
>>>  }
>
> ...
>
>>> -static void leaf_pull_suffix(struct key_vector *tp, struct key_vector
>>> *l)
>>> +static void node_set_suffix(struct key_vector *tp, unsigned char slen)
>>>  {
>>> -       while ((tp->slen > tp->pos) && (tp->slen > l->slen)) {
>>> -               if (update_suffix(tp) > l->slen)
>>> +       if (slen > tp->slen)
>>> +               tp->slen = slen;
>>> +}
>>> +
>>> +static void node_pull_suffix(struct key_vector *tn)
>>> +{
>>> +       struct key_vector *tp;
>>> +       unsigned char slen;
>>> +
>>> +       slen = update_suffix(tn);
>>> +       tp = node_parent(tn);
>>> +       while ((tp->slen > tp->pos) && (tp->slen > slen)) {
>>> +               if (update_suffix(tp) > slen)
>>>                         break;
>>>                 tp = node_parent(tp);
>>>         }
>>>  }
>>>
>>

Actually I realized that there is a bug here.  The check for
update_suffix(tp) > slen can cause us to stop prematurely if I am not
mistaken.  What we should probably be doing is pulling out tp->slen
and if the result of update_suffix is the same value then we can break
the loop.  Otherwise we can stop early if a "second runner up" shows
up that is supposed to be pushed up the trie.

I actually started around with patches to do much the same as what you
are doing and I will probably submit them as an RFC so if you need you
can pick pieces out as needed, or I could submit them if they work for
you.

>> I really hate all the renaming.  Can't you just leave these as
>> leaf_pull_suffix and leaf_push _suffix.  I'm fine with us dropping the
>> leaf of the suffix but the renaming just makes adds a bunch of noise.
>> Really it might work better if you broke the replacement of the
>> key_vector as a leaf with the suffix length into a separate patch,
>> then you could do the rename as a part of that.
>
>
> Ok, I'll leave the naming of leaf_push_suffix alone. Note that
> leaf_pull_suffix hasn't been renamed, the below in the diff is just an
> artifact of how diff decided to present the changes along with the moving of
> leaf_push_suffix.

So I have been looking this over for the last couple days and actually
I have started to be okay with the renaming.

However I would ask to be consistent.  If you are going to have
node_pull_suffix and node_push_suffix then just pass a node and a
suffix length.  You can drop the leaf key vector from both functions
instead of just one.

>>
>>> -static void leaf_push_suffix(struct key_vector *tn, struct key_vector
>>> *l)
>>> +static void leaf_pull_suffix(struct key_vector *tp, struct key_vector
>>> *l)
>>>  {
>>> -       /* if this is a new leaf then tn will be NULL and we can sort
>>> -        * out parent suffix lengths as a part of trie_rebalance
>>> -        */
>>> -       while (tn->slen < l->slen) {
>>> -               tn->slen = l->slen;
>>> -               tn = node_parent(tn);
>>> +       while ((tp->slen > tp->pos) && (tp->slen > l->slen)) {
>>> +               if (update_suffix(tp) > l->slen)
>>> +                       break;
>>> +               tp = node_parent(tp);
>>>         }
>>>  }
>>
>>
>> If possible it would work better if you could avoid moving functions
>> around as a result of your changes.
>
>
> Ok, I can add a forward declaration instead.

It shouldn't be necessary.  I think you are doing way too much with
this patch.  We just need this to be a fix, you are doing a bit too
much like adding this new node_set_suffix function which isn't really
needed.

>>
>>> @@ -1107,7 +1122,7 @@ static int fib_insert_alias(struct trie *t, struct
>>> key_vector *tp,
>>>         /* if we added to the tail node then we need to update slen */
>>>         if (l->slen < new->fa_slen) {
>>>                 l->slen = new->fa_slen;
>>> -               leaf_push_suffix(tp, l);
>>> +               node_push_suffix(tp, l);
>>>         }
>>>
>>>         return 0;
>
> ...
>>>
>>> @@ -1783,6 +1801,16 @@ void fib_table_flush_external(struct fib_table
>>> *tb)
>>>                         if (IS_TRIE(pn))
>>>                                 break;
>>>
>>> +                       /* push the suffix length to the parent node,
>>> +                        * since a previous leaf removal may have
>>> +                        * caused it to change
>>> +                        */
>>> +                       if (pn->slen > pn->pos) {
>>> +                               unsigned char slen = update_suffix(pn);
>>> +
>>> +                               node_set_suffix(node_parent(pn), slen);
>>> +                       }
>>> +
>>
>>
>> Why bother with the local variable?  You could just pass
>> update_suffix(pn) as the parameter to your node_set_suffix function.
>
>
> To avoid a long line on the node_set_suffix call or splitting it across
> lines, but I'll remove the local variable as you suggest and the same below.

Actually I think there is a bug here.  You shouldn't be setting the
suffix for the parent based on the child.  You can just call
update_suffix(pn) and that should be enough.
