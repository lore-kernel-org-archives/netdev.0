From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 12/13] sfc: Fix timekeeping in efx_mcdi_poll()
Date: Sat, 1 Dec 2012 04:44:19 +0000
Message-ID: <1354337059.2640.51.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26201 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994Ab2LAEoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:44:22 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_mcdi_poll() uses get_seconds() to read the current time and to
implement a polling timeout.  The use of this function was chosen
partly because it could easily be replaced in a co-sim environment
with a macro that read the simulated time.

Unfortunately the real get_seconds() returns the system time (real
time) which is subject to adjustment by e.g. ntpd.  If the system time
is adjusted forward during a polled MCDI operation, the effective
timeout can be shorter than the intended 10 seconds, resulting in a
spurious failure.  It is also possible for a backward adjustment to
delay detection of a areal failure.

Use jiffies instead, and change MCDI_RPC_TIMEOUT to be denominated in
jiffies.  Also correct rounding of the timeout: check time > finish
(or rather time_after(time, finish)) and not time >= finish.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 3ef71a0..0095ce9 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -22,7 +22,7 @@
  **************************************************************************
  */
 
-#define MCDI_RPC_TIMEOUT       10 /*seconds */
+#define MCDI_RPC_TIMEOUT       (10 * HZ)
 
 #define MCDI_PDU(efx)							\
 	(efx_port_num(efx) ? MC_SMEM_P1_PDU_OFST : MC_SMEM_P0_PDU_OFST)
@@ -120,7 +120,7 @@ static void efx_mcdi_copyout(struct efx_nic *efx, u8 *outbuf, size_t outlen)
 static int efx_mcdi_poll(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
-	unsigned int time, finish;
+	unsigned long time, finish;
 	unsigned int respseq, respcmd, error;
 	unsigned int pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
 	unsigned int rc, spins;
@@ -136,7 +136,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 	 * and poll once a jiffy (approximately)
 	 */
 	spins = TICK_USEC;
-	finish = get_seconds() + MCDI_RPC_TIMEOUT;
+	finish = jiffies + MCDI_RPC_TIMEOUT;
 
 	while (1) {
 		if (spins != 0) {
@@ -146,7 +146,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 			schedule_timeout_uninterruptible(1);
 		}
 
-		time = get_seconds();
+		time = jiffies;
 
 		rmb();
 		efx_readd(efx, &reg, pdu);
@@ -158,7 +158,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 		    EFX_DWORD_FIELD(reg, MCDI_HEADER_RESPONSE))
 			break;
 
-		if (time >= finish)
+		if (time_after(time, finish))
 			return -ETIMEDOUT;
 	}
 
@@ -257,7 +257,7 @@ static int efx_mcdi_await_completion(struct efx_nic *efx)
 	if (wait_event_timeout(
 		    mcdi->wq,
 		    atomic_read(&mcdi->state) == MCDI_STATE_COMPLETED,
-		    msecs_to_jiffies(MCDI_RPC_TIMEOUT * 1000)) == 0)
+		    MCDI_RPC_TIMEOUT) == 0)
 		return -ETIMEDOUT;
 
 	/* Check if efx_mcdi_set_mode() switched us back to polled completions.
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
