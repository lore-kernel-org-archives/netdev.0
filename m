From: Greg KH <gregkh@suse.de>
Subject: [patch 10/51] e1000: fix virtualization bug
Date: Thu, 14 May 2009 15:32:45 -0700
Message-ID: <20090514223521.833331091@mini.kroah.org>
References: <20090514223235.348540705@mini.kroah.org>
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>, Willy Tarreau <w@1wt.eu>,
	Rodrigo Rubira Branco <rbranco@la.checkpoint.com>,
	Jake Edge <jake@lwn.net>, Eugene Teo <eteo@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	chrisw@sous-sol.org, greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:51523 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755993AbZENWmC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2009 18:42:02 -0400
Content-Disposition: inline; filename=e1000-fix-virtualization-bug.patch
In-Reply-To: <20090514223755.GA27019@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


2.6.29-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

[STABLE] backport upstream commit e151a60ad1faffb6241cf7eb6846353df1f33a32

a recent fix to e1000 (commit 15b2bee2) caused KVM/QEMU/VMware based
virtualized e1000 interfaces to begin failing when resetting.

This is because the driver in a virtual environment doesn't
get to run instructions *AT ALL* when an interrupt is asserted.
The interrupt code runs immediately and this recent bug fix
allows an interrupt to be possible when the interrupt handler
will reject it (due to the new code), when being called from
any path in the driver that holds the E1000_RESETTING flag.

the driver should use the __E1000_DOWN flag instead of the
__E1000_RESETTING flag to prevent interrupt execution
while reconfiguring the hardware.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/e1000/e1000_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3712,7 +3712,7 @@ static irqreturn_t e1000_intr(int irq, v
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl, icr = er32(ICR);
 
-	if (unlikely((!icr) || test_bit(__E1000_RESETTING, &adapter->flags)))
+	if (unlikely((!icr) || test_bit(__E1000_DOWN, &adapter->flags)))
 		return IRQ_NONE;  /* Not our interrupt */
 
 	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is


