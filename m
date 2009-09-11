From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next PATCH V2] etherdevice.h: random_ether_addr update
Date: Fri, 11 Sep 2009 14:13:04 -0700
Message-ID: <43F901BD926A4E43B106BF17856F07556A7EAC63@orsmsx508.amr.corp.intel.com>
References: <20090911014757.19631.66570.stgit@localhost.localdomain>
	 <20090910190703.25d14533@nehalam>
	 <1252638163.4355.35.camel@Joe-Laptop.home>
	 <20090911.121542.45333246.davem@davemloft.net>
	 <1252700442.15292.62.camel@Joe-Laptop.home>
 <1252701862.15292.73.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48560 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756838AbZIKVNE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 17:13:04 -0400
In-Reply-To: <1252701862.15292.73.camel@Joe-Laptop.home>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The addresses generated here will likely never be used in a production environment.  They are place holders so that the device will function before any management console has done what 99.9% of all vendors will do, which is assign their own address.  OK, that 99% is not a real number, but consider it illustrative of the fact that almost all VMM vendors will assign their own MAC addresses.

They're useful for test and development and that's about it.  We're in discussion with partners about how best to approach the management interface for this and each vendor has his own preferred approach (which complicates the solution) but for now the accepted method is for the igbvf driver to set it's own assigned MAC address in the guest.

The discussion is useful but I think we should keep in mind that the addresses in question will be transitory in nature, likely to be never used except for test and development.

One thing, the original patch described it as ncessary to help prevent collisions among MAC address and this is incorrect.  It was intended to help reduce collisions with other vendors MAC addresses.  If the list doesn't consider that a worth while goal then we can withdraw the patch or take one of the suggested permutations.

Thanks,

- Greg Rose
LAN Access Division
Intel Corp.

-----Original Message-----
From: Joe Perches [mailto:joe@perches.com] 
Sent: Friday, September 11, 2009 1:44 PM
To: David Miller
Cc: shemminger@vyatta.com; Kirsher, Jeffrey T; netdev@vger.kernel.org; gospo@redhat.com; Rose, Gregory V; Skidmore, Donald C
Subject: Re: [net-next PATCH V2] etherdevice.h: random_ether_addr update

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


