From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] fib_trie: flush improvement
Date: Wed, 02 Apr 2008 21:36:17 +0200
Message-ID: <47F3E031.1030806@cosmosbay.com>
References: <20080401172702.094c0700@extreme>	<47F33D42.9080302@cosmosbay.com>	<47F39998.8040605@cosmosbay.com> <20080402110335.66b04181@extreme>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020900000509030802050604"
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:48576
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756881AbYDBThI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 15:37:08 -0400
In-Reply-To: <20080402110335.66b04181@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020900000509030802050604
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Stephen Hemminger a écrit :
> On Wed, 02 Apr 2008 16:35:04 +0200
> Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
>> Eric Dumazet a écrit :
>>> Stephen Hemminger a écrit :
>>>> This is an attempt to fix the problem described in:
>>>>      http://bugzilla.kernel.org/show_bug.cgi?id=6648
>>>> I can reproduce this by loading lots and lots of routes and the taking
>>>> the interface down. This causes all entries in trie to be flushed, but
>>>> each leaf removal causes a rebalance of the trie. And since the removal
>>>> is depth first, it creates lots of needless work.
>>>>
>>>> Instead on flush, just walk the trie and prune as we go.
>>>> The implementation is for description only, it probably doesn't work 
>>>> yet.
>>>>
>>>>   
>>> I dont get it, since the bug reporter mentions with recent kernels :
>>>
>>> Fix inflate_threshold_root. Now=15 size=11 bits
>>>
>>> Is it what you get with your tests ?
>>>
>>> Pawel reports :
>>>
>>> cat /proc/net/fib_triestat
>>> Main: Aver depth: 2.26 Max depth: 6 Leaves: 235924
>>> Internal nodes: 57854 1: 31632 2: 11422 3: 8475 4: 3755 5: 1676 6: 893 
>>> 18: 1
>>>
>>> Pointers: 609760 Null ptrs: 315983 Total size: 16240 kB
>>>
>>> warning messages comes from rootnode that cannot be expanded, since it 
>>> hits MAX_ORDER (on a 32bit x86)
>>>
>>>
>>>
>>> (sizeof(struct tnode) + (sizeof(struct node *) << bits);) is rounded 
>>> to 4 << (bit + 1), ie 2 << 20
>>>
>>> For larger allocations Pawel has two choices :
>>>
>>> change MAX_ORDER from 11 to 13 or 14
>>> If this machine is a pure router, this change wont have performance 
>>> impact.
>>>
>>> Or (more difficult, but more appropriate for mainline) change 
>>> fib_trie.c to use vmalloc() for very big allocaions (for the root 
>>> only), and vfree()
>>>
>>> Since vfree() cannot be called from rcu callback, one has to setup a 
>>> struct work_struct helper.
>>>
>> Here is a patch (untested unfortunatly) to implement this.
>>
>> [IPV4] fib_trie: root_tnode can benefit of vmalloc()
>>
>> FIB_TRIE root node can be very large and currently hits MAX_ORDER limit.
>> It also wastes about 50% of allocated size, because of power of two 
>> rounding of tnode.
>>
>> A switch to vmalloc() can improve FIB_TRIE performance by allowing root 
>> node to grow
>> past the alloc_pages() limit, while preserving memory.
>>
>> Special care must be taken to free such zone, as rcu handler is not 
>> allowed to call vfree(),
>> we use a worker instead.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>
>>
> 
> Rather than switching between three allocation strategies, I would rather
> just have kmalloc and vmalloc.

Yes, probably :)

[IPV4] fib_trie: root_tnode can benefit of vmalloc()

FIB_TRIE root node can be very large and currently hits MAX_ORDER limit.
It also wastes about 50% of allocated size, because of power of two
rounding of tnode.

A switch to vmalloc() can improve FIB_TRIE performance by allowing root
node to grow past the alloc_pages() limit, while preserving memory.

Special care must be taken to free such zone, as rcu handler is not
allowed to call vfree(), we use a worker instead.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------020900000509030802050604
Content-Type: text/plain;
 name="trie_vmalloc.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="trie_vmalloc.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L2ZpYl90cmllLmMgYi9uZXQvaXB2NC9maWJfdHJpZS5j
