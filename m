From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH net-2.6.25 4/7][ATM]: [br2864] routed support
Date: Sat, 26 Jan 2008 07:20:19 -0500
Message-ID: <200801261220.m0QCKJ15023510@cmf.nrl.navy.mil>
References: <3f696b20801152016r52048016g7c293dbfdc6c9f29@mail.gmail.com>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: "Chung-Chi Lo" <linolo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:35538 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbYAZMUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 07:20:38 -0500
In-reply-to: <3f696b20801152016r52048016g7c293dbfdc6c9f29@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <3f696b20801152016r52048016g7c293dbfdc6c9f29@mail.gmail.com>,"Chung-
Chi Lo" writes:
>Question to decode the encaps=VCMUX and bridge mode:
>
>This line
>skb_pull((skb, BR2684_PAD_LEN + ETH_HLEN);
>should be replaced by
>skb_pull((skb, BR2684_PAD_LEN);

you are correct.

>By the way, this routed mode patch doesn't include encaps=VCMUX and
>RFC2684 routed
>protocol decapsulation?

yep.  eric believes the following should fix both problems:

commit 43e4b025ffe130cd6a292fa9ff909e39a88f849c
Author: Chas Williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
Date:   Sat Jan 26 07:18:26 2008 -0500

    [ATM]: [br2864] fix vcmux support
    
    From: Eric Kinzie <ekinzie@cmf.nrl.navy.mil>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 31347cb..97b422c 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -400,15 +400,20 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 			return;
 		}
 
-	} else {
-		/* first 2 chars should be 0 */
-		if (*((u16 *) (skb->data)) != 0) {
-			brdev->stats.rx_errors++;
-			dev_kfree_skb(skb);
-			return;
+	} else { /* vc-mux */
+		if (brdev->payload == p_routed) {
+			skb_reset_network_header(skb);
+			skb->pkt_type = PACKET_HOST;
+		} else { /* p_bridged */
+			/* first 2 chars should be 0 */
+			if (*((u16 *) (skb->data)) != 0) {
+				brdev->stats.rx_errors++;
+				dev_kfree_skb(skb);
+				return;
+			}
+			skb_pull(skb, BR2684_PAD_LEN);
+			skb->protocol = eth_type_trans(skb, net_dev);
 		}
-		skb_pull(skb, BR2684_PAD_LEN + ETH_HLEN);	/* pad, dstmac, srcmac, ethtype */
-		skb->protocol = eth_type_trans(skb, net_dev);
 	}
 
 #ifdef CONFIG_ATM_BR2684_IPFILTER
