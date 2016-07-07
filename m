From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Thu, 7 Jul 2016 13:17:18 +0200
Message-ID: <20160707111718.GL620@orbyte.nwl.cc>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
 <87twg4ywjz.fsf@x220.int.ebiederm.org>
 <20160705205103.GE620@orbyte.nwl.cc>
 <87h9c259ip.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:39104 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405AbcGGLRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 07:17:20 -0400
Content-Disposition: inline
In-Reply-To: <87h9c259ip.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Jul 06, 2016 at 11:58:54PM -0500, Eric W. Biederman wrote:
> Phil Sutter <phil@nwl.cc> writes:
> 
> > Hi Eric,
> >
> > Thanks for your quick and insightful reply rightfully pointing out the
> > lack of rationale behind this change. So let me try to catch up:
> 
> Grr.  I did not get what you are trying to accomplish the first time I
> skimmed this and rereading it all again closely I still don't get what
> you are trying to acomplish.

Maybe I did not get what information you are missing. Communication
issues always include two parties. :)

> What real world scenario do you have that approximates 100 mount
> namespaces all sharing with each other with 1000 network namespaces
> in that shared world?
> 
> I am inclined to suspect you are setting up containers that don't
> contain and those 100 mount namespaces that share with each other
> are your real concern.  But I don't know.

The issue came up during OpenStack Neutron testing, see this ticket for
reference:

https://bugzilla.redhat.com/show_bug.cgi?id=1310795

> > On Tue, Jul 05, 2016 at 09:44:00AM -0500, Eric W. Biederman wrote:
> >> Phil Sutter <phil@nwl.cc> writes:
> >> 
> >> > Stress-testing OpenStack Neutron revealed poor performance of 'ip netns'
> >> > when dealing with a high amount of namespaces. The cause of this lies in
> >> > the combination of how iproute2 mounts NETNS_RUN_DIR and the netns files
> >> > therein and the fact that systemd makes all mount points of the system
> >> > shared.
> >> 
> >> So please tell me.  Given that it was clearly a deliberate choice in the
> >> code to make these directories shared, and that this is not a result
> >> of a systemd making all directories shared by default.  Why is it
> >> better to these directories non-shared?
> >
> > NETNS_RUN_DIR itself is kept shared as it was intended by you (I hope).
> > The only difference is that we should avoid it being in the same group
> > as the parent mount point. Otherwise, all netns mount points will occur
> > twice.
> 
> How do they occur twice?  Are you dealing with a system that bind mounts
> /run and /var/run?  The netns mount points occurring twice sounds
> correct in that scenario.  Replacing a bind mount with a symlink would
> be a more appropriate fix if you are concerned with the mount overhead.

In RHEL7, /var/run is a symlink to ../run. /run itself is a tmpfs mount.
After creating a namespace 'foo', findmnt lists /run/netns/foo as a
child of /run and /run/netns, hence it occurs twice in mount output.

> > Regarding the shared state of the netns mount points, I have actually no
> > idea what's the benefit, as there won't be any child mount points and
> > therefore no propagation should occur. Or am I missing something?
> 
> I think the second patch is probably ok.  I get turned around with the
> finer points of mount propagation somedays as it is the parent mount
> whose attributes matter when it comes to propagating the children.  
> 
> Still if the change semantically does not matter we have a missing
> optimization in the kernel, and I would much rather implement that
> optmization in the kernel than in every application that might possibly
> hit it.  Especially given that the default on systemd systems is
> "mount --make-rshared /"

Which change are you talking about that semantically does not matter?

> >> This may be the appropriate change but saying you stress testing things
> >> and have a problem but do not describe how large a scale you had a
> >> problem, or anything else to make your problem reproducible by anyone
> >> else makes it difficult to consider the merits of this change.
> >> 
> >> Sometimes things are a good default policy but have imperfect scaling on
> >> extreme workloads.
> >> 
> >> My experience with the current situtation with ip netns is that it
> >> prevents a whole lot of confusion by making the network namespace names
> >> visible whichever mount namespace your processes are running in.
> >
> > The only functional difference I noticed was the no longer twice
> > appearing netns mount points. They are still visible in all namespaces
> > though, just as before.
> 
> But you are fighting the how the rest of the system is configured at
> that point and that concerns me.  iproute is not the place to
> reconfigure the system.

But iproute is in control of /run/netns mount point, at least in that it
manipulates it's propagation flags. Therefore it should try to not cause
unexpected results irrespective of how the parent mount point is set up
by the system.

> > Here's the script I wrote to benchmark 'ip netns':
> >
[...]
> >
> > As you can see, the biggest improvement comes during deletion and from
> > patch 1. Though the second patch lowers the total time to delete the
> > namespaces by another second, which is still relatively much in
> > comparison to the low total time.
> 
> Which all seems to be about making /run/netns and /var/run/netns not
> shared with each other which appears to be semantically wrong.

No, it's basically about not making /run and /run/netns not shared with
each other since that is unnecessary.

I hope this clarifies things a bit.

Cheers, Phil
