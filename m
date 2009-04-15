From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast
	messages
Date: Wed, 15 Apr 2009 12:38:12 -0400
Message-ID: <20090415163812.GD21448@hmsreliant.think-freely.org>
References: <20090414182731.GD14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141447310.30596@qirst.com> <20090414204445.GB17196@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141740280.3973@qirst.com> <20090415110714.GA21448@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904150841550.10217@qirst.com> <20090415142208.GB21448@hmsreliant.think-freely.org> <49E5F1FF.1000801@hp.com> <20090415155702.GC21448@hmsreliant.think-freely.org> <49E6063B.3040107@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42412 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393AbZDOQiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 12:38:24 -0400
Content-Disposition: inline
In-Reply-To: <49E6063B.3040107@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2009 at 12:07:23PM -0400, Vlad Yasevich wrote:
> Neil Horman wrote:
> > On Wed, Apr 15, 2009 at 10:41:03AM -0400, Vlad Yasevich wrote:
> >> Neil Horman wrote:
> >>> On Wed, Apr 15, 2009 at 08:51:35AM -0400, Christoph Lameter wrote:
> >>>> On Wed, 15 Apr 2009, Neil Horman wrote:
> >>>>
> >>>>>> How are you going to do this?
> >>>>> I'm going to write each application to use 2 sockets, one bound to each
> >>>>> multicast group.  Thats the way it works now.  I think you missed the obvious in
> >>>>> your construction of this example.
> >>>> Ok it could be done with binding. But you would need 3 sockets. One per MC
> >>>> groups bound to a MC group each and then one for the replies (hmmm...
> >>>> looks like you could use SO_BINDTODEVICE on one socket to get around the
> >>> Depending on your setup, 2 is perfectly sufficient.  In fact 1 can be sufficient
> >>> if you want to filter in your application, but we've been over that.
> >>>
> >>>> third one --there is even an exception case for this in inet_bind causing
> >>>> more weird semantics-- but then the application needs to know the device
> >>>> name of the NIC, argh)
> >>> Of course it does, but thats zero incremental cost, since you need to know the
> >>> device name anyway, when specifying the ifindex to the join request.
> >>>
> >>>>>> Its trivial to do with this patch and one
> >>>>>> socket in each process listening to port 4711 that subscribes to the
> >>>>>> necessary multicast groups.
> >>>>> Its trivial without the patch as well.
> >>>> I do not see how you can justify making such a statement.
> >>>>
> >>> I find it justified because I don't see an application using 2 or 3 sockets and a poll or
> >>> select call as anything more than trivial.  If you find that to be non-trivial,
> >>> perhaps a refresher programming course might be in order for you?
> >>>
> >>>>> It boils down to this:  This is the way multicast subscriptions have worked in
> >>>>> bsd, linux, and presumably various other unix and non-unix operating systems for
> >>>>> lord only knows how long.  Provide some documentation that shows its in
> >>>>> violation of a newer standard, or that it is common practice to behave
> >>>>> differently on another OS (such that including this directive would make porting
> >>>>> easier).  As it stands currently, this patch only serves to create a crutch to
> >>>>> perpetuate misundersandings about how the behavior currently works.
> >>>> The way things work is counterintuitive and leads to weird code constructs
> >>>> with the application having to manage multiple sockets because weird
> >>>> semantics have developed over the years.
> >>> The way things work is counterintuitive to _you_ (is it was to me a few months
> >>> ago).  That asside, I came to understand how this actually works, how it has
> >>> worked for decades, and how programmers have successfully written applications
> >>> that use this model over that time period.  Can we modify the model?  Sure.
> >>> Should we?  I certainly don't see any need, given that it does little except
> >>> change the model.  For those who understand it, its compltely useless.  I'm
> >>> willing to concede that I'm wrong, but not without some modicum of evidence that
> >>> this change will benefit existing applications.  If some other operating system
> >>> adheres to the model you expect it to, perhaps this has legs, but I don't know
> >>> of any that do.  The current model, even if counter intuitive, is well defined,
> >>> well understood, and documented.  I fail to see how adding an alternate,
> >>> undocumented model (that may itself be counterintuitive to all the developers
> >>> who have developed under the current model) adds anything significant.
> >>>
> >>> Neil
> >> Hi Neil
> >>
> >> This has been somewhat bugging me for a while, so I went digging.
> >>
> >> Here is a rather pertinent text that points out that we "might" have a bug.
> >> RFC 4607:
> >>
> >> 4.2.  Requirements on the Host IP Module
> >>
> >>    An incoming datagram destined to an SSM address MUST be delivered by
> >>    the IP module to all sockets that have indicated (via Subscribe) a
> >>    desire to receive data that matches the datagram's source address,
> >>    destination address, and arriving interface.  It MUST NOT be
> >>    delivered to other sockets.
> >>
> > I'll let David respond more fully, since I'm not familiar with this RFC, but a
> > quick read would suggest that (from the abstract), this only applies to a subset
> > of addresses, which are not being used in the application in question here.
> > From what I read, the RFC defines an extenstion to the sockets api which allows
> > you to subscribe to a multicast group from a specific source, using one of the
> > reserved muticast ranges provided in the abstract.  It appears that we support
> > this RFC via the IP_ADD_SOURCE_MEMBERSHIP socket option.  Now, if we allow
> > sockets that issue IP_ADD_SOURCE_MEMBERSHIP calls to receive datagrams from
> > multicast addresses within the range defined by the rfc from other sources that
> > they have not subscribed to, yes we have a bug, but thats not overly relevant I
> > think to Christophs problem, since he's using the any-source model, and its
> > corresponding addresses.  Switching to the specific-source model would solve his
> > immeidate problem here that we've been debating, but would likely introduce a
> > new set, in that he would then have to write his app to subscribe to the myrriad
> > of sources that are sending to that multicast group.
> 
> The problem is that if an application follows an IP_ADD_MEMBERSHIP call with
> an IP_BLOCK_SOURCE call, thus extending the exclude the list, we would still
> deliver packets that don't match the multicast destination.  That violates the
> above SSM requirement.  It appears to be an API bug that allows for a violation
> of the protocol specification.
> 
Ok, but IP_BLOCK_SOURCE is part of the any-source api, not the SSM api (although
it allows it).  I agree what you've described is a bug, but its a bug against
the SSM RFC, not RFC 3678, which is what Christoph is using based on the
selection of his multicast address being outside the range of that defined by
SSM.

