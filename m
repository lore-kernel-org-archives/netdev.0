From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] rocker: forward packets to CPU when port is
 joined to openvswitch
Date: Thu, 16 Jul 2015 07:41:05 -0700
Message-ID: <55A7C281.9000207@gmail.com>
References: <1437010754-29038-1-git-send-email-simon.horman@netronome.com> <CAE4R7bCBaMZKAhUbW4MC3Z5hmic2kUZuBn94zB6j+kY1Z2piag@mail.gmail.com> <20150716065827.GA2145@nanopsycho.orion> <CAE4R7bANdQqxkU_0yUh1W0+o2bPvTnw7u_3ruNsfaPFm-Vs=Yg@mail.gmail.com> <20150716081441.GB2145@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:34667 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbbGPOku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 10:40:50 -0400
Received: by obre1 with SMTP id e1so48163079obr.1
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 07:40:49 -0700 (PDT)
In-Reply-To: <20150716081441.GB2145@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-16 01:14 AM, Jiri Pirko wrote:
> Thu, Jul 16, 2015 at 09:09:39AM CEST, sfeldma@gmail.com wrote:
>> On Wed, Jul 15, 2015 at 11:58 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Thu, Jul 16, 2015 at 08:40:31AM CEST, sfeldma@gmail.com wrote:
>>>> On Wed, Jul 15, 2015 at 6:39 PM, Simon Horman
>>>> <simon.horman@netronome.com> wrote:
>>>>> Teach rocker to forward packets to CPU when a port is joined to Open vSwitch.
>>>>> There is scope to later refine what is passed up as per Open vSwitch flows
>>>>> on a port.
>>>>>
>>>>> This does not change the behaviour of rocker ports that are
>>>>> not joined to Open vSwitch.
>>>>>
>>>>> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>>>>
>>>> Acked-by: Scott Feldman <sfeldma@gmail.com>
>>>>
>>>> Now, OVS flows on a port.  Strange enough, that was the first RFC
>>>> implementation for switchdev/rocker where we hooked into ovs-kernel
>>>> module and programmed flows into hw.  We pulled all of that code
>>>> because, IIRC, the ovs folks didn't want us hooking into the kernel
>>>> module directly.  We dropped the ovs hooks and focused on hooking
>>>> kernel's L2/L3.  The device (rocker) didn't really change: OF-DPA
>>>> pipeline was used for both.  Might be interesting to try hooking it
>>>> again.
>>>
>>>
>>> I think that now we have an infrastructure prepared for that. I mean,
>>> what we need to do is to introduce another generic switchdev object
>>> called "ntupleflow" and hook-up again into ovs datapath and cls_flower
>>> and insert/remove the object from those codes. Should be pretty easy to do.
>>
>> That sounds right.  Is the ovs datapath hooking still happening in the
>> ovs-kernel module?  Remind me again, what was the objection the last
>> time we tried that?
> 
> Yep, we need to hook there. Otherwise it won't be transparent.
> 
> Last time the objection was that this would be ovs specific. But that is
> passed today. We have switchdev infra with objects, we have cls_flower
> which would use the same object. I say let's do this now.
> 

My objection wasn't that it was OVS specific but based on two
observations. First the user-kernel interface for OVS would need
to changed to optimally use hardware and then userspace would need
to be changed to pack rules optimally for hardware. The reason is
hardware has wildcards _and_ priority fields typically. This is a
different structure than we would want to use in software. Maybe
there is value in having a sub-optimal 'transparent' implementation
though. Note I can't see how you can possibly reverse engineer this
from what the kernel gets from userspace today and build out an
optimal solution.

Second I was hoping to use the interface as a "better" ethtool flow
classifier with a control plane in user space that controllers in the
network could interface with. In this mode I'm not running on a TOR but
at the edge. In this case I want to do some pre-processing of packets
before sending them up to the kernel to complete processing. Examples
like partial completion of classification and rule chaining where I
implement some rules in software and others in hardware. Perhaps this is
not OVS and I should just write a better ethtool flow classifier. But
with a 'bit' similar to how we do L2 I would get this.

All that said seeing a switchdev infra object could be interesting.

.John
