From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next] bpf: Optimize lpm trie delete
Date: Wed, 20 Sep 2017 14:51:56 -0400
Message-ID: <CAEfhGiy_hC0tCd=5qoPZ1okyMCYsgMQbKAa0ms1Tb9cnYDaLBg@mail.gmail.com>
References: <20170920162247.63787-1-kraigatgoog@gmail.com> <47e47f0d-d04d-b52b-647a-7883aa5f3268@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:50050 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751740AbdITSv7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 14:51:59 -0400
Received: by mail-qt0-f177.google.com with SMTP id o3so2737590qte.6
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 11:51:59 -0700 (PDT)
Received: from mail-qt0-f172.google.com (mail-qt0-f172.google.com. [209.85.216.172])
        by smtp.gmail.com with ESMTPSA id u49sm1813061qta.85.2017.09.20.11.51.57
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 11:51:57 -0700 (PDT)
Received: by mail-qt0-f172.google.com with SMTP id b1so3781409qtc.4
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 11:51:57 -0700 (PDT)
In-Reply-To: <47e47f0d-d04d-b52b-647a-7883aa5f3268@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 12:51 PM, Daniel Mack <daniel@zonque.org> wrote:
> Hi Craig,
>
> Thanks, this looks much cleaner already :)
>
> On 09/20/2017 06:22 PM, Craig Gallek wrote:
>> diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
>> index 9d58a576b2ae..b5a7d70ec8b5 100644
>> --- a/kernel/bpf/lpm_trie.c
>> +++ b/kernel/bpf/lpm_trie.c
>> @@ -397,7 +397,7 @@ static int trie_delete_elem(struct bpf_map *map, void *_key)
>>       struct lpm_trie_node __rcu **trim;
>>       struct lpm_trie_node *node;
>>       unsigned long irq_flags;
>> -     unsigned int next_bit;
>> +     unsigned int next_bit = 0;
>
> This default assignment seems wrong, and I guess you only added it to
> squelch a compiler warning?
Yes, this variable is only initialized after the lookup iterations
below (meaning it will never be initialized the the root-removal
case).

> [...]
>
>> +     /* If the node has one child, we may be able to collapse the tree
>> +      * while removing this node if the node's child is in the same
>> +      * 'next bit' slot as this node was in its parent or if the node
>> +      * itself is the root.
>> +      */
>> +     if (trim == &trie->root) {
>> +             next_bit = node->child[0] ? 0 : 1;
>> +             rcu_assign_pointer(trie->root, node->child[next_bit]);
>> +             kfree_rcu(node, rcu);
>
> I don't think you should treat this 'root' case special.
>
> Instead, move the 'next_bit' assignment outside of the condition ...
I'm not quite sure I follow.  Are you saying do something like this:

if (trim == &trie->root) {
  next_bit = node->child[0] ? 0 : 1;
}
if (rcu_access_pointer(node->child[next_bit])) {
...

This would save a couple lines of code, but I think the as-is
implementation is slightly easier to understand.  I don't have a
strong opinion either way, though.

Thanks for the pointers,
Craig
