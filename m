From: Peter Wu <lekensteyn@gmail.com>
Subject: [ethtool] Add new Realtek devices
Date: Tue, 23 Jul 2013 10:51:04 +0200
Message-ID: <3162188.mmLmSZRt9A@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:64548 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755912Ab3GWIyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 04:54:21 -0400
Received: by mail-ee0-f47.google.com with SMTP id e49so4261715eek.6
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 01:54:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The list of devices supported by `ethtool -d eth0` was quite outdated
and did not support my onboard NIC. With the following two patches, the
supported devices list will be in sync with the r8169 kernel driver
(r8169 as of 3.11). Note that no new registers have been added, I am
sure that some registers are incorrect (like the Power Management wakeup
frames), but important information such as MAC address is still correct.

Another note, I have observed that memcpy_fromio results in invalid
reads for the RTL8111E (via `ethtool -d`). In fact, any reads of size
greater than or equal to 8 result in a sequence of FFs. As a quick hack,
I patched r8169 to perform reads of word size (see bottom), but I am not
sure what the cause is of this strange behavior. Francois, perhaps you
have an idea why reading in blocks of larger than 7 results in a error?

Regards,
Peter
---
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1897,12 +2050,17 @@ static void rtl8169_get_regs(struct net_device *dev, 
struct ethtool_regs *regs,
 			     void *p)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	char *bytes = p;
+	int i;
 
 	if (regs->len > R8169_REGS_SIZE)
 		regs->len = R8169_REGS_SIZE;
 
 	rtl_lock_work(tp);
-	memcpy_fromio(p, tp->mmio_addr, regs->len);
+	for (i = 0; i < regs->len - 4; i += 4)
+		memcpy_fromio(bytes + i, tp->mmio_addr + i, 4);
+	if (i < regs->len)
+		memcpy_fromio(bytes + i, tp->mmio_addr + i, regs->len - i);
 	rtl_unlock_work(tp);
 }
