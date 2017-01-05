From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v1 1/2] bpf: add a longest prefix match trie map implementation
Date: Thu, 05 Jan 2017 21:20:22 +0100
Message-ID: <586EAA86.6030608@iogearbox.net>
References: <20161229172855.14910-1-daniel@zonque.org> <20161229172855.14910-2-daniel@zonque.org> <586E7366.1010708@iogearbox.net> <91fbf150-4e97-7400-90cf-dbe7ea3e6597@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dh.herrmann@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Mack <daniel@zonque.org>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56819 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934022AbdAEUU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 15:20:27 -0500
In-Reply-To: <91fbf150-4e97-7400-90cf-dbe7ea3e6597@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On 01/05/2017 09:04 PM, Daniel Mack wrote:
> On 01/05/2017 05:25 PM, Daniel Borkmann wrote:
>> On 12/29/2016 06:28 PM, Daniel Mack wrote:
>
>>> diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
>>> new file mode 100644
>>> index 0000000..8b6a61d
>>> --- /dev/null
>>> +++ b/kernel/bpf/lpm_trie.c
>
> [..]
>
>>> +static struct bpf_map *trie_alloc(union bpf_attr *attr)
>>> +{
>>> +	struct lpm_trie *trie;
>>> +
>>> +	/* check sanity of attributes */
>>> +	if (attr->max_entries == 0 || attr->map_flags ||
>>> +	    attr->key_size < sizeof(struct bpf_lpm_trie_key) + 1   ||
>>> +	    attr->key_size > sizeof(struct bpf_lpm_trie_key) + 256 ||
>>> +	    attr->value_size != sizeof(u64))
>>> +		return ERR_PTR(-EINVAL);
>>
>> The correct attr->map_flags test here would need to be ...
>>
>>     attr->map_flags != BPF_F_NO_PREALLOC
>>
>> ... since in this case we don't have any prealloc pool, and
>> should that come one day that test could be relaxed again.
>>
>>> +	trie = kzalloc(sizeof(*trie), GFP_USER | __GFP_NOWARN);
>>> +	if (!trie)
>>> +		return NULL;
>>> +
>>> +	/* copy mandatory map attributes */
>>> +	trie->map.map_type = attr->map_type;
>>> +	trie->map.key_size = attr->key_size;
>>> +	trie->map.value_size = attr->value_size;
>>> +	trie->map.max_entries = attr->max_entries;
>>
>> You also need to fill in trie->map.pages as that is eventually
>> used to charge memory against in bpf_map_charge_memlock(), right
>> now that would remain as 0 meaning the map is not accounted for.
>
> Hmm, okay. The nodes are, however, allocated dynamically at runtime in
> this case. That means that we have trie->map.pages on each allocation,
> right?

The current scheme (f.e. htab_map_alloc() has some details, although
probably not too obvious) that was done charges worst-case cost up front,
so it would be in trie_alloc() where you fill map.pages and map_create()
will later account for them.

Thanks,
Daniel
