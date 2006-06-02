From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [FIX] e1000: fix irq sharing when running ethtool test
Date: Fri, 02 Jun 2006 15:19:47 -0700
Message-ID: <4480B983.50702@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020705070209060202050303"
Cc: NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:59564 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751507AbWFBWU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 18:20:26 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020705070209060202050303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



New code added in 2.6.17 caused setup_irq to print a warning when
running ethtool -t eth0 offline.

This test marks the request_irq call made by this test as a "probe" to
see if the interrupt is shared or not.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>


---

Jeff,

Because upstream and upstream-fixes have a whitespace conflict in them, I've 
prepared two separate git branches to pull from so that a subsequent pull or 
merge from upstream-fixes into upstream doesn't resolve into a conflict:

please pull from our git-server:

into upstream:
git-pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream

into upstream-fixes:
git-pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-fixes


Cheers,

Auke


---
  e1000_ethtool.c |    9 ++++++---
  1 file changed, 6 insertions(+), 3 deletions(-)


--------------020705070209060202050303
Content-Type: text/x-patch;
 name="e1000_setup_irq_probe.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e1000_setup_irq_probe.patch"

e1000: fix ethtool test irq alloc as "probe"

New code added in 2.6.17 caused setup_irq to print a warning when
running ethtool -t eth0 offline.

This test marks the request_irq call made by this test as a "probe"
to see if the interrupt is shared or not.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index ecccca3..d1c705b 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -870,13 +870,16 @@ e1000_intr_test(struct e1000_adapter *ad
 	*data = 0;
 
 	/* Hook up test interrupt handler just for this test */
-	if (!request_irq(irq, &e1000_test_intr, 0, netdev->name, netdev)) {
+	if (!request_irq(irq, &e1000_test_intr, SA_PROBEIRQ, netdev->name,
+	                 netdev)) {
 		shared_int = FALSE;
 	} else if (request_irq(irq, &e1000_test_intr, SA_SHIRQ,
 			      netdev->name, netdev)){
 		*data = 1;
 		return -1;
 	}
+	DPRINTK(PROBE,INFO, "testing %s interrupt\n",
+	        (shared_int ? "shared" : "unshared"));
 
 	/* Disable all the interrupts */
 	E1000_WRITE_REG(&adapter->hw, IMC, 0xFFFFFFFF);

--------------020705070209060202050303--
