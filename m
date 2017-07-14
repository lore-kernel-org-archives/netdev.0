From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] net: sched: allow qdiscs to share filter
 block instances
Date: Fri, 14 Jul 2017 03:33:35 -0400
Message-ID: <1b890dd0-6c33-1d69-ab02-30622736dd3d@mojatatu.com>
References: <20170710185110.3180-1-jiri@resnulli.us>
 <29fbfb29-1737-1990-a6a7-b79bed7ed1fa@mojatatu.com>
 <20170711123412.GB1874@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, edumazet@google.com,
        stephen@networkplumber.org, jbenc@redhat.com, mlxsw@mellanox.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, john.fastabend@gmail.com,
        alexander.h.duyck@intel.com, daniel@iogearbox.net,
        ogerlitz@mellanox.com, mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32797 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbdGNHdi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 03:33:38 -0400
Received: by mail-wm0-f68.google.com with SMTP id j85so9234717wmj.0
        for <netdev@vger.kernel.org>; Fri, 14 Jul 2017 00:33:38 -0700 (PDT)
In-Reply-To: <20170711123412.GB1874@nanopsycho>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-11 08:34 AM, Jiri Pirko wrote:
> Tue, Jul 11, 2017 at 02:15:27PM CEST, jhs@mojatatu.com wrote:
>> Hi Jiri,
>>

[..]
>>> Now we can add filter to any of qdiscs sharing the same block:
>>>
>>> $ tc filter add dev ens7 parent ffff: protocol ip pref 25 flower dst_ip 192.168.0.0/16 action drop
>>>
>>
>> So for backward compat - this also makes sense. But:
>> it does make sense to create new syntax for adding
>> filters and actions:
>>
>> tc filter add block 22 protocol ip pref 25 flower \
>>   dst_ip 192.168.0.0/16 action drop
> 
> Was thinking about that. Decided to pass on this now. This should be
> addressed by follow-up anyway.
> 

Ok, thanks. I feel it is very important.

> 
>>
>> Coordinates of the filter block before were:
>>
>> <ifindex>, <parent>, [handle]
>>
>> You should be able to abuse struct tcmsg ifindex to represent block #
>> as long as you set parent to be something meaningful that is
>> identified "block coordinate" via TC_H_XXX (pick something safe not
>> in use by ingress or egress; look at: uapi/linux/pkt_sched.h)
> 
> Not sure about this. I have take closer look. In general, I don't like
> to abuse anything :)
> 

I should have said it without "ab" i.e "use" ;->
The purpose of those coordinates is to describe the "location"
of what you call the "block" now.
We used to have egress, then ingress "blocks" tied to a port.
then Daniel added clsact above but still ingress + egress
And it used to be tied to a port and you just changed it to be
port independent etc.
It is a natural evolution.


>>> We will see the same output if we list filters for ens7 and ens8, including stats:

[..]
>>> $ tc -s filter show dev ens8 root
>>> filter dev ens7 parent ffff: protocol ip pref 25 flower
>>> filter dev ens7 parent ffff: protocol ip pref 25 flower handle 0x1
>>>     eth_type ipv4
>>>     dst_ip 192.168.1.0/24
>>>           action order 1: gact action drop
>>>            random type none pass val 0
>>>            index 3 ref 1 bind 1 installed 10202 sec used 10152 sec
>>>           Action statistics:
>>>           Sent 4200 bytes 50 pkt (dropped 50, overlimits 0 requeues 0)
>>>           backlog 0b 0p requeues 0
>>>
>>>
>>> Issues:
>>> - tp->q is set by the device used to add the filter. That has to be resolved.
>>>     Impacts the dump (as you can see above)
>>>
>>
>> I think you have more problems if the dump above is reality;->
>> You added to ingress and this is showing egress.
> 
> Howcome? I only don't see "dev x" on ens7. That is the only difference,
> 

I meant you are displaying egress qdisc filters(root) but you added them
to ingress (ffff:). I would have expected the output you showed had you
said:
tc -s filter show dev ens8 parent ffff:


cheers,
jamal
