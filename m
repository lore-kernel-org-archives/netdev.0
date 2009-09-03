From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Thu, 03 Sep 2009 17:02:10 +0200
Message-ID: <4A9FDA72.8060001@gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>  <alpine.DEB.1.10.0908121820410.3257@gentwo.org>  <c4e36d110908131009l78b29bffvb4d41b90f9b83288@mail.gmail.com>  <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com>  <4A87CE60.4020506@gmail.com> <4A896324.3040104@trash.net>  <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>  <4A9EEF07.5070800@gmail.com>  <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>  <4A9F1620.2080105@gmail.com> <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1> <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35986 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753328AbZICPCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 11:02:47 -0400
In-Reply-To: <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Thu, 3 Sep 2009, Eric Dumazet wrote:
>=20
>> Christoph Lameter a ?crit :
>>> On Thu, 3 Sep 2009, Eric Dumazet wrote:
>>>
>>>> on a SLAB_DESTROY_BY_RCU cache, there is no need to try to optimiz=
e this
>>>> rcu_barrier() call, unless we want superfast reboot/halt sequences=
=2E..
>>> I stilll think that the action to quiesce rcu is something that the=
 caller
>>> of kmem_cache_destroy must take care of.
>> Do you mean :
>>
>> if (kmem_cache_shrink(s) =3D=3D 0) {
>> 	rcu_barrier();
>> 	kmem_cache_destroy_no_rcu_barrier(s);
>> } else {
>> 	kmem_cache_destroy_with_rcu_barrier_because_SLAB_DESTROY_BY_RCU_cac=
he(s);
>> }
>>
>> What would be the point ?
>=20
> The above is port of slub?

No, I am trying to code what you suggest, and I could not find a clean =
way with
current API (SLAB/SLUB/SLOB)

>=20
> I mean that (in this case) the net subsystem would have to deal with =
RCU quietness
> before disposing of the slab cache. There may be multiple ways of dea=
ling
> with RCU. The RCU barrier may be unnecessary for future uses. Typical=
ly
> one would expect that all deferred handling of structures must be com=
plete
> for correctness before disposing of the whole cache.

Point is we cannot deal with RCU quietness before disposing the slab ca=
che,
(if SLAB_DESTROY_BY_RCU was set on the cache) since this disposing *wil=
l*=20
make call_rcu() calls when a full slab is freed/purged.
And when RCU grace period is elapsed, the callback *will* need access t=
o=20
the cache we want to dismantle. Better to not have kfreed()/poisoned it=
=2E..

I believe you mix two RCU uses here.

1) The one we all know, is use normal caches (!SLAB_DESTROY_BY_RCU)=20
(or kmalloc()), and use call_rcu(... kfree_something)

   In this case, you are 100% right that the subsystem itself has
   to call rcu_barrier() (or respect whatever self-synchro) itself,
   before calling kmem_cache_destroy()

2) The SLAB_DESTROY_BY_RCU one.

   Part of cache dismantle needs to call rcu_barrier() itself.
   Caller doesnt have to use rcu_barrier(). It would be a waste of time=
,
   as kmem_cache_destroy() will refill rcu wait queues with its own stu=
ff.





