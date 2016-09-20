From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH RFC] brcmfmac: stop netif queue when waiting for packets transmission
Date: Wed, 21 Sep 2016 00:00:22 +0200
Message-ID: <20160920220030.10257-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Pieter-Paul Giesberts <pieterpg@broadcom.com>,
        "Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
        brcm80211-dev-list.pdl@broadcom.com (open list:BROADCOM BRCM80211
        IEEE802.11n WIRELESS DRIVER),
        netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
        linux-kernel@vger.kernel.org (open list)
To: Hante Meuleman <meuleman@broadcom.com>,
        Arend van Spriel <arend@broadcom.com>,
        brcm80211-dev-list@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafał Miłecki <rafal@milecki.pl>

Sending a new key to the firmware should be done without any 802.1x
packets pending. Currently brcmfmac has very trivial code waiting for
that condition and it doesn't seem to be enough.

We should stop netif from sending any extra packets in order to:
1) Make sure new 802.1x packets won't be coming over and over
2) Avoid a race with netif providing a new packet right after our
   waiting code

Another solution would be to accept only non-802.1x packets. This would
require enqueuing all packets and hacking brcmf_fws_dequeue_worker to
dequeue only non-802.1x ones but that would most likely result in too
hacky code.
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index 201a980..1791060 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -471,11 +471,14 @@ send_key_to_dongle(struct brcmf_if *ifp, struct brcmf_wsec_key *key)
 
 	convert_key_from_CPU(key, &key_le);
 
+	netif_stop_queue(ifp->ndev);
 	brcmf_netdev_wait_pend8021x(ifp);
 
 	err = brcmf_fil_bsscfg_data_set(ifp, "wsec_key", &key_le,
 					sizeof(key_le));
 
+	netif_start_queue(ifp->ndev);
+
 	if (err)
 		brcmf_err("wsec_key error (%d)\n", err);
 	return err;
-- 
2.9.3
