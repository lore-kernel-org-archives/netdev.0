From: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 66/75] fcoe: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:38 +0100
Message-ID: <1313760467-8598-66-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, devel-s9riP+hp16TNLxjTenLetw@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <1313760393.5010.356.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
List-Unsubscribe: <https://lists.open-fcoe.org/mailman/options/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Cc: Robert Love <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: "James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: devel-s9riP+hp16TNLxjTenLetw@public.gmane.org
Cc: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/scsi/fcoe/fcoe.c           |    2 +-
 drivers/scsi/fcoe/fcoe_transport.c |    5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index ba710e3..3416ab6 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1514,7 +1514,7 @@ int fcoe_xmit(struct fc_lport *lport, struct fc_frame *fp)
 			return -ENOMEM;
 		}
 		frag = &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
-		cp = kmap_atomic(frag->page, KM_SKB_DATA_SOFTIRQ)
+		cp = kmap_atomic(skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ)
 			+ frag->page_offset;
 	} else {
 		cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
diff --git a/drivers/scsi/fcoe/fcoe_transport.c b/drivers/scsi/fcoe/fcoe_transport.c
index 41068e8..f6613f9 100644
--- a/drivers/scsi/fcoe/fcoe_transport.c
+++ b/drivers/scsi/fcoe/fcoe_transport.c
@@ -108,8 +108,9 @@ u32 fcoe_fc_crc(struct fc_frame *fp)
 		len = frag->size;
 		while (len > 0) {
 			clen = min(len, PAGE_SIZE - (off & ~PAGE_MASK));
-			data = kmap_atomic(frag->page + (off >> PAGE_SHIFT),
-					   KM_SKB_DATA_SOFTIRQ);
+			data = kmap_atomic(
+				skb_frag_page(frag) + (off >> PAGE_SHIFT),
+				KM_SKB_DATA_SOFTIRQ);
 			crc = crc32(crc, data + (off & ~PAGE_MASK), clen);
 			kunmap_atomic(data, KM_SKB_DATA_SOFTIRQ);
 			off += clen;
-- 
1.7.2.5
