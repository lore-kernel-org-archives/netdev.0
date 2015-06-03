From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: change fib behavior based on interface
 link status
Date: Wed, 3 Jun 2015 13:57:27 -0400
Message-ID: <20150603175725.GI588@gospo.home.greyhouse.net>
References: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bDHsoaN6spkOW5jk94wB3wkUBd-j+y3H47611CxZUT6ag@mail.gmail.com>
 <20150603151207.GG588@gospo.home.greyhouse.net>
 <CAE4R7bC=t4fTO8tM85REWu-237VGE2wdR3mcKnasbBybnMBmVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36790 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755997AbbFCR5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 13:57:47 -0400
Received: by qkx62 with SMTP id 62so10025599qkx.3
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 10:57:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bC=t4fTO8tM85REWu-237VGE2wdR3mcKnasbBybnMBmVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 10:40:26AM -0700, Scott Feldman wrote:
> On Wed, Jun 3, 2015 at 8:12 AM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> > On Tue, Jun 02, 2015 at 10:03:23PM -0700, Scott Feldman wrote:
> >> On Tue, Jun 2, 2015 at 8:07 PM, Andy Gospodarek
> >> <gospo@cumulusnetworks.com> wrote:
> >> > This patch adds the ability to have the Linux kernel track whether or
> >> > not a particular route should be used based on the link-status of the
> >> > interface associated with the next-hop.
> >> >
> >> > Before this patch any link-failure on an interface that was serving as a
> >> > gateway for some systems could result in those systems being isolated
> >> > from the rest of the network as the stack would continue to attempt to
> >> > send frames out of an interface that is actually linked-down.  When the
> >> > kernel is responsible for all forwarding, it should also be responsible
> >> > for taking action when the traffic can no longer be forwarded -- there
> >> > is no real need to outsource link-monitoring to userspace anymore.
> >>
> >> Hi Andy, how does this work for the hardware offload case?  I'm not
> >> seeing how hardware gets updated when the software route is updated.
> >> Seems hardware isn't updated and would send frames out the downed nh
> >> interface.
> >
> > Scott, you are correct that this does not currently address the hardware
> > offload case.  If one wanted offloaded hardware to reflect this change,
> > then there needs to be either:
> >
> > - The ability to communicate the flag changes down to offload devices in
> >   the event that they want some action to take place
> >   switchdev_fib_ipv4_modify(), maybe? (Not to derail this convo too much
> >   but it will soon be time to consider what to do at the switchdev layer
> >   when route flags are modified like when the RTNH_F_OFFLOAD flag is
> >   removed by the user if they feel the route does not need to be
> >   offloaded for any reason.)
> 
> Switchdev_fib_ipv4_add() can handle adds and mods, so you can use
> that.  Any place you're sending notification of route change, hook
> switchdev so the offload device is updated with the route change.
I should know better than to ask this, but does just the rocker
implementation presume this operation is an add and modify or was this
the implementation from the beginning.  (Forgive me for not remembering
earlier discussion on this.)

> 
> Please include updates for switchdev for this patch v2.
I knew there was a reason why I should have submitted these patches
earlier.  ;-)

> I'm assuming you're already shipping this feature on offloaded
> switches, so you want it to work with switchdev, right?
Of course I think there is value there and I'm happy to do it.  This is
quite useful in the case of a forwarding element, so having support
switchdev is something I would like to see.

> 
> 
> > - Register a register_netdevice_notifier and take action at the
> >   switchdev layer to make sure that routes can be removed or marked as
> >   inactive when link goes down.
> 
> The core code is already handling the events, so it seems better to
> call into switchdev from core code rather than having two listeners
> potentially handling the event differently.
> 
> -scott
