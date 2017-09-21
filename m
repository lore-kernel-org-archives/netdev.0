From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next] bpf: Optimize lpm trie delete
Date: Thu, 21 Sep 2017 09:13:21 -0400
Message-ID: <CAEfhGiwLd0rj47HiecMSf3SKGVAS3Xyjvytjoh5K5+zviN8dxw@mail.gmail.com>
References: <20170920162247.63787-1-kraigatgoog@gmail.com> <47e47f0d-d04d-b52b-647a-7883aa5f3268@zonque.org>
 <CAEfhGiy_hC0tCd=5qoPZ1okyMCYsgMQbKAa0ms1Tb9cnYDaLBg@mail.gmail.com> <dc09f044-be69-a2a9-bf77-331ce558eee9@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:54730 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdIUNNY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 09:13:24 -0400
Received: by mail-qt0-f175.google.com with SMTP id i13so5822118qtc.11
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 06:13:24 -0700 (PDT)
Received: from mail-qt0-f171.google.com (mail-qt0-f171.google.com. [209.85.216.171])
        by smtp.gmail.com with ESMTPSA id q51sm975718qtk.18.2017.09.21.06.13.22
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 06:13:22 -0700 (PDT)
Received: by mail-qt0-f171.google.com with SMTP id l25so5807491qtf.13
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 06:13:22 -0700 (PDT)
In-Reply-To: <dc09f044-be69-a2a9-bf77-331ce558eee9@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 6:56 PM, Daniel Mack <daniel@zonque.org> wrote:
> On 09/20/2017 08:51 PM, Craig Gallek wrote:
>> On Wed, Sep 20, 2017 at 12:51 PM, Daniel Mack <daniel@zonque.org> wrote:
>>> Hi Craig,
>>>
>>> Thanks, this looks much cleaner already :)
>>>
>>> On 09/20/2017 06:22 PM, Craig Gallek wrote:
>>>> diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
>>>> index 9d58a576b2ae..b5a7d70ec8b5 100644
>>>> --- a/kernel/bpf/lpm_trie.c
>>>> +++ b/kernel/bpf/lpm_trie.c
>>>> @@ -397,7 +397,7 @@ static int trie_delete_elem(struct bpf_map *map, void *_key)
>>>>       struct lpm_trie_node __rcu **trim;
>>>>       struct lpm_trie_node *node;
>>>>       unsigned long irq_flags;
>>>> -     unsigned int next_bit;
>>>> +     unsigned int next_bit = 0;
>>>
>>> This default assignment seems wrong, and I guess you only added it to
>>> squelch a compiler warning?
>> Yes, this variable is only initialized after the lookup iterations
>> below (meaning it will never be initialized the the root-removal
>> case).
>
> Right, and once set, it's only updated in case we don't have an exact
> match and try to drill down further.
>
>>> [...]
>>>
>>>> +     /* If the node has one child, we may be able to collapse the tree
>>>> +      * while removing this node if the node's child is in the same
>>>> +      * 'next bit' slot as this node was in its parent or if the node
>>>> +      * itself is the root.
>>>> +      */
>>>> +     if (trim == &trie->root) {
>>>> +             next_bit = node->child[0] ? 0 : 1;
>>>> +             rcu_assign_pointer(trie->root, node->child[next_bit]);
>>>> +             kfree_rcu(node, rcu);
>>>
>>> I don't think you should treat this 'root' case special.
>>>
>>> Instead, move the 'next_bit' assignment outside of the condition ...
>> I'm not quite sure I follow.  Are you saying do something like this:
>>
>> if (trim == &trie->root) {
>>   next_bit = node->child[0] ? 0 : 1;
>> }
>> if (rcu_access_pointer(node->child[next_bit])) {
>> ...
>>
>> This would save a couple lines of code, but I think the as-is
>> implementation is slightly easier to understand.  I don't have a
>> strong opinion either way, though.
>
> Me neither :)
>
> My idea was to set
>
>   next_bit = node->child[0] ? 0 : 1;
>
> unconditionally, because it should result in the same in both cases.
>
> It might be a bit of bike shedding, but I dislike this default
> assignment, and I believe that not relying on next_bit to be set as a
> side effect of the lookup loop makes the code a bit more readable.
>
> WDYT?
That sounds reasonable.  I'll spin a v2 today if no one else has any comments.

Thanks again,
Craig
