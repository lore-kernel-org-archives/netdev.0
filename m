From: Florin Malita <fmalita@gmail.com>
Subject: [PATCH] libertas: skb dereferenced after netif_rx
Date: Wed, 16 May 2007 17:01:27 -0400
Message-ID: <464B7127.5080502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcelo@kvack.org, linville@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:14390 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965570AbXEPVBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 17:01:46 -0400
Received: by an-out-0708.google.com with SMTP id d18so75779and
        for <netdev@vger.kernel.org>; Wed, 16 May 2007 14:01:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In libertas_process_rxed_packet() and process_rxed_802_11_packet() the 
skb is dereferenced after being passed to netif_rx (called from 
libertas_upload_rx_packet). Spotted by Coverity (1658, 1659).

Also, libertas_upload_rx_packet() unconditionally returns 0 so the error 
check is dead code - might as well take it out.


Signed-off-by: Florin Malita <fmalita@gmail.com>
---

 rx.c |   18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index d17924f..5e98055 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -269,15 +269,11 @@ int libertas_process_rxed_packet(wlan_private * priv, struct sk_buff *skb)
 	wlan_compute_rssi(priv, p_rx_pd);
 
 	lbs_pr_debug(1, "RX Data: size of actual packet = %d\n", skb->len);
-	if (libertas_upload_rx_packet(priv, skb)) {
-		lbs_pr_debug(1, "RX error: libertas_upload_rx_packet"
-		       " returns failure\n");
-		ret = -1;
-		goto done;
-	}
 	priv->stats.rx_bytes += skb->len;
 	priv->stats.rx_packets++;
 
+	libertas_upload_rx_packet(priv, skb);
+
 	ret = 0;
 done:
 	LEAVE();
@@ -438,17 +434,11 @@ static int process_rxed_802_11_packet(wlan_private * priv, struct sk_buff *skb)
 	wlan_compute_rssi(priv, prxpd);
 
 	lbs_pr_debug(1, "RX Data: size of actual packet = %d\n", skb->len);
-
-	if (libertas_upload_rx_packet(priv, skb)) {
-		lbs_pr_debug(1, "RX error: libertas_upload_rx_packet "
-			"returns failure\n");
-		ret = -1;
-		goto done;
-	}
-
 	priv->stats.rx_bytes += skb->len;
 	priv->stats.rx_packets++;
 
+	libertas_upload_rx_packet(priv, skb);
+
 	ret = 0;
 done:
 	LEAVE();

