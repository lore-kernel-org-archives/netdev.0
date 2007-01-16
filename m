From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Tue, 16 Jan 2007 17:42:19 +0900
Message-ID: <45AC8FEB.5090102@cj.jp.nec.com>
References: <36D9DB17C6DE9E40B059440DB8D95F52013ABFE9@orsmsx418.amr.corp.intel.com> <4562D207.60301@cj.jp.nec.com> <4573E6FD.3030905@cj.jp.nec.com> <4574C14E.2060108@intel.com> <457E610D.4060908@cj.jp.nec.com> <45872EAC.7050501@cj.jp.nec.com> <45AB4561.8040400@cj.jp.nec.com> <45ABA882.20806@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Shaw Vrana <shaw@vranix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:59259 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932451AbXAPImz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 03:42:55 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <45ABA882.20806@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thank you for your comment.

> thanks for staying patient while most of us were out or busy. Apart from acknowledging 
> that you might have fixed a problem with your patch, we're very reluctant to merge such 
> a huge change in our driver that touches much more cases then the one that seems to be 
> giving you problems.
> 
> I've thought up a much more elegant solution that prevents the driver from asserting the 
> swfw semaphore during normal operations by checking the mac LU (link up) register in the 
> watchdog. This allows the watchdog task to bypass all PHY checking in case all link 
> statuses are OK, and thus removes the big problem that you are seeing.
> 
> Attached a version that should apply against most current trees. Please give it a try 
> and let us know if this also fixes the problem for you. I will most likely push this 
> patch to the netdev tree in any case.

I tried your patch. Unfortunately, the system still panicked with the
same symptom.

In your patch, e1000_update_stats() is still called by e1000_watchdog().
And, e1000_update_stats() calls e1000_read_phy_reg().
Therefore, interrupt handler tires to acquire the semaphore.
As a result, the same problem still occurs.

To fix this problem, interrupt handler must not call e1000_read_phy_reg()
while the interrupted code is holding the semaphore.

My patch may seem like a huge change, but in essence the change is
pretty simple.

In my patch, the interrupt handler code will check whether the interrupted
code is holding the swfw semaphore. If it is held, the watchdog function
is deferred until swfw semaphore is released.
The modification is for the interrupted code which is holding the
semaphore, and the interrupt handler, so they are both directly related
to this problem.

I will try to add some comments to my code to make it more readable.
--
  Kenzo Iwami (k-iwami@cj.jp.nec.com)

