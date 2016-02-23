From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 5/5] Support to encoding decoding skb queue map
 on IFE action
Date: Tue, 23 Feb 2016 11:33:42 -0800
Message-ID: <56CCB416.8000500@gmail.com>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com> <1456147304-13355-6-git-send-email-jhs@emojatatu.com> <56CB77A9.4060907@gmail.com> <56CC4DC8.7000906@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34322 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353AbcBWTd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 14:33:57 -0500
Received: by mail-pf0-f177.google.com with SMTP id x65so117247652pfb.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 11:33:56 -0800 (PST)
In-Reply-To: <56CC4DC8.7000906@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-23 04:17 AM, Jamal Hadi Salim wrote:
> On 16-02-22 04:03 PM, John Fastabend wrote:
>> On 16-02-22 05:21 AM, Jamal Hadi Salim wrote:
>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>>
>>> hard code static value of 10 for qmap
>>> mark of 12
>>> prio of 13
>>> and hashid of 11
>>>
>>> sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
>>> u32 match ip protocol 1 0xff flowid 1:2 \
>>> action ife encode \
>>> type 0xDEAD \
>>> use mark 12 \
>>> use prio 13 \
>>> use hashid 11 \
>>> use qmap 10 \
>>> dst 02:15:15:15:15:15
>>>
>>> Note: as of the time of submission skbedit of queue map doesnt work
>>> (just in case you try to use it)
>>>
>>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>>> ---
>>
>> Well the skbedit queue_mapping action does work I'm just guessing it
>> is not working as you expect? We probably haven't done a good job
>> explaining how to set it up.
>>
>> If you set it on the clsact egress filter chain for example it will
>> map traffic to a queue if you disable XPS and get sk_tx_queue() to
>> return -1. This is because XPS and socket mappings have a higher
>> precedence in queue selection.
>>
> 
> Ok, I am going to use your comment in the commit log.
> When i have time i will test it.
> 
>> Anyways just tested on net-next and it works, the following
>> puts ip traffic with src 15.0.0.1 on hardware queue 6,
>>
>> ./tc/tc qdisc add dev eth4 clsact
>> ./tc/tc filter add dev eth4 egress protocol ip \
>>           u32 ht 800: order 1 \
>>           match ip src 15.0.0.1/32 \
>>          action skbedit queue_mapping 6
>>
> 
> 
> 
> I used a asimilar example:
> 
> sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
> u32 match ip protocol 1 0xff flowid 1:2 \
> action skbedit queue_mapping 49

ah if its not obvious setting queue_mapping from inside a qdisc
has no effect except on multiq because the tx queue has already
been selected. Maybe I need to do a man page update.

Also please don't use multiq I'm tempted to remove it now that
we have mq and mqprio with clsact there is no reason to use it.

> 
> BTW: You didnt have flow/classid in your example rule;
> weird things could happen when you dont have one (unfortunately
> we dont check at user space).

Its safe as far as I can tell on many qdiscs including clsact and
ingress. fq_codel is an example of a qdisc where it would break things
however.

> 
> cheers,
> jamal
