From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH net-next 1/3] bpf: Implement map_delete_elem for
 BPF_MAP_TYPE_LPM_TRIE
Date: Tue, 19 Sep 2017 21:48:16 +0200
Message-ID: <910eaafa-57a1-2a22-709e-a9107b108d9d@zonque.org>
References: <20170918193057.37644-1-kraigatgoog@gmail.com>
 <20170918193057.37644-2-kraigatgoog@gmail.com>
 <3e537b56-d0f2-de9a-5bb1-f60fbfc11ca5@fb.com>
 <CAEfhGixLCqEmR=bwBqC6bT=-j22X5+rSScPb=1qWX3F-mi6H3g@mail.gmail.com>
 <59C141DC.9060200@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Craig Gallek <kraigatgoog@gmail.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bugwerft.de ([46.23.86.59]:50854 "EHLO mail.bugwerft.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751556AbdIST5K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 15:57:10 -0400
In-Reply-To: <59C141DC.9060200@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thanks for working on this, Craig!

On 09/19/2017 06:12 PM, Daniel Borkmann wrote:
> On 09/19/2017 05:08 PM, Craig Gallek wrote:
>> On Mon, Sep 18, 2017 at 6:53 PM, Alexei Starovoitov <ast@fb.com> wrote:
>>> On 9/18/17 12:30 PM, Craig Gallek wrote:
> [...]
>>>> +
>>>> +               next_bit = extract_bit(key->data, node->prefixlen);
>>>> +               /* If we hit a node that has more than one child or is a
>>>> valid
>>>> +                * prefix itself, do not remove it. Reset the root of the
>>>> trim
>>>> +                * path to its descendant on our path.
>>>> +                */
>>>> +               if (!(node->flags & LPM_TREE_NODE_FLAG_IM) ||
>>>> +                   (node->child[0] && node->child[1]))
>>>> +                       trim = &node->child[next_bit];
>>>> +               node = rcu_dereference_protected(
>>>> +                       node->child[next_bit],
>>>> lockdep_is_held(&trie->lock));
>>>> +       }
>>>> +
>>>> +       if (!node || node->prefixlen != key->prefixlen ||
>>>> +           (node->flags & LPM_TREE_NODE_FLAG_IM)) {
>>>> +               ret = -ENOENT;
>>>> +               goto out;
>>>> +       }
>>>> +
>>>> +       trie->n_entries--;
>>>> +
>>>> +       /* If the node we are removing is not a leaf node, simply mark it
>>>> +        * as intermediate and we are done.
>>>> +        */
>>>> +       if (rcu_access_pointer(node->child[0]) ||
>>>> +           rcu_access_pointer(node->child[1])) {
>>>> +               node->flags |= LPM_TREE_NODE_FLAG_IM;
>>>> +               goto out;
>>>> +       }
>>>> +
>>>> +       /* trim should now point to the slot holding the start of a path
>>>> from
>>>> +        * zero or more intermediate nodes to our leaf node for deletion.
>>>> +        */
>>>> +       while ((node = rcu_dereference_protected(
>>>> +                       *trim, lockdep_is_held(&trie->lock)))) {
>>>> +               RCU_INIT_POINTER(*trim, NULL);
>>>> +               trim = rcu_access_pointer(node->child[0]) ?
>>>> +                       &node->child[0] :
>>>> +                       &node->child[1];
>>>> +               kfree_rcu(node, rcu);
>>>
>>> can it be that some of the nodes this loop walks have
>>> both child[0] and [1] ?
>> No, the loop above will push trim down the walk every time it
>> encounters a node with two children.  The only other trim assignment
>> is the initial trim = &trie->root.  But the only time we would skip
>> the assignment in the loop is if the node being removed is the root.
>> If the root had multiple children and is being removed, it would be
>> handled by the case that turns the node into an intermediate node
>> rather than walking the trim path freeing things.
> 
> Looks good to me. We should probably still merge nodes once we turn
> a real node into an im which just has a single child attached to it;
> parent can be im or real node. Thus, we don't need to traverse this
> extra one on lookup.

Right, but only if the the parent of the node allows us to do that,
because the 'next bit' in the lookup key has to match the slot index.

To illustrate, consider the following trie with no IM nodes:

                      +----------------+
                      |       (1)  (R) |
                      | 192.168.0.0/16 |
                      |    value: 1    |
                      |   [0]    [1]   |
                      +----------------+
                           |      |
            +----------------+  +------------------+
            |       (2)      |  |        (3)       |
            | 192.168.0.0/23 |  | 192.168.128.0/24 |
            |    value: 2    |  |     value: 3     |
            |   [0]    [1]   |  |    [0]    [1]    |
            +----------------+  +------------------+
                        |
                      +----------------+
                      |       (4)      |
                      | 192.168.1.0/24 |
                      |     value: 4   |
                      |   [0]    [1]   |
                      +----------------+

If you now try to delete (2), the node has to stay around because (3)
and (4) share the same value in bit 17 (1). If, however, (4) had a
prefix of 192.168.0.0/24, then (2) should be removed completely, and (4)
should be directly attached to (1) as child[0].

With this implementation, a situation in which multiple IM nodes appear
in a chain cannot emerge. And that again should make your trimming
algorithm simpler, because you only need to find an exact match, and
then handle three distinct cases:

a) the node as 0 children: simply remove it and nullify the pointer in
the parent

b) the node has 1 child: apply logic I described above

c) the node has 2 children: turn the node into an IM


Makes sense?


Thanks,
Daniel
