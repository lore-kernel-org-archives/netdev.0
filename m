From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: PHC device sharing between PCI functions
Date: Fri, 5 Jul 2013 07:25:48 +0200
Message-ID: <20130705052546.GA6422@netboy>
References: <20130702142420.GC14630@netboy>
 <1372778262.1919.12.camel@bwh-desktop.uk.level5networks.com>
 <20130703183035.GA4446@netboy>
 <1372881153.1919.49.camel@bwh-desktop.uk.level5networks.com>
 <20130704053605.GC4457@netboy>
 <1372948466.1853.1.camel@bwh-desktop.uk.level5networks.com>
 <20130704155339.GA15214@netboy>
 <1372954878.1853.6.camel@bwh-desktop.uk.level5networks.com>
 <20130704173925.GA4429@netboy>
 <1372961945.1853.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Laurence Evans <levans@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:45783 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749Ab3GEF0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 01:26:00 -0400
Received: by mail-wi0-f169.google.com with SMTP id c10so7859664wiw.0
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 22:25:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1372961945.1853.9.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 04, 2013 at 07:19:05PM +0100, Ben Hutchings wrote:

> The functions that are intended to be assigned to guests will still
> appear and may have a driver bound to them in the host before they are
> assigned to guests.

Okay, then to answer your question...

> On Thu, 2013-07-04 at 19:39 +0200, Richard Cochran wrote:
> > On Thu, Jul 04, 2013 at 05:21:18PM +0100, Ben Hutchings wrote:
> > > 
> > > But that is the opposite of what we're talking about.  Say the card has,
> > > 16 functions resulting in net devices eth0-eth15, each of which can
> > > access the same physical clock.  You said it's OK to have read-only
> > > aliases for a clock, so then there might be a writable /dev/ptp0 and
> > > read-only /dev/ptp1-ptp15.  What is the proper association between net
> > > devices and clock devices?

I would say simply:

	ethtool -T eth0  -> phc index 0  RDWR
	ethtool -T eth1  -> phc index 1  RDONLY
	...
	ethtool -T eth15 -> phc index 15 RDONLY

The numbering might come out differently, but it should be 1:1.

The userland PTP stack will just have to be configured to make sense
of this. For example, the host can just use eth0/ptp0 normally. For
the guests, in ptp4l we have a "free_running" option that leaves the
clock alone and just calculates phase and frequency offset.

Local applications can use this information to synchronize to the
remote master. (BTW this method is specified by 802.1AS). Also, you
can discipline the system clock by measuring the sys-phc offset and
adding the phc-master offset.

If the clocks set their .max_adj to zero, then the fact that they are
read only is discoverable.

Thanks,
Richard
