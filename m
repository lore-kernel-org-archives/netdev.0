From: Dave Jones <davej@redhat.com>
Subject: Re: brcmfmac: fix txglomming scatter-gather packet transfers
Date: Thu, 6 Mar 2014 01:09:36 -0500
Message-ID: <20140306060936.GB26578@redhat.com>
References: <20140305192636.D06AA660D72@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arend@broadcom.com, linville@tuxdriver.com,
	linux-coverity@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42851 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442AbaCFGJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 01:09:56 -0500
Content-Disposition: inline
In-Reply-To: <20140305192636.D06AA660D72@gitolite.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 05, 2014 at 07:26:36PM +0000, Linux Kernel wrote:
 
 > Commit:     1eb43018673e735ea9cd756970f4e71ca01a5f21
 > Parent:     21f8aaee0c62708654988ce092838aa7df4d25d8
 > Author:     Arend van Spriel <arend@broadcom.com>
 > AuthorDate: Thu Feb 20 18:55:55 2014 +0100
 > Committer:  John W. Linville <linville@tuxdriver.com>
 > CommitDate: Thu Feb 20 15:53:20 2014 -0500
 > 
 >     brcmfmac: fix txglomming scatter-gather packet transfers

Coverity just flagged this code.

 >  	if (skb_tailroom(pkt) < tail_pad && pkt->len > blksize) {
 > +		pkt_pad = brcmu_pkt_buf_get_skb(tail_pad + tail_chop +
 > +						bus->head_align);
 >  		if (pkt_pad == NULL)
 >  			return -ENOMEM;
 >  		ret = brcmf_sdio_txpkt_hdalign(bus, pkt_pad);

Right after this, I think we need the diff below or we leak pkt_pad.
If this looks right, I'll submit it properly tomorrow.

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
