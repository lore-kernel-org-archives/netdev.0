From: Maarten Lankhorst <maarten.lankhorst@canonical.com>
Subject: [RFC PATCH] unlock rtnl mutex in ic_open_devs while waiting
Date: Mon, 05 Jan 2015 14:52:06 +0100
Message-ID: <54AA9706.5020202@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a deadlock with alx_link_check, which takes the rtnl_mutex in
a work item to check the link.

I have no idea whether alx should be fixed or ipconfig.c,
but this saves 120 seconds off my boot time. ;-)

Signed-off-by: Maarten Lankhorst <maarten.lankhorst@canonical.com>
---
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 7fa18bc7e47f..c8aa15a0cdf4 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -270,7 +270,9 @@ static int __init ic_open_devs(void)
 			if (ic_is_init_dev(dev) && netif_carrier_ok(dev))
 				goto have_carrier;
 
+		rtnl_unlock();
 		msleep(1);
+		rtnl_lock();
 
 		if (time_before(jiffies, next_msg))
 			continue;
