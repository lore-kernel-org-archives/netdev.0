From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 4.9] brcmfmac: use correct skb freeing helper when deleting flowring
Date: Tue, 27 Sep 2016 11:14:28 +0200
Message-ID: <20160927091428.19223-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Franky Lin <frankyl@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafał Miłecki <rafal@milecki.pl>

Flowrings contain skbs waiting for transmission that were passed to us
by netif. It means we checked every one of them looking for 802.1x
Ethernet type. When deleting flowring we have to use freeing function
that will check for 802.1x type as well.

Freeing skbs without a proper check was leading to counter not being
properly decreased. This was triggering a WARNING every time
brcmf_netdev_wait_pend8021x was called.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
Kalle: this isn't important enough for 4.8 as it's too late for that.

I'd like to get it for 4.9 however, as this fixes bug that could lead
to WARNING on every add_key/del_key call. We was struggling with these
WARNINGs for some time and this fixes one of two problems causing them.
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/flowring.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/flowring.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/flowring.c
index b16b367..d0b738d 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/flowring.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/flowring.c
@@ -234,13 +234,20 @@ static void brcmf_flowring_block(struct brcmf_flowring *flow, u16 flowid,
 
 void brcmf_flowring_delete(struct brcmf_flowring *flow, u16 flowid)
 {
+	struct brcmf_bus *bus_if = dev_get_drvdata(flow->dev);
 	struct brcmf_flowring_ring *ring;
+	struct brcmf_if *ifp;
 	u16 hash_idx;
+	u8 ifidx;
 	struct sk_buff *skb;
 
 	ring = flow->rings[flowid];
 	if (!ring)
 		return;
+
+	ifidx = brcmf_flowring_ifidx_get(flow, flowid);
+	ifp = brcmf_get_ifp(bus_if->drvr, ifidx);
+
 	brcmf_flowring_block(flow, flowid, false);
 	hash_idx = ring->hash_id;
 	flow->hash[hash_idx].ifidx = BRCMF_FLOWRING_INVALID_IFIDX;
@@ -249,7 +256,7 @@ void brcmf_flowring_delete(struct brcmf_flowring *flow, u16 flowid)
 
 	skb = skb_dequeue(&ring->skblist);
 	while (skb) {
-		brcmu_pkt_buf_free_skb(skb);
+		brcmf_txfinalize(ifp, skb, false);
 		skb = skb_dequeue(&ring->skblist);
 	}
 
-- 
2.9.3
