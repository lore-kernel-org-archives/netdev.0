From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH repost net-next] dsa: mv88e6xxx: Optimise atu_get
Date: Wed,  4 Jan 2017 19:56:24 +0100
Message-ID: <1483556184-4176-1-git-send-email-andrew@lunn.ch>
Cc: volodymyr.bendiuga@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43278 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934937AbdADS46 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 13:56:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lookup in the ATU can be performed starting from a given MAC
address. This is faster than starting with the first possible MAC
address and iterating all entries.

Entries are returned in numeric order. So if the MAC address returned
is bigger than what we are searching for, we know it is not in the
ATU.

Using the benchmark provided by Volodymyr Bendiuga
<volodymyr.bendiuga@gmail.com>,

https://www.spinics.net/lists/netdev/msg411550.html

on an Marvell Armada 370 RD, the test to add a number of static fdb
entries went from 1.616531 seconds to 0.312052 seconds.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---

Cc: netdev this time.

 drivers/net/dsa/mv88e6xxx/chip.c |  5 ++--
 include/linux/etherdevice.h      | 60 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 63 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index f7222dc6581d..4cdb0f09788b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2023,7 +2023,8 @@ static int mv88e6xxx_atu_get(struct mv88e6xxx_chip *chip, int fid,
 	struct mv88e6xxx_atu_entry next;
 	int err;
 
-	eth_broadcast_addr(next.mac);
+	memcpy(next.mac, addr, ETH_ALEN);
+	eth_addr_dec(next.mac);
 
 	err = _mv88e6xxx_atu_mac_write(chip, next.mac);
 	if (err)
@@ -2041,7 +2042,7 @@ static int mv88e6xxx_atu_get(struct mv88e6xxx_chip *chip, int fid,
 			*entry = next;
 			return 0;
 		}
-	} while (!is_broadcast_ether_addr(next.mac));
+	} while (ether_addr_greater(addr, next.mac));
 
 	memset(entry, 0, sizeof(*entry));
 	entry->fid = fid;
diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 6fec9e81bd70..42add77ae47d 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -397,6 +397,66 @@ static inline bool ether_addr_equal_masked(const u8 *addr1, const u8 *addr2,
 }
 
 /**
+ * ether_addr_to_u64 - Convert an Ethernet address into a u64 value.
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Return a u64 value of the address
+ */
+static inline u64 ether_addr_to_u64(const u8 *addr)
+{
+	u64 u = 0;
+	int i;
+
+	for (i = 0; i < ETH_ALEN; i++)
+		u = u << 8 | addr[i];
+
+	return u;
+}
+
+/**
+ * u64_to_ether_addr - Convert a u64 to an Ethernet address.
+ * @u: u64 to convert to an Ethernet MAC address
+ * @addr: Pointer to a six-byte array to contain the Ethernet address
+ */
+static inline void u64_to_ether_addr(u64 u, u8 *addr)
+{
+	int i;
+
+	for (i = ETH_ALEN - 1; i >= 0; i--) {
+		addr[i] = u & 0xff;
+		u = u >> 8;
+	}
+}
+
+/**
+ * eth_addr_dec - Decrement the given MAC address
+ *
+ * @addr: Pointer to a six-byte array containing Ethernet address to decrement
+ */
+static inline void eth_addr_dec(u8 *addr)
+{
+	u64 u = ether_addr_to_u64(addr);
+
+	u--;
+	u64_to_ether_addr(u, addr);
+}
+
+/**
+ * ether_addr_greater - Compare two Ethernet addresses
+ * @addr1: Pointer to a six-byte array containing the Ethernet address
+ * @addr2: Pointer other six-byte array containing the Ethernet address
+ *
+ * Compare two Ethernet addresses, returns true addr1 is greater than addr2
+ */
+static inline bool ether_addr_greater(const u8 *addr1, const u8 *addr2)
+{
+	u64 u1 = ether_addr_to_u64(addr1);
+	u64 u2 = ether_addr_to_u64(addr2);
+
+	return u1 > u2;
+}
+
+/**
  * is_etherdev_addr - Tell if given Ethernet address belongs to the device.
  * @dev: Pointer to a device structure
  * @addr: Pointer to a six-byte array containing the Ethernet address
-- 
2.11.0
