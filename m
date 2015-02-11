From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/7] net: Clarify meaning of CHECKSUM_PARTIAL for receive path
Date: Tue, 10 Feb 2015 16:30:28 -0800
Message-ID: <1423614633-25042-3-git-send-email-therbert@google.com>
References: <1423614633-25042-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:35579 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbbBKAas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:30:48 -0500
Received: by iebtr6 with SMTP id tr6so493836ieb.2
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 16:30:47 -0800 (PST)
In-Reply-To: <1423614633-25042-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current meaning of CHECKSUM_PARTIAL for validating checksums
is that _all_ checksums in the packet are considered valid.
However, in the manner that CHECKSUM_PARTIAL is set only the checksum
at csum_start+csum_offset and any preceding checksums may
be considered valid. If there are checksums in the packet after
csum_offset it is possible they have not been verfied.

This patch changes CHECKSUM_PARTIAL logic in skb_csum_unnecessary and
__skb_gro_checksum_validate_needed to only considered checksums
referring to csum_start and any preceding checksums (with starting
offset before csum_start) to be verified.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |  4 +++-
 include/linux/skbuff.h    | 17 ++++++++++++-----
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3aa0245..9e9be22 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2246,7 +2246,9 @@ static inline bool __skb_gro_checksum_validate_needed(struct sk_buff *skb,
 						      bool zero_okay,
 						      __sum16 check)
 {
-	return (skb->ip_summed != CHECKSUM_PARTIAL &&
+	return ((skb->ip_summed != CHECKSUM_PARTIAL ||
+		skb_checksum_start_offset(skb) <
+		 skb_gro_offset(skb)) &&
 		NAPI_GRO_CB(skb)->csum_cnt == 0 &&
 		(!zero_okay || check));
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1bb36ed..da6028a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -83,11 +83,15 @@
  *
  * CHECKSUM_PARTIAL:
  *
- *   This is identical to the case for output below. This may occur on a packet
+ *   A checksum is set up to be offloaded to a device as described in the
+ *   output description for CHECKSUM_PARTIAL. This may occur on a packet
  *   received directly from another Linux OS, e.g., a virtualized Linux kernel
- *   on the same host. The packet can be treated in the same way as
- *   CHECKSUM_UNNECESSARY, except that on output (i.e., forwarding) the
- *   checksum must be filled in by the OS or the hardware.
+ *   on the same host, or it may be set in the input path in GRO or remote
+ *   checksum offload. For the purposes of checksum verification, the checksum
+ *   referred to by skb->csum_start + skb->csum_offset and any preceding
+ *   checksums in the packet are considered verified. Any checksums in the
+ *   packet that are after the checksum being offloaded are not considered to
+ *   be verified.
  *
  * B. Checksumming on output.
  *
@@ -2915,7 +2919,10 @@ __sum16 __skb_checksum_complete(struct sk_buff *skb);
 
 static inline int skb_csum_unnecessary(const struct sk_buff *skb)
 {
-	return ((skb->ip_summed & CHECKSUM_UNNECESSARY) || skb->csum_valid);
+	return ((skb->ip_summed == CHECKSUM_UNNECESSARY) ||
+		skb->csum_valid ||
+		(skb->ip_summed == CHECKSUM_PARTIAL &&
+		 skb_checksum_start_offset(skb) >= 0));
 }
 
 /**
-- 
2.2.0.rc0.207.ga3a616c
