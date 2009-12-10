From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3: link is permanently down after ifdown and ifup
Date: Wed, 9 Dec 2009 17:19:31 -0800
Message-ID: <20091210011931.GA30802@xw6200.broadcom.net>
References: <4B056158.5060104@embedded-sol.com>
 <4B056D85.5010904@embedded-sol.com>
 <1258671053.14964.20.camel@nseg_linux_HP1.broadcom.com>
 <4B1F631E.5030908@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Felix Radensky" <felix@embedded-sol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3263 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755616AbZLJBTa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2009 20:19:30 -0500
In-Reply-To: <4B1F631E.5030908@embedded-sol.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I understand the problem now.  The problem is that tg3_set_power_state()
puts the phy into a low-power mode when it releases the device.  When
the phy is reacquired, a phy reset is missing to take the device back
out of the low-power mode.

The patch at the bottom of this email is the fix I'm currently testing.
If you wish, you can try it out.

On Wed, Dec 09, 2009 at 12:43:10AM -0800, Felix Radensky wrote:
> Hi, Matt
> 
> Did you have a chance to look into this problem ?
> 
> Thanks a lot.
> 
> Felix.
>  
> Michael Chan wrote:
> > On Thu, 2009-11-19 at 08:08 -0800, Felix Radensky wrote:
> >   
> >> Hi,
> >>
> >> The problem goes away if I remove the call to
> >>
> >> tg3_set_power_state(tp, PCI_D3hot);
> >>
> >> from tg3_close().
> >>     
> >
> > Added Matt to CC.  He is on vacation and may not be able to look into
> > this right away.  Thanks.


[PATCH] tg3: Fix 57780 connectivity problems

When management firmware is not present, and WOL is disabled, the driver
will put the phy into a low-power mode when shutting down.  To get out
of low-power mode, the operation must be reversed or the phy must be
reset.

In the past, the phylib reset the phy from either phy_start() or
phy_start_aneg().  This phy reset has been removed from more recent
kernels.  The tg3 driver already has phy reset code in place which is
called when it assumes control of the device.  It is bypassed if phylib
is enabled though.

This patch removes the phylib exception.
---
 drivers/net/tg3.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3a74d21..c0a3080 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7523,8 +7523,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tg3_abort_hw(tp, 1);
 	}
 
-	if (reset_phy &&
-	    !(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB))
+	if (reset_phy)
 		tg3_phy_reset(tp);
 
 	err = tg3_chip_reset(tp);
-- 
1.6.4.4


