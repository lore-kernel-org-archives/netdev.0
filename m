From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 2/6] net: dsa: Do not reschedule polling if driver removed
Date: Thu, 29 Oct 2015 14:22:49 +0100
Message-ID: <56321DA9.5060600@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38177 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757040AbbJ2NXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 09:23:24 -0400
Received: by wmeg8 with SMTP id g8so24962029wme.1
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 06:23:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not reschedule the delayed work used for polling when
the driver is removed, by testing the 'poll_link_needed'
flag.
Avoids this crash:
 dsa dsa ethmv2 (unregistering): Link is Down
 device eth1 left promiscuous mode
 Unable to handle kernel paging request at virtual address bacc5cf6
 ...
 (run_timer_softirq) from [<c003e810>] (__do_softirq+0xcc/0x320)
 (__do_softirq) from [<c003ed40>] (irq_exit+0xac/0x10c)
 (irq_exit) from [<c007ec20>] (__handle_domain_irq+0x50/0xa8)

Signed-off-by: Frode Isaksen <fisaksen@baylibre.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index aeb6a7c..19cff8f 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -522,7 +522,8 @@ static void dsa_link_poll_work(struct work_struct *ugly)
 			ds->drv->poll_link(ds);
 	}

-	schedule_delayed_work(&dst->link_poll_work, round_jiffies_relative(HZ));
+	if (dst->link_poll_needed)
+		schedule_delayed_work(&dst->link_poll_work, round_jiffies_relative(HZ));
 }

 /* platform driver init and cleanup *****************************************/
@@ -943,6 +944,7 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 	int i;

 	if (dst->link_poll_needed) {
+		dst->link_poll_needed = 0;
 		cancel_delayed_work_sync(&dst->link_poll_work);
 		flush_delayed_work(&dst->link_poll_work);
 	}
-- 
1.9.1
