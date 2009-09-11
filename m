From: Joe Perches <joe@perches.com>
Subject: [net-next PATCH] etherdevice.h: random_ether_addr update
Date: Fri, 11 Sep 2009 13:20:42 -0700
Message-ID: <1252700442.15292.62.camel@Joe-Laptop.home>
References: <20090911014757.19631.66570.stgit@localhost.localdomain>
	 <20090910190703.25d14533@nehalam>
	 <1252638163.4355.35.camel@Joe-Laptop.home>
	 <20090911.121542.45333246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com,
	donald.c.skidmore@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1110 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751988AbZIKUUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 16:20:40 -0400
In-Reply-To: <20090911.121542.45333246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-09-11 at 12:15 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Thu, 10 Sep 2009 20:02:43 -0700
> > On Thu, 2009-09-10 at 19:07 -0700, Stephen Hemminger wrote:
> >> On Thu, 10 Sep 2009 18:48:27 -0700
> >> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> >> > From: Gregory Rose <gregory.v.rose@intel.com>
> >> > This patch changes the default VF MAC address generation to use an Intel
> >> > Organizational Unit Identifier (OUI), instead of a fully randomized
> >> > Ethernet address.  This is to help prevent accidental MAC address
> >> > collisions.
> > I think this not a very good idea.
> I also completely agree that this patch is not a wise move.

Perhaps this?

random_ether_address should not assign an "0x02" leading octet.

"02" has the local assignment bit set,
but is actually a value assigned via OUI.

Do not use get_random_bytes to avoid drawing down entropy pool.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 3d7a668..ae7f261 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -121,9 +121,17 @@ static inline int is_valid_ether_addr(const u8 *addr)
  */
 static inline void random_ether_addr(u8 *addr)
 {
-	get_random_bytes (addr, ETH_ALEN);
-	addr [0] &= 0xfe;	/* clear multicast bit */
-	addr [0] |= 0x02;	/* set local assignment bit (IEEE802) */
+	int i;
+
+	/* not calling get_random_bytes to avoid using entropy */
+	do {
+		addr[0] = random32();
+	} while (addr[0] == 0 || addr[0] == 1);
+				/* get a non-zero, non-one leading octet */
+	addr[0] &= 0xfe;	/* clear multicast bit */
+	addr[0] |= 0x02;	/* set local assignment bit (IEEE802) */
+	for (i = 1; i < ETH_ALEN; i++)
+		addr[i] = random32();
 }
 
 /**


