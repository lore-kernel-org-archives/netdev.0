From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v2 1/2] bpf: add a longest prefix match trie map
 implementation
Date: Sat, 14 Jan 2017 11:37:59 +0100
Message-ID: <5bbf4088-005d-d9ca-785e-6e4e684b62f9@zonque.org>
References: <20170112172922.16636-1-daniel@zonque.org>
 <20170112172922.16636-2-daniel@zonque.org>
 <20170113180139.GB49247@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: ast@fb.com, dh.herrmann@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, davem@davemloft.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:40482 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751770AbdANKiD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 14 Jan 2017 05:38:03 -0500
In-Reply-To: <20170113180139.GB49247@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2017 07:01 PM, Alexei Starovoitov wrote:
> On Thu, Jan 12, 2017 at 06:29:21PM +0100, Daniel Mack wrote:
>> This trie implements a longest prefix match algorithm that can be used
>> to match IP addresses to a stored set of ranges.
>>
>> Internally, data is stored in an unbalanced trie of nodes that has a
>> maximum height of n, where n is the prefixlen the trie was created
>> with.
>>
>> Tries may be created with prefix lengths that are multiples of 8, in
>> the range from 8 to 2048. The key used for lookup and update operations
>> is a struct bpf_lpm_trie_key, and the value is a uint64_t.
>>
>> The code carries more information about the internal implementation.
>>
>> Signed-off-by: Daniel Mack <daniel@zonque.org>
>> Reviewed-by: David Herrmann <dh.herrmann@gmail.com>
>> ---
>>  include/uapi/linux/bpf.h |   7 +
>>  kernel/bpf/Makefile      |   2 +-
>>  kernel/bpf/lpm_trie.c    | 499 +++++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 507 insertions(+), 1 deletion(-)
>>  create mode 100644 kernel/bpf/lpm_trie.c

...

Thanks for spotting my typos! :)

>> +static struct lpm_trie_node *lpm_trie_node_alloc(const struct lpm_trie *trie,
>> +						 const void *value)
>> +{
>> +	struct lpm_trie_node *node;
>> +	gfp_t gfp = GFP_ATOMIC | __GFP_NOWARN;
>> +
>> +	node = kmalloc(sizeof(struct lpm_trie_node) + trie->data_size, gfp);
>> +	if (!node)
>> +		return ERR_PTR(-ENOMEM);
>> +
>> +	if (value) {
>> +		node->value = kmemdup(value, trie->map.value_size, gfp);
> 
> can you make value to be part of the node? similar to how hash map is done?
> that will help avoid 2nd allocation, will speedup insertion and will
> help converting this code to user pre-allocated elements.
> I suspect the concern was that for many inner nodes that value is null ?
> But in your use case the value_size will be == 0 eventually,
> so by embedding it when can save memory too, since 'value' pointer will
> be replaced with boolean present flag ?
> So potentially less memory and less cache misses?

Yes, that's a good idea. Implemented that now.

> Overall algorithm is indeed straightforward and simple which is great,
> but I would still like to see some performance numbers.

I'm not sure yet how to implement such a test in a meaningful way, tbh.
Given that the lookups have to be done one by one, I expect the syscall
overhead to be quite significant.

> Looks like
> the best case for single 32-bit element it needs 4 xors and compares
> which is fine. For mostly populate trie it's 4xors * 32 depth
> which is pretty good too, but cache misses on pointer walks may
> kill performance unless we're hitting the same path all the time.
> I think it's all acceptable due to simplicity of the implementation
> which we may improve later if it turns out to be a bottle neck for
> some use cases. We just need a baseline to have realistic expectations.

Yes, the maximum height of the trie is the number of bits in the prefix,
so for n bits, the iteration would at most take n steps to finish. For
each step, an xor and compare for n/8 bytes are needed.

As you say, the implementation could be improved under the hood if
someone spots a bottleneck somewhere.

I'll post a v3 with your comments addressed for further discussion.


Thanks,
Daniel
