From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 09/10] vmxnet3: use static RSS key
Date: Tue, 15 Jan 2013 09:28:34 -0800
Message-ID: <1358270915-32758-10-git-send-email-stephen@networkplumber.org>
References: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:57143 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756649Ab3AORaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 12:30:20 -0500
Received: by mail-pb0-f41.google.com with SMTP id xa7so172190pbc.0
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 09:30:19 -0800 (PST)
In-Reply-To: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than generating a different RSS key on each boot, just use
a predetermined value that will map same flow to same value on
every device for more predictable testing. This is already done
on most hardware drivers.

Initial key value just some arbitrary bits extracted once
from /dev/random.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 45c39cc..9777dc6 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2157,6 +2157,14 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 
 	if (adapter->rss) {
 		struct UPT1_RSSConf *rssConf = adapter->rss_conf;
+		static const uint8_t rss_key[UPT1_RSS_MAX_KEY_SIZE] = {
+			0x3b, 0x56, 0xd1, 0x56, 0x13, 0x4a, 0xe7, 0xac,
+			0xe8, 0x79, 0x09, 0x75, 0xe8, 0x65, 0x79, 0x28,
+			0x35, 0x12, 0xb9, 0x56, 0x7c, 0x76, 0x4b, 0x70,
+			0xd8, 0x56, 0xa3, 0x18, 0x9b, 0x0a, 0xee, 0xf3,
+			0x96, 0xa6, 0x9f, 0x8f, 0x9e, 0x8c, 0x90, 0xc9,
+		};
+
 		devRead->misc.uptFeatures |= UPT1_F_RSS;
 		devRead->misc.numRxQueues = adapter->num_rx_queues;
 		rssConf->hashType = UPT1_RSS_HASH_TYPE_TCP_IPV4 |
@@ -2166,7 +2174,8 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 		rssConf->hashFunc = UPT1_RSS_HASH_FUNC_TOEPLITZ;
 		rssConf->hashKeySize = UPT1_RSS_MAX_KEY_SIZE;
 		rssConf->indTableSize = VMXNET3_RSS_IND_TABLE_SIZE;
-		get_random_bytes(&rssConf->hashKey[0], rssConf->hashKeySize);
+		memcpy(rssConf->hashKey, rss_key, sizeof(rss_key));
+
 		for (i = 0; i < rssConf->indTableSize; i++)
 			rssConf->indTable[i] = ethtool_rxfh_indir_default(
 				i, adapter->num_rx_queues);
-- 
1.7.10.4
