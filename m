From: Rolf Neugebauer <rolf.neugebauer@docker.com>
Subject: [PATCH] virtio: don't set VIRTIO_NET_HDR_F_DATA_VALID on xmit
Date: Tue, 17 Jan 2017 18:13:51 +0000
Message-ID: <20170117181351.98291-1-rolf.neugebauer@docker.com>
Cc: mst@redhat.com, davem@davemloft.net, jasowang@redhat.com,
        rppt@linux.vnet.ibm.com,
        Rolf Neugebauer <rolf.neugebauer@docker.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36690 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751007AbdAQSOC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 13:14:02 -0500
Received: by mail-wm0-f50.google.com with SMTP id c85so211677383wmi.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 10:14:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch part reverts fd2a0437dc33 and e858fae2b0b8 which introduced a
subtle change in how the virtio_net flags are derived from the SKBs
ip_summed field.

With the above commits, the flags are set to VIRTIO_NET_HDR_F_DATA_VALID
when ip_summed == CHECKSUM_UNNECESSARY, thus treating it differently to
ip_summed == CHECKSUM_NONE, which should be the same.

Further, the virtio spec 1.0 / CS04 explicitly says that
VIRTIO_NET_HDR_F_DATA_VALID must not be set by the driver.

Signed-off-by: Rolf Neugebauer <rolf.neugebauer@docker.com>
---
 include/linux/virtio_net.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 66204007d7ac..56436472ccc7 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -91,8 +91,6 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
 				skb_checksum_start_offset(skb));
 		hdr->csum_offset = __cpu_to_virtio16(little_endian,
 				skb->csum_offset);
-	} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-		hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;
 	} /* else everything is zero */
 
 	return 0;
-- 
2.11.0
