From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 1/2] ip_tunnel: GSO: Add check for nested encap.
Date: Sun, 25 May 2014 04:39:32 -0700
Message-ID: <1401017972-1544-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:39837 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932226AbaFJAze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 20:55:34 -0400
Received: by mail-pb0-f53.google.com with SMTP id md12so5586461pbc.40
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 17:55:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current networking stack can only handle single encap packet
for GSO.  Following patch adds check for already encapsulated
packet so that we can drop it.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ip_tunnel_core.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index f4c987b..b150546 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -122,12 +122,16 @@ struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
 {
 	int err;
 
-	if (likely(!skb->encapsulation)) {
+	if (skb_is_gso(skb)) {
+		if (unlikely(skb->encapsulation)) {
+			/* Current networking GSO stack can handle
+			 * only one level of encapsulation. */
+			err = -ENOSYS;
+			goto error;
+		}
 		skb_reset_inner_headers(skb);
 		skb->encapsulation = 1;
-	}
 
-	if (skb_is_gso(skb)) {
 		err = skb_unclone(skb, GFP_ATOMIC);
 		if (unlikely(err))
 			goto error;
-- 
1.9.1
