From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 06/17] sfc: Fix event based MCDI completion
 and MC REBOOT/CMDDONE ordering issue
Date: Thu, 02 Dec 2010 23:46:55 +0000
Message-ID: <1291333615.3259.29.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13025 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932290Ab0LBXq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:46:58 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

The mcfw *never* sends CMDDONE when rebooting. Changing this so that it always
sends CMDDONE *before* REBOOT is easy on Siena, but it's not obvious that we
could guarantee to be able to implement this on future hardware.

Given this, I'm less convinced that the protocol should be changed.

To reiterate the failure mode: The driver sees this:

 issue command
 receive REBOOT event

Was that reboot event sent before the command was issued, or in
response to the command? If the former then there will be a subsequent
CMDDONE event, if the latter, then there will be no CMDDONE event.

Options to resolve this are:

 1. REBOOT always completes an outstanding mcdi request, and we set
    the credits count to ignore a subsequent CMDDONE event with
    mismatching seqno.

 2. REBOOT never completes an outstanding mcdi request. If there is
    no CMDDONE event then we rely on the mcdi timeout code to complete
    the outstanding request, incurring a 10s delay.

I'd argue that (2) is tidier, but that incurring a 10s delay is a little
needless. Let's go with (1).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index e389ac6..b716e82 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -463,6 +463,7 @@ static void efx_mcdi_ev_death(struct efx_nic *efx, int rc)
 		if (mcdi->mode == MCDI_MODE_EVENTS) {
 			mcdi->resprc = rc;
 			mcdi->resplen = 0;
+			++mcdi->credits;
 		}
 	} else
 		/* Nobody was waiting for an MCDI request, so trigger a reset */
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

