From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next v2 2/8] ieee802154: add
	address struct with proper endiannes and some operations
Date: Fri, 14 Mar 2014 21:23:58 +0100
Message-ID: <1394828644-19898-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1394828644-19898-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1394828644-19898-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a replacement ieee802154_addr struct with proper endianness on
fields. Short address fields are stored as __le16 as on the network,
extended (EUI64) addresses are __le64 as opposed to the u8[8] format
used previously. This disconnect with the netdev address, which is
stored as big-endian u8[8], is intentional.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 include/net/ieee802154_netdev.h | 72 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 72 insertions(+)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 53937cd..86d5d50 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -29,6 +29,78 @@
 
 #include <net/af_ieee802154.h>
 
+struct ieee802154_addr {
+	u8 mode;
+	__le16 pan_id;
+	union {
+		__le16 short_addr;
+		__le64 extended_addr;
+	};
+};
+
+static inline bool ieee802154_addr_equal(const struct ieee802154_addr *a1,
+					 const struct ieee802154_addr *a2)
+{
+	if (a1->pan_id != a2->pan_id || a1->mode != a2->mode)
+		return false;
+
+	if ((a1->mode == IEEE802154_ADDR_LONG &&
+	     a1->extended_addr != a2->extended_addr) ||
+	    (a1->mode == IEEE802154_ADDR_SHORT &&
+	     a1->short_addr != a2->short_addr))
+		return false;
+
+	return true;
+}
+
+static inline __le64 ieee802154_devaddr_from_raw(const void *raw)
+{
+	u64 temp;
+
+	memcpy(&temp, raw, IEEE802154_ADDR_LEN);
+	return (__force __le64)swab64(temp);
+}
+
+static inline void ieee802154_devaddr_to_raw(void *raw, __le64 addr)
+{
+	u64 temp = swab64((__force u64)addr);
+
+	memcpy(raw, &temp, IEEE802154_ADDR_LEN);
+}
+
+static inline void ieee802154_addr_from_sa(struct ieee802154_addr *a,
+					   const struct ieee802154_addr_sa *sa)
+{
+	a->mode = sa->addr_type;
+	a->pan_id = cpu_to_le16(sa->pan_id);
+
+	switch (a->mode) {
+	case IEEE802154_ADDR_SHORT:
+		a->short_addr = cpu_to_le16(sa->short_addr);
+		break;
+	case IEEE802154_ADDR_LONG:
+		a->extended_addr = ieee802154_devaddr_from_raw(sa->hwaddr);
+		break;
+	}
+}
+
+static inline void ieee802154_addr_to_sa(struct ieee802154_addr_sa *sa,
+					 const struct ieee802154_addr *a)
+{
+	sa->addr_type = a->mode;
+	sa->pan_id = le16_to_cpu(a->pan_id);
+
+	switch (a->mode) {
+	case IEEE802154_ADDR_SHORT:
+		sa->short_addr = le16_to_cpu(a->short_addr);
+		break;
+	case IEEE802154_ADDR_LONG:
+		ieee802154_devaddr_to_raw(sa->hwaddr, a->extended_addr);
+		break;
+	}
+}
+
+
 struct ieee802154_frag_info {
 	__be16 d_tag;
 	u16 d_size;
-- 
1.9.0


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
