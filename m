From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 7/8] mpls: Multicast route table change notifications
Date: Thu, 26 Feb 2015 07:12:34 -0800
Message-ID: <54EF37E2.1040506@cumulusnetworks.com>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org> <87fv9tvrgq.fsf@x220.int.ebiederm.org> <54EEC967.20106@cumulusnetworks.com> <87oaogn51k.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:42479 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733AbbBZPMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 10:12:37 -0500
Received: by iecrp18 with SMTP id rp18so16321098iec.9
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 07:12:36 -0800 (PST)
In-Reply-To: <87oaogn51k.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/26/15, 6:03 AM, Eric W. Biederman wrote:
> roopa <roopa@cumulusnetworks.com> writes:
>
>> On 2/25/15, 9:19 AM, Eric W. Biederman wrote:
>>> Unlike IPv4 this code notifies on all cases where mpls routes
>>> are added or removed as that was the simplest to implement.
>>>
>>> In particular routes being removed because a network interface
>>> goes down or is removed are notified about.  Are there technical
>>> arguments for handling this differently ? Userspace developers
>>> don't particularly like the way IPv4 handles route removal
>>> on ifdown.
>> that is true. However, from previous emails on this topic on netdev,
>> there is no reason to notify these deletes to userspace thereby creating a
>> notification storm
>> when userspace can figure this out. Which seems like a valid reason.
>> (Your approach resembles IPv6 which does generate these notifications and
>> userspace is usually happy with this).
> Grr.  There is an even better way to do this.
>
> The semantically best way to handle this is to simply not use routes for
> forwarding where the network inteface is down, the carrier is down, or
> the network device has gone away for forwarding.

agreed, And we have an internal patch that does this for regular routing
on carrier down (which we will upstream soon).
>
> Apparently there are some multi-path scenearios that already do this
> legitimately, and routes going away auto-matically can cause userspace
> other kinds of problems.
>
> In MPLS I especially don't want to free the routing table slot until I
> know that the change has propagated in the network and I can be
> reasonably confident that no-one will send me traffic on that label.
> Otherwise there is a chance the label will be reused too soon.
ack
>
> Grumble.  That is a code change I need to make.  Grumble.
>
> I also need to look and see if those multi-path scenarios report a next
> hop as dead or just rely on the network interface state (which I think
> it is) to be sufficient information relayed to userspace
>
they are marked DEAD on ifdown today (AFAIR they dont generate a 
notification in IPv4)  and are skipped during route lookup.
Only when all the nexthops in a multi-path route are dead, is the route 
multipath route declared dead
and is deleted today (with no notification to userspace in the IPv4 case).

Thanks,
Roopa
