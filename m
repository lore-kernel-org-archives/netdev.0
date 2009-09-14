From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH alt] sky2: Make sure both ports initialize correctly
Date: Mon, 14 Sep 2009 09:22:29 -0700
Message-ID: <20090914092229.31490f45@nehalam>
References: <4AAD7B86.6060300@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33053 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756026AbZINQXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 12:23:11 -0400
In-Reply-To: <4AAD7B86.6060300@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry Mike, I sent you off the wrong way. The following is simpler and the
second port is diffrent enough in setup (because of NAPI), that the
following is simpler.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-09-14 09:16:34.313731803 -0700
+++ b/drivers/net/sky2.c	2009-09-14 09:19:48.240726224 -0700
@@ -4550,16 +4550,18 @@ static int __devinit sky2_probe(struct p
 	if (hw->ports > 1) {
 		struct net_device *dev1;
 
+		err = -ENOMEM;
 		dev1 = sky2_init_netdev(hw, 1, using_dac, wol_default);
-		if (!dev1)
-			dev_warn(&pdev->dev, "allocation for second device failed\n");
-		else if ((err = register_netdev(dev1))) {
+		if (dev1 && (err = register_netdev(dev1)) == 0)
+			sky2_show_addr(dev1);
+		else {
 			dev_warn(&pdev->dev,
 				 "register of second port failed (%d)\n", err);
 			hw->dev[1] = NULL;
-			free_netdev(dev1);
-		} else
-			sky2_show_addr(dev1);
+			hw->ports = 1;
+			if (dev1)
+				free_netdev(dev1);
+		}
 	}
 
 	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);



-- 
