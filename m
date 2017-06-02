From: "Peter S. Housel" <housel-HInyCGIudOg@public.gmane.org>
Subject: [PATCH] brcmfmac: Fix glob_skb leak in brcmf_sdiod_recv_chain
Date: Fri,  2 Jun 2017 10:22:21 -0700
Message-ID: <1496424146-10928-1-git-send-email-housel@acm.org>
To: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Christian Daudt <csd-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Pieter-Paul Giesberts <pieter-paul.giesberts-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "Peter S. Housel" <housel-HInyCGIudOg@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:BROADCOM BRCM80211
        IEEE802.11n WIRELESS DRIVER),
        brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org (open list:BROADCOM BRCM80211
        IEEE802.11n WIRELESS DRIVER),
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:NETWORKING DRIVERS),
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

An earlier change to this function (3bdae810721b) fixed a leak in the
case of an unsuccessful call to brcmf_sdiod_buffrw(). However, the
glob_skb buffer, used for emulating a scattering read, is never used
or referenced after its contents are copied into the destination
buffers, and therefore always needs to be freed by the end of the
function.

Signed-off-by: Peter S. Housel <housel-HInyCGIudOg@public.gmane.org>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
index 9b970dc..4c5064f 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
@@ -727,15 +727,16 @@ int brcmf_sdiod_recv_chain(struct brcmf_sdio_dev *sdiodev,
 			return -ENOMEM;
 		err = brcmf_sdiod_buffrw(sdiodev, SDIO_FUNC_2, false, addr,
 					 glom_skb);
-		if (err) {
-			brcmu_pkt_buf_free_skb(glom_skb);
-			goto done;
-		}
+		if (err)
+			goto free_glom_skb;
 
 		skb_queue_walk(pktq, skb) {
 			memcpy(skb->data, glom_skb->data, skb->len);
 			skb_pull(glom_skb, skb->len);
 		}
+
+free_glom_skb:
+		brcmu_pkt_buf_free_skb(glom_skb);
 	} else
 		err = brcmf_sdiod_sglist_rw(sdiodev, SDIO_FUNC_2, false, addr,
 					    pktq);
-- 
2.7.4
