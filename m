From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net] fib_trie: Avoid expensive update of suffix length
 when not required
Date: Fri, 2 Dec 2016 13:54:16 +0000
Message-ID: <f470ac98-9b23-1374-9c93-b33ea0ae149c@brocade.com>
References: <1480441605-27855-1-git-send-email-rshearma@brocade.com>
 <CAKgT0UcK-+t3DK=TtxY14y6XB8nqtgdv57E53QkOAjmdB36-vw@mail.gmail.com>
 <50c4f236-c486-1224-e3b0-c3e322d68d58@brocade.com>
 <CAKgT0Uep40bYFQtToVBdmez5sPoyzapXNTUU10m9x6pyTj=Etg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:36275 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1760536AbcLBNyh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 08:54:37 -0500
In-Reply-To: <CAKgT0Uep40bYFQtToVBdmez5sPoyzapXNTUU10m9x6pyTj=Etg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/16 18:29, Alexander Duyck wrote:
> On Wed, Nov 30, 2016 at 4:27 PM, Robert Shearman <rshearma@brocade.com> wrote:
>> On 29/11/16 23:14, Alexander Duyck wrote:
>>> On Tue, Nov 29, 2016 at 9:46 AM, Robert Shearman <rshearma@brocade.com>
>>>>
>>>> Fixes: 5405afd1a306 ("fib_trie: Add tracking value for suffix length")
>>>> Signed-off-by: Robert Shearman <rshearma@brocade.com>
>>>
>>>
>>> So I am not entirely convinced this is a regression, I was wondering
>>> what your numbers looked like before the patch you are saying this
>>> fixes?  I recall I fixed a number of issues leading up to this so I am
>>> just curious.
>>
>>
>> At commit 21d1f11db0e2f20a549ad8322879507850544670 ("fib_trie: Remove checks
>> for index >= tnode_child_length from tnode_get_child") which is the parent
>> of 5405afd1a306:
>>
>> $ time sudo ip route restore < ~/allroutes
>> RTNETLINK answers: File exists
>> RTNETLINK answers: File exists
>> RTNETLINK answers: File exists
>> RTNETLINK answers: File exists
>>
>> real    0m3.451s
>> user    0m0.184s
>> sys     0m2.004s
>>
>>
>> At commit 5405afd1a30620de8601436bae739c67c0bc7324 ("fib_trie: Add tracking
>> value for suffix length"):
>>
>> $ time sudo ip route restore < ~/allroutes
>> RTNETLINK answers: File exists
>> RTNETLINK answers: File exists
>> RTNETLINK answers: File exists
>> RTNETLINK answers: File exists
>>
>> real    0m48.624s
>> user    0m0.360s
>> sys     0m46.960s
>>
>> So does that warrant a fixes tag for this patch?
>
> Yes, please include it in the patch description next time.
>
> I've been giving it thought and the fact is the patch series has
> merit.  I just think it was being a bit too aggressive in terms of
> some of the changes.  So placing any changes in put_child seem to be
> the one piece in this that make this a bit ugly.

Does that imply the current updating of the parent's slen value should 
be removed from put_child then?

I started out without doing the changes in put_child, but that meant the 
changes to push the slen up through the trie were spread all over the 
place. This seemed like the cleaner solution.

>>>> +       }
>>>> +}
>>>> +
>>>>  /* Add a child at position i overwriting the old value.
>>>>   * Update the value of full_children and empty_children.
>>>> + *
>>>> + * The suffix length of the parent node and the rest of the tree is
>>>> + * updated (if required) when adding/replacing a node, but is caller's
>>>> + * responsibility on removal.
>>>>   */
>>>>  static void put_child(struct key_vector *tn, unsigned long i,
>>>>                       struct key_vector *n)
>>>> @@ -447,8 +461,8 @@ static void put_child(struct key_vector *tn, unsigned
>>>> long i,
>>>>         else if (!wasfull && isfull)
>>>>                 tn_info(tn)->full_children++;
>>>>
>>>> -       if (n && (tn->slen < n->slen))
>>>> -               tn->slen = n->slen;
>>>> +       if (n)
>>>> +               node_push_suffix(tn, n);
>>>
>>>
>>> This is just creating redundant work if we have to perform a resize.
>>
>>
>> The only real redundant work is the assignment of slen in tn, since the
>> propagation up the trie has to happen regardless and if a subsequent resize
>> results in changes to the trie then the propagation will stop at tn's parent
>> since the suffix length of the tn's parent will not be less than tn's suffix
>> length.
>
>
> This isn't going to work.  We want to avoid trying to push the suffix
> when we place a child.  There are scenarios where we are placing
> children in nodes that don't have parents yet because we are doing
> rebalances and such.  I suspect this could be pretty expensive on a
> resize call.

It's not expensive because the new parents that are being built up are 
orphaned from the rest of the trie, so the push up won't proceed into 
the rest of the trie until the new node is inserted into the trie.

> We want to pull the suffix pushing out of the resize completely.  The
> problem is this is going to cause us to start pushing suffixes for
> every node moved as a part of resize.

This will mean that nodes will have to be visited multiple times, which 
could well be more expensive than doing it during the resize.

>
>>>
>>>>         rcu_assign_pointer(tn->tnode[i], n);
>>>>  }
>>
>> ...
>>
>>>> -static void leaf_pull_suffix(struct key_vector *tp, struct key_vector
>>>> *l)
>>>> +static void node_set_suffix(struct key_vector *tp, unsigned char slen)
>>>>  {
>>>> -       while ((tp->slen > tp->pos) && (tp->slen > l->slen)) {
>>>> -               if (update_suffix(tp) > l->slen)
>>>> +       if (slen > tp->slen)
>>>> +               tp->slen = slen;
>>>> +}
>>>> +
>>>> +static void node_pull_suffix(struct key_vector *tn)
>>>> +{
>>>> +       struct key_vector *tp;
>>>> +       unsigned char slen;
>>>> +
>>>> +       slen = update_suffix(tn);
>>>> +       tp = node_parent(tn);
>>>> +       while ((tp->slen > tp->pos) && (tp->slen > slen)) {
>>>> +               if (update_suffix(tp) > slen)
>>>>                         break;
>>>>                 tp = node_parent(tp);
>>>>         }
>>>>  }
>>>>
>>>
>
> Actually I realized that there is a bug here.  The check for
> update_suffix(tp) > slen can cause us to stop prematurely if I am not
> mistaken.  What we should probably be doing is pulling out tp->slen
> and if the result of update_suffix is the same value then we can break
> the loop.  Otherwise we can stop early if a "second runner up" shows
> up that is supposed to be pushed up the trie.

Excellent point. This also a problem in the existing code when removing 
a fib alias with other aliases still on the leaf. I'll send a separate 
patch for this and base my changes on top of it.

> I actually started around with patches to do much the same as what you
> are doing and I will probably submit them as an RFC so if you need you
> can pick pieces out as needed, or I could submit them if they work for
> you.

I'd be happy to test out any patches you send me.

>>> I really hate all the renaming.  Can't you just leave these as
>>> leaf_pull_suffix and leaf_push _suffix.  I'm fine with us dropping the
>>> leaf of the suffix but the renaming just makes adds a bunch of noise.
>>> Really it might work better if you broke the replacement of the
>>> key_vector as a leaf with the suffix length into a separate patch,
>>> then you could do the rename as a part of that.
>>
>>
>> Ok, I'll leave the naming of leaf_push_suffix alone. Note that
>> leaf_pull_suffix hasn't been renamed, the below in the diff is just an
>> artifact of how diff decided to present the changes along with the moving of
>> leaf_push_suffix.
>
> So I have been looking this over for the last couple days and actually
> I have started to be okay with the renaming.
>
> However I would ask to be consistent.  If you are going to have
> node_pull_suffix and node_push_suffix then just pass a node and a
> suffix length.  You can drop the leaf key vector from both functions
> instead of just one.

Ok, I can do that.

>
>>>
>>>> -static void leaf_push_suffix(struct key_vector *tn, struct key_vector
>>>> *l)
>>>> +static void leaf_pull_suffix(struct key_vector *tp, struct key_vector
>>>> *l)
>>>>  {
>>>> -       /* if this is a new leaf then tn will be NULL and we can sort
>>>> -        * out parent suffix lengths as a part of trie_rebalance
>>>> -        */
>>>> -       while (tn->slen < l->slen) {
>>>> -               tn->slen = l->slen;
>>>> -               tn = node_parent(tn);
>>>> +       while ((tp->slen > tp->pos) && (tp->slen > l->slen)) {
>>>> +               if (update_suffix(tp) > l->slen)
>>>> +                       break;
>>>> +               tp = node_parent(tp);
>>>>         }
>>>>  }
>>>
>>>
>>> If possible it would work better if you could avoid moving functions
>>> around as a result of your changes.
>>
>>
>> Ok, I can add a forward declaration instead.
>
> It shouldn't be necessary.  I think you are doing way too much with
> this patch.  We just need this to be a fix, you are doing a bit too
> much like adding this new node_set_suffix function which isn't really
> needed.

As per your comment below the node_set_suffix function isn't necessary. 
However, I'm not sure exactly what you're suggesting with this patch 
doing too much. Are you saying that you'd like to see a series of 
patches starting with some of the restructuring/renaming of the 
push/pull functions, or are you saying that the sum total is too much?

>>>>
>>>> @@ -1783,6 +1801,16 @@ void fib_table_flush_external(struct fib_table
>>>> *tb)
>>>>                         if (IS_TRIE(pn))
>>>>                                 break;
>>>>
>>>> +                       /* push the suffix length to the parent node,
>>>> +                        * since a previous leaf removal may have
>>>> +                        * caused it to change
>>>> +                        */
>>>> +                       if (pn->slen > pn->pos) {
>>>> +                               unsigned char slen = update_suffix(pn);
>>>> +
>>>> +                               node_set_suffix(node_parent(pn), slen);
>>>> +                       }
>>>> +
>>>
>>>
>>> Why bother with the local variable?  You could just pass
>>> update_suffix(pn) as the parameter to your node_set_suffix function.
>>
>>
>> To avoid a long line on the node_set_suffix call or splitting it across
>> lines, but I'll remove the local variable as you suggest and the same below.
>
> Actually I think there is a bug here.  You shouldn't be setting the
> suffix for the parent based on the child.  You can just call
> update_suffix(pn) and that should be enough.

Yes, you're right. BTW, this logic is transferred from the existing 
resize function and I think what saves us both before and after my 
changes is that the logic is repeated for the parent node which fixes 
the value and so on all the way up the trie.

Thanks,
Rob
