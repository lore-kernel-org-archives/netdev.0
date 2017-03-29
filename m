From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next] rtnl: Add support for netdev event to link
 messages
Date: Wed, 29 Mar 2017 13:05:37 -0400
Message-ID: <8c2ab762-5b76-7a70-a096-51529d8a3edb@redhat.com>
References: <1490493587-25819-1-git-send-email-vyasevic@redhat.com>
 <20170327.155835.1930829109806331326.davem@davemloft.net>
 <2fe31fc9-2837-91a7-e2a4-7937bb15cf3d@redhat.com>
 <58DBE2D9.10509@cumulusnetworks.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58794 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752256AbdC2RFj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 13:05:39 -0400
In-Reply-To: <58DBE2D9.10509@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2017 12:37 PM, Roopa Prabhu wrote:
> On 3/29/17, 5:23 AM, Vlad Yasevich wrote:
>> [ resending to list.  hit the wrong reply button last time ]
>>
>> On 03/27/2017 06:58 PM, David Miller wrote:
>>> From: Vladislav Yasevich <vyasevich@gmail.com>
>>> Date: Sat, 25 Mar 2017 21:59:47 -0400
>>>
>>>> RTNL currently generates notifications on some netdev notifier events.
>>>> However, user space has no idea what changed.  All it sees is the
>>>> data and has to infer what has changed.  For some events that is not
>>>> possible.
>>>>
>>>> This patch adds a new field to RTM_NEWLINK message called IFLA_EVENT
>>>> that would have an encoding of the which event triggered this
>>>> notification.  Currectly, only 2 events (NETDEV_NOTIFY_PEERS and
>>>> NETDEV_MTUCHANGED) are supported.  These events could be interesting
>>>> in the virt space to trigger additional configuration commands to VMs.
>>>> Other events of interest may be added later.
>>>>
>>>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>>> At what point do we start providing the metadata for the changed
>>> values as well?  You'd probably need to provide both the old and
>>> new values to cover all cases.
>> I don't think if that would be possible because of when events are triggered.
>> We send these notifications after all the changes have already been made, so
>> it might be tough to carry old data.
>>
>> Looking at just the two events I am supporting in this patch, we could actually
>> supply the old mtu data through a NETDEV_PRECHANGEMTU event, if it is necessary.
> 
> But, NETDEV_PRECHANGEMTU will be a unnecessary notification to userspace without
> changes. There are already enough notifications generated for links (I know you are not
> suggesting adding it here)

Actually, this one already triggers a link notification to userspace.  It just has
no event data in it to tell you that. :)

>> For the use cases I am looking at, it isn't usefull, but easy enough to add.
>>
> Most of the times a single notification can carry multiple changes, this helps user-space..by
> cutting down on notifications in systems with large number of links. I don't see IFLA_EVENT attribute
> handle multiple changes..
> 

No it doesn't handle multiple changes mainly because we already generate a link
notification for a lot of the events.  This patch doesn't add any additional user space
notifications.  All it does is add the "event" information to existing ones so that user
space may know what happened.

For instance, if you change the mtu on an interface, you get the following:

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

The above is the result when you run
 # ip l s lo mtu 1500

With this patch, you'd be able to tell that the notification 2 above was a result of mtu
change.  The first one was a result of "PRECHANGEMTU".  Didn't look to see what the
third one is.

> Given the number of attributes for which events are generated, I think a model where user-space
> maintains a cache and diff's the new link object with the old one works best in all cases.
> 

This patch doesn't preclude this.  It doesn't change how many notifications are generated.
 All it does is a carry a hint as to why a particular notification is generated.

It's also impossible to tell what happened if the data did not change.  As and example,
how does one know that a NETDEV_NOTIFY_PEERS or NETDEV_IGMP_RESEND netdev event occurred?

And if you ask why we need those, consider a case where a VM is connected to the network
through a bridge or macvtap on top of active-backup bond.  Now, there is failover
in the bond and bond generates the above events.  The hypervisor will update the switches
with its own mac/multicast groups, but the VM has no idea this happened.

-vlad
