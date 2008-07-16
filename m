From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2: no error message when link up command fails.
Date: Wed, 16 Jul 2008 15:53:54 -0700
Message-ID: <20080716155354.28281053@extreme>
References: <20080716220058.GA31425@amd64.fatal.se>
	<20080716150320.63f20215@extreme>
	<1216247237.31646.12.camel@amd64.fatal.se>
	<20080716152631.04125f56@extreme>
	<1216247722.3422.38.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andreas Henriksson <andreas@fatal.se>,
	stephen.hemminger@vyatta.com, 489340@bugs.debian.org,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:41807 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751200AbYGPWx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 18:53:56 -0400
In-Reply-To: <1216247722.3422.38.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Jul 2008 00:35:22 +0200
Johannes Berg <johannes@sipsolutions.net> wrote:

> 
> > > (By the way, most uses of rtnl_* seems to be if (rtnl_* < 0) exit(1); in
> > > iproute2 currently. The error messages are in libnetlink.)
> 
> > The problem is the driver is responding with an error packet but the
> > errno is 0. This looks like a kernel bug, not an library bug.
> 
> I don't think so, the recvmsg() call worked fine, but the message
> indicates that the netlink consumer had an error. Or am I missing
> something?
> 
> johannes

The netlink message in question is marked as type ERROR but the errno
encoded in the message is zero.

		if (h->nlmsg_type == NLMSG_ERROR) {
			struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
			if (l < sizeof(struct nlmsgerr)) {
				fprintf(stderr, "ERROR truncated\n");
			} else {
				errno = -err->error;
				if (errno == 0) {
					if (answer)
						memcpy(answer, h, h->nlmsg_len);
					return 0;
				}
				perror("RTNETLINK answers");
			}

So the netlink library just treats as a successful return.
To me it looks like the problem is in the kernel sending back
a NLMSG_ERROR with errno of zero. Some code path isn't setting
it up properly.
