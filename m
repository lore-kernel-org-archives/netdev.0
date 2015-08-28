From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: FIB tracepoints
Date: Thu, 27 Aug 2015 22:27:38 -0700
Message-ID: <55DFF14A.90203@cumulusnetworks.com>
References: <1440737972-10468-1-git-send-email-dsa@cumulusnetworks.com>
 <20150827.220538.2154843333132928646.davem@davemloft.net>
 <55DFEC92.8050700@cumulusnetworks.com>
 <20150827.221643.2144480812551172735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36240 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbbH1F1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:27:41 -0400
Received: by pacgr6 with SMTP id gr6so13573841pac.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 22:27:40 -0700 (PDT)
In-Reply-To: <20150827.221643.2144480812551172735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/27/15 10:16 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Thu, 27 Aug 2015 22:07:30 -0700
>
>> On 8/27/15 10:05 PM, David Miller wrote:
>>> From: David Ahern <dsa@cumulusnetworks.com>
>>> Date: Thu, 27 Aug 2015 21:59:32 -0700
>>>
>>>> +		__array(	__u8,	src,	4	)
>>>> +		__array(	__u8,	dst,	4	)
>>>    ...
>>>> +		__array(	__u8,	src,	4	)
>>>
>>> Maybe there is something I don't understand about tracing, but why not
>>> use __u32?  If endianness types are the issue, just force cast it as
>>> needed.
>>>
>>> Using a memcpy() on a 4-byte array is kinda excessive.
>>>
>>
>> Silly trick need to use %pI4. ie., printing the addresses as strings
>> vs. hex.
>
> %pI4 doesn't care what kind of pointer you give it, &__entry->src will
> work just fine if you used __u32.
>


$ git diff
diff --git a/include/trace/events/fib.h b/include/trace/events/fib.h
index 1fd7cfeb36ff..07687b93a4f0 100644
--- a/include/trace/events/fib.h
+++ b/include/trace/events/fib.h
@@ -22,7 +22,7 @@ TRACE_EVENT(fib_table_lookup,
                 __field(        __u8,   tos             )
                 __field(        __u8,   scope           )
                 __field(        __u8,   flags           )
-               __array(        __u8,   src,    4       )
+               __field(        __u32,  src     )
                 __array(        __u8,   dst,    4       )
         ),

@@ -33,13 +33,13 @@ TRACE_EVENT(fib_table_lookup,
                 __entry->tos = flp->flowi4_tos;
                 __entry->scope = flp->flowi4_scope;
                 __entry->flags = flp->flowi4_flags;
-               memcpy(&__entry->src,  &flp->saddr, 4);
+               __entry->src = flp->saddr;
                 memcpy(&__entry->dst,  &flp->daddr, 4);
         ),

         TP_printk("table %d oif %d iif %d src %pI4 dst %pI4 tos %d 
scope %d flags %x",
                   __entry->tb_id, __entry->oif, __entry->iif,
-                 __entry->src, __entry->dst, __entry->tos, __entry->scope,
+                 &__entry->src, __entry->dst, __entry->tos, __entry->scope,
                   __entry->flags)
  );

and compiles fine but run time:

$ perf record -e fib:* -a
   Warning: [fib:fib_table_lookup] bad op token &
^C[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.089 MB perf.data (148 samples) ]

$ perf script
  Warning: [fib:fib_table_lookup] bad op token &
...
          swapper     0 [000]    49.533997: fib:fib_table_lookup: 
[FAILED TO PARSE] tb_id=254 oif=0 iif=3 tos=0 scope=0 flags=0 
src=16843096 dst=ARRA
...


ie., it does matter. src was declared a u32 and trying to pass &src to 
the printk fails. Been down this road a lot.

David
