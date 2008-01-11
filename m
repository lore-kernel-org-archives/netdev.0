From: Dzianis Kahanovich <mahatma@bspu.unibel.by>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Fri, 11 Jan 2008 18:42:06 -0200
Message-ID: <4787D49E.6080906@bspu.unibel.by>
References: <47866C69.3080904@bspu.unibel.by>	 <1200001167.4443.38.camel@localhost>  <4787A663.4030204@bspu.unibel.by> <1200063541.4483.42.camel@localhost>
Reply-To: mahatma@eu.by
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bspu.unibel.by ([195.50.2.21]:37199 "EHLO
	mail.bspu.unibel.by" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761253AbYAKRvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 12:51:22 -0500
Received: from [10.200.200.1] ([10.200.200.1])
	by mail.bspu.unibel.by (8.14.1/8.14.0) with ESMTP id m0BGgDWb018792
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 18:42:14 +0200
In-Reply-To: <1200063541.4483.42.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:

>> Yes, I do so. But there are simple:
>> ---
>> if [[ $[TC_INDEX2MARK] == 0 ]] ; then
==1
>>   c=${c//action ipt -j MARK --set-mark /flowid :}
    c=${c//action ipt -j MARK --set-mark 0x/flowid :}
>> fi
>> $c
>> ---
> 
> I didnt quiet understand what you have above. Does your script above
> read the flowid and sets the MARK to some dynamic value based on flowid?
> if thats what you are doing - it sounds sensible and much more clever
> than what is posted. And it doesnt require any kernel patch.

I suggest just to use classid to toggle mark/nfmark in ingress. I see, classid
are near unused in ingress (no classes, etc) and for many solutions classid in
ingress filters may be used only for nfmarking. Also I suggest to use both
parts (major & minor) of classid - major may be "and" value, minor - "or". In
current place it may be useful only for (if, unsure) overriting netfilter
"raw" table marks, but if it will be moved outside current "CLS_ACT" block -
tc filter rules may operate mark bits more useful.

About script example:
While I compose filter, I check flag ($TC_INDEX2MARK), tells me are patch
applied or no. If no - I use usual "-j MARK --set-mark", else I use classid to
change mark. All in ingress only. For example:
tc filter add dev eth0 parent ffff: protocol ip u32 ... action ipt -j MARK 0x10
are cname to:
tc filter add dev eth0 parent ffff: protocol ip u32 ... flowid :10

- it use less code/modules and, in many cases, may be single/main goal to
ingress usage - pre-marking packets.

>> Simpliest:
>> --- linux-2.6.23-gentoo-r2/net/sched/sch_ingress.c
>> +++ linux-2.6.23-gentoo-r2.fixed/net/sched/sch_ingress.c
>> @@ -222,6 +222,16 @@
>> -   			skb->tc_index = TC_H_MIN(res.classid);
>> +   			skb->tc_index = TC_H_MIN(mark=res.classid);
> 
> Just write a metaset action and you can have all sorts of policies on
> what tc_index, mark etc you want. It is something thats needed in any
> case.
> When we did tc_index it made sense then because it was for "tc" to use
> some default policy. Enforcing policies in the kernel is not the best
> thing to do; as an example you want to specify the polciy for mark to
> be: classid major>>16|minor. I am sure you have good reasons; however,
> for the next person who wants to set it it major>>8|minor for their own
> good reason, theres conflict.  
> My offer to help you is still open.

OK, I understand there are not too transparent for future usage, but I see too
few applications for ingress/classid will conflicting with.

Thanx, I will try to understand "metaset actions", but I think it will be not
so elegant for my usage then my "#define tc_index mark" in the beginning of
sch_ingress.c. Or may be I will use "and/or" behaviour, but now "#define
tc_index mark" works on my router many month (I may use also -j MARK - with
one flag in my script, but there are lot of unuseful code).

This code (ingress/classifying[/CLS_ACT]) are executing everywhen and I
suggest changes from none (changing target variable from "tc_index" to "mark")
to few "and/or" atomic operations for useful functionality. With
"mark=res.classid" only (I may use self, but not suggest to kernel) it even
less code then default (no TC_H_MIN) and fully satisfy to many goals (traffic
marking without netfilter, but compatible with it).

-- 
WBR,
Denis Kaganovich,  mahatma@eu.by  http://mahatma.bspu.unibel.by

