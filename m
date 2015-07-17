From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] rocker: forward packets to CPU when port is
 joined to openvswitch
Date: Fri, 17 Jul 2015 16:33:59 -0700
Message-ID: <CAEP_g=9rtisxsDg0TJzZh3THUd_PeNo9d0MHSip5nzLw1P0WSQ@mail.gmail.com>
References: <1437010754-29038-1-git-send-email-simon.horman@netronome.com>
 <CAE4R7bCBaMZKAhUbW4MC3Z5hmic2kUZuBn94zB6j+kY1Z2piag@mail.gmail.com>
 <20150716065827.GA2145@nanopsycho.orion> <CAE4R7bANdQqxkU_0yUh1W0+o2bPvTnw7u_3ruNsfaPFm-Vs=Yg@mail.gmail.com>
 <20150716081441.GB2145@nanopsycho.orion> <55A7C281.9000207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	Simon Horman <simon.horman@netronome.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:35402 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbbGQXeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 19:34:20 -0400
Received: by lahh5 with SMTP id h5so68886034lah.2
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 16:34:18 -0700 (PDT)
In-Reply-To: <55A7C281.9000207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2015 at 7:41 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 15-07-16 01:14 AM, Jiri Pirko wrote:
>> Thu, Jul 16, 2015 at 09:09:39AM CEST, sfeldma@gmail.com wrote:
>>> On Wed, Jul 15, 2015 at 11:58 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Thu, Jul 16, 2015 at 08:40:31AM CEST, sfeldma@gmail.com wrote:
>>>>> On Wed, Jul 15, 2015 at 6:39 PM, Simon Horman
>>>>> <simon.horman@netronome.com> wrote:
>>>>>> Teach rocker to forward packets to CPU when a port is joined to Open vSwitch.
>>>>>> There is scope to later refine what is passed up as per Open vSwitch flows
>>>>>> on a port.
>>>>>>
>>>>>> This does not change the behaviour of rocker ports that are
>>>>>> not joined to Open vSwitch.
>>>>>>
>>>>>> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>>>>>
>>>>> Acked-by: Scott Feldman <sfeldma@gmail.com>
>>>>>
>>>>> Now, OVS flows on a port.  Strange enough, that was the first RFC
>>>>> implementation for switchdev/rocker where we hooked into ovs-kernel
>>>>> module and programmed flows into hw.  We pulled all of that code
>>>>> because, IIRC, the ovs folks didn't want us hooking into the kernel
>>>>> module directly.  We dropped the ovs hooks and focused on hooking
>>>>> kernel's L2/L3.  The device (rocker) didn't really change: OF-DPA
>>>>> pipeline was used for both.  Might be interesting to try hooking it
>>>>> again.
>>>>
>>>>
>>>> I think that now we have an infrastructure prepared for that. I mean,
>>>> what we need to do is to introduce another generic switchdev object
>>>> called "ntupleflow" and hook-up again into ovs datapath and cls_flower
>>>> and insert/remove the object from those codes. Should be pretty easy to do.
>>>
>>> That sounds right.  Is the ovs datapath hooking still happening in the
>>> ovs-kernel module?  Remind me again, what was the objection the last
>>> time we tried that?
>>
>> Yep, we need to hook there. Otherwise it won't be transparent.
>>
>> Last time the objection was that this would be ovs specific. But that is
>> passed today. We have switchdev infra with objects, we have cls_flower
>> which would use the same object. I say let's do this now.
>>
>
> My objection wasn't that it was OVS specific but based on two
> observations. First the user-kernel interface for OVS would need
> to changed to optimally use hardware and then userspace would need
> to be changed to pack rules optimally for hardware. The reason is
> hardware has wildcards _and_ priority fields typically. This is a
> different structure than we would want to use in software. Maybe
> there is value in having a sub-optimal 'transparent' implementation
> though. Note I can't see how you can possibly reverse engineer this
> from what the kernel gets from userspace today and build out an
> optimal solution.

Yes, this was the main concern. Furthermore, things are likely to get
worse rather than better on this front (i.e. if/when OVS starts using
a more general BPF engine rather than its own flow processor).