> > 
> >> Additionally, RFC 3678 describes IP_ADD_MEMBERSHIP as an 'any-source group'
> >> and is allowed by the SSM spec.  This is also how it is implemented in the kernel.
> >> However, we do not appear to perform the filtering required by the above quoted
> >> section 4.2.  
> > Very true, so we may have a bug in the SSM model, but again, thats not what
> > Christoph is using, its the any-source model, using group address unrelated to
> > the ssm RFC.
> > 
> 
> See above.  IP_ADD_MEMBERSHIP is also part of the ssm model since it can be
> followed with IP_BLOCK_SOURCE.  They have to work together, but the socket matching
> code is ignoring it if it can't find the multicast in the socket's list.
> 
Also see above, hes using multicast group 239.x.x.x.  SSM only encompases
addresses in the 232.0.0.1 to 232.255.255.255 range.  He's using ASM not SSM,
regardless of what SSM allows.  I agree it sounds like we have a bug in SSM
behavior, but its not overly relevant to this discussion (saving for the fact
that his new feature would inadvertantly fix the bug, in addition to altering
ASM behavior).  If we want to fix the SSM bug, thats great, lets fix it, but
lets not do it by introducing a new behavior to ASM.

And thats all moot anyway, becaues Christoph (unless I'm mistaken) is not, and
does not want to restrict source sending privlidges.  He wants to get data on
multicast groups from all/any source, he just doesn't want to get multicast data
from groups he didn't explicitly join in the app doing the receiving, which is
exactly what you can currently use bind for.

Neil

> -vlad
> 
> > In particular, if we fail to match the 'datagram's destination address',
> >> we deliver the packet, which I believe is in violation of the "MUST NOT" above.
> >>
> > I think only if the SSM model is used via the socket extensions the RFC
> > describes.  If Christophs app is subscribing via IP_ADD_SOURCE_MEMBERSHIP, then
> > yes, we have a problem.  But everything I've read says he uses the standard, any-source
> > IP_ADD_MEMBERSHIP option which I think makes assertions from RFC 4607 void.
> > Christoph, are you using IP_ADD_SOURCE_MEMBERSHIP?
> > 
> > Neil
> > 
> >> I've CC'd Dave Stevens, since I'd like to hear his opinion regarding this text.
> >>
> >> Thanks
> >> -vlad
> >>
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> 
