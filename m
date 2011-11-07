From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Linux Route Cache performance tests
Date: Mon, 07 Nov 2011 09:36:53 +0100
Message-ID: <4EB798A5.7000900@itcare.pl>
References: <4EB6AE62.5050803@itcare.pl>     <1320600597.6506.7.camel@edumazet-laptop> <4EB6D1D8.8040604@itcare.pl>    <1320605326.6506.27.camel@edumazet-laptop> <4EB6DE06.7050009@itcare.pl>   <1320608290.6506.33.camel@edumazet-laptop> <4EB6ED2E.1070106@itcare.pl>  <1320614788.6506.38.camel@edumazet-laptop> <4EB702D3.1090703@itcare.pl> <1320620915.6506.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:38867 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751858Ab1KGIhA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 03:37:00 -0500
In-Reply-To: <1320620915.6506.44.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2011-11-07 00:08, Eric Dumazet pisze:
> Le dimanche 06 novembre 2011 =C3=A0 22:57 +0100, Pawe=C5=82 Staszewsk=
i a =C3=A9crit :
>> W dniu 2011-11-06 22:26, Eric Dumazet pisze:
>>> Le dimanche 06 novembre 2011 =C3=A0 21:25 +0100, Pawe=C5=82 Staszew=
ski a =C3=A9crit :
>>>> Yes with this is a little problem i think with kernel 3.1 because
>>>> dmesg | egrep  '(rhash)|(route)'
>>>> [    0.000000] Command line: root=3D/dev/md2 rhash_entries=3D20971=
52
>>>> [    0.000000] Kernel command line: root=3D/dev/md2 rhash_entries=3D=
2097152
>>>> [    4.697294] IP route cache hash table entries: 524288 (order: 1=
0,
>>>> 4194304 bytes)
>>>>
>>>>
>>> Dont tell me you _still_ use a 32bit kernel ?
>> no it is 64bit :)
>> Linux localhost 3.1.0 #16 SMP Sun Nov 6 18:09:48 CET 2011 x86_64 Int=
el(R)
>> :)
>>
>>> If so, you need to tweak alloc_large_system_hash() to use vmalloc,
>>> because you hit MAX_ORDER (10) page allocations.
>> funny then :)
>> Maybee i turned off too many kernel features
>>> But considering LOWMEM is about 700 Mbytes, you wont be able to cre=
ate a
>>> lot of route cache entries.
>>>
>>> Come on, do us a favor, and enter new era of computing.
> OK, then your kernel is not CONFIG_NUMA enabled
>
> It seems strange given you probably have a NUMA machine (24 cpus)
Yes NUMA was not enabled
I make some tests with NUMA and without to compare performance of ixgbe=
=20
with use Node=3D"" parameters for ixgbe module

> If so, your choices are :
>
> 1) enable CONFIG_NUMA. Really this is a must given the workload of yo=
ur
> machine.
>
> 2) Or : you need to add "hashdist=3D1" on boot params
>     and patch your kernel with following patch :
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9dd443d..07f86e0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5362,7 +5362,6 @@ int percpu_pagelist_fraction_sysctl_handler(ctl=
_table *table, int write,
>
>   int hashdist =3D HASHDIST_DEFAULT;
>
> -#ifdef CONFIG_NUMA
>   static int __init set_hashdist(char *str)
>   {
>   	if (!str)
> @@ -5371,7 +5370,6 @@ static int __init set_hashdist(char *str)
>   	return 1;
>   }
>   __setup("hashdist=3D", set_hashdist);
> -#endif
>
>   /*
>    * allocate a large system hash table from bootmem
>
Yes after enabling NUMA I can change rhash_entries on kernel boot.

And what is the most important for big route cahce is rhash_entries
if route cache size exceed hash size performance will drop 6x to 8x
So the best settings for route cache are:
rhash_entries =3D gc_thresh =3D max_size

Eric tell me what are the plans for removing route cache from kernel ?
Because as You see with route cache performance is better
And without route cache performance is not soo good than with route=20
cache enabled but it is stable for all situations even DDOS with 10kk=20
random_ips

So for the feature we need to prepare for lower kernel IP forwarding=20
performance because of no route cache ?
Or removing route cache will save some time in IP stack  processing ?


Thanks
Pawel


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
