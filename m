From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH] netlink: add send and receive capability requirement and
 capability flags
Date: Wed, 30 Jan 2013 13:54:40 -0500
Message-ID: <20130130185440.GC11492@shell.eng.rdu.redhat.com>
References: <1358952744-29288-1-git-send-email-rbriggs@redhat.com>
 <20130128.225524.472002600658532532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rbriggs@redhat.com, netdev@vger.kernel.org, eparis@redhat.com,
	sgrubb@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18351 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755447Ab3A3Syn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 13:54:43 -0500
Content-Disposition: inline
In-Reply-To: <20130128.225524.472002600658532532.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 28, 2013 at 10:55:24PM -0500, David Miller wrote:
> From: Richard Guy Briggs <rbriggs@redhat.com>
> Date: Wed, 23 Jan 2013 09:52:24 -0500
> 
> > From: Richard Guy Briggs <rgb@redhat.com>
> > 
> > Currently netlink socket permissions are controlled by the
> > NL_CFG_F_NONROOT_{RECV,SEND} flags in the kernel socket configuration or by the
> > CAP_NET_ADMIN capability of the client.  The former allows non-root users
> > access to the socket.  The latter allows all network admin clients access to
> > the socket.  It would be useful to be able to further restrict this access to
> > send or receive capabilities individually within specific subsystems with a
> > more targetted capability.  Two more flags, NL_CFG_F_CAPABILITY_{RECV,SEND},
> > have been added to specifically require a named capability should the subsystem
> > request it, allowing the client to drop other broad unneeded capabilities.
> > 
> > Signed-off-by: Richard Guy Briggs <rbriggs@redhat.com>
> 
> I've been looking at this over and over again the past few days,
> are you really sure you cannot get the behavior you need within
> the current framework and using existing facilities?

Was there any facility that you can think of or point out that could
provide this functionality?

At the moment, any process with CAP_NET_ADMIN has full access to this
socket.  That uses the default service structure provided by netlink.
We want to restrict this.

Were you thinking along the lines of checking each broadcast subscriber
at send time for the capability in question?  It would seem more
efficient and safer to check them upon subscription.  The code changes
would also be a bit more complex, at first blush.

Could a custom bind function be used instead?  I had looked into that.
I must admit I like this option better in the long term, but it would
also disrupt another subsystem in the process (netfilter).  The bind
function only accepts a group ID and not a socket against which to check
requesting socket owner priveleges.  The custom bind function returns
void so we have no way of signalling a permissions denial.  It is only
used by netfilter at the moment.  Would you be agreeable to adding a
parameter to this function call, and to adding a return value?

Could netlink_setsockopt be used?  When subscribing to a group, it
first checks capabilities, which are limited as described originally
above.  It then calls the custom bind function if it exists.  See
paragraph above.

Thanks for taking the time to mull this one over, David.

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer
AMER ENG Base Operating Systems
Remote, Canada, Ottawa
Voice: 1.647.777.2635
Internal: (81) 32635
