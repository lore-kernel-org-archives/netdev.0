From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 7/8] mpls: Multicast route table change notifications
Date: Thu, 26 Feb 2015 08:03:35 -0600
Message-ID: <87oaogn51k.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<87fv9tvrgq.fsf@x220.int.ebiederm.org>
	<54EEC967.20106@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47914 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932161AbbBZOHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:07:08 -0500
In-Reply-To: <54EEC967.20106@cumulusnetworks.com> (roopa@cumulusnetworks.com's
	message of "Wed, 25 Feb 2015 23:21:11 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

roopa <roopa@cumulusnetworks.com> writes:

> On 2/25/15, 9:19 AM, Eric W. Biederman wrote:
>> Unlike IPv4 this code notifies on all cases where mpls routes
>> are added or removed as that was the simplest to implement.
>>
>> In particular routes being removed because a network interface
>> goes down or is removed are notified about.  Are there technical
>> arguments for handling this differently ? Userspace developers
>> don't particularly like the way IPv4 handles route removal
>> on ifdown.
> that is true. However, from previous emails on this topic on netdev,
> there is no reason to notify these deletes to userspace thereby creating a
> notification storm
> when userspace can figure this out. Which seems like a valid reason.
> (Your approach resembles IPv6 which does generate these notifications and
> userspace is usually happy with this).

Grr.  There is an even better way to do this.

The semantically best way to handle this is to simply not use routes for
forwarding where the network inteface is down, the carrier is down, or
the network device has gone away for forwarding.

Apparently there are some multi-path scenearios that already do this
legitimately, and routes going away auto-matically can cause userspace
other kinds of problems.

In MPLS I especially don't want to free the routing table slot until I
know that the change has propagated in the network and I can be
reasonably confident that no-one will send me traffic on that label.
Otherwise there is a chance the label will be reused too soon.

Grumble.  That is a code change I need to make.  Grumble.

I also need to look and see if those multi-path scenarios report a next
hop as dead or just rely on the network interface state (which I think
it is) to be sufficient information relayed to userspace

Eric
