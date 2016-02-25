From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 4/4] net: sched: create hardware only classifier
 filter
Date: Thu, 25 Feb 2016 09:36:44 -0800
Message-ID: <56CF3BAC.90104@gmail.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810> <20160223190356.5970.94298.stgit@john-Precision-Tower-5810> <20160224084728.GD2151@nanopsycho.orion> <56CEFE2F.4060203@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32780 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932381AbcBYRg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 12:36:58 -0500
Received: by mail-pa0-f44.google.com with SMTP id fl4so35560443pad.0
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 09:36:58 -0800 (PST)
In-Reply-To: <56CEFE2F.4060203@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-25 05:14 AM, Jamal Hadi Salim wrote:
> On 16-02-24 03:47 AM, Jiri Pirko wrote:
>> Tue, Feb 23, 2016 at 08:03:56PM CET, john.fastabend@gmail.com wrote:
>>> If users want to run filters specifically in hardware without software
>>> running the classifiers we need to use a special handler for this.
>>> By using a new classifier list we are able to add filters in hardware
>>> and keep all the same semantics in the core module. So the core code
>>> will continue to block duplicate entries, incorrect usage of flags
>>> such as exclusive, and all the other cases software already handles.
>>>
>>> Additionally by having a filter list that is not run by software in
>>> the datapath we avoid any overhead related to adding these rules in
>>> the hot path.
>>>
>>> The new filter list TC_H_MIN_INGRESS_HW is logically run in front
>>> of the TC_H_MIN_INGRESS filter list. Driver writers can avoid aborting
>>> on many cases that would potentially conflict with software rules in
>>> the TC_H_MIN_INGRESS filter list this way.
>>
>> Oh, although it looks straightforward to implement this, I don't like it.
>> User should be able to do the same thing he did before, only extension
>> would be to allow to pass 2 flags for adding rules:
>> SKIP_HW
>> SKIP_SW
>>
>> Default would be to add rule to both.
>> u32 and other classifiers should take care of processing this flags
>> internaly and act accordingly. The implementation can be just to skip
>> rule in sw processing or it can maintain hw-only structures.
> 
> I think there is another axis: To add it to sofware but execute it in
> hardware (and not in s/ware).
> This way you can do faster lookups from user space (control
> purposes) and from the hardware you can periodically update things to
> synchronize things like stats for example.
> IOW, this compensates for h/ware interfaces being slow and not needing
> to keep talking to them when you dont have to.
> BTW: At netdev01 - the mellanox people and qualcom both complained about
> this (low speed) issue. I believe someone was recommending a
> "EINPROGRESS" netlink msg or even lying for the set case to say
> "success" when in fact it wasnt. EINPROGRESS may still be a useful idea
> but a different discussion.
> 
> 

Agreed which is why I used its own unique filter list to indicate the
SKIP SW flag. This seems fairly elegant to me and keeps the hardware
operations from interfering with the software operations.

This seems like the most elegant solution to me and it also ensures
users understand the ordering of rules e.g. HW filter list runs in
front of the SW filter list. The alternative is to in u32_change()
somehow spin out another HW root ht and build off of that when a
flag is set.


> cheers,
> jamal
> 
