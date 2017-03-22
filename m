From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 8/9] netvsc: eliminate unnecessary skb == NULL checks
Date: Wed, 22 Mar 2017 14:51:04 -0700
Message-ID: <20170322215105.1059-9-sthemmin@microsoft.com>
References: <20170322215105.1059-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36236 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751550AbdCVVvX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:51:23 -0400
Received: by mail-pg0-f45.google.com with SMTP id g2so112665200pge.3
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 14:51:22 -0700 (PDT)
In-Reply-To: <20170322215105.1059-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since there already is a special case goto for control messages (skb == NULL)
in netvsc_send, there is no need for later checks in same code path.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 1f17d948f9b0..e998e2f7a619 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -706,8 +706,7 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 		packet->page_buf_cnt;
 
 	/* Add padding */
-	if (skb && skb->xmit_more && remain &&
-	    !packet->cp_partial) {
+	if (skb->xmit_more && remain && !packet->cp_partial) {
 		padding = net_device->pkt_align - remain;
 		rndis_msg->msg_len += padding;
 		packet->total_data_buflen += padding;
@@ -865,9 +864,7 @@ int netvsc_send(struct hv_device *device,
 	if (msdp->pkt)
 		msd_len = msdp->pkt->total_data_buflen;
 
-	try_batch = (skb != NULL) && msd_len > 0 && msdp->count <
-		    net_device->max_pkt;
-
+	try_batch =  msd_len > 0 && msdp->count < net_device->max_pkt;
 	if (try_batch && msd_len + pktlen + net_device->pkt_align <
 	    net_device->send_section_size) {
 		section_index = msdp->pkt->send_buf_index;
@@ -877,7 +874,7 @@ int netvsc_send(struct hv_device *device,
 		section_index = msdp->pkt->send_buf_index;
 		packet->cp_partial = true;
 
-	} else if ((skb != NULL) && pktlen + net_device->pkt_align <
+	} else if (pktlen + net_device->pkt_align <
 		   net_device->send_section_size) {
 		section_index = netvsc_get_next_send_section(net_device);
 		if (section_index != NETVSC_INVALID_INDEX) {
-- 
2.11.0
