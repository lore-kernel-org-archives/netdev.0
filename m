From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC] net: store port/representative id in metadata_dst
Date: Fri, 23 Sep 2016 14:20:40 -0700
Message-ID: <57E59CA8.30007@gmail.com>
References: <1474572417-15907-1-git-send-email-jakub.kicinski@netronome.com>
 <20160923063429.GA1821@nanopsycho.orion> <20160923110609.2f221f99@griffin>
 <20160923135512.64e5d5e9@jkicinski-Precision-T1700>
 <57E53ADE.10806@gmail.com>
 <20160923162907.7fd5314e@jkicinski-Precision-T1700>
 <57E564F3.5010107@intel.com>
 <20160923211728.4c2f05ab@jkicinski-Precision-T1700>
 <57E58FA6.3050001@gmail.com> <20160923214544.6a3cd0ff@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jiri@resnulli.us>,
        netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        ogerlitz@mellanox.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, Paolo Abeni <pabeni@redhat.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        hannes@stressinduktion.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34170 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965005AbcIWVVA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 17:21:00 -0400
Received: by mail-pa0-f66.google.com with SMTP id i5so2372154pad.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 14:21:00 -0700 (PDT)
In-Reply-To: <20160923214544.6a3cd0ff@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-23 01:45 PM, Jakub Kicinski wrote:
> On Fri, 23 Sep 2016 13:25:10 -0700, John Fastabend wrote:
>> On 16-09-23 01:17 PM, Jakub Kicinski wrote:
>>> On Fri, 23 Sep 2016 10:22:59 -0700, Samudrala, Sridhar wrote:  
>>>> On 9/23/2016 8:29 AM, Jakub Kicinski wrote:  
>>  [...]  
>>  [...]  
>>>>
>>>> The 'accel' parameter in dev_queue_xmit_accel() is currently only passed
>>>> to ndo_select_queue() via netdev_pick_tx() and is used to select the tx 
>>>> queue.
>>>> Also, it is not passed all the way to the driver specific xmit routine.  
>>>> Doesn't it require
>>>> changing all the driver xmit routines if we want to pass this parameter?
>>>>  
>>  [...]  
>>>>
>>>> Yes.  The VFPR netdevs don't have any HW queues associated with them and 
>>>> we would like
>>>> to use the PF queues for the xmit.
>>>> I was also looking into some way of passing the port id via skb 
>>>> parameter to the
>>>> dev_queue_xmit() call so that the PF xmit routine can do a directed 
>>>> transmit to a specifc VF.
>>>> Is skb->cb an option to pass this info?
>>>> dst_metadata approach would work  too if it is acceptable.  
>>>
>>> I don't think we can trust skb->cb to be set to anything meaningful
>>> when the skb is received by the lower device. 
>>
>> Agreed. I wouldn't recommend using skb->cb. How about passing it through
>> dev_queue_xmit_accel() through to the driver?
>>
>> If you pass the metadata through the dev_queue_xmit_accel() handle tx
>> queue  selection would work using normal mechanisms (xps, select_queue,
>> cls  hook, etc.). If you wanted to pick some specific queue based on
>> policy the policy could be loaded into one of those hooks.
> 
> Do you mean without extending how accel is handled by
> dev_queue_xmit_accel() today?  If my goal is to not have extra HW
> queues then I don't see how I could mux in the lower dev without extra
> locking (as I tried to explain two emails ago).  Sorry for being slow
> here :(
> 

Not slow here I think I was overly optimistic...

Yeh let me try this, roughly the current flow is,

   dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv);
   __dev_queue_xmit(skb, accel_priv);
   netdev_pick_tx(dev, skb, accel_priv);
	ndo_select_queue(dev, skb, accel_priv, ...);
   [...]
   q->enqueue();
   [...]
   dev_hard_start_xmit();
   [...]
    <driver code here>

So in this flow the VFR netdev driver handles its xmit routine by
calling dev_queue_xmit_accel after setting skb->dev to the physical
device and passing a cookie via accel that the select_queue() routine
can use to pick a tx queue. The rest of the stack q->enqueue() and
friends will ensure that locking and qdisc is handled correctly.

But accel_priv was lost at queue selection and so its not being passed
down to the driver so no way to set your descriptor bits or whatever
needed to push to the VF. I was sort of thinking we could map it from
the select_queue routine but I can't figure out how to do that either.

The metadata idea doesn't seem that bad now that I've spent some more
time going through it. Either that or hijack some field in the skb but
I think that might be worse than the proposal here.

I'm trying to think up some other alternative now and will let you know
if I think of anything clever but got nothing at the moment.

.John
	
