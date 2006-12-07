From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] convert hh_lock to seqlock
Date: Thu, 07 Dec 2006 23:27:00 +0100
Message-ID: <45789534.1050703@cosmosbay.com>
References: <20061207113309.2f892cf1@localhost>
 <4578782B.4010908@cosmosbay.com> <20061207131553.45e4388b@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003mt.neufgp.fr ([84.96.92.56]:37648 "EHLO smTp.neuf.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1163496AbWLGW0o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 17:26:44 -0500
Received: from [192.168.30.10] ([84.7.37.114]) by sp604003mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J9X003G7D0HRJE0@sp604003mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Thu, 07 Dec 2006 23:26:42 +0100 (CET)
In-reply-to: <20061207131553.45e4388b@localhost>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =C3=A9crit :
> On Thu, 07 Dec 2006 21:23:07 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>> Stephen Hemminger a =C3=A9crit :
>>> The hard header cache is in the main output path, so using
>>> seqlock instead of reader/writer lock should reduce overhead.
>>>
>> Nice work Stephen, I am very interested.
>>
>> Did you benchmarked it ?
>>
>> I ask because I think hh_refcnt frequent changes may defeat the gain=
 you want=20
>> (ie avoiding cache line ping pongs between cpus). seqlock are defini=
tly better=20
>> than rwlock, but if we really keep cache lines shared.
>>
>> So I would suggest reordering fields of hh_cache and adding one=20
>> ____cacheline_aligned_in_smp to keep hh_refcnt in another cache line=
=2E
>>
>> (hh_len, hh_lock and hh_data should be placed on a 'mostly read' cac=
he line)
>>
>> Thank you
>> Eric
>=20
> It doesn't make any visible performance difference for real networks;=
=20
> copies and device issues are much larger.

Hum, so 'my' machines must be unreal :)

>=20
> The hh_refcnt is used only when creating destroying neighbor entries,
> so except under DoS attack it doesn't make a lot of difference.
> The hh_lock is used on each packet sent.

Some machines create/delete 10.000 entries per second in rt_cache.
I believe they are real. DoS ? you tell it, some people wont agree.


# grep eth0 /proc/net/rt_cache|head -n 10000|cut -f13|sort -u|wc -l
     359
(13th field of /proc/net/rt_cache is HHRef)

# rtstat -c1000 -i1
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache=
|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cach=
e|rt_cache|
  entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_mart=
i|=20
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|=
out_hlis|
         |        |     tot|      mc|     ute|        |  an_dst|  an_sr=
c|=20
    |    _tot|     _mc|        |      ed|    miss| verflow| _search|t_s=
earch|
  2467048|2479640328|1334812199|       0|       0|      34|       0|=20
117112|6139056109|7510556324|       0|       0|       0|       0|=20
0|8864696485|9819074477|
  2465642|   16594|    4791|       0|       0|       0|       0|       =
0|=20
2387|    2738|       0|       0|       0|       0|       0|   21878|   =
 7478|
  2464482|   16505|    4765|       0|       0|       0|       0|       =
0|=20
2460|    2669|       0|       0|       0|       0|       0|   22224|   =
 7499|
  2463512|   17281|    4640|       0|       0|       0|       0|       =
0|=20
2449|    2632|       0|       0|       0|       0|       0|   22069|   =
 7240|
  2462651|   16504|    4314|       0|       0|       0|       0|       =
0|=20
2446|    2497|       0|       0|       0|       0|       0|   20796|   =
 6979|
  2462175|   18152|    5792|       0|       0|       0|       0|       =
0|=20
2448|    2791|       0|       0|       0|       0|       0|   26164|   =
 7731|
  2461889|   16970|    5059|       0|       0|       0|       0|       =
0|=20
2535|    2829|       0|       0|       0|       0|       0|   22614|   =
 7595|
  2461719|   16446|    4643|       0|       0|       0|       0|       =
0|=20
2496|    2717|       0|       0|       0|       0|       0|   21347|   =
 7354|
  2461775|   17098|    4782|       0|       0|       0|       0|       =
0|=20
2386|    2570|       0|       0|       0|       0|       0|   22448|   =
 7049|



Thank you
Eric
