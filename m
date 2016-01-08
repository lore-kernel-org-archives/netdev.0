From: Huw Davies <huw@codeweavers.com>
Subject: [RFC PATCH v2 16/18] calipso: Add validation of CALIPSO option.
Date: Fri,  8 Jan 2016 09:52:52 +0000
Message-ID: <1452246774-13241-17-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

We check lengths, checksum and the DOI.  We leave checking of the
level and categories for the socket layer.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 include/net/calipso.h |  6 ++++++
 net/ipv6/calipso.c    | 43 +++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/exthdrs.c    | 27 +++++++++++++++++++++++++++
 3 files changed, 76 insertions(+)

diff --git a/include/net/calipso.h b/include/net/calipso.h
index ad4d653..99df89b 100644
--- a/include/net/calipso.h
+++ b/include/net/calipso.h
@@ -65,6 +65,7 @@ struct calipso_doi {
 #ifdef CONFIG_NETLABEL
 int __init calipso_init(void);
 void calipso_exit(void);
+bool calipso_validate(const struct sk_buff *skb, const unsigned char *option);
 #else
 static inline int __init calipso_init(void)
 {
@@ -74,6 +75,11 @@ static inline int __init calipso_init(void)
 static inline void calipso_exit(void)
 {
 }
+static inline bool calipso_validate(const struct sk_buff *skb,
+				    const unsigned char *option)
+{
+	return true;
+}
 #endif /* CONFIG_NETLABEL */
 
 #endif /* _CALIPSO_H */
diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index 1616464..4aa2f66 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -315,6 +315,49 @@ doi_walk_return:
 }
 
 /**
+ * calipso_validate - Validate a CALIPSO option
+ * @skb: the packet
+ * @option: the start of the option
+ *
+ * Description:
+ * This routine is called to validate a CALIPSO option.
+ * If the option is valid then a zero value is returned.  If the
+ * option is invalid then a non-zero value is returned and
+ * representing the offset to the offending portion of the option.
+ *
+ * The caller should have already checked that the length of the
+ * option (including the TLV header) is >= 10 and that the catmap
+ * length is consistent with the option length.
+ *
+ * We leave checks on the level and categories to the socket layer.
+ */
+bool calipso_validate(const struct sk_buff *skb, const unsigned char *option)
+{
+	struct calipso_doi *doi_def;
+	int ret_val;
+	u16 crc, len = option[1] + 2;
+	static const u8 zero[2];
+
+	/* The original CRC runs over the option including the TLV header
+	 * with the CRC-16 field (at offset 8) zeroed out.
+	 */
+	crc = crc_ccitt(0xffff, option, 8);
+	crc = crc_ccitt(crc, zero, sizeof(zero));
+	if (len > 10)
+		crc = crc_ccitt(crc, option + 10, len - 10);
+	crc = ~crc;
+	if (option[8] != (crc & 0xff) || option[9] != ((crc >> 8) & 0xff))
+		return false;
+
+	rcu_read_lock();
+	doi_def = calipso_doi_search(get_unaligned_be32(option + 2));
+	ret_val = !!doi_def;
+	rcu_read_unlock();
+
+	return ret_val;
+}
+
+/**
  * calipso_map_cat_hton - Perform a category mapping from host to network
  * @doi_def: the DOI definition
  * @secattr: the security attributes
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index d5fd3e7..0f69cab 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -43,6 +43,7 @@
 #include <net/ndisc.h>
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
+#include <net/calipso.h>
 #if IS_ENABLED(CONFIG_IPV6_MIP6)
 #include <net/xfrm.h>
 #endif
@@ -603,6 +604,28 @@ drop:
 	return false;
 }
 
+/* CALIPSO RFC 5570 */
+
+static bool ipv6_hop_calipso(struct sk_buff *skb, int optoff)
+{
+	const unsigned char *nh = skb_network_header(skb);
+
+	if (nh[optoff + 1] < 8)
+		goto drop;
+
+	if (nh[optoff + 6] * 4 + 8 > nh[optoff + 1])
+		goto drop;
+
+	if (!calipso_validate(skb, nh + optoff))
+		goto drop;
+
+	return true;
+
+drop:
+	kfree_skb(skb);
+	return false;
+}
+
 static const struct tlvtype_proc tlvprochopopt_lst[] = {
 	{
 		.type	= IPV6_TLV_ROUTERALERT,
@@ -612,6 +635,10 @@ static const struct tlvtype_proc tlvprochopopt_lst[] = {
 		.type	= IPV6_TLV_JUMBO,
 		.func	= ipv6_hop_jumbo,
 	},
+	{
+		.type	= IPV6_TLV_CALIPSO,
+		.func	= ipv6_hop_calipso,
+	},
 	{ -1, }
 };
 
-- 
1.8.0

