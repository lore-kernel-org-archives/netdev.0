From: Jan Oravec <jan.oravec@6com.sk>
Subject: [PATCH] IPv6, mcast: deactivate timers before ipv6_mc_destroy_dev()
Date: Sun, 5 Oct 2003 11:06:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031005090610.GA23600@wsx.ksp.sk>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,


the following patch calls ipv6_mc_down(idev) to deactivate timers. If we do
not deactivate them, the following may happen:

1) remove last IPv6 address from the interface
  - mld_ifc_timer may be active, thus referencing idev
  - addrconf_ifdown() is called (which calls ipv6_mc_destroy_dev()),
    removing all references to idev except the timer reference
  - timer expires, mld_ifc_timer_expire() is called, reference to idev is
    removed, but not tested (__in6_dev_put())
  - idev is not removed and it is referencing dev
2) destroy interface
  - idev's reference to dev never disappears


--- linux/net/ipv6/mcast.c.orig	2003-09-28 02:50:53.000000000 +0200
+++ linux/net/ipv6/mcast.c	2003-10-05 10:42:57.535993672 +0200
@@ -2029,6 +2029,9 @@
 	struct ifmcaddr6 *i;
 	struct in6_addr maddr;
 
+	/* Deactivate timers */
+	ipv6_mc_down(idev);
+
 	/* Delete all-nodes address. */
 	ipv6_addr_all_nodes(&maddr);
 



Best Regards,

-- 
Jan Oravec
6COM s.r.o.
http://www.6com.sk
