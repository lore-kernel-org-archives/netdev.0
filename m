From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: weird problem
Date: Fri, 10 Jul 2009 01:59:00 +0200
Message-ID: <4A568444.7010307@itcare.pl>
References: <20090708223459.GB3666@ami.dom.local> <4A5679CC.800@itcare.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000807080902060909040603"
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:51100 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799AbZGIX7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 19:59:07 -0400
In-Reply-To: <4A5679CC.800@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000807080902060909040603
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Today i make other tests with change of 
/proc/sys/net/ipv4/rt_cache_rebuild_count and kernel 2.6.30.1

And when rt_cache_rebuild_count is set to "-1" i have always load on 
x86_64 machine approx 40-50% of each cpu where network card is binded by 
irq_aff

when rt_cache_rebuild_count is set to more than "-1" i have 15 to 20 sec 
of 1 to 3% cpu and after 40-50% cpu

I attach some oprofile output for
rt_cache_rebuild_count = 4 - oprofile_rt_cache_rebuild_count_4.txt
and
rt_cache_rebuild_count = -1 - oprofile_rt_cache_rebuild_count_-1.txt


Regards
Pawel Staszewski

Paweł Staszewski pisze:
> Jarek Poplawski pisze:
>> Pawel Staszewski wrote, On 06/30/2009 10:36 AM:
>> ...
>>  
>>>>>>> rt_worker_func() taking 13% of cpu0 is an alarm for me :)
>>>>>>> And 21% of cpu0 and 34% of cpu6 taken by oprofiled seems odd too...
>>>>>>>             
>>
>> Pawel, here is a patch which changes this function (or what it calls)
>> back to 2.6.28 version; I'm not sure it's OK, so try it very
>> cautiously...
>>
>> Cheers,
>> Jarek P.
>> --- (for debugging only; apply to 2.6.29.5 or .6)
>>
>>   
> I added this patch 30min ago - all is working but problem still exist.
>
> There is only one change - without this patch cpu load was rising from 
> 40 to 50%
> With this patch there is 15 to 25% cpu load.
>
>
>> diff -Nurp a/net/ipv4/route.c b/net/ipv4/route.c
>> --- a/net/ipv4/route.c    2009-07-08 23:42:15.000000000 +0200
>> +++ b/net/ipv4/route.c    2009-07-08 22:47:52.000000000 +0200
>> @@ -769,24 +769,11 @@ static void rt_do_flush(int process_cont
>>      }
>>  }
>>  
>> -/*
>> - * While freeing expired entries, we compute average chain length
>> - * and standard deviation, using fixed-point arithmetic.
>> - * This to have an estimation of rt_chain_length_max
>> - *  rt_chain_length_max = max(elasticity, AVG + 4*SD)
>> - * We use 3 bits for frational part, and 29 (or 61) for magnitude.
>> - */
>> -
>> -#define FRACT_BITS 3
>> -#define ONE (1UL << FRACT_BITS)
>> -
>>  static void rt_check_expire(void)
>>  {
>>      static unsigned int rover;
>>      unsigned int i = rover, goal;
>> -    struct rtable *rth, *aux, **rthp;
>> -    unsigned long samples = 0;
>> -    unsigned long sum = 0, sum2 = 0;
>> +    struct rtable *rth, **rthp;
>>      u64 mult;
>>  
>>      mult = ((u64)ip_rt_gc_interval) << rt_hash_log;
>> @@ -797,7 +784,6 @@ static void rt_check_expire(void)
>>          goal = rt_hash_mask + 1;
>>      for (; goal > 0; goal--) {
>>          unsigned long tmo = ip_rt_gc_timeout;
>> -        unsigned long length;
>>  
>>          i = (i + 1) & rt_hash_mask;
>>          rthp = &rt_hash_table[i].chain;
>> @@ -805,14 +791,10 @@ static void rt_check_expire(void)
>>          if (need_resched())
>>              cond_resched();
>>  
>> -        samples++;
>> -
>>          if (*rthp == NULL)
>>              continue;
>> -        length = 0;
>>          spin_lock_bh(rt_hash_lock_addr(i));
>>          while ((rth = *rthp) != NULL) {
>> -            prefetch(rth->u.dst.rt_next);
>>              if (rt_is_expired(rth)) {
>>                  *rthp = rth->u.dst.rt_next;
>>                  rt_free(rth);
>> @@ -821,46 +803,23 @@ static void rt_check_expire(void)
>>              if (rth->u.dst.expires) {
>>                  /* Entry is expired even if it is in use */
>>                  if (time_before_eq(jiffies, rth->u.dst.expires)) {
>> -nofree:
>>                      tmo >>= 1;
>>                      rthp = &rth->u.dst.rt_next;
>> -                    /*
>> -                     * We only count entries on
>> -                     * a chain with equal hash inputs once
>> -                     * so that entries for different QOS
>> -                     * levels, and other non-hash input
>> -                     * attributes don't unfairly skew
>> -                     * the length computation
>> -                     */
>> -                    for (aux = rt_hash_table[i].chain;;) {
>> -                        if (aux == rth) {
>> -                            length += ONE;
>> -                            break;
>> -                        }
>> -                        if (compare_hash_inputs(&aux->fl, &rth->fl))
>> -                            break;
>> -                        aux = aux->u.dst.rt_next;
>> -                    }
>>                      continue;
>>                  }
>> -            } else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout))
>> -                goto nofree;
>> +            } else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
>> +                tmo >>= 1;
>> +                rthp = &rth->u.dst.rt_next;
>> +                continue;
>> +            }
>>  
>>              /* Cleanup aged off entries. */
>>              *rthp = rth->u.dst.rt_next;
>>              rt_free(rth);
>>          }
>>          spin_unlock_bh(rt_hash_lock_addr(i));
>> -        sum += length;
>> -        sum2 += length*length;
>> -    }
>> -    if (samples) {
>> -        unsigned long avg = sum / samples;
>> -        unsigned long sd = int_sqrt(sum2 / samples - avg*avg);
>> -        rt_chain_length_max = max_t(unsigned long,
>> -                    ip_rt_gc_elasticity,
>> -                    (avg + 4*sd) >> FRACT_BITS);
>>      }
>> +    rt_chain_length_max = ip_rt_gc_elasticity;
>>      rover = i;
>>  }
>>  
>>
>>
>>   
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>


