From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: ZD1211RW unaligned accesses...
Date: Fri, 23 Nov 2007 11:41:26 +0100
Message-ID: <1195814486.4149.83.camel@johannes.berg>
References: <20071120.040546.222294375.davem@davemloft.net>
	 (sfid-20071120_120554_491311_552F5A44)
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	shaddy_baddah-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071120.040546.222294375.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (sfid-20071120_120554_491311_552F5A44)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> The problem is
> drivers/net/wireless/zd1211/zd_mac.c:update_qual_rssi().
> Specifically the compare_ether_addr() call

I don't believe this is true. Shaddy seems to back that up by the patch
not helping.

> Wireless folks, I would suggest we do some auditing of the
> compare_ether_addr() calls and for the ones that are operating
> on these potentially unaligned structs we change it to either
> a straight memcmp() or some new routine which will more reflect
> the issue (say something like "compare_ether_addr_unaligned()"
> or "ieee80211_compare_ether_addr()").

All MAC addresses in 802.11 headers are at least aligned on 16-bit
boundaries. Hence, if the some MAC address like the BSSID here was
unaligned we'd also have the IP header unaligned causing a lot more
trouble than this.

Shaddy, please rebuild zd1211 with the patch below, it should make the
compiler not inline all those static functions allowing us to pinpoint
much better where the problem occurs. You will probably need to delete
all *.o files in the zd1211rw/ directory to the them rebuilt after the
Makefile change.

--- everything.orig/drivers/net/wireless/zd1211rw/Makefile	2007-11-23 11:36:30.652094075 +0100
+++ everything/drivers/net/wireless/zd1211rw/Makefile	2007-11-23 11:36:57.112090711 +0100
@@ -1,5 +1,7 @@
 obj-$(CONFIG_ZD1211RW) += zd1211rw.o
 
+EXTRA_CFLAGS += -fno-inline-functions-called-once
+
 zd1211rw-objs := zd_chip.o zd_ieee80211.o \
 		zd_mac.o zd_netdev.o \
 		zd_rf_al2230.o zd_rf_rf2959.o \
