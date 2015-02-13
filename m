From: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Subject: [PATCH] hso: fix rx parsing logic when skb allocation fails
Date: Fri, 13 Feb 2015 14:51:02 +0100
Message-ID: <1423835462-3454-1-git-send-email-aleksander@aleksander.es>
Cc: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org, Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If skb allocation fails once the IP header has been received, the rx state is
being set to WAIT_SYNC. The logic, though, shouldn't directly return, as the
buffer may contain a full packet, and therefore the WAIT_SYNC state needs to be
processed (resetting state to WAIT_IP, clearing rx_buf_size and re-initializing
rx_buf_missing).

So, just let the while loop continue so that in the next iteration the WAIT_SYNC
state cleanly stops the loop. The WAIT_SYNC processing will be done just after
that, only if the end of packet is flagged.

Signed-off-by: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
---
 drivers/net/usb/hso.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 6b8efca..9cdfb3f 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -914,7 +914,7 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 					/* We got no receive buffer. */
 					D1("could not allocate memory");
 					odev->rx_parse_state = WAIT_SYNC;
-					return;
+					continue;
 				}
 
 				/* Copy what we got so far. make room for iphdr
-- 
2.3.0

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
