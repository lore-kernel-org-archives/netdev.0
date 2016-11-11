From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next] sfc: clear napi_hash state when copying channels
Date: Fri, 11 Nov 2016 15:56:51 +0000
Message-ID: <80535661-f88f-3dc5-9b40-111358707ffd@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        Solarflare Linux Maintainers <linux-net-drivers@solarflare.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:33187 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755920AbcKKP6O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 10:58:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_copy_channel() doesn't correctly clear the napi_hash related state.
This means that when napi_hash_add is called for that channel nothing is
done, and we are left with a copy of the napi_hash_node from the old
channel. When we later call napi_hash_del() on this channel we have a
stale napi_hash_node.

Corruption is only seen when there are multiple entries in one of the
napi_hash lists. This is made more likely by having a very large number
of channels. Testing was carried out with 512 channels - 32 channels on
each of 16 ports.

This failure typically appears as protection faults within napi_by_id()
or napi_hash_add(). efx_copy_channel() is only used when tx or rx ring
sizes are changed (ethtool -G).

Fixes: 36763266bbe8 ("sfc: Add support for busy polling")
Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 3cf3557..6b89e4a 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -485,6 +485,9 @@ efx_copy_channel(const struct efx_channel *old_channel)
 	*channel = *old_channel;
 
 	channel->napi_dev = NULL;
+	INIT_HLIST_NODE(&channel->napi_str.napi_hash_node);
+	channel->napi_str.napi_id = 0;
+	channel->napi_str.state = 0;
 	memset(&channel->eventq, 0, sizeof(channel->eventq));
 
 	for (j = 0; j < EFX_TXQ_TYPES; j++) {
-- 
2.7.4