--------------000807080902060909040603
Content-Type: text/plain;
 name="oprofile_rt_cache_rebuild_count_4.txt"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="oprofile_rt_cache_rebuild_count_4.txt"

Q1BVOiBDb3JlIDIsIHNwZWVkIDI5OTkuNjUgTUh6IChlc3RpbWF0ZWQpDQpDb3VudGVkIENQ
VV9DTEtfVU5IQUxURUQgZXZlbnRzIChDbG9jayBjeWNsZXMgd2hlbiBub3QgaGFsdGVkKSB3
aXRoIGEgdW5pdCBtYXNrIG9mIDB4MDAgKFVuaGFsdGVkIGNvcmUgY3ljbGVzKSBjb3VudCAx
MDAwMDANClNhbXBsZXMgb24gQ1BVIDANClNhbXBsZXMgb24gQ1BVIDENClNhbXBsZXMgb24g
Q1BVIDINClNhbXBsZXMgb24gQ1BVIDMNClNhbXBsZXMgb24gQ1BVIDQNClNhbXBsZXMgb24g
Q1BVIDUNClNhbXBsZXMgb24gQ1BVIDYNClNhbXBsZXMgb24gQ1BVIDcNCnNhbXBsZXMgICUg
ICAgICAgIHNhbXBsZXMgICUgICAgICAgIHNhbXBsZXMgICUgICAgICAgIHNhbXBsZXMgICUg
ICAgICAgIHNhbXBsZXMgICUgICAgICAgIHNhbXBsZXMgICUgICAgICAgIHNhbXBsZXMgICUg
ICAgICAgIHNhbXBsZXMgICUgICAgICAgIGltYWdlIG5hbWUNCiAgICAgICAgICAgYXBwIG5h
bWUgICAgICAgICAgICAgICAgIHN5bWJvbCBuYW1lDQoyMDUxICAgICAxNy44NDg4ICAwICAg
ICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAg
ICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAg
ICAgICAgICAgICAwICBvcHJvZmlsZWQNCiAgICAgICAgICAgb3Byb2ZpbGVkICAgICAgICAg
ICAgICAgIChubyBzeW1ib2xzKQ0KMTg0NSAgICAgMTYuMDU2MCAgMTYzNjIgICAgIDQuNzM0
MCAgMjIwNDkgICAgIDQuMjA2NyAgMTk0OSAgICAgMTYuNTE5NyAgMTAwICAgICAgIDkuNjYx
OCAgNDMgICAgICAgMTAuMjYyNSAgOTUgICAgICAgMTAuNTIwNSAgNDkgICAgICAgIDIuMzUx
MiAgdm1saW51eA0KICAgICAgICAgICB2bWxpbnV4ICAgICAgICAgICAgICAgICAgbXdhaXRf
aWRsZQ0KMTEyNiAgICAgIDkuNzk5MCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAg
ICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAg
ICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgdm1saW51eA0KICAg
ICAgICAgICB2bWxpbnV4ICAgICAgICAgICAgICAgICAgcnRfd29ya2VyX2Z1bmMNCjc1MSAg
ICAgICA2LjUzNTUgIDUxICAgICAgICAwLjAxNDggIDUzICAgICAgICAwLjAxMDEgIDUgICAg
ICAgICAwLjA0MjQgIDMgICAgICAgICAwLjI4OTkgIDAgICAgICAgICAgICAgIDAgIDQgICAg
ICAgICAwLjQ0MzAgIDE2ICAgICAgICAwLjc2NzggIHZtbGludXgNCiAgICAgICAgICAgdm1s
aW51eCAgICAgICAgICAgICAgICAgIGZyZWVfYmxvY2sNCjYyMSAgICAgICA1LjQwNDIgIDAg
ICAgICAgICAgICAgIDAgIDQgICAgICAgIDcuNmUtMDQgIDM3NjYgICAgIDMxLjkyMDcgIDEg
ICAgICAgICAwLjA5NjYgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDY4
NiAgICAgIDMyLjkxNzUgIG9wcmVwb3J0DQogICAgICAgICAgIG9wcmVwb3J0ICAgICAgICAg
ICAgICAgICAobm8gc3ltYm9scykNCjU2OCAgICAgICA0Ljk0MzAgIDI1ICAgICAgICAwLjAw
NzIgIDM4ICAgICAgICAwLjAwNzMgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAg
IDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAg
IDAgIHZtbGludXgNCiAgICAgICAgICAgdm1saW51eCAgICAgICAgICAgICAgICAgIGRzdF9k
ZXN0cm95DQozMDMgICAgICAgMi42MzY4ICAyICAgICAgICA1LjhlLTA0ICA2ICAgICAgICAg
MC4wMDExICAxMDYgICAgICAgMC44OTg1ICAwICAgICAgICAgICAgICAwICAwICAgICAgICAg
ICAgICAwICA1ICAgICAgICAgMC41NTM3ICAyNiAgICAgICAgMS4yNDc2ICB2bWxpbnV4DQog
ICAgICAgICAgIHZtbGludXggICAgICAgICAgICAgICAgICBjb3B5X3VzZXJfZ2VuZXJpY19z
dHJpbmcNCjI5NiAgICAgICAyLjU3NTkgIDE3MTc1ICAgICA0Ljk2OTIgIDIzMDUwICAgICA0
LjM5NzcgIDE5NiAgICAgICAxLjY2MTMgIDU5ICAgICAgICA1LjcwMDUgIDI4ICAgICAgICA2
LjY4MjYgIDcxICAgICAgICA3Ljg2MjcgIDYzICAgICAgICAzLjAyMzAgIHZtbGludXgNCiAg
ICAgICAgICAgdm1saW51eCAgICAgICAgICAgICAgICAgIF9yYXdfc3Bpbl9sb2NrDQoyNjcg
ICAgICAgMi4zMjM2ICAyMSAgICAgICAgMC4wMDYxICAzMDQ0ICAgICAgMC41ODA4ICAxMzI4
ICAgICAxMS4yNTYxICAzICAgICAgICAgMC4yODk5ICAxICAgICAgICAgMC4yMzg3ICAyNiAg
ICAgICAgMi44NzkzICAyNjUgICAgICAxMi43MTU5ICBsaWJjLTIuOC5zbw0KICAgICAgICAg
ICBsaWJjLTIuOC5zbyAgICAgICAgICAgICAgKG5vIHN5bWJvbHMpDQoyNjEgICAgICAgMi4y
NzEzICAwICAgICAgICAgICAgICAwICAxICAgICAgICAxLjllLTA0ICAzNiAgICAgICAgMC4z
MDUxICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAxICAgICAgICAgMC4x
MTA3ICA2ICAgICAgICAgMC4yODc5ICB2bWxpbnV4DQogICAgICAgICAgIHZtbGludXggICAg
ICAgICAgICAgICAgICBzZWFyY2hfYnlfa2V5DQoyNDcgICAgICAgMi4xNDk1ICA5ICAgICAg
ICAgMC4wMDI2ICAyMSAgICAgICAgMC4wMDQwICAzICAgICAgICAgMC4wMjU0ICAxICAgICAg
ICAgMC4wOTY2ICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAg
ICAgICAgICAwICB2bWxpbnV4DQogICAgICAgICAgIHZtbGludXggICAgICAgICAgICAgICAg
ICBfX2NhbGxfcmN1DQoyMTkgICAgICAgMS45MDU4ICAwICAgICAgICAgICAgICAwICAwICAg
ICAgICAgICAgICAwICAxMTc3ICAgICAgOS45NzYzICAwICAgICAgICAgICAgICAwICAwICAg
ICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAyNDcgICAgICAxMS44NTIyICBsaWJz
dGRjKysuc28uNg0KLjAuMTAgICAgICBsaWJzdGRjKysuc28uNi4wLjEwICAgICAgKG5vIHN5
bWJvbHMpDQoxNTAgICAgICAgMS4zMDU0ICAxNjA2ICAgICAgMC40NjQ3ICAyMTA0ICAgICAg
MC40MDE0ICA1ICAgICAgICAgMC4wNDI0ICAyICAgICAgICAgMC4xOTMyICAzICAgICAgICAg
MC43MTYwICAyICAgICAgICAgMC4yMjE1ICAxICAgICAgICAgMC4wNDgwICB2bWxpbnV4DQog
ICAgICAgICAgIHZtbGludXggICAgICAgICAgICAgICAgICBnZXRfbmV4dF90aW1lcl9pbnRl
cnJ1cHQNCjEzOCAgICAgICAxLjIwMDkgIDE1ICAgICAgICAwLjAwNDMgIDIzICAgICAgICAw
LjAwNDQgIDIgICAgICAgICAwLjAxNzAgIDIgICAgICAgICAwLjE5MzIgIDAgICAgICAgICAg
ICAgIDAgIDMgICAgICAgICAwLjMzMjIgIDEgICAgICAgICAwLjA0ODAgIHZtbGludXgNCiAg
ICAgICAgICAgdm1saW51eCAgICAgICAgICAgICAgICAgIF9fcmN1X3Byb2Nlc3NfY2FsbGJh
Y2tzDQoxMDUgICAgICAgMC45MTM4ICAzMjEgICAgICAgMC4wOTI5ICAzNjggICAgICAgMC4w
NzAyICA0NCAgICAgICAgMC4zNzI5ICAyNzEgICAgICAyNi4xODM2ICA1NCAgICAgICAxMi44
ODc4ICA2MyAgICAgICAgNi45NzY3ICA1NyAgICAgICAgMi43MzUxICB2bWxpbnV4DQogICAg
ICAgICAgIHZtbGludXggICAgICAgICAgICAgICAgICB0Z19zaGFyZXNfdXANCjEwMCAgICAg
ICAwLjg3MDIgIDI3ICAgICAgICAwLjAwNzggIDE2ICAgICAgICAwLjAwMzEgIDAgICAgICAg
ICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAg
ICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIHZtbGludXgNCiAgICAgICAgICAgdm1saW51
eCAgICAgICAgICAgICAgICAgIG1lbW1vdmUNCjg4ICAgICAgICAwLjc2NTggIDEgICAgICAg
IDIuOWUtMDQgIDcgICAgICAgICAwLjAwMTMgIDQ4OCAgICAgICA0LjEzNjMgIDAgICAgICAg
ICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDE2ICAgICAgICAxLjc3MTkgIDEyMSAgICAg
ICA1LjgwNjEgIHZtbGludXgNCiAgICAgICAgICAgdm1saW51eCAgICAgICAgICAgICAgICAg
IGNsZWFyX3BhZ2VfYw0KODYgICAgICAgIDAuNzQ4NCAgMCAgICAgICAgICAgICAgMCAgMCAg
ICAgICAgICAgICAgMCAgNDU0ICAgICAgIDMuODQ4MSAgMCAgICAgICAgICAgICAgMCAgMCAg
ICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgOTYgICAgICAgIDQuNjA2NSAgbGli
YmZkLTIuMTguc28NCiAgICAgICAgICAgbGliYmZkLTIuMTguc28gICAgICAgICAgIChubyBz
eW1ib2xzKQ0KNjUgICAgICAgIDAuNTY1NyAgMCAgICAgICAgICAgICAgMCAgMiAgICAgICAg
My44ZS0wNCAgMiAgICAgICAgIDAuMDE3MCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAg
ICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgdm1saW51eA0K
ICAgICAgICAgICB2bWxpbnV4ICAgICAgICAgICAgICAgICAgX19maW5kX2dldF9ibG9jaw0K
NjIgICAgICAgIDAuNTM5NiAgMTUzNiAgICAgIDAuNDQ0NCAgMzMxMyAgICAgIDAuNjMyMSAg
MTUgICAgICAgIDAuMTI3MSAgNCAgICAgICAgIDAuMzg2NSAgMCAgICAgICAgICAgICAgMCAg
NCAgICAgICAgIDAuNDQzMCAgNSAgICAgICAgIDAuMjM5OSAgdm1saW51eA0KICAgICAgICAg
ICB2bWxpbnV4ICAgICAgICAgICAgICAgICAgX3Jhd19zcGluX3VubG9jaw0KNTcgICAgICAg
IDAuNDk2MCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAg
ICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAg
ICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgdm1saW51eA0KICAgICAgICAgICB2bWxpbnV4
ICAgICAgICAgICAgICAgICAgY3JlYXRlX3ZpcnR1YWxfbm9kZQ0KNTIgICAgICAgIDAuNDUy
NSAgNiAgICAgICAgIDAuMDAxNyAgMCAgICAgICAgICAgICAgMCAgOTMwICAgICAgIDcuODgy
NyAgNTAgICAgICAgIDQuODMwOSAgMTYzICAgICAgMzguOTAyMSAgOTUgICAgICAgMTAuNTIw
NSAgMTMgICAgICAgIDAuNjIzOCAgdm1saW51eA0KICAgICAgICAgICB2bWxpbnV4ICAgICAg
ICAgICAgICAgICAgbXV0ZXhfc3Bpbl9vbl9vd25lcg0KNTAgICAgICAgIDAuNDM1MSAgMiAg
ICAgICAgNS44ZS0wNCAgMiAgICAgICAgMy44ZS0wNCAgMCAgICAgICAgICAgICAgMCAgMCAg
ICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAg
ICAgICAgICAgICAgMCAgdm1saW51eA0KICAgICAgICAgICB2bWxpbnV4ICAgICAgICAgICAg
ICAgICAgZHN0X3JjdV9mcmVlDQo0OSAgICAgICAgMC40MjY0ICA0NzcgICAgICAgMC4xMzgw
ICA4NzEgICAgICAgMC4xNjYyICAyICAgICAgICAgMC4wMTcwICAxICAgICAgICAgMC4wOTY2
ICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAxICAgICAgICAgMC4wNDgw
ICB2bWxpbnV4DQo=
--------------000807080902060909040603
Content-Type: text/plain;
 name="oprofile_rt_cache_rebuild_count_-1.txt"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="oprofile_rt_cache_rebuild_count_-1.txt"

