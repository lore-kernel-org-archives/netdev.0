From: James Hughes <james.hughes-FnsA7b+Nu9XbIbC87yuRow@public.gmane.org>
Subject: [PATCH v3] brcmfmac: Make skb header writable before use
Date: Tue, 25 Apr 2017 10:15:06 +0100
Message-ID: <20170425091506.18224-1-james.hughes@raspberrypi.org>
Cc: James Hughes <james.hughes-FnsA7b+Nu9XbIbC87yuRow@public.gmane.org>
To: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The driver was making changes to the skb_header without
ensuring it was writable (i.e. uncloned).
This patch also removes some boiler plate header size
checking/adjustment code as that is also handled by the
skb_cow_header function used to make header writable.

Please apply to 4.12, important fix.

This patch depends on
brcmfmac: Ensure pointer correctly set if skb data location changes

Signed-off-by: James Hughes <james.hughes-FnsA7b+Nu9XbIbC87yuRow@public.gmane.org>
Acked-by: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---

Changes in v2
   Makes the _cow_ call at the entry point of the skb in to the
   stack, means only needs to be done once, and error handling
   is easier.
   Split a separate minor bug fix off to a separate patch (which
   this patch depends on)

Changes in v3
   Minor change to the 'if' logic to reduce patch size as per
   maintainers request.
   Flagged as important fix for 4.12 in commit message

 .../net/wireless/broadcom/brcm80211/brcmfmac/core.c | 21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
index 9b7c19a508ac..433f2c8408e9 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
@@ -211,22 +211,13 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
 		goto done;
 	}
 
-	/* Make sure there's enough room for any header */
-	if (skb_headroom(skb) < drvr->hdrlen) {
-		struct sk_buff *skb2;
