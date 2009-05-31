From: "Zhang, Sonic" <Sonic.Zhang@analog.com>
Subject: RE: [PATCH 2/4 v2] netdev: bfin_mac: fix malformed UDP packet transmission when polling with KGDB
Date: Sun, 31 May 2009 10:57:49 +0800
Message-ID: <0F1B54C89D5F954D8535DB252AF412FA041F17F9@chinexm1.ad.analog.com>
References: <1243404615-25879-3-git-send-email-vapier@gentoo.org> <1243604443-27204-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <uclinux-dist-devel@blackfin.uclinux.org>,
	"Bryan Wu" <cooloney@kernel.org>
To: "Mike Frysinger" <vapier@gentoo.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:11865 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbZEaC4m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 22:56:42 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <1243604443-27204-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK. Mike's explanation is correct.

Sonic 

-----Original Message-----
From: Mike Frysinger [mailto:vapier@gentoo.org] 
Sent: Friday, May 29, 2009 9:41 PM
To: netdev@vger.kernel.org
Cc: uclinux-dist-devel@blackfin.uclinux.org; Zhang, Sonic; Bryan Wu
Subject: [PATCH 2/4 v2] netdev: bfin_mac: fix malformed UDP packet
transmission when polling with KGDB

From: Sonic Zhang <sonic.zhang@analog.com>

Writes to the DMA descriptors may sit in the internal Blackfin data
buffers and not actually be available when the DMA engine goes to fetch
them.  This does not typically happen, but when dealing with short/fast
packets such as UDP and polling KGDB, this occurs much more frequently.
Same goes for heavy loads as seen by netperf tests or large scp
transfers.  So force the buffers to drain with SSYNC otherwise we get
random malformed packets.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
v2
	- make comment/changelog reflect what is actually going on

 drivers/net/bfin_mac.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c index
1905532..38d34ce 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -688,6 +688,12 @@ static int bfin_mac_hard_start_xmit(struct sk_buff
*skb,
 		}
 	}
 
+	/* make sure the internal data buffers in the core are drained
+	 * so that the DMA descriptors are completely written when the
+	 * DMA engine goes to fetch them below
+	 */
+	SSYNC();
+
 	/* enable this packet's dma */
 	current_tx_ptr->desc_a.config |= DMAEN;
 
--
1.6.3.1

