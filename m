From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: mlx4_en SIOCSHWTSTAMP cycles the link
Date: Tue, 17 Dec 2013 12:26:08 +0100
Message-ID: <20131217112606.GA5307@netboy>
References: <1386786265-6322-1-git-send-email-shawn.bohrer@gmail.com>
 <20131211185438.GC4371@netboy>
 <20131211212801.GB8283@sbohrermbp13-local.rgmadvisors.com>
 <52A986CF.5030004@mellanox.com>
 <20131212152815.GB3938@sbohrermbp13-local.rgmadvisors.com>
 <20131216233415.GA17259@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:46934 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537Ab3LQL0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 06:26:13 -0500
Received: by mail-ea0-f178.google.com with SMTP id d10so2773720eaj.37
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 03:26:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131216233415.GA17259@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 05:34:15PM -0600, Shawn Bohrer wrote:
> On Thu, Dec 12, 2013 at 09:28:15AM -0600, Shawn Bohrer wrote:
> > Below is v2.  It compiles, and boots, but linuxptp doesn't work yet
> > and I haven't looked into why.  I think linuxptp is actually
> > complaining about SIOCSHWTSTAMP not working as expected, but again I
> > haven't really even started debugging yet.
> 
> So performing a SIOCSHWTSTAMP on the mlx4_en driver cycles the link:
> 
> [ 9463.081330] mlx4_en: p2p1: Changing Time Stamp configuration
> [ 9463.084637] mlx4_en: p2p1:   frag:0 - size:1526 prefix:0 align:0 stride:1536
> [ 9463.155533] mlx4_en: p2p1: Link Down
> [ 9466.471169] mlx4_en: p2p1: Link Up
> 
> This breaks linuxptp (ptp4l) since it causes all of the already open
> sockets to silently loose their multicast joins.  Thus ptp4l sits
> there waiting for multicast PTP packets that aren't going to come.

The ptp4l program should notice this and recover. This happens when
catching the transmission error on the next sync or delay request. (Or
in slave only E2E mode the sockets are closed and reopened after every
announce interval). If this isn't happening, please post to the
linuxptp-users list the details of your setup.

> I hacked around this in ptp4l by performing the ioctl once with the
> hwstamp_ctl program from linuxptp and skipping the ioctl in ptp4l,
> which works, but quite frankly this sucks.  I'd love to know if anyone
> has any better ideas on how to make SIOCSHWTSTAMP usable.
> 
> After hacking around the SIOCSHWTSTAMP issue I've noticed that ptp4l
> synchronizes the PHC, however there must be another bug somewhere
> because it creates a 35 second offset from the PTP master.

This is the current TAI-UTC offset. Maybe your grand master is serving
UTC instead of the PTP timescale?

Thanks,
Richard
