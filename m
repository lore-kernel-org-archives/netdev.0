From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 5/7] sfc: Work around XMAC bug causing packet loss with
	some peers
Date: Wed, 26 Aug 2009 19:17:59 +0100
Message-ID: <1251310679.27345.17.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:33456 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752539AbZHZSR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 14:17:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Received frames must be re-clocked by the local XGXS to the 156.25 MHz
(DDR) clock of the XGMII.  If the remote clock is slightly faster this
can reduce a minimum IPG of 64 bit-times (1 cycle) to 32 bit-times
(half a cycle).  If the XMAC detects that a frame has reached the
maximum RX frame length in the same cycle that it receives one of
these reduced IPGs, it may miss the IPG, causing two valid frames to
be treated as a single invalid frame (over-length with bad CRC).

We work around this by increasing the maximum RX frame length so that
peers with matched MTU will not provoke this bug.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 5eabede..298566d 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -984,9 +984,14 @@ static inline void clear_bit_le(unsigned nr, unsigned char *addr)
  *
  * The 10G MAC used in Falcon requires 8-byte alignment on the frame
  * length, so we round up to the nearest 8.
+ *
+ * Re-clocking by the XGXS on RX can reduce an IPG to 32 bits (half an
+ * XGMII cycle).  If the frame length reaches the maximum value in the
+ * same cycle, the XMAC can miss the IPG altogether.  We work around
+ * this by adding a further 16 bytes.
  */
 #define EFX_MAX_FRAME_LEN(mtu) \
-	((((mtu) + ETH_HLEN + VLAN_HLEN + 4/* FCS */) + 7) & ~7)
+	((((mtu) + ETH_HLEN + VLAN_HLEN + 4/* FCS */ + 7) & ~7) + 16)
 

 #endif /* EFX_NET_DRIVER_H */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

