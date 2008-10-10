From: "Alex Bennee" <kernel-hacker@bennee.com>
Subject: rtl8169_get_stats seems to be adding random crap to rx_missed_errors count
Date: Fri, 10 Oct 2008 17:47:31 +0100
Message-ID: <b2cdc9f30810100947s699dbc76ia72023b08e064816@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: lkml@vger.kernel.org, romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.184]:26589 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147AbYJJQrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 12:47:32 -0400
Received: by rn-out-0910.google.com with SMTP id k40so438354rnd.17
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2008 09:47:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've been seeing odd behaviour in the ifconfig output for my rtl8169
based network device. The ifconfig output had a very high number of
dropped packets in the display which changed massively every time I
checked. I tracked it down to /proc/net/dev and the a few test patches
it seems the rc_missed field is the culprit. I did a test patch of the
form:

+++ b/drivers/net/r8169.c
@@ -3062,10 +3062,16 @@ static struct net_device_stats
*rtl8169_get_stats(struct net_device *dev)
        unsigned long flags;

        if (netif_running(dev)) {
+               u32 missed;
                spin_lock_irqsave(&tp->lock, flags);
-               dev->stats.rx_missed_errors += RTL_R32(RxMissed);
+               missed = RTL_R32(RxMissed);
                RTL_W32(RxMissed, 0);
                spin_unlock_irqrestore(&tp->lock, flags);
+
+               dev->stats.rx_missed_errors += missed;
+               if (missed)
+                       printk(KERN_INFO "rtl8169_get_stats added %d
to missed count\n", missed);
+
        }

        return &dev->stats;

And low and behold I see this behaviour:

[  946.160188] rtl8169_get_stats added 250834943 to missed count
[  946.160354] rtl8169_get_stats added 20768 to missed count
[  946.160411] rtl8169_get_stats added 7032 to missed count
[  946.160425] rtl8169_get_stats added 1677 to missed count
[  946.160439] rtl8169_get_stats added 1577 to missed count
[  946.160452] rtl8169_get_stats added 1543 to missed count
[  946.160465] rtl8169_get_stats added 1517 to missed count
[  946.160479] rtl8169_get_stats added 1572 to missed count
[  946.160492] rtl8169_get_stats added 1586 to missed count
[  946.160504] rtl8169_get_stats added 1284 to missed count
[  948.164206] rtl8169_get_stats added 250864594 to missed count
[  948.164374] rtl8169_get_stats added 21004 to missed count
[  948.164434] rtl8169_get_stats added 7385 to missed count
[  948.164447] rtl8169_get_stats added 1631 to missed count
[  948.164461] rtl8169_get_stats added 1574 to missed count
[  948.164475] rtl8169_get_stats added 1645 to missed count
[  948.164489] rtl8169_get_stats added 1583 to missed count
[  948.164503] rtl8169_get_stats added 1561 to missed count
[  948.164523] rtl8169_get_stats added 2314 to missed count
[  948.164534] rtl8169_get_stats added 1300 to missed count
[  950.168182] rtl8169_get_stats added 250857857 to missed count
[  950.168345] rtl8169_get_stats added 20465 to missed count
[  950.168401] rtl8169_get_stats added 6903 to missed count
[  950.168416] rtl8169_get_stats added 1711 to missed count
[  950.168430] rtl8169_get_stats added 1585 to missed count
[  950.168443] rtl8169_get_stats added 1532 to missed count
[  950.168456] rtl8169_get_stats added 1520 to missed count
[  950.168469] rtl8169_get_stats added 1539 to missed count
[  950.168483] rtl8169_get_stats added 1588 to missed count
[  950.168494] rtl8169_get_stats added 1282 to missed count

It looks very much like the number being read is a decreasing counter
rather than anything else.

Has anyone got a copy of the data sheet and can confirm that:

	RxMissed	= 0x4c,

is the correct offset for the register and it doesn't need any special
handling to be read?




--
Alex, homepage: http://www.bennee.com/~alex/
