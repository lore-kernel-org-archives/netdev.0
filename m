From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH 2/3] e1000e: e1000e_cyclecounter_read(): fix er32(SYSTIML) overflow check
Date: Tue, 19 Apr 2016 14:34:45 +0200
Message-ID: <1461069286-31946-2-git-send-email-dvlasenk@redhat.com>
References: <1461069286-31946-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461069286-31946-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If two consecutive reads of the counter are the same, it is also not an overflow.
"systimel_1 < systimel_2" should be "systimel_1 <= systimel_2".

Before the patch, we could perform an *erroneous* correction:

Let's say that systimel_1 == systimel_2 == 0xffffffff.
"systimel_1 < systimel_2" is false, we think it's an overflow,
we read "systimeh = er32(SYSTIMH)" which meanwhile had incremented,
and use "(systimeh << 32) + systimel_2" value which is 2^32 too large.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Shannon Nelson <shannon.nelson@intel.com>
CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
CC: Don Skidmore <donald.c.skidmore@intel.com>
CC: Bruce Allan <bruce.w.allan@intel.com>
CC: John Ronciak <john.ronciak@intel.com>
CC: Mitch Williams <mitch.a.williams@intel.com>
CC: David S. Miller <davem@davemloft.net>
CC: LKML <linux-kernel@vger.kernel.org>
CC: netdev@vger.kernel.org
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 967311b..99d0e6e 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4287,7 +4287,7 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 	systimeh = er32(SYSTIMH);
 	systimel_2 = er32(SYSTIML);
 	/* Check for overflow. If there was no overflow, use the values */
-	if (systimel_1 < systimel_2) {
+	if (systimel_1 <= systimel_2) {
 		systim = (cycle_t)systimel_1;
 		systim |= (cycle_t)systimeh << 32;
 	} else {
-- 
1.8.1.4