Q1BVOiBDb3JlIDIsIHNwZWVkIDI5OTkuNjUgTUh6IChlc3RpbWF0ZWQpDQpDb3VudGVkIENQ
VV9DTEtfVU5IQUxURUQgZXZlbnRzIChDbG9jayBjeWNsZXMgd2hlbiBub3QgaGFsdGVkKSB3
aXRoIGEgdW5pdCBtYXNrIG9mIDB4MDAgKFVuaGFsdGVkIGNvcmUgY3ljbGVzKSBjb3VudCAx
MDAwMDANClNhbXBsZXMgb24gQ1BVIDANClNhbXBsZXMgb24gQ1BVIDENClNhbXBsZXMgb24g
Q1BVIDINClNhbXBsZXMgb24gQ1BVIDMNClNhbXBsZXMgb24gQ1BVIDQNClNhbXBsZXMgb24g
Q1BVIDUNClNhbXBsZXMgb24gQ1BVIDYNClNhbXBsZXMgb24gQ1BVIDcNCnNhbXBsZXMgICUg
ICAgICAgIHNhbXBsZXMgICUgICAgICAgIHNhbXBsZXMgICUgICAgICAgIHNhbXBsZXMgICUg
ICAgICAgIHNhbXBsZXMgICUgICAgICAgIHNhbXBsZXMgICUgICAgICAgIHNhbXBsZXMgICUg
ICAgICAgIHNhbXBsZXMgICUgICAgICAgIGltYWdlIG5hbWUNCiAgICAgICAgICAgYXBwIG5h
bWUgICAgICAgICAgICAgICAgIHN5bWJvbCBuYW1lDQo1MjMzICAgICAxNS43MTkwICA3NjAg
ICAgICAgMC4wNzk1ICAyNTkgICAgICAgMC4wMTkwICAxMCAgICAgICAgMC4xODU3ICAwICAg
ICAgICAgICAgICAwICAxICAgICAgICAgMC4xMjQ3ICAzNDAgICAgICAgOS42NDU0ICAyMCAg
ICAgICAgMS40MDA2ICBsaWJjLTIuOC5zbw0KICAgICAgICAgICBsaWJjLTIuOC5zbyAgICAg
ICAgICAgICAgKG5vIHN5bWJvbHMpDQo1MTE2ICAgICAxNS4zNjc1ICAwICAgICAgICAgICAg
ICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAg
ICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAg
ICAwICBiZ3BkDQogICAgICAgICAgIGJncGQgICAgICAgICAgICAgICAgICAgICBiZ3BfYmVz
dF9zZWxlY3Rpb24NCjQ0OTkgICAgIDEzLjUxNDIgIDM3NDIzICAgICAzLjkxNjIgIDQ3Mzk5
ICAgICAzLjQ4MzIgIDQ2MTUgICAgIDg1LjcwMTAgIDkxOCAgICAgICA5Ljk4MDQgIDE3MiAg
ICAgIDIxLjQ0NjQgIDU0MCAgICAgIDE1LjMxOTEgIDE5MSAgICAgIDEzLjM3NTQgIHZtbGlu
dXgNCiAgICAgICAgICAgdm1saW51eCAgICAgICAgICAgICAgICAgIG13YWl0X2lkbGUNCjM2
MzUgICAgIDEwLjkxODkgIDAgICAgICAgICAgICAgIDAgIDIxMDIgICAgICAwLjE1NDUgIDAg
ICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAg
ICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIG9wcm9maWxlZA0KICAgICAgICAg
ICBvcHJvZmlsZWQgICAgICAgICAgICAgICAgKG5vIHN5bWJvbHMpDQoyODU1ICAgICAgOC41
NzU5ICA3NjUgICAgICAgMC4wODAxICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAg
ICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAg
ICAwICAwICAgICAgICAgICAgICAwICBiZ3BkDQogICAgICAgICAgIGJncGQgICAgICAgICAg
ICAgICAgICAgICBiZ3Bfcm91dGVfbmV4dA0KMTYyNiAgICAgIDQuODg0MiAgMzcyICAgICAg
IDAuMDM4OSAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAg
ICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAg
ICAgICAgMCAgYmdwZA0KICAgICAgICAgICBiZ3BkICAgICAgICAgICAgICAgICAgICAgYmdw
X3NjYW5fdGltZXINCjE2MTEgICAgICA0LjgzOTEgIDAgICAgICAgICAgICAgIDAgIDAgICAg
ICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAg
ICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIGJncGQN
CiAgICAgICAgICAgYmdwZCAgICAgICAgICAgICAgICAgICAgIGJncF9wcm9jZXNzX21haW4N
CjExMzMgICAgICAzLjQwMzMgIDEgICAgICAgIDEuMGUtMDQgIDAgICAgICAgICAgICAgIDAg
IDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAg
IDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIGJncGQNCiAgICAgICAgICAg
YmdwZCAgICAgICAgICAgICAgICAgICAgIGJncF9wcm9jZXNzX2Fubm91bmNlX3NlbGVjdGVk
DQo5NTAgICAgICAgMi44NTM2ICAyMTggICAgICAgMC4wMjI4ICAwICAgICAgICAgICAgICAw
ICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAw
ICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICBiZ3BkDQogICAgICAgICAg
IGJncGQgICAgICAgICAgICAgICAgICAgICBiZ3BfcHJvY2Vzcw0KNDg2ICAgICAgIDEuNDU5
OSAgMTEgICAgICAgIDAuMDAxMiAgMjQwICAgICAgIDAuMDE3NiAgMSAgICAgICAgIDAuMDE4
NiAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMzEgICAgICAgIDAuODc5
NCAgMSAgICAgICAgIDAuMDcwMCAgdm1saW51eA0KICAgICAgICAgICB2bWxpbnV4ICAgICAg
ICAgICAgICAgICAgY29weV91c2VyX2dlbmVyaWNfc3RyaW5nDQo0NDIgICAgICAgMS4zMjc3
ICAxMTEgICAgICAgMC4wMTE2ICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAw
ICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAw
ICAwICAgICAgICAgICAgICAwICBiZ3BkDQogICAgICAgICAgIGJncGQgICAgICAgICAgICAg
ICAgICAgICBiZ3BfbmV4dGhvcF9sb29rdXANCjM3NiAgICAgICAxLjEyOTQgIDEgICAgICAg
IDEuMGUtMDQgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAg
ICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAg
ICAgICAgIDAgIGxpYnplYnJhLnNvLjAuDQowLjAgICAgICAgIGxpYnplYnJhLnNvLjAuMC4w
ICAgICAgICB3b3JrX3F1ZXVlX3J1bg0KMzIzICAgICAgIDAuOTcwMiAgODIgICAgICAgIDAu
MDA4NiAgMiAgICAgICAgMS41ZS0wNCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAg
ICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAg
ICAgMCAgbGliemVicmEuc28uMC4NCjAuMCAgICAgICAgbGliemVicmEuc28uMC4wLjAgICAg
ICAgIHByZWZpeF9tYXRjaA0KMjM3ICAgICAgIDAuNzExOSAgNjQgICAgICAgIDAuMDA2NyAg
MSAgICAgICAgNy4zZS0wNSAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAg
MCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAg
bGliemVicmEuc28uMC4NCjAuMCAgICAgICAgbGliemVicmEuc28uMC4wLjAgICAgICAgIHpj
YWxsb2MNCjIxNiAgICAgICAwLjY0ODggIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAg
ICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAg
ICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIHZtbGludXgNCiAg
ICAgICAgICAgdm1saW51eCAgICAgICAgICAgICAgICAgIHJ0X3dvcmtlcl9mdW5jDQoyMDMg
ICAgICAgMC42MDk4ICAzMDcwICAgICAgMC4zMjEzICA0MDM4ICAgICAgMC4yOTY3ICA3ICAg
ICAgICAgMC4xMzAwICAzMiAgICAgICAgMC4zNDc5ICAxMyAgICAgICAgMS42MjA5ICAzICAg
ICAgICAgMC4wODUxICA2ICAgICAgICAgMC40MjAyICB2bWxpbnV4DQogICAgICAgICAgIHZt
bGludXggICAgICAgICAgICAgICAgICBnZXRfbmV4dF90aW1lcl9pbnRlcnJ1cHQNCjE5MiAg
ICAgICAwLjU3NjcgIDMwICAgICAgICAwLjAwMzEgIDAgICAgICAgICAgICAgIDAgIDAgICAg
ICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAg
ICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIGxpYnplYnJhLnNvLjAuDQowLjAgICAg
ICAgIGxpYnplYnJhLnNvLjAuMC4wICAgICAgICAucGx0DQoxODkgICAgICAgMC41Njc3ICAw
ICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAw
ICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAw
ICAgICAgICAgICAgICAwICBiZ3BkDQogICAgICAgICAgIGJncGQgICAgICAgICAgICAgICAg
ICAgICBiZ3BfYWRqX291dF91bnNldA0KMTg3ICAgICAgIDAuNTYxNyAgNDA1NjIgICAgIDQu
MjQ0NyAgNTQ0MjIgICAgIDMuOTk5MyAgNjUgICAgICAgIDEuMjA3MSAgNDA5ICAgICAgIDQu
NDQ2NiAgNzMgICAgICAgIDkuMTAyMiAgMTI2ICAgICAgIDMuNTc0NSAgMTE2ICAgICAgIDgu
MTIzMiAgdm1saW51eA0KICAgICAgICAgICB2bWxpbnV4ICAgICAgICAgICAgICAgICAgX3Jh
d19zcGluX2xvY2sNCjE0NCAgICAgICAwLjQzMjUgIDYwICAgICAgICAwLjAwNjMgIDMgICAg
ICAgIDIuMmUtMDQgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAg
ICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIDAgICAgICAgICAgICAgIDAgIGJncGQN
CiAgICAgICAgICAgYmdwZCAgICAgICAgICAgICAgICAgICAgIGJncF9ub2RlX2dldA0KMTI3
ICAgICAgIDAuMzgxNSAgNDAgICAgICAgIDAuMDA0MiAgMCAgICAgICAgICAgICAgMCAgMCAg
ICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgMCAg
ICAgICAgICAgICAgMCAgMCAgICAgICAgICAgICAgMCAgbGliemVicmEuc28uMC4NCjAuMCAg
ICAgICAgbGliemVicmEuc28uMC4wLjAgICAgICAgIGxpc3Rub2RlX2FkZA0KMTI0ICAgICAg
IDAuMzcyNSAgMTE4MyAgICAgIDAuMTIzOCAgMTYyMyAgICAgIDAuMTE5MyAgNzIgICAgICAg
IDEuMzM3MCAgMjg5NCAgICAgMzEuNDYzNCAgOTAgICAgICAgMTEuMjIxOSAgMTA4ICAgICAg
IDMuMDYzOCAgMTkxICAgICAgMTMuMzc1NCAgdm1saW51eA0KICAgICAgICAgICB2bWxpbnV4
ICAgICAgICAgICAgICAgICAgdGdfc2hhcmVzX3VwDQoxMTkgICAgICAgMC4zNTc1ICAwICAg
ICAgICAgICAgICAwICAxMyAgICAgICA5LjZlLTA0ICAwICAgICAgICAgICAgICAwICAwICAg
ICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAg
ICAgICAgICAgICAwICB2bWxpbnV4DQogICAgICAgICAgIHZtbGludXggICAgICAgICAgICAg
ICAgICBtdXRleF9zcGluX29uX293bmVyDQoxMTQgICAgICAgMC4zNDI0ICAxNCAgICAgICAg
MC4wMDE1ICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAg
ICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAgICAgICAwICAwICAgICAgICAg
ICAgICAwICBiZ3BkDQo=
--------------000807080902060909040603--
