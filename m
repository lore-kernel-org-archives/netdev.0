From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 1/2] ethtool: Fix potential kernel buffer overflow
 in ETHTOOL_GRXCLSRLALL
Date: Mon, 28 Jun 2010 19:44:07 +0100
Message-ID: <1277750647.2089.19.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Santwona Behera <santwona.behera@sun.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:57212 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735Ab0F1SoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 14:44:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On a 32-bit machine, info.rule_cnt >= 0x40000000 leads to integer
overflow and the buffer may be smaller than needed.  Since
ETHTOOL_GRXCLSRLALL is unprivileged, this can presumably be used for at
least denial of service.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Cc: stable@kernel.org
---
 net/core/ethtool.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index a0f4964..a3a7e9a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -347,8 +347,9 @@ static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
 
 	if (info.cmd == ETHTOOL_GRXCLSRLALL) {
 		if (info.rule_cnt > 0) {
-			rule_buf = kmalloc(info.rule_cnt * sizeof(u32),
-					   GFP_USER);
+			if (info.rule_cnt <= KMALLOC_MAX_SIZE / sizeof(u32))
+				rule_buf = kmalloc(info.rule_cnt * sizeof(u32),
+						   GFP_USER);
 			if (!rule_buf)
 				return -ENOMEM;
 		}
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

