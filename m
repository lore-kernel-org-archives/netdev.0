From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next] sfc: don't rearm interrupts if busy polling
Date: Mon, 6 Feb 2017 16:50:55 +0000
Message-ID: <ccee0048-9399-3d13-8274-790833b992d9@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Solarflare Linux Maintainers <linux-net-drivers@solarflare.com>,
        Eric Dumazet <edumazet@google.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:24963 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751001AbdBFQvM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 11:51:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 364b6055738b ("net: busy-poll: return busypolling status
to drivers"), napi_complete_done() returns a boolean that can be used
by drivers to conditionally rearm interrupts.

Testing with a 7142 shows a small latency improvement of ~100 ns.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/sfc/efx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index fcd4eeecfef4..c28cd9daf949 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -328,8 +328,8 @@ static int efx_poll(struct napi_struct *napi, int budget)
 		 * since efx_nic_eventq_read_ack() will have no effect if
 		 * interrupts have already been disabled.
 		 */
-		napi_complete_done(napi, spent);
-		efx_nic_eventq_read_ack(channel);
+		if (napi_complete_done(napi, spent))
+			efx_nic_eventq_read_ack(channel);
 	}
 
 	return spent;
-- 
2.7.4
