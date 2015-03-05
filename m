From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 7/8] mpls: Multicast route table change
 notifications
Date: Wed, 4 Mar 2015 20:56:06 -0500
Message-ID: <20150305015606.GD1551@gospo>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
 <87fv9tvrgq.fsf@x220.int.ebiederm.org>
 <54EEC967.20106@cumulusnetworks.com>
 <87oaogn51k.fsf@x220.int.ebiederm.org>
 <54EF37E2.1040506@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:45727 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147AbbCEB4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 20:56:11 -0500
Received: by qcwb13 with SMTP id b13so3144070qcw.12
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 17:56:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54EF37E2.1040506@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 07:12:34AM -0800, roopa wrote:
> On 2/26/15, 6:03 AM, Eric W. Biederman wrote:
> >roopa <roopa@cumulusnetworks.com> writes:
> >
> >>On 2/25/15, 9:19 AM, Eric W. Biederman wrote:
> >>>Unlike IPv4 this code notifies on all cases where mpls routes
> >>>are added or removed as that was the simplest to implement.
> >>>
> >>>In particular routes being removed because a network interface
> >>>goes down or is removed are notified about.  Are there technical
> >>>arguments for handling this differently ? Userspace developers
> >>>don't particularly like the way IPv4 handles route removal
> >>>on ifdown.
> >>that is true. However, from previous emails on this topic on netdev,
> >>there is no reason to notify these deletes to userspace thereby creating a
> >>notification storm
> >>when userspace can figure this out. Which seems like a valid reason.
> >>(Your approach resembles IPv6 which does generate these notifications and
> >>userspace is usually happy with this).
> >Grr.  There is an even better way to do this.
> >
> >The semantically best way to handle this is to simply not use routes for
> >forwarding where the network inteface is down, the carrier is down, or
> >the network device has gone away for forwarding.
> 
> agreed, And we have an internal patch that does this for regular routing
> on carrier down (which we will upstream soon).
Yep, I should be able to easily forward-port it from 3.17 to net-next
without much issue.  Eric feel free to email me directly if you want to
see what I've got now.

> >
> >Apparently there are some multi-path scenearios that already do this
> >legitimately, and routes going away auto-matically can cause userspace
> >other kinds of problems.
> >
> >In MPLS I especially don't want to free the routing table slot until I
> >know that the change has propagated in the network and I can be
> >reasonably confident that no-one will send me traffic on that label.
> >Otherwise there is a chance the label will be reused too soon.
> ack
> >
> >Grumble.  That is a code change I need to make.  Grumble.
> >
> >I also need to look and see if those multi-path scenarios report a next
> >hop as dead or just rely on the network interface state (which I think
> >it is) to be sufficient information relayed to userspace
> >
> they are marked DEAD on ifdown today (AFAIR they dont generate a
> notification in IPv4)  and are skipped during route lookup.
> Only when all the nexthops in a multi-path route are dead, is the route
> multipath route declared dead
> and is deleted today (with no notification to userspace in the IPv4 case).
> 
> Thanks,
> Roopa
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
