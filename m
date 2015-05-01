From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net PATCH 2/3] r8169: Do not use dev_kfree_skb in xmit path
Date: Fri, 01 May 2015 10:34:44 -0700
Message-ID: <20150501173444.1029.11465.stgit@ahduyck-vm-fedora22>
References: <20150501173049.1029.54421.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, davem@davemloft.net
To: netdev@vger.kernel.org, nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491AbbEARfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2015 13:35:47 -0400
In-Reply-To: <20150501173049.1029.54421.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function r8169_csum_workaround is called in the ndo_start_xmit path of
the r8169 driver.  As such it should not be using dev_kfree_skb as it is
not irq safe, so instead we should be using dev_kfree_skb_any for freeing
in the dropped path, and dev_consume_skb_any for any frames that were
transmitted.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/realtek/r8169.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c70ab40d8698..3df51faf18ae 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6884,7 +6884,7 @@ static void r8169_csum_workaround(struct rtl8169_private *tp,
 			rtl8169_start_xmit(nskb, tp->dev);
 		} while (segs);
 
-		dev_kfree_skb(skb);
+		dev_consume_skb_any(skb);
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		if (skb_checksum_help(skb) < 0)
 			goto drop;
@@ -6896,7 +6896,7 @@ static void r8169_csum_workaround(struct rtl8169_private *tp,
 drop:
 		stats = &tp->dev->stats;
 		stats->tx_dropped++;
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 	}
 }
 
