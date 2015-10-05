From: Hante Meuleman <meuleman@broadcom.com>
Subject: RE: [PATCHv2] brcm80211:Fix locking region in the function
 brcmf_sdio_sendfromq
Date: Mon, 5 Oct 2015 08:01:45 +0000
Message-ID: <F51492713EF10846800D8C0ED37A7DCE01995CBF@SJEXCHMB15.corp.ad.broadcom.com>
References: <1444000277-25694-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Arend Van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	brcm80211-dev-list <brcm80211-dev-list@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>,
	Brett Rudley <brudley@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444000277-25694-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Nicholas, 

I can understand that if you read the comment that there is supposed to be a lock taken, but why would you assume that it is the txq_lock? Two things:

1) The comment that a look should have been taken is wrong. Once upon a time a packet could be transmitted/handled from two paths. To protect for concurrency the callee of brcmf_sdio_txpkt was assumed to have take some sort of lock to protect against this. 
2) Nowadays all frames are put on the txq and then pulled from that queue in the DPC. This queue is protected with a lock and therefor a lock is taken around the dequeueing of txq in dpc. Also the reason for the chosen var name txq_lock. This lock protects for concurrent access to the txq and the lock should be taken as short as possible, and therefor this patch could possible result in throughput degradation and does not solve anything.

Please do not submit this patch, if anything then remove the comment from the function brcmf_sdio_txpkt.

Regards,
Hante

-----Original Message-----
From: Nicholas Krause [mailto:xerofoify@gmail.com] 
Sent: Monday, October 05, 2015 1:11 AM
To: Brett Rudley
Cc: Arend Van Spriel; Franky (Zhenhui) Lin; Hante Meuleman; kvalo@codeaurora.org; Pieter-Paul Giesberts; linux-wireless@vger.kernel.org; brcm80211-dev-list; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: [PATCHv2] brcm80211:Fix locking region in the function brcmf_sdio_sendfromq

This fixes the locking region in the function brcmf_sdio_sendfromq
to properly lock around the call to the function brcmrf_sdio_txpkt
in order to avoid concurrent access issues when calling this
function as stated in the function's comments about the caller
being required to lock around the call to this particular function.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
v2
Fix issue with deadlock occurrence due to not unlocking before
break in for loop if the variable i is equal to zero
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
index f990e3d..260f063 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
@@ -2388,11 +2388,13 @@ static uint brcmf_sdio_sendfromq(struct brcmf_sdio *bus, uint maxframes)
 				break;
 			__skb_queue_tail(&pktq, pkt);
 		}
-		spin_unlock_bh(&bus->txq_lock);
-		if (i == 0)
+		if (i == 0) {
+			spin_unlock_bh(&bus->txq_lock);
 			break;
+		}
 
 		ret = brcmf_sdio_txpkt(bus, &pktq, SDPCM_DATA_CHANNEL);
+		spin_unlock_bh(&bus->txq_lock);
 
 		cnt += i;
 
-- 
2.1.4
