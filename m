From: akpm@linux-foundation.org
Subject: [patch (for 2.6.25?) 1/2] The kernel gets no IP from some DHCP servers
Date: Tue, 04 Mar 2008 14:56:48 -0800
Message-ID: <200803042256.m24MumHJ001353@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	Marcel.Wappler@bridgeco.net, kaber@trash.net,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34486 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765373AbYCDXBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:01:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Wappler Marcel" <Marcel.Wappler@bridgeco.net>

This patch fixes a DHCP issue of the kernel: some DHCP servers (i.e.  in the
Linksys WRT54Gv5) are very strict about the contents of the DHCPDISCOVER
packet they receive from clients.

Table 5 in RFC2131 page 36 requests the fields 'ciaddr' and 'siaddr' MUST be
set to '0'.  These DHCP servers ignore Linux kernel's DHCP discovery packets
with these two fields set to '255.255.255.255' (in contrast to popular DHCP
clients, such as 'dhclient' or 'udhcpc').  This leads to a not booting system.

I tested this on a ARM embedded device mounting rootfs over NFS obtaining its
IP from a Linksys WRT54Gv5 Router running VxWorks and a PC based Server
running a Linux.  Changing the two fields to '0.0.0.0' worked.

Cc: Stephen Hemminger <shemminger@osdl.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/ipv4/ipconfig.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff -puN net/ipv4/ipconfig.c~the-kernel-gets-no-ip-from-some-dhcp-servers net/ipv4/ipconfig.c
--- a/net/ipv4/ipconfig.c~the-kernel-gets-no-ip-from-some-dhcp-servers
+++ a/net/ipv4/ipconfig.c
@@ -29,6 +29,10 @@
  *
  *  Multiple Nameservers in /proc/net/pnp
  *              --  Josef Siemes <jsiemes@web.de>, Aug 2002
+ *
+ *  Bugfix: Not getting an IP from some DHCP servers: RFC2131 page 36
+ *  Table 5 requests DHCPDISCOVER fields ciaddr and siaddr MUST be '0'.
+ *              -- marcel.wappler@bridgeco.net
  */
 
 #include <linux/types.h>
@@ -103,6 +107,7 @@
 					   - '3' from resolv.h */
 
 #define NONE __constant_htonl(INADDR_NONE)
+#define ZERO __constant_htonl(((unsigned long int) 0x00000000))
 
 /*
  * Public IP configuration
@@ -754,8 +759,8 @@ static void __init ic_bootp_send_if(stru
 		b->htype = dev->type; /* can cause undefined behavior */
 	}
 	b->hlen = dev->addr_len;
-	b->your_ip = NONE;
-	b->server_ip = NONE;
+	b->your_ip = ZERO;
+	b->server_ip = ZERO;
 	memcpy(b->hw_addr, dev->dev_addr, dev->addr_len);
 	b->secs = htons(jiffies_diff / HZ);
 	b->xid = d->xid;
_
