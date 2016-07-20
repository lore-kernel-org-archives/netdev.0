From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 1/2] ipaddress: Simplify vf_info parsing
Date: Wed, 20 Jul 2016 22:10:41 +0200
Message-ID: <20160720201041.GA17504@orbyte.nwl.cc>
References: <1464811430-19415-1-git-send-email-phil@nwl.cc>
 <1464811430-19415-2-git-send-email-phil@nwl.cc>
 <CALgkqUq5nedx+wjEur9WVjvYr0pzvL7CMQmHiVtuuB_1PtOZ2Q@mail.gmail.com>
 <20160601220750.GC2729@orbyte.nwl.cc>
 <CALgkqUq8uDErRPMxyDx-M5UQB3v5+tHMyxXpAmK381W_z9KXPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg Rose <gvrose8192@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51781 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753404AbcGTUKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 16:10:43 -0400
Content-Disposition: inline
In-Reply-To: <CALgkqUq8uDErRPMxyDx-M5UQB3v5+tHMyxXpAmK381W_z9KXPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2016 at 03:36:09PM -0700, Greg Rose wrote:
> On Wed, Jun 1, 2016 at 3:07 PM, Phil Sutter <phil@nwl.cc> wrote:
> > On Wed, Jun 01, 2016 at 03:00:08PM -0700, Greg Rose wrote:
> >> On Wed, Jun 1, 2016 at 1:03 PM, Phil Sutter <phil@nwl.cc> wrote:
> >> > Not sure whether I misinterpret commit 7b8179c780a1a, but it looks
> >> > overly complicated. Instead rely upon parse_rtattr_nested() to assign
> >> > the relevant pointer if requested rtattr fields are present.
> >>
> >> I'm not sure if newer iproute2 utilities are supposed to work on older
> >> kernels but if it is you may want to check this against a 2.6.32
> >> kernel.
> >
> > Yes, it is supposed to. Actually I tried, but the old RHEL6 kernel I
> > used didn't export the VF list at all and then I lost motivation.
> >
> > I didn't check all earlier versions of 7b8179c780a1a, was there a stage
> > when it looked like what I'm changing it to?
> 
> I don't think so but your patch looks correct - I mean it looks like
> it should work.
> 
> It's been 5 years since I wrote that original patch and my memory
> isn't so great as to why I didn't just do as your patch does but I
> think it had something to do with not all drivers reporting a spoof
> check value.  However, your patch should handle that case so I see no
> reason not to accept it.  Unfortunately I don't have time or the
> resources at the moment to check it on an older kernel.

OK, I checked the code and your v1 patch again. Here it is for
reference:

http://www.spinics.net/lists/netdev/msg175377.html

The issue back then was related to the existence of struct ifla_vf_info
which you extended and thus created and incompatibility with older
kernel's headers. This potential problem went away with the introduction
of uapi headers in kernel commit 607ca46e97a1b, as in
include/uapi/linux/if_link.h named structure doesn't even exist anymore.

The netlink interface between kernel and userspace is safe in that
regard: The returned message is merely a list of struct rtattr buffers,
and parse_rtattr_nested() as used in print_vfinfo() iterates over this
list and populates struct rtattr *vf[] with pointers into that buffer.
So in case a given identifier (IFLA_VF_SPOOFCHK in this case) is not
present in the message returned by the kernel, the respective field in
'vf' will just remain a null pointer.

Please note that the above applies to recent kernels as well as older
ones, so the procedure is backward-compatible.

Furthermore, my patch eliminates a potential bug in iproute2 which is
triggered when the kernel at some point decides to not send the
IFLA_VF_SPOOFCHK buffer immediately after IFLA_VF_TX_RATE. This is
perfectly valid in netlink, thus such assumption categorically wrong.

Stephen, please reconsider this patch as it merely aligns print_vfinfo()
with all other places parsing rtnetlink messages, like e.g.
print_linkinfo().

Thanks, Phil
