From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Thu, 27 Mar 2008 17:29:51 +0100
Message-ID: <47EBCB7F.8040704@cosmosbay.com>
References: <20080327062502.M51594@visp.net.lb> <20080326.234049.256533912.davem@davemloft.net> <47EB46BD.2080001@cosmosbay.com> <20080327144102.M65267@visp.net.lb> <47EBB4A3.4090102@cosmosbay.com> <20080327151520.M89250@visp.net.lb> <47EBC641.8040405@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.113]:26003 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754672AbYC0Q34 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 12:29:56 -0400
In-Reply-To: <47EBC641.8040405@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
> Denys Fedoryshchenko a =C3=A9crit :
>> I did this tuning. Not sure what does mean rt_cache_entries, but=20
>> seems they are still increasing.
>>
>> Kup /config #  rtstat -c1000 -i60
>> rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_ca=
che|
>> rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_ca=
che|
>> rt_cache|
>>  entries|  in_hit|in_slow_|in_slow_|in_no_ro| =20
>> in_brd|in_marti|in_marti|=20
>> out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hli=
st|
>> out_hlis|
>>         |        |     tot|      mc|     ute|        |  an_dst| =20
>> an_src|        |    _tot|     _mc|        |      ed|    miss|=20
>> verflow| _search|t_search|
>>   274234| 1590009|  271953|       0|    1809|       6|       0|     =
 =20
>> 0|   24551|    7365|       0|  279991|  279867|      24|       0|=20
>> 5438630|   89656|
>>   280535|   25463|   19956|       0|     187|       0|       0|     =
 =20
>> 0|     485|     263|       0|   20407|   20404|       3|       0|  =20
>> 12796|     242|
>>   288072|   25367|   19830|       0|     163|       0|       0|     =
 =20
>> 0|     493|     256|       0|   20248|   20245|       3|       0|  =20
>> 17146|     346|
>>   294943|   25689|   19807|       0|     154|       0|       0|     =
 =20
>> 0|     438|     250|       0|   20211|   20208|       3|       0|  =20
>> 21554|     432|
>>   301118|   25287|   19645|       0|     170|       0|       0|     =
 =20
>> 0|     466|     236|       0|   20052|   20048|       3|       0|  =20
>> 25713|     528|
>>   307651|   25663|   20264|       0|     180|       0|       0|     =
 =20
>> 0|     472|     234|       0|   20678|   20675|       3|       0|  =20
>> 30588|     607|
>>   313767|   25810|   20014|       0|     175|       0|       0|     =
 =20
>> 0|     459|     237|       0|   20425|   20422|       3|       0|  =20
>> 33701|     699|
>>
>>
>>  =20
> Then try to lower gc_elasticity, to 3, or even 2
>
> echo 3 >/proc/sys/net/ipv4/route/gc_elasticity
>
>
One more idea before leaving :)

If rt_cache_entries still increasing, we might have a dst leak somewher=
e :
gc tries to evict entries that have a non null refcount -> they are put=
=20
in dst_garbage.list

=46ollowing patch will show us how dst_garbage behaves.
 ( printk(KERN_DEBUG "dst_total: %d delayed: %d work_perf: %d" ...)


diff --git a/net/core/dst.c b/net/core/dst.c
index 7deef48..e634e5f 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -31,6 +31,8 @@
  * 3) This list is guarded by a mutex,
  *    so that the gc_task and dst_dev_event() can be synchronized.
  */
+#undef RT_CACHE_DEBUG
+#define RT_CACHE_DEBUG 2
 #if RT_CACHE_DEBUG >=3D 2
 static atomic_t                         dst_total =3D ATOMIC_INIT(0);
 #endif





