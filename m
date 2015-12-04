From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next] sfc: check warm_boot_count after other functions
 have been reset
Date: Fri, 4 Dec 2015 08:48:39 +0000
Message-ID: <56615367.30002@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Daniel Pieczko <dpieczko@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:46698 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755372AbbLDIs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 03:48:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

A change in MCFW behaviour means that the net driver must update its record
of the warm_boot_count by reading it from the ER_DZ_BIU_MC_SFT_STATUS
register.

On v4.6.x MCFW the global boot count was incremented when some functions
needed to be reset to enable multicast chaining, so all functions saw the
same value.  In that case, the driver needed to increment its
warm_boot_count when other functions were reset, to avoid noticing it later
and then trying to reset itself to recover unnecessarily.

With v4.7+ MCFW, the boot count in firmware doesn't change as that is
unnecessary since the PFs that have been reset will each receive an MC
reboot notification.  In that case, the driver re-reads the unchanged
value.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 425df3d..c4a0e8a 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2374,8 +2374,19 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 				    1 << MC_CMD_WORKAROUND_EXT_OUT_FLR_DONE_LBN) {
 					netif_info(efx, drv, efx->net_dev,
 						   "other functions on NIC have been reset\n");
-					/* MC's boot count has incremented */
-					++nic_data->warm_boot_count;
+
+					/* With MCFW v4.6.x and earlier, the
+					 * boot count will have incremented,
+					 * so re-read the warm_boot_count
+					 * value now to ensure this function
+					 * doesn't think it has changed next
+					 * time it checks.
+					 */
+					rc = efx_ef10_get_warm_boot_count(efx);
+					if (rc >= 0) {
+						nic_data->warm_boot_count = rc;
+						rc = 0;
+					}
 				}
 				nic_data->workaround_26807 = true;
 			} else if (rc == -EPERM) {
-- 
2.4.3
