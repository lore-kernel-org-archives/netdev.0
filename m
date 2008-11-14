From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: make sure struct dst_entry refcount is aligned on
	64 bytes
Date: Fri, 14 Nov 2008 16:22:30 +0300
Message-ID: <20081114132230.GA27462@x200.localdomain>
References: <491D323B.9030802@cosmosbay.com> <20081114.005437.09284570.davem@davemloft.net> <491D3F18.5030505@cosmosbay.com> <20081114093613.GA2834@x200.localdomain> <491D5725.50006@cosmosbay.com> <20081114113558.GA9692@x200.localdomain> <491D644A.4040309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:40544 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbYKNNTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 08:19:01 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1637513ugf.37
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 05:18:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <491D644A.4040309@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2008 at 12:43:06PM +0100, Eric Dumazet wrote:
> Alexey Dobriyan a =E9crit :
>> On Fri, Nov 14, 2008 at 11:47:01AM +0100, Eric Dumazet wrote:
>>> Alexey Dobriyan a =E9crit :
>>>> On Fri, Nov 14, 2008 at 10:04:24AM +0100, Eric Dumazet wrote:
>>>>> David Miller a =E9crit :
>>>>>> From: Eric Dumazet <dada1@cosmosbay.com>
>>>>>> Date: Fri, 14 Nov 2008 09:09:31 +0100
>>>>>>
>>>>>>> During tbench/oprofile sessions, I found that dst_release() was=
 in third position.
>>>>>>  ...
>>>>>>> Instead of first checking the refcount value, then decrement it=
,
>>>>>>> we use atomic_dec_return() to help CPU to make the right memory=
 transaction
>>>>>>> (ie getting the cache line in exclusive mode)
>>>>>>  ...
>>>>>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>>>>> This looks great, applied, thanks Eric.
>>>>>>
>>>>> Thanks David
>>>>>
>>>>>
>>>>> I think I understood some regressions here on 32bits=20
>>>>>
>>>>> offsetof(struct dst_entry, __refcnt) is 0x7c again !!!
>>>>>
>>>>> This is really really bad for performance
>>>>>
>>>>> I believe this comes from a patch from Alexey Dobriyan
>>>>> (commit def8b4faff5ca349beafbbfeb2c51f3602a6ef3a
>>>>> net: reduce structures when XFRM=3Dn)
>>>> Ick.
>>> Well, your patch is a good thing, we only need to make adjustments.
>>>
>>>>> This kills effort from Zhang Yanmin (and me...)
>>>>>
>>>>> (commit f1dd9c379cac7d5a76259e7dffcd5f8edc697d17
>>>>> [NET]: Fix tbench regression in 2.6.25-rc1)
>>>>>
>>>>>
>>>>> Really we must find something so that this damned __refcnt is sta=
rting at 0x80
>>>> Make it last member?
>>> Yes, it will help tbench, but not machines that stress IP route cac=
he
>>>
>>> (dst_use() must dirty the three fields "refcnt, __use , lastuse" )
>>>
>>> Also, 'next' pointer should be in the same cache line, to speedup r=
oute
>>> cache lookups.
>>
>> Knowledge taken.
>>
>>> Next problem is that offsets depend on architecture being 32 or 64 =
bits.
>>>
>>> On 64bit, offsetof(struct dst_entry, __refcnt) is 0xb0 : not very g=
ood...
>>
>> I think all these constraints can be satisfied with clever rearrangi=
ng of dst_entry.
>> Let me come up with alternative patch which still reduces dst slab s=
ize.
>
> You cannot reduce size, and it doesnt matter, since we use dst_entry =
inside rtable
> and rtable is using SLAB_HWCACHE_ALIGN kmem_cachep : we have many byt=
es available.
>
> After patch on 32 bits
>
> sizeof(struct rtable)=3D244   (12 bytes left)
>
> Same for other containers.

Hmm, indeed.

I tried moving __refcnt et al to the very beginning, but it seems to ma=
ke
things worse (on x86_64, almost within statistical error).

And there is no way to use offset_of() inside struct definition. :-(
