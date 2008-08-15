From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 6/7] tg3: fix 64 bit counter for ethtool stats
Date: Fri, 15 Aug 2008 14:03:23 -0700
Message-ID: <1218834769.6487@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3922 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454AbYHOU1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2008 16:27:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethtool stats are 64-bits in length.  net_device_stats members are
unsigned long types.  When gathering information for
a get_ethtool_stats call, the driver will call a driver-private,
inlined get_stat64() function, which returns an unsigned long value.
This call will inadvertently mask off the upper 32-bits of a stat on
32-bit machines.

This patch defines a new get_estat() inline function and modifies the
ESTAT_ADD() macro to use it.

Signed-off-by: Stefan Buehler <stbuehler@web.de>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

---
 drivers/net/tg3.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c26011e..ada1d0d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8466,6 +8466,11 @@ static inline unsigned long get_stat64(tg3_stat64_t *val)
 	return ret;
 }
 
+static inline u64 get_estat64(tg3_stat64_t *val)
+{
+       return ((u64)val->high << 32) | ((u64)val->low);
+}
+
 static unsigned long calc_crc_errors(struct tg3 *tp)
 {
 	struct tg3_hw_stats *hw_stats = tp->hw_stats;
@@ -8494,7 +8499,7 @@ static unsigned long calc_crc_errors(struct tg3 *tp)
 
 #define ESTAT_ADD(member) \
 	estats->member =	old_estats->member + \
-				get_stat64(&hw_stats->member)
+				get_estat64(&hw_stats->member)
 
 static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *tp)
 {
-- 
1.5.6.4



