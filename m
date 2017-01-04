From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH] Ipvlan should return an error when an address is already
 in use.
Date: Wed, 4 Jan 2017 02:04:25 -0800
Message-ID: <20170104100425.GE3009@templeofstupid.com>
References: <20161231041058.GC2448@templeofstupid.com>
 <20170101.222632.843875843588487678.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kjlx@templeofstupid.com, maheshb@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:48107 "EHLO
        homiemail-a124.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965087AbdADKkR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 05:40:17 -0500
Received: from homiemail-a124.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a124.g.dreamhost.com (Postfix) with ESMTP id EA22660000D01
        for <netdev@vger.kernel.org>; Wed,  4 Jan 2017 02:40:16 -0800 (PST)
Received: from kmjvbox (c-73-70-90-212.hsd1.ca.comcast.net [73.70.90.212])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a124.g.dreamhost.com (Postfix) with ESMTPSA id D3D4560000D06
        for <netdev@vger.kernel.org>; Wed,  4 Jan 2017 02:40:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170101.222632.843875843588487678.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 01, 2017 at 10:26:32PM -0500, David Miller wrote:
> From: Krister Johansen <kjlx@templeofstupid.com>
> Date: Fri, 30 Dec 2016 20:10:58 -0800
> 
> > The ipvlan code already knows how to detect when a duplicate address is
> > about to be assigned to an ipvlan device.  However, that failure is not
> > propogated outward and leads to a silent failure.  This teaches the ip
> > address addition functions how to report this error to the user
> > applications so that a notifier chain failure during ip address addition
> > will not appear to succeed when it actually has not.
> > 
> > This can be especially useful if it is necessary to provision many
> > ipvlans in containers.  The provisioning software (or operator) can use
> > this to detect situations where an ip address is unexpectedly in use.
> > 
> > Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
> 
> Your patch isn't handling the case of primary address promotions,
> which also issue NETDEV_UP events on these notifier chains.
> 
> But on a more basic level, it's extremely important that once you
> start using the notifier_{from,to}_errno() handling for a notifier,
> you must start doing so for all such cases of that notifier.

Thanks for taking a look.  I'm relatively new to this area of the code.
I do appreciate the feedback.

In terms of interpreting your final comment, does that mean any call on
the inetaddr_chain or inet6addr_chain, and if so would that include all
callers of call_netdevice_notifiers()?

Another concern that I had with my approach was that the
blocking_notifier_call_chain() occurs after a rtmsg_ifa(RTM_NEWADDR)
call.  In the places where I put rollback code, the address delete ends
up generating a corresponding rtmsg_ifa(RTM_DELADDR).  This is likely to
emit messages that make it look like the address was created and
deleted, except that the validation failed before creation was
completed.  Is the rtmsg_ifa() call consumed by other listeners in the
kernel, or is this purely a generation of a rtnetlink message for
applications listening in userland?

More generally, is using the notifier_call_chain a reasonable way of
getting this error information back to userland or would a different
approach be better?  I'm also concerned about the cases where the code
currently treats these invocations as atomic.  I had considered
introducing an alternate chain that might allow us to check that the
operation is valid prior to committing the change, but that seemed
potentially racy and that it might involve a lot of extra mechanism.

-K
