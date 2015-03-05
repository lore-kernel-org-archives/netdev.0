From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [ovs-dev] OVS Offload Decision Proposal
Date: Wed, 04 Mar 2015 23:39:01 -0800
Message-ID: <54F80815.5030208@gmail.com>
References: <54F7B76E.4040902@gmail.com> <20150305.000015.1427044514000703740.davem@davemloft.net> <CA+mtBx_Q5Zp58ZkBB0oeyHm5NC8sg1kx=uzTN_8TYG6zYh8yUA@mail.gmail.com> <20150305.014257.974664546228241067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, davidch@broadcom.com,
	simon.horman@netronome.com, dev@openvswitch.org,
	netdev@vger.kernel.org, pablo@netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:37411 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754365AbbCEHjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 02:39:21 -0500
Received: by oigi138 with SMTP id i138so10296815oig.4
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 23:39:20 -0800 (PST)
In-Reply-To: <20150305.014257.974664546228241067.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2015 10:42 PM, David Miller wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Wed, 4 Mar 2015 21:20:41 -0800
>
>> On Wed, Mar 4, 2015 at 9:00 PM, David Miller <davem@davemloft.net> wrote:
>>> From: John Fastabend <john.fastabend@gmail.com>
>>> Date: Wed, 04 Mar 2015 17:54:54 -0800
>>>
>>>> I think a set operation _is_ necessary for OVS and other
>>>> applications that run in user space.
>>>
>>> It's necessary for the kernel to internally manage the chip
>>> flow resources.
>>>
>>> Full stop.
>>>
>>> It's not being exported to userspace.  That is exactly the kind
>>> of open ended, outside the model, crap we're trying to avoid
>>> by putting everything into the kernel where we have consistent
>>> mechanisms, well understood behaviors, and rules.
>>
>> David,
>>
>> Just to make sure everyone is on the same page... this discussion has
>> been about where the policy of offload is implemented, not just who is
>> actually sending config bits to the device. The question is who gets
>> to decide how to best divvy up the finite resources of the device and
>> network amongst various requestors. Is this what you're referring to?
>
> I'm talking about only the kernel being able to make ->set() calls
> through the flow manager API to the device.
>
> Resource control is the kernel's job.
>
> You cannot delegate this crap between ipv4 routing in the kernel,
> L2 bridging in the kernel, and some user space crap.  It's simply
> not going to happen.

The intent was to reserve space in the tables for l2, l3, user space,
and whatever else is needed. This reservation needs to come from the
administrator because even the kernel doesn't know how much of my
table space I want to reserve for l2 vs l3 vs tc vs ... The sizing
of each of these tables will depend on the use case. If I'm provisioning
L3 networks I may want to create a large l3 table and no 'tc' table.
If I'm building a firewall box I might want a small l3 table and a
large 'tc' table. Also depending on how wide I want my matches in the
'tc' case I may consume more or less resources in the hardware.

Once the reservation of resources occurs we wouldn't let user space
arbitrarily write to any table but only tables that have been
explicitly reserved for user space to write to.

Even without the user space piece we need this reservation when
the table space for l2, l3, etc are shared. Otherwise driver writers
end up doing a best guess for you or end up delivering driver flavours
based on firmware and you can hope the driver writer guessed something
that is close to your network.

>
> All of the delegation of the hardware resource must occur in the
> kernel.  Because only the kernel has a full view of all of the
> resources and how each and every subsystem needs to use it.
>

So I'm going to ask... even if we restrict the set() using the above
scheme to only work on pre-defined tables you see an issue with it?
I might be missing the point but I could similarly drive the set()
calls through 'tc' via a new filter call it xflow.

.John

-- 
John Fastabend         Intel Corporation
