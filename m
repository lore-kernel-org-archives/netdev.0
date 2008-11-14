From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: make sure struct dst_entry refcount is aligned on 64
 bytes
Date: Fri, 14 Nov 2008 11:47:01 +0100
Message-ID: <491D5725.50006@cosmosbay.com>
References: <491D323B.9030802@cosmosbay.com> <20081114.005437.09284570.davem@davemloft.net> <491D3F18.5030505@cosmosbay.com> <20081114093613.GA2834@x200.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060108070003070803090909"
Cc: Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	shemminger@vyatta.com,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:53415 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbYKNKrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 05:47:13 -0500
In-Reply-To: <20081114093613.GA2834@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060108070003070803090909
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Alexey Dobriyan a =E9crit :
> On Fri, Nov 14, 2008 at 10:04:24AM +0100, Eric Dumazet wrote:
>> David Miller a =E9crit :
>>> From: Eric Dumazet <dada1@cosmosbay.com>
>>> Date: Fri, 14 Nov 2008 09:09:31 +0100
>>>
>>>> During tbench/oprofile sessions, I found that dst_release() was in t=
hird position.
>>>  ...
>>>> Instead of first checking the refcount value, then decrement it,
>>>> we use atomic_dec_return() to help CPU to make the right memory tran=
saction
>>>> (ie getting the cache line in exclusive mode)
>>>  ...
>>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>> This looks great, applied, thanks Eric.
>>>
>> Thanks David
>>
>>
>> I think I understood some regressions here on 32bits=20
>>
>> offsetof(struct dst_entry, __refcnt) is 0x7c again !!!
>>
>> This is really really bad for performance
>>
>> I believe this comes from a patch from Alexey Dobriyan
>> (commit def8b4faff5ca349beafbbfeb2c51f3602a6ef3a
>> net: reduce structures when XFRM=3Dn)
>=20
> Ick.

Well, your patch is a good thing, we only need to make adjustments.

>=20
>> This kills effort from Zhang Yanmin (and me...)
>>
>> (commit f1dd9c379cac7d5a76259e7dffcd5f8edc697d17
>> [NET]: Fix tbench regression in 2.6.25-rc1)
>>
>>
>> Really we must find something so that this damned __refcnt is starting=
 at 0x80
>=20
> Make it last member?

Yes, it will help tbench, but not machines that stress IP route cache

(dst_use() must dirty the three fields "refcnt, __use , lastuse" )

Also, 'next' pointer should be in the same cache line, to speedup route
cache lookups.

Next problem is that offsets depend on architecture being 32 or 64 bits.

On 64bit, offsetof(struct dst_entry, __refcnt) is 0xb0 : not very good...=



[PATCH] net: make sure struct dst_entry refcount is aligned on 64 bytes

As found in the past (commit f1dd9c379cac7d5a76259e7dffcd5f8edc697d17
[NET]: Fix tbench regression in 2.6.25-rc1), it is really
important that struct dst_entry refcount is aligned on a cache line.

We cannot use __atribute((aligned)), so manually pad the structure
for 32 and 64 bit arches.

for 32bit : offsetof(truct dst_entry, __refcnt) is 0x80
for 64bit : offsetof(truct dst_entry, __refcnt) is 0xc0

As it is not possible to guess at compile time cache line size,
we use a generic value of 64 bytes, that satisfies many current arches.
(Using 128 bytes alignment on 64bit arches would waste 64 bytes)

Add a BUILD_BUG_ON to catch future updates to "struct dst_entry" dont
break this alignment.

"tbench 8" is 4.4 % faster on a dual quad core (HP BL460c G1), Intel E545=
0 @3.00GHz
(2350 MB/s instead of 2250 MB/s)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/dst.h |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+)

--------------060108070003070803090909
Content-Type: text/plain;
 name="dst_align.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dst_align.patch"

diff --git a/include/net/dst.h b/include/net/dst.h
index 65a60fa..6c77879 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -61,6 +61,8 @@ struct dst_entry
 	struct hh_cache		*hh;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
+#else
+	void			*__pad1;
 #endif
 	int			(*input)(struct sk_buff*);
 	int			(*output)(struct sk_buff*);
@@ -71,8 +73,20 @@ struct dst_entry
 
 #ifdef CONFIG_NET_CLS_ROUTE
 	__u32			tclassid;
+#else
+	__u32			__pad2;
 #endif
 
+
+	/*
+	 * Align __refcnt to a 64 bytes alignment
+	 * (L1_CACHE_SIZE would be too much)
+	 */
+#ifdef CONFIG_64BIT
+	long			__pad_to_align_refcnt[2];
+#else
+	long			__pad_to_align_refcnt[1];
+#endif
 	/*
 	 * __refcnt wants to be on a different cache line from
 	 * input/output/ops or performance tanks badly
@@ -157,6 +171,11 @@ dst_metric_locked(struct dst_entry *dst, int metric)
 
 static inline void dst_hold(struct dst_entry * dst)
 {
+	/*
+	 * If your kernel compilation stops here, please check
+	 * __pad_to_align_refcnt declaration in struct dst_entry
+	 */
+	BUILD_BUG_ON(offsetof(struct dst_entry, __refcnt) & 63);
 	atomic_inc(&dst->__refcnt);
 }
 

--------------060108070003070803090909--