CmluZGV4IDllNDkxZTcuLmM3ZDdkOWUgMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L2ZpYl90cmll
LmMKKysrIGIvbmV0L2lwdjQvZmliX3RyaWUuYwpAQCAtMTIyLDcgKzEyMiwxMCBAQCBzdHJ1
Y3QgdG5vZGUgewogCXVuc2lnbmVkIGNoYXIgYml0czsJCS8qIDJsb2coS0VZTEVOR1RIKSBi
aXRzIG5lZWRlZCAqLwogCXVuc2lnbmVkIGludCBmdWxsX2NoaWxkcmVuOwkvKiBLRVlMRU5H
VEggYml0cyBuZWVkZWQgKi8KIAl1bnNpZ25lZCBpbnQgZW1wdHlfY2hpbGRyZW47CS8qIEtF
WUxFTkdUSCBiaXRzIG5lZWRlZCAqLwotCXN0cnVjdCByY3VfaGVhZCByY3U7CisJdW5pb24g
eworCQlzdHJ1Y3QgcmN1X2hlYWQgcmN1OworCQlzdHJ1Y3QgdG5vZGUgKm5leHQ7CisJfTsK
IAlzdHJ1Y3Qgbm9kZSAqY2hpbGRbMF07CiB9OwogCkBAIC0zNDYsMTggKzM0OSwxNyBAQCBz
dGF0aWMgaW5saW5lIHZvaWQgZnJlZV9sZWFmX2luZm8oc3RydWN0IGxlYWZfaW5mbyAqbGVh
ZikKIAogc3RhdGljIHN0cnVjdCB0bm9kZSAqdG5vZGVfYWxsb2Moc2l6ZV90IHNpemUpCiB7
Ci0Jc3RydWN0IHBhZ2UgKnBhZ2VzOwotCiAJaWYgKHNpemUgPD0gUEFHRV9TSVpFKQogCQly
ZXR1cm4ga3phbGxvYyhzaXplLCBHRlBfS0VSTkVMKTsKIAotCXBhZ2VzID0gYWxsb2NfcGFn
ZXMoR0ZQX0tFUk5FTHxfX0dGUF9aRVJPLCBnZXRfb3JkZXIoc2l6ZSkpOwotCWlmICghcGFn
ZXMpCi0JCXJldHVybiBOVUxMOwotCi0JcmV0dXJuIHBhZ2VfYWRkcmVzcyhwYWdlcyk7CisJ
cmV0dXJuIF9fdm1hbGxvYyhzaXplLCBHRlBfS0VSTkVMIHwgX19HRlBfWkVSTywgUEFHRV9L
RVJORUwpOwogfQogCitzdGF0aWMgdm9pZCBmYl93b3JrZXJfZnVuYyhzdHJ1Y3Qgd29ya19z
dHJ1Y3QgKndvcmspOworc3RhdGljIERFQ0xBUkVfV09SSyhmYl92ZnJlZV93b3JrLCBmYl93
b3JrZXJfZnVuYyk7CitzdGF0aWMgREVGSU5FX1NQSU5MT0NLKGZiX3ZmcmVlX2xvY2spOwor
c3RhdGljIHN0cnVjdCB0bm9kZSAqZmJfdmZyZWVfbGlzdDsKKwogc3RhdGljIHZvaWQgX190
bm9kZV9mcmVlX3JjdShzdHJ1Y3QgcmN1X2hlYWQgKmhlYWQpCiB7CiAJc3RydWN0IHRub2Rl
ICp0biA9IGNvbnRhaW5lcl9vZihoZWFkLCBzdHJ1Y3QgdG5vZGUsIHJjdSk7CkBAIC0zNjYs
OCArMzY4LDI4IEBAIHN0YXRpYyB2b2lkIF9fdG5vZGVfZnJlZV9yY3Uoc3RydWN0IHJjdV9o
ZWFkICpoZWFkKQogCiAJaWYgKHNpemUgPD0gUEFHRV9TSVpFKQogCQlrZnJlZSh0bik7Ci0J
ZWxzZQotCQlmcmVlX3BhZ2VzKCh1bnNpZ25lZCBsb25nKXRuLCBnZXRfb3JkZXIoc2l6ZSkp
OworCWVsc2UgeworCQlzcGluX2xvY2soJmZiX3ZmcmVlX2xvY2spOworCQl0bi0+bmV4dCA9
IGZiX3ZmcmVlX2xpc3Q7CisJCWZiX3ZmcmVlX2xpc3QgPSB0bjsKKwkJc2NoZWR1bGVfd29y
aygmZmJfdmZyZWVfd29yayk7CisJCXNwaW5fdW5sb2NrKCZmYl92ZnJlZV9sb2NrKTsKKwl9
Cit9CisKK3N0YXRpYyB2b2lkIGZiX3dvcmtlcl9mdW5jKHN0cnVjdCB3b3JrX3N0cnVjdCAq
d29yaykKK3sKKwlzdHJ1Y3QgdG5vZGUgKnRuLCAqbmV4dDsKKworCXNwaW5fbG9ja19iaCgm
ZmJfdmZyZWVfbG9jayk7CisJdG4gPSBmYl92ZnJlZV9saXN0OworCWZiX3ZmcmVlX2xpc3Qg
PSBOVUxMOworCXNwaW5fdW5sb2NrX2JoKCZmYl92ZnJlZV9sb2NrKTsKKwl3aGlsZSAodG4p
IHsKKwkJbmV4dCA9IHRuLT5uZXh0OworCQl2ZnJlZSh0bik7CisJCXRuID0gbmV4dDsKKwl9
CiB9CiAKIHN0YXRpYyBpbmxpbmUgdm9pZCB0bm9kZV9mcmVlKHN0cnVjdCB0bm9kZSAqdG4p
Cg==
--------------020900000509030802050604--
