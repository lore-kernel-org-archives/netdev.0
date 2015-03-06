From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 5/9] fib_trie: Add tnode struct as a container
 for fields not needed in key_vector
Date: Fri, 06 Mar 2015 08:13:35 -0800
Message-ID: <54F9D22F.3080701@gmail.com>
References: <20150305224208.1642.34205.stgit@ahduyck-vm-fedora20> <20150305225100.1642.67688.stgit@ahduyck-vm-fedora20> <54F9A8D7.4070304@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:38537 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbbCFQNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 11:13:37 -0500
Received: by pabrd3 with SMTP id rd3so28661034pab.5
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 08:13:36 -0800 (PST)
In-Reply-To: <54F9A8D7.4070304@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2015 05:17 AM, Sergei Shtylyov wrote:
> Hello.
>
> On 3/6/2015 1:51 AM, Alexander Duyck wrote:
>
>> This change pulls the fields not explicitly needed in the key_vector and
>> placed them in the new tnode structure.  By doing this we will
>> eventually
>> be able to reduce the key_vector down to 16 bytes on 64 bit systems, and
>> 12 bytes on 32 bit systems.
>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>> ---
>>   net/ipv4/fib_trie.c |   72
>> ++++++++++++++++++++++++++++-----------------------
>>   1 file changed, 39 insertions(+), 33 deletions(-)
>>
>> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>> index f06c92e..5e1c469 100644
>> --- a/net/ipv4/fib_trie.c
>> +++ b/net/ipv4/fib_trie.c
> [...]
>> @@ -316,48 +320,50 @@ static inline void empty_child_dec(struct
>> key_vector *n)
>>
>>   static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
>>   {
> [...]
>> +    struct tnode *kv = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
>> +    struct key_vector *l = kv->kv;
>> +
>> +    if (!kv)
>
>    You dereference 'kv' before this check.
>
> [...]
>>   static struct key_vector *tnode_new(t_key key, int pos, int bits)
>>   {
>> -    struct key_vector *tn = tnode_alloc(bits);
>> +    struct tnode *tnode = tnode_alloc(bits);
>>       unsigned int shift = pos + bits;
>> +    struct key_vector *tn = tnode->kv;
>>
>>       /* verify bits and pos their msb bits clear and values are
>> valid */
>>       BUG_ON(!bits || (shift > KEYLENGTH));
>>
> [...]
>> +    pr_debug("AT %p s=%zu %zu\n", tnode, TNODE_SIZE(0),
>>            sizeof(struct key_vector *) << bits);
>> +
>> +    if (!tnode)
>
>    Likewise with 'tnode'.
>
> [...]
>
> WBR, Sergei

Actually neither of these are a deference.  The 'kv' member is an array
of size 1, so tnode->kv is actually just adding the offset of the array
to the pointer and storing it.  So if tnode is NULL, then tnode->kv is
NULL + 32 on a 64b system.  It isn't really a dereference until I use
the ->, *, or [] operators on the tn pointer.

- Alex
