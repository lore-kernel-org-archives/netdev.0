From: Dave Jones <davej@redhat.com>
Subject: brcmfmac: fix skb leak in brcmf_sdio_txpkt_prep_sg error path.
Date: Thu, 6 Mar 2014 15:51:08 -0500
Message-ID: <20140306205108.GA16008@redhat.com>
References: <20140305192636.D06AA660D72@gitolite.kernel.org>
 <20140306060936.GB26578@redhat.com>
 <53183722.7000301@broadcom.com>
 <20140306170354.GA31372@redhat.com>
 <5318EB9E.808@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arend van Spriel <arend@broadcom.com>, netdev@vger.kernel.org,
	linville@tuxdriver.com, linux-coverity@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47436 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752229AbaCFUv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 15:51:28 -0500
Content-Disposition: inline
In-Reply-To: <5318EB9E.808@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1eb4301867 (brcmfmac: fix txglomming scatter-gather packet transfers)
added an allocation of an skb via brcmu_pkt_buf_get_skb() but forgot to
free it on one of the error paths.

Acked-by: Arend van Spriel <arend@broadcom.com>
Signed-off-by: Dave Jones<davej@fedoraproject.org>

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 119ee6eaf1c3..ddaa9efd053d 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -1948,8 +1948,10 @@ static int brcmf_sdio_txpkt_prep_sg(struct brcmf_sdio *bus,
 		if (pkt_pad == NULL)
 			return -ENOMEM;
 		ret = brcmf_sdio_txpkt_hdalign(bus, pkt_pad);
-		if (unlikely(ret < 0))
+		if (unlikely(ret < 0)) {
+			kfree_skb(pkt_pad);
 			return ret;
+		}
 		memcpy(pkt_pad->data,
 		       pkt->data + pkt->len - tail_chop,
 		       tail_chop);
