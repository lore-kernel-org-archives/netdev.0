From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Kernel panic nf_nat_setup_info+0x5b3/0x6e0
Date: Thu, 3 Mar 2011 15:33:31 +0800
Message-ID: <AANLkTik87dd0=CqcMOcwKN-Hx7W6KD7A36DUhGAzLddr@mail.gmail.com>
References: <118081298480841@web25.yandex.ru> <4D6E2BEB.50805@trash.net>
 <AANLkTikkz23221ZSiat8N5tnE_bkHN=1EUNQTDdnC30L@mail.gmail.com> <124481299095426@web67.yandex.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf304341f8076ed4049d8f0de5
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: "Oleg A. Arkhangelsky" <sysoleg@yandex.ru>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <124481299095426@web67.yandex.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--20cf304341f8076ed4049d8f0de5
Content-Type: text/plain; charset=KOI8-R

On Thu, Mar 3, 2011 at 3:50 AM, "Oleg A. Arkhangelsky"
<sysoleg@yandex.ru> wrote:
> 02.03.2011, 17:37, "Changli Gao" <xiaosuo@gmail.com>:
>
>> t should be NULL here, as offsetof(struct nf_conn, dst.protonum) == 0x36.
>> We should free the nf_ct_extend with call_rcu(), since nat ext is
>> referenced in the rcu read context.
>
> Yes, I think the problem is triggered when nf_conntrack_free() is called by
> different CPU during net->ipv4.nat_bysource hash traversal. Extensions
> framework doesn't have any SLAB_DESTROY_BY_RCU magic.
>
> I'm not sure, but couldn't this problem be introduced by:
>
> ea781f197d6a835cbb93a0bf88ee1696296ed8aa
> netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid of call_rcu()
>
> ?
>

There is nothing to do with SLAB_DESTROY_BY_RCU. Here is the comment
for this flag:

/*
 * SLAB_DESTROY_BY_RCU - **WARNING** READ THIS!
 *
 * This delays freeing the SLAB page by a grace period, it does _NOT_
 * delay object freeing. This means that if you do kmem_cache_free()
 * that memory location is free to be reused at any time. Thus it may
 * be possible to see another object there in the same RCU grace period.
 *
 * This feature only ensures the memory location backing the object
 * stays valid, the trick to using this is relying on an independent
 * object validation pass. Something like:
...

Please try the patch attached and test if the problem is solved or not. Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)

--20cf304341f8076ed4049d8f0de5
Content-Type: text/plain; charset=US-ASCII; name="nf_ext_rcu.diff"
Content-Disposition: attachment; filename="nf_ext_rcu.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gktd48in0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L25ldGZpbHRlci9uZl9jb25udHJhY2tfZXh0ZW5kLmgg
Yi9pbmNsdWRlL25ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNrX2V4dGVuZC5oCmluZGV4IDJkY2Yz
MTcuLjM1NGNjY2I5IDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC9uZXRmaWx0ZXIvbmZfY29ubnRy
YWNrX2V4dGVuZC5oCisrKyBiL2luY2x1ZGUvbmV0L25ldGZpbHRlci9uZl9jb25udHJhY2tfZXh0
ZW5kLmgKQEAgLTY2LDEzICs2NiwxNSBAQCBzdGF0aWMgaW5saW5lIHZvaWQgbmZfY3RfZXh0X2Rl
c3Ryb3koc3RydWN0IG5mX2Nvbm4gKmN0KQogCQlfX25mX2N0X2V4dF9kZXN0cm95KGN0KTsKIH0K
IAordm9pZCBfX25mX2N0X2V4dF9mcmVlX3JjdShzdHJ1Y3QgcmN1X2hlYWQgKmhlYWQpOworCiAv
KiBGcmVlIG9wZXJhdGlvbi4gSWYgeW91IHdhbnQgdG8gZnJlZSBhIG9iamVjdCByZWZlcnJlZCBm
cm9tIHByaXZhdGUgYXJlYSwKICAqIHBsZWFzZSBpbXBsZW1lbnQgX19uZl9jdF9leHRfZnJlZSgp
IGFuZCBjYWxsIGl0LgogICovCiBzdGF0aWMgaW5saW5lIHZvaWQgbmZfY3RfZXh0X2ZyZWUoc3Ry
dWN0IG5mX2Nvbm4gKmN0KQogewogCWlmIChjdC0+ZXh0KQotCQlrZnJlZShjdC0+ZXh0KTsKKwkJ
Y2FsbF9yY3UoJmN0LT5leHQtPnJjdSwgX19uZl9jdF9leHRfZnJlZV9yY3UpOwogfQogCiAvKiBB
ZGQgdGhpcyB0eXBlLCByZXR1cm5zIHBvaW50ZXIgdG8gZGF0YSBvciBOVUxMLiAqLwpkaWZmIC0t
Z2l0IGEvbmV0L25ldGZpbHRlci9uZl9jb25udHJhY2tfZXh0ZW5kLmMgYi9uZXQvbmV0ZmlsdGVy
L25mX2Nvbm50cmFja19leHRlbmQuYwppbmRleCA4MGEyM2VkLi4zYTQ3Yjc2IDEwMDY0NAotLS0g
YS9uZXQvbmV0ZmlsdGVyL25mX2Nvbm50cmFja19leHRlbmQuYworKysgYi9uZXQvbmV0ZmlsdGVy
L25mX2Nvbm50cmFja19leHRlbmQuYwpAQCAtNjgsMTEgKzY4LDEyIEBAIG5mX2N0X2V4dF9jcmVh
dGUoc3RydWN0IG5mX2N0X2V4dCAqKmV4dCwgZW51bSBuZl9jdF9leHRfaWQgaWQsIGdmcF90IGdm
cCkKIAlyZXR1cm4gKHZvaWQgKikoKmV4dCkgKyBvZmY7CiB9CiAKLXN0YXRpYyB2b2lkIF9fbmZf
Y3RfZXh0X2ZyZWVfcmN1KHN0cnVjdCByY3VfaGVhZCAqaGVhZCkKK3ZvaWQgX19uZl9jdF9leHRf
ZnJlZV9yY3Uoc3RydWN0IHJjdV9oZWFkICpoZWFkKQogewogCXN0cnVjdCBuZl9jdF9leHQgKmV4
dCA9IGNvbnRhaW5lcl9vZihoZWFkLCBzdHJ1Y3QgbmZfY3RfZXh0LCByY3UpOwogCWtmcmVlKGV4
dCk7CiB9CitFWFBPUlRfU1lNQk9MX0dQTChfX25mX2N0X2V4dF9mcmVlX3JjdSk7CiAKIHZvaWQg
Kl9fbmZfY3RfZXh0X2FkZChzdHJ1Y3QgbmZfY29ubiAqY3QsIGVudW0gbmZfY3RfZXh0X2lkIGlk
LCBnZnBfdCBnZnApCiB7Cg==
--20cf304341f8076ed4049d8f0de5--
