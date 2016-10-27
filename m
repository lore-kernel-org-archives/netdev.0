From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC net-next iproute2 1/2] libnetlink: Add test for error code
 returned from netlink reply
Date: Thu, 27 Oct 2016 09:52:53 +0300
Message-ID: <20161027065253.GB1867@uranus.lan>
References: <1477510208-20292-1-git-send-email-gorcunov@gmail.com>
 <1477510208-20292-2-git-send-email-gorcunov@gmail.com>
 <20161026205256.162e1d25@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Andrey Vagin <avagin@openvz.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33762 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933466AbcJ0Gw4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 02:52:56 -0400
Received: by mail-lf0-f67.google.com with SMTP id n3so1398901lfn.0
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 23:52:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161026205256.162e1d25@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 08:52:56PM -0700, Stephen Hemminger wrote:
> On Wed, 26 Oct 2016 22:30:07 +0300
> Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> 
> >  
> >  				if (h->nlmsg_type == NLMSG_DONE) {
> > +					int len;
> > +
> > +					/*
> > +					 * The kernel reports if there is
> > +					 * no inet-diag module present in
> > +					 * the system via negative length
> > +					 * as error code.
> > +					 */
> > +					if (h->nlmsg_len < NLMSG_LENGTH(sizeof(int))) {
> > +						fprintf(stderr, "Truncated length reply\n");
> > +						return -1;
> > +					}
> > +					len = *(int *)NLMSG_DATA(h);
> > +					if (len < 0) {
> > +						errno = -len;
> > +						if (errno == ENOENT ||
> > +						    errno == EOPNOTSUPP)
> > +							return -1;
> > +						perror("RTNETLINK answers");
> > +						return len;
> > +					}
> >  					found_done = 1;
> >  					break; /* process next filter */
> >  				
> 
> This looks like a mistake in how you implemented the functionality in the kernel.
> Despite what it looks like, all netlink request/reply functionality reports
> errors in current implementation by returning error to the sendmsg request.
> 
> What you added implies that the new kernel api is wrong, or many other usages
> are wrong.  Please fix the kernel.

No. This is not my code. This code has been in kernel for the really long time.
I don't know why you've not been doing such test in libnetlink before.

Actually I've hit this problem accidentaly -- I made a patch 2 from this
set and run it on the machine where kernel was unpatched, ie without
raw-diag module, and I found that we can't figure out if kernel notified
us that some diag module simply not present in the system. And here is
the only way to find it out.
