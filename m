From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: tc filter flow hash question
Date: Tue, 30 Jun 2009 14:30:38 +0400
Message-ID: <4A49E94E.40209@bigtelecom.ru>
References: <20090630085706.GD5589@ff.dom.local> <4A49D872.5050403@bigtelecom.ru> <20090630092344.GA8592@ff.dom.local> <4A49DF97.6090608@bigtelecom.ru> <20090630095628.GB8592@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:54578 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbZF3Kah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 06:30:37 -0400
In-Reply-To: <20090630095628.GB8592@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski пишет:
> On Tue, Jun 30, 2009 at 01:49:11PM +0400, Badalian Vyacheslav wrote:
> ...
>   
>> This example not approach? 
>>
>> tc qdisc add dev eth0 root handle 1 htb default 7
>> tc class add dev eth0 parent 1: classid 1:7 htb rate 500mbit ceil 1000mbit prio 3
>> tc qdisc add dev eth0 parent 1:7 handle 10: sfq perturb 10
>>
>> # all traffic go to class 1-7.
>>
>> # Try group traffic by "src,dst" key
>>
>> tc filter add dev eth0 protocol ip parent 10: handle 2 flow hash keys src,dst
>>
>> # all traffic dropped
>>     
>
> Try:
> tc filter add dev eth0 protocol ip parent 10: handle 2 flow hash keys src,dst divisor 1024
>
>   
Outh! Very thanks! I'm so stupid. its simple :(

Also i look in code and see in flow_classify function this lines:

if (f->divisor)
        classid %= f->divisor;

classid generated in up.
Also i see to SFQ code and see that SFQ create 1024 hashes.
If we do not add divisor when added filter rule we get classid > 1024
and its not go to hash of SFQ (my example).
Also divisor must be > 0 because = NaN as i understand.
I not sure that it must be <= 1024 because it may use not in SFQ and i
don't know MAX size of other qdiscs but if it use only in in SFQ i think
we need to check <= SFQ_HASH_DIVISOR also?

Maybe "if" code must be changed to

if (f->divisor && f->divisor > 0)
        classid %= f->divisor;
else
        classid %= 1024;


How you think?
Best regals, Slavon


> Jarek P.
>   
>>>   
>>>       
>>>>> Here are some hints (if we don't mention google ;-)
>>>>> http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.29.y.git;a=commitdiff;h=e5dfb815181fcb186d6080ac3a091eadff2d98fe
>>>>>
>>>>> Regards,
>>>>> Jarek P
>>>>>           
>
>
>   

