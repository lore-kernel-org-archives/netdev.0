From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH V2] etherdevice.h: random_ether_addr update
Date: Fri, 11 Sep 2009 13:44:22 -0700
Message-ID: <1252701862.15292.73.camel@Joe-Laptop.home>
References: <20090911014757.19631.66570.stgit@localhost.localdomain>
	 <20090910190703.25d14533@nehalam>
	 <1252638163.4355.35.camel@Joe-Laptop.home>
	 <20090911.121542.45333246.davem@davemloft.net>
	 <1252700442.15292.62.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com,
	donald.c.skidmore@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1116 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751760AbZIKUoU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 16:44:20 -0400
In-Reply-To: <1252700442.15292.62.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Perhaps this is slightly better, it doesn't call
random32 for each octet and makes sure the leading
octet is >= 0x04.

random_ether_address should assign a leading octet >= "0x04"

Does not use get_random_bytes to avoid drawing down entropy pool.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 3d7a668..fddcabf 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -121,9 +121,26 @@ static inline int is_valid_ether_addr(const u8 *addr)
  */
 static inline void random_ether_addr(u8 *addr)
 {
-	get_random_bytes (addr, ETH_ALEN);
-	addr [0] &= 0xfe;	/* clear multicast bit */
-	addr [0] |= 0x02;	/* set local assignment bit (IEEE802) */
+	u32 val;
+
+	/* not calling get_random_bytes to avoid using entropy */
+	do {
+		val = random32();
+		addr[0] = val;
+	} while (addr[0] < 4);
+	addr[0] &= 0xfe;	/* clear multicast bit */
+	addr[0] |= 0x02;	/* set local assignment bit (IEEE802) */
+
+	val >>= 8;
+	addr[1] = val;
+	val >>= 8;
+	addr[2] = val;
+	val >>= 8;
+	addr[3] = val;
+	val = random32();
+	addr[4] = val;
+	val >>= 8;
+	addr[5] = val;
 }
 
 /**


