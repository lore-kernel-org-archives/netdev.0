From: Zach Sadecki <zach@sadecki.net>
Subject: [PATCH] fec driver multicast (and IPv6) problem
Date: Thu, 26 May 2011 08:19:38 -0500
Message-ID: <4DDE536A.30005@sadecki.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:49669 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752037Ab1EZNTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 09:19:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed that sometimes I could not connect to my i.MX28 board over 
IPv6.  After some diagnosis I learned that it was not responding any NDP 
requests.  A simple "ip link set eth0 promisc off" would cause it to 
respond properly to those requests.  While that command didn't really do 
anything (it wasn't in promisc mode to begin with), it did trigger a 
call to set_multicast_list in the fec driver.  It turns out that the 
fec_restart function was zeroing out the multicast group hash registers 
which breaks IPv6 NDP (amongst other things dependent on multicast 
functionality).  Changing the zeroing functionality into a call to 
set_multicast_list fixed this problem for me.  Note that simply removing 
the calls that zero out the registers didn't work, as I believe the 
reset call a few lines above had already cleared them.  A patch is 
inline below.

Zach

diff -ru linux-2.6.39/drivers/net/fec.c 
linux-2.6.39-fecpatch/drivers/net/fec.c
--- linux-2.6.39/drivers/net/fec.c    2011-05-18 23:06:34.000000000 -0500
+++ linux-2.6.39-fecpatch/drivers/net/fec.c    2011-05-25 
15:17:12.294339147 -0500
@@ -361,8 +361,7 @@
      writel(0xffc00000, fep->hwp + FEC_IEVENT);

      /* Reset all multicast.    */
-    writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-    writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+    set_multicast_list(dev);
  #ifndef CONFIG_M5272
      writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
      writel(0, fep->hwp + FEC_HASH_TABLE_LOW);

