From: Florin Malita <fmalita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] libertas: skb dereferenced after netif_rx
Date: Fri, 18 May 2007 16:04:33 -0400
Message-ID: <464E06D1.9070804@gmail.com>
References: <464B7127.5080502@gmail.com> <20070518180903.GC3492@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: marcelo-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linville-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070518180903.GC3492-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
>> Also, libertas_upload_rx_packet() unconditionally returns 0 so the error 
>> check is dead code - might as well take it out.
>>     
>
> Is this merely an implementation detail?  Or an absolute fact?
>   

I believe it's an absolute fact that got lost among implementation 
details ;)

All libertas_upload_rx_packet does is set a few fields in the skb, then 
pass it up to the stack via netif_rx:

139 int libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb)
140 {
141         lbs_pr_debug(1, "skb->data=%p\n", skb->data);
142
143         if(IS_MESH_FRAME(skb))
144                 skb->dev = priv->mesh_dev;
145         else
146                 skb->dev = priv->wlan_dev.netdev;
147         skb->protocol = eth_type_trans(skb, priv->wlan_dev.netdev);
148         skb->ip_summed = CHECKSUM_UNNECESSARY;
149
150         netif_rx(skb);
151
152         return 0;
153 }


Since netif_rx always succeeds, so should libertas_upload_rx_packet - 
there's no reason for passing back a success code (especially one that's 
hardcoded to 0).

> If the latter, then we should change the signature of
> libertas_upload_rx_packet to return void.
>   

Makes sense, updated patch below.

> Another potential patch is to remove the "ret = 0" line before the
> "done" label, since ret is initialized at the head of the function.
> Come to think of it, you can probably remove the "= 0" part of ret's
> declaration as well (in both functions).
>   

Right, even more: looks like both process_rxed_802_11_packet & 
libertas_process_rxed_packet can only return 0 so we could drop the 
return code altogether and change their signature to void too (nobody 
seems to care about their return code anyway). I will send a separate 
cleanup patch but this might be leaning more on the implementation 
detail side (planning to extend the functions and make the return code 
meaningful in the future?) so somebody familiar with the driver should 
make the call.

Thanks,
Florin


Signed-off-by: Florin Malita <fmalita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 decl.h |    2 +-
 rx.c   |   22 +++++-----------------
 2 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wireless/libertas/decl.h b/drivers/net/wireless/libertas/decl.h
index 606bdd0..dfe2764 100644
--- a/drivers/net/wireless/libertas/decl.h
+++ b/drivers/net/wireless/libertas/decl.h
@@ -46,7 +46,7 @@ u32 libertas_index_to_data_rate(u8 index);
 u8 libertas_data_rate_to_index(u32 rate);
 void libertas_get_fwversion(wlan_adapter * adapter, char *fwversion, int maxlen);
 
-int libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb);
+void libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb);
 
 /** The proc fs interface */
 int libertas_process_rx_command(wlan_private * priv);
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index d17924f..b19b5aa 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -136,7 +136,7 @@ static void wlan_compute_rssi(wlan_private * priv, struct rxpd *p_rx_pd)
 	LEAVE();
 }
 
-int libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb)
+void libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb)
 {
 	lbs_pr_debug(1, "skb->data=%p\n", skb->data);
 
@@ -148,8 +148,6 @@ int libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb)
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	netif_rx(skb);
-
-	return 0;
 }
 
 /**
@@ -269,15 +267,11 @@ int libertas_process_rxed_packet(wlan_private * priv, struct sk_buff *skb)
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
@@ -438,17 +432,11 @@ static int process_rxed_802_11_packet(wlan_private * priv, struct sk_buff *skb)
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
