From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 1/5] etherdev: Fix sparse error,
 make test usable by other functions
Date: Mon, 04 May 2015 14:33:48 -0700
Message-ID: <20150504213348.2536.53993.stgit@ahduyck-vm-fedora22>
References: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, pshelar@nicira.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751697AbbEDVdz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 17:33:55 -0400
In-Reply-To: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change does two things.  First it fixes a sparse error for the fact
that the __be16 degrades to an integer.  Since that is actually what I am
kind of doing I am simply working around that by forcing both sides of the
comparison to u16.

Also I realized on some compilers I was generating another instruction for
big endian systems such as PowerPC since it was masking the value before
doing the comparison.  So to resolve that I have simply pulled the mask out
and wrapped it in an #ifndef __BIG_ENDIAN.

Lastly I pulled this all out into its own function.  I notices there are
similar checks in a number of other places so this function can be reused
there to help reduce overhead in these paths as well.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/etherdevice.h |   18 ++++++++++++++++++
 net/ethernet/eth.c          |    2 +-
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index c4a10f991fe0..9012f8775208 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -191,6 +191,24 @@ static inline bool is_valid_ether_addr(const u8 *addr)
 }
 
 /**
+ * eth_proto_is_802_3 - Determine if a given Ethertype/length is a protocol
+ * @proto: Ethertype/length value to be tested
+ *
+ * Check that the value from the Ethertype/length field is a valid Ethertype.
+ *
+ * Return true if the valid is an 802.3 supported Ethertype.
+ */
+static inline bool eth_proto_is_802_3(__be16 proto)
+{
+#ifndef __BIG_ENDIAN
+	/* if CPU is little endian mask off bits representing LSB */
+	proto &= htons(0xFF00);
+#endif
+	/* cast both to u16 and compare since LSB can be ignored */
+	return (__force u16)proto >= (__force u16)htons(ETH_P_802_3_MIN);
+}
+
+/**
  * eth_random_addr - Generate software assigned random Ethernet address
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 314e4c5a5a5e..9045e2a1108f 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -179,7 +179,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(netdev_uses_dsa(dev)))
 		return htons(ETH_P_XDSA);
 
-	if (likely((eth->h_proto & htons(0xFF00)) >= htons(ETH_P_802_3_MIN)))
+	if (likely(eth_proto_is_802_3(eth->h_proto)))
 		return eth->h_proto;
 
 	/*
