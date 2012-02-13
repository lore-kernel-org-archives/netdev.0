From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: Disable LRO on FCoE or iSCSI boot
 device
Date: Mon, 13 Feb 2012 11:09:47 -0800
Message-ID: <1329160187.8108.9.camel@HP1>
References: <4F38F1E2.5010807@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Dmitry Kravkov" <dmitry@broadcom.com>
To: "Vasily Averin" <vvs@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2967 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757656Ab2BMTXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 14:23:45 -0500
In-Reply-To: <4F38F1E2.5010807@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2012-02-13 at 15:20 +0400, Vasily Averin wrote:
> Michael, Dmitry,
> 
> Could you please clarify how you have fixed this issue?
> I've noticed very similar problem in CentOS6.2 environment,
> could you please clarify how it's possible to fix or workaround it? 
> 

We made a number of fixes:

1. iscsiuio user daemon no longer logs to the log file in the root fs
during reset.  The longer term fix is to use a different thread for
logging that can block when the fs is not available

2. iscsiuio is locked into memory and won't be swapped out.

3. bnx2x now caches the firmware after initial open:

http://git.kernel.org/?p=linux/kernel/git/davem/net.git;a=commit;h=eb2afd4a622985eaccfa8c7fc83e890b8930e0ab

because request_firmware() may not be able to get the firmware when the
root fs is not available.

These fixes should address all issues involving bnx2x reset during
iSCSI/FCoE/network boot.  RHEL6.2 has #1 and #2 fixes, but not #3.

> On 10/27/2011 at 16:30 -0700, Michael Chan wrote:
> > On Wed, 2011-10-19 at 13:53 -0700, John Fastabend wrote:
> >> As a reference point this works fine in both FCoE and iSCSI stacks
> >> today. The device is reset or link is lost for whatever reason
> >> when the link comes back up the stack logs back in, enumerates
> >> the luns and the scsi stack recovers as expected.
> >>
> >> Firmware should do the equivalent login, lun enumeration, etc as
> >> needed.
> > 
> > Just a quick follow-up on this issue.  Our firmware actually performs
> > the same logout before the reset and login after the reset.  For iSCSI,
> > the problem on our device was actually caused by our userspace daemon
> > logging events to a log file in the root fs.  The file I/O was blocked
> > and the daemon could not proceed to do the important operations during
> > the reset, and this caused filesystem I/O errors.  We have now fixed the
> > problem in the userspace daemon.
> > 
> > For FCoE, there is no logging issue and the root fs failure seems to
> > happen only in a multipath configuration with all paths going down for a
> > short time (caused by reset in this case).  We believe this also affects
> > other devices and not just ours.  We are now working with the multipath
> > maintainer to understand this issue.
> > 
> > So this confirms that the original patch for bnx2x is not needed.
> 
> 
