From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next] r8152: add skb_cow_head
Date: Mon, 10 Mar 2014 14:22:31 +0800
Message-ID: <1394432551-4856-1-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393934464-23675-1-git-send-email-hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Call skb_cow_head() before editing the tx packet header. The header
would be reallocated if it is shared.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index c7ef30d..faad39b 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1376,6 +1376,11 @@ static int msdn_giant_send_check(struct sk_buff *skb)
 {
 	const struct ipv6hdr *ipv6h;
 	struct tcphdr *th;
+	int ret;
+
+	ret = skb_cow_head(skb, 0);
+	if (ret)
+		goto out1;
 
 	ipv6h = ipv6_hdr(skb);
 	th = tcp_hdr(skb);
@@ -1383,7 +1388,8 @@ static int msdn_giant_send_check(struct sk_buff *skb)
 	th->check = 0;
 	th->check = ~tcp_v6_check(0, &ipv6h->saddr, &ipv6h->daddr, 0);
 
-	return 0;
+out1:
+	return ret;
 }
 
 static int r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc,
@@ -1412,8 +1418,11 @@ static int r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc,
 			break;
 
 		case htons(ETH_P_IPV6):
+			if (msdn_giant_send_check(skb)) {
+				ret = TX_CSUM_TSO;
+				goto unavailable;
+			}
 			opts1 |= GTSENDV6;
-			msdn_giant_send_check(skb);
 			break;
 
 		default:
-- 
1.8.4.2

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
