From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Mon, 15 Jan 2007 08:14:58 -0800
Message-ID: <45ABA882.20806@intel.com>
References: <36D9DB17C6DE9E40B059440DB8D95F52013ABFE9@orsmsx418.amr.corp.intel.com> <4562D207.60301@cj.jp.nec.com> <4573E6FD.3030905@cj.jp.nec.com> <4574C14E.2060108@intel.com> <457E610D.4060908@cj.jp.nec.com> <45872EAC.7050501@cj.jp.nec.com> <45AB4561.8040400@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080207060601070403060706"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Shaw Vrana <shaw@vranix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9357 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750922AbXAOQPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 11:15:08 -0500
To: Kenzo Iwami <k-iwami@cj.jp.nec.com>
In-Reply-To: <45AB4561.8040400@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080207060601070403060706
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Kenzo Iwami wrote:
> With this patch applied, I confirmed that the system doesn't panic.
> I think this patch can fix this problem.
> Does this patch have problems.

Kenzo,

thanks for staying patient while most of us were out or busy. Apart from acknowledging 
that you might have fixed a problem with your patch, we're very reluctant to merge such 
a huge change in our driver that touches much more cases then the one that seems to be 
giving you problems.

I've thought up a much more elegant solution that prevents the driver from asserting the 
swfw semaphore during normal operations by checking the mac LU (link up) register in the 
watchdog. This allows the watchdog task to bypass all PHY checking in case all link 
statuses are OK, and thus removes the big problem that you are seeing.

Attached a version that should apply against most current trees. Please give it a try 
and let us know if this also fixes the problem for you. I will most likely push this 
patch to the netdev tree in any case.

Cheers,

Auke
---

--------------080207060601070403060706
Content-Type: text/x-patch;
 name="e1000_git_link_check_for_change_only.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e1000_git_link_check_for_change_only.patch"


From: Auke Kok <auke-jan.h.kok@intel.com>

e1000: Don't do PHY reads in watchdog unless link status is down

The watchdog runs code that every 2 seconds performs several PHY reads
that are locked with the swfw semaphore, causing the semaphore to be
unavailable for a short time. This is completely unneeded in case the
MAC detects PHY link up (LU).

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

---
 drivers/net/e1000/e1000_main.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 34d8e5d..9660925 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2556,6 +2556,10 @@ e1000_watchdog(unsigned long data)
 	uint32_t link, tctl;
 	int32_t ret_val;
 
+	if ((netif_carrier_ok(netdev)) &&
+	    (E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_LU))
+		goto link_up;
+
 	ret_val = e1000_check_for_link(&adapter->hw);
 	if ((ret_val == E1000_ERR_PHY) &&
 	    (adapter->hw.phy_type == e1000_phy_igp_3) &&
@@ -2684,6 +2688,7 @@ e1000_watchdog(unsigned long data)
 		e1000_smartspeed(adapter);
 	}
 
+link_up:
 	e1000_update_stats(adapter);
 
 	adapter->hw.tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;

--------------080207060601070403060706--
