From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 3/4] net: sched: cls_u32 add bit to specify software
 only rules
Date: Thu, 25 Feb 2016 13:56:11 -0800
Message-ID: <56CF787B.2070505@gmail.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810> <20160223190321.5970.58924.stgit@john-Precision-Tower-5810> <56CDB0B0.4080609@mojatatu.com> <56CE7D37.9000701@gmail.com> <56CEFA03.3080802@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>, jiri@resnulli.us,
	daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35324 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbcBYV4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:56:24 -0500
Received: by mail-pa0-f46.google.com with SMTP id ho8so39935976pac.2
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 13:56:24 -0800 (PST)
In-Reply-To: <56CEFA03.3080802@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-25 04:56 AM, Jamal Hadi Salim wrote:
> On 16-02-24 11:04 PM, John Fastabend wrote:
>> On 16-02-24 05:31 AM, Jamal Hadi Salim wrote:
> 
>> I think this is absolutely necessary not only for performance of
>> reporting the rules back to software but if we don't do it generically
>> the driver will have to do it anyways because doing the inverse
>> transformation from hw implementation to u32 is really tricky and in
>> fact with hnodes and knodes there are multiple cls_u32 "programs" that
>> functionally are the same so we have no way to return what the user
>> actually programmed without it. Further eBPF (the next classifier I'm
>> working on) is even worse in this regard.
> 
> Ok, I guess there are multiple use cases for it ;->
> Yes, with ebpf it will be worse because data and instructions are
> inter- mingled (and our interest is in data only). Note:
> Over the years this has been a big struggle for human
> friendliness. I thought we didnt care about humans (as in automation)
> but you are saying this will affect machines too ;-> We cant allow
> that ;->
> 
> Note: You could decode u32 descriptions but it is an involved effort.
> Example, see this feature in tc:
> ---
> jhs@jhs1 tc -pretty filter ls dev $ETH parent ffff: protocol ip
> filter pref 11 u32
> filter pref 11 u32 fh 800: ht divisor 1
> filter pref 11 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1
>   match IP src 10.0.0.130/32
>     action order 1: gact action drop
>      random type none pass val 0
>      index 1 ref 1 bind 1
> ----

decoding that is not a problem. The ixgbe driver code already applied
can decode that without much trouble. The thing I want to avoid is
requiring my driver to do the inverse translation because although it
is possible its entirely unnecessary.

To do the above example without a software cache for example
means I read out row 2048 of a hardware table then you get a bunch of
bits. From those bits I consult what fields are being loaded into
the table in the packet processing pipeline. I learn its the src_ip
fields then I have the value/mask and can unwind it. Finally if I
collapsed some hash tables onto this hardware table I have to do the
inverse of my collapsing scheme. The ixgbe one is sort of simple just
because I only have one table in hardware but with multiple tables
its a bit more difficult. Finally I've unwound the thing and can
print something back out of 'tc' but it seems easier to just cache
the hardware rules somewhere. Maybe other driver/hardware will have
a different opinion though depending on how much your firmware can
store and how ambitious you are. Personally I don't see any need
for the above code.

> See that "match" field reading in anglais? It requires more and more
> additions of pretty printers that translate back.
> 
> What about adding some tag to allow for easy "babel translation"?
> 

not sure what this would be...

>> You can see my solution to
>> this "load in hardware" filter list in patch 4/4. See Jiri's comment
>> also on that and see if you agree.
> 
> Ok, will do.
> 
> cheers,
> jamal
