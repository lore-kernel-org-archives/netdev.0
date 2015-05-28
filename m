From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Thu, 28 May 2015 08:35:05 -0700
Message-ID: <556735A9.60103@gmail.com>
References: <1431906125-13808-1-git-send-email-roopa@cumulusnetworks.com> <20150518.161916.2132217836491222672.davem@davemloft.net> <20150528094244.GA19629@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, roopa@cumulusnetworks.com,
	sfeldma@gmail.com, netdev@vger.kernel.org, andy@greyhouse.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35819 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbbE1PfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 11:35:16 -0400
Received: by oihd6 with SMTP id d6so35185515oih.2
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 08:35:16 -0700 (PDT)
In-Reply-To: <20150528094244.GA19629@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2015 02:42 AM, Jiri Pirko wrote:
> Mon, May 18, 2015 at 10:19:16PM CEST, davem@davemloft.net wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Date: Sun, 17 May 2015 16:42:05 -0700
>>
>>> On most systems where you can offload routes to hardware,
>>> doing routing in software is not an option (the cpu limitations
>>> make routing impossible in software).
>>
>> You absolutely do not get to determine this policy, none of us
>> do.
>>
>> What matters is that by default the damn switch device being there
>> is %100 transparent to the user.
>>
>> And the way to achieve that default is to do software routes as
>> a fallback.
>>
>> I am not going to entertain changes of this nature which fail
>> route loading by default just because we've exceeded a device's
>> HW capacity to offload.
>>
>> I thought I was _really_ clear about this at netdev 0.1
>
> I certainly agree that by default, transparency 1:1 sw:hw mapping is
> what we need for fib. The current code is a good start!
>
> I see couple of issues regarding switchdev_fib_ipv4_abort:
> 1) If user adds and entry, switchdev_fib_ipv4_add fails, abort is
>     executed -> and, error returned. I would expect that route entry should
>     be added in this case. The next attempt of adding the same entry will
>     be successful.
>     The current behaviour breaks the transparency you are reffering to.
> 2) When switchdev_fib_ipv4_abort happens to be executed, the offload is
>     disabled for good (until reboot). That is certainly not nice, alhough
>     I understand that is the easiest solution for now.
>
> I believe that we all agree that the 1:1 transparency, although it is a
> default, may not be optimal for real-life usage. HW resources are
> limited and user does not know them. The danger of hitting _abort and
> screwing-up the whole system is huge, unacceptable.
>
> So here, there are couple of more or less simple things that I suggest to
> do in order to move a little bit forward:
> 1) Introduce system-wide option to switch _abort to just plain fail.
>     When HW does not have capacity, do not flush and fallback to sw, but
>     rather just fail to add the entry. This would not break anything.
>     Userspace has to be prepared that entry add could fail.
> 2) Introduce a way to propagate resources to userspace. Driver knows about
>     resources used/available/potentially_available. Switchdev infra could
>     be extended in order to propagate the info to the user.

I currently use the FlowAPI work I presented at netdev conference for
this. Perhaps I was a bit reaching by trying to also push it as a
replacement for the ethtool flow classification mechanism all in one
shot. For what it is worth replacing 'ethtool' flow classifier when
I have a pipeline of tables in a NIC is really my first use case for
the 'set' operations but that is off-topic probably.

The benefits I see of using this interface (or if you want rename
it and push it into a different netlink type) is it gives you the entire
view of the switch resources and pipeline from a single interface. Also
because you are talking about system-wide behaviour above it nicely
rolls up into user space software where we can act on it with the
flags we have for l2 already and if we pursue your option (3) also l3.
I like the single interface vs. scattering the information across many
different interfaces this way we can do it once and be done with it.
If you scatter it across all the interfaces just l2,l3 for now but
we will get more then each interface will have its own mechanism and
I have no idea where you put global information such as table ordering.

IMO we are going to need at least the base operations I outlined when
we want to work on many different pipelines possibly with different
ordering of tables, different amounts of resource sharing (l2 vs l3 vs
acls vs...), different levels of support (mac/vlan or just mac). And I
don't think it fits into an existing netlink structure because its not
specific to any one thing but the model of the hardware.

Also I believe that match/action tables are a really nice way to work
with hardware so this aligns with that. That said I think the interface
would need some tweaks to fit into the current code base. The biggest
one I would want is to make l2/l3 tables 'well-defined' e.g. give them
a #define value so we can always track them down easily, drop the set
operation (at least for now because the tables we have already have
defined interfaces l2/l3  I'll reopen this in the context of extending
flow classification on the NIC), and clean up the action bits so they
are well defined. I've pushed an update to my code on github to restrict
the hardware from exporting arbitrary actions which should be a
reasonable first step.

What do you think? I would like to try to make the above updates and
resubmit if we can get an agreement that "knowing" the hardware
resources and capabilities is useful. It is at least useful for my
software stacks/use cases.

> 3) Introduce couple of flags for entry add that would alter the default
>     behaviour. Something like:
>     	NLM_F_SKIP_KERNEL
>     	NLM_F_SKIP_OFFLOAD
>     Again, this does not break the current users. On the other hand, this
>     gives new users a leverage to instruct kernel where the entry should
>     be added to (or not added to).
>

This would be my choice. Although at least in my use case space I do
not mind making the software stack aware it is offloading rules.

> Any thoughts? Objections?
>
> Thanks!
>
> Jiri
>


-- 
John Fastabend         Intel Corporation
