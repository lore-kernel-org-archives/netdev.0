From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFCv2 PATCH net-next 1/3] uapi: add MACsec bits
Date: Tue,  2 Feb 2016 14:29:19 +0100
Message-ID: <d4ba69ae4ab8ac84d38ab595b69a9e14fdb509f7.1454404823.git.sd@queasysnail.net>
References: <cover.1454404823.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755242AbcBBN3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 08:29:37 -0500
In-Reply-To: <cover.1454404823.git.sd@queasysnail.net>
In-Reply-To: <cover.1454404823.git.sd@queasysnail.net>
References: <cover.1454404823.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
RFCv2:
 - add include, detected by the kbuild robot
 - split off the attributes for RXSC and SA from enum macsec_attrs

 include/uapi/linux/Kbuild      |   1 +
 include/uapi/linux/if_ether.h  |   1 +
 include/uapi/linux/if_link.h   |  21 ++++++
 include/uapi/linux/if_macsec.h | 165 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 188 insertions(+)
 create mode 100644 include/uapi/linux/if_macsec.h

diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index ebd10e624598..e25ebcfbcb48 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -173,6 +173,7 @@ header-y += if_hippi.h
 header-y += if_infiniband.h
 header-y += if_link.h
 header-y += if_ltalk.h
+header-y += if_macsec.h
 header-y += if_packet.h
 header-y += if_phonet.h
 header-y += if_plip.h
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index ea9221b0331a..4a93051c578c 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -83,6 +83,7 @@
 #define ETH_P_8021AD	0x88A8          /* 802.1ad Service VLAN		*/
 #define ETH_P_802_EX1	0x88B5		/* 802.1 Local Experimental 1.  */
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
+#define ETH_P_MACSEC	0x88E5		/* 802.1ae MACsec */
 #define ETH_P_8021AH	0x88E7          /* 802.1ah Backbone Service Tag */
 #define ETH_P_MVRP	0x88F5          /* 802.1Q MVRP                  */
 #define ETH_P_1588	0x88F7		/* IEEE 1588 Timesync */
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index a30b78090594..be0e6caf0bf0 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -401,6 +401,27 @@ enum {
 
 #define IFLA_VRF_MAX (__IFLA_VRF_MAX - 1)
 
+/* MACSEC section */
+enum {
+	IFLA_MACSEC_UNSPEC,
+	IFLA_MACSEC_SCI,
+	IFLA_MACSEC_PORT,
+	IFLA_MACSEC_ICV_LEN,
+	IFLA_MACSEC_CIPHER_SUITE,
+	IFLA_MACSEC_WINDOW,
+	IFLA_MACSEC_ENCODING_SA,
+	IFLA_MACSEC_ENCRYPT,
+	IFLA_MACSEC_PROTECT,
+	IFLA_MACSEC_INC_SCI,
+	IFLA_MACSEC_ES,
+	IFLA_MACSEC_SCB,
+	IFLA_MACSEC_REPLAY_PROTECT,
+	IFLA_MACSEC_VALIDATION,
+	__IFLA_MACSEC_MAX,
+};
+
+#define IFLA_MACSEC_MAX (__IFLA_MACSEC_MAX - 1)
+
 /* IPVLAN section */
 enum {
 	IFLA_IPVLAN_UNSPEC,
diff --git a/include/uapi/linux/if_macsec.h b/include/uapi/linux/if_macsec.h
new file mode 100644
index 000000000000..bd1abe1717e9
--- /dev/null
+++ b/include/uapi/linux/if_macsec.h
@@ -0,0 +1,165 @@
+/*
+ * include/uapi/linux/if_macsec.h - MACsec device
+ *
+ * Copyright (c) 2015 Sabrina Dubroca <sd@queasysnail.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _UAPI_MACSEC_H
+#define _UAPI_MACSEC_H
+
+#include <linux/types.h>
+
+#define MACSEC_GENL_NAME "macsec"
+#define MACSEC_GENL_VERSION 1
+
+#define MACSEC_MAX_KEY_LEN 128
+
+
+#define DEFAULT_CIPHER_NAME "GCM-AES-128"
+#define DEFAULT_CIPHER_ID   0x0080020001000001ULL
+#define DEFAULT_CIPHER_ALT  0x0080C20001000001ULL
+
+#define MACSEC_MIN_ICV_LEN 8
+#define MACSEC_MAX_ICV_LEN 32
+
+enum macsec_attrs {
+	MACSEC_ATTR_UNSPEC,
+	MACSEC_ATTR_IFINDEX,
+	MACSEC_ATTR_SCI,
+	MACSEC_ATTR_ENCODING_SA,
+	MACSEC_ATTR_WINDOW,
+	MACSEC_ATTR_CIPHER_SUITE,
+	MACSEC_ATTR_ICV_LEN,
+	MACSEC_TXSA_LIST,
+	MACSEC_RXSC_LIST,
+	MACSEC_TXSC_STATS,
+	MACSEC_SECY_STATS,
+	MACSEC_ATTR_PROTECT,
+	MACSEC_ATTR_REPLAY,
+	MACSEC_ATTR_OPER,
+	MACSEC_ATTR_VALIDATE,
+	MACSEC_ATTR_ENCRYPT,
+	MACSEC_ATTR_INC_SCI,
+	MACSEC_ATTR_ES,
+	MACSEC_ATTR_SCB,
+	__MACSEC_ATTR_END,
+	NUM_MACSEC_ATTR = __MACSEC_ATTR_END,
+	MACSEC_ATTR_MAX = __MACSEC_ATTR_END - 1,
+};
+
+enum macsec_sa_list_attrs {
+	MACSEC_SA_LIST_UNSPEC,
+	MACSEC_SA,
+	__MACSEC_ATTR_SA_LIST_MAX,
+	MACSEC_ATTR_SA_LIST_MAX = __MACSEC_ATTR_SA_LIST_MAX - 1,
+};
+
+enum macsec_rxsc_list_attrs {
+	MACSEC_RXSC_LIST_UNSPEC,
+	MACSEC_RXSC,
+	__MACSEC_ATTR_RXSC_LIST_MAX,
+	MACSEC_ATTR_RXSC_LIST_MAX = __MACSEC_ATTR_RXSC_LIST_MAX - 1,
+};
+
+enum macsec_rxsc_attrs {
+	MACSEC_ATTR_SC_UNSPEC,
+	/* use the same value to allow generic helper function, see
+	 * get_*_from_nl in drivers/net/macsec.c */
+	MACSEC_ATTR_SC_IFINDEX = MACSEC_ATTR_IFINDEX,
+	MACSEC_ATTR_SC_SCI = MACSEC_ATTR_SCI,
+	MACSEC_ATTR_SC_ACTIVE,
+	MACSEC_RXSA_LIST,
+	MACSEC_RXSC_STATS,
+	__MACSEC_ATTR_SC_END,
+	NUM_MACSEC_SC_ATTR = __MACSEC_ATTR_SC_END,
+	MACSEC_ATTR_SC_MAX = __MACSEC_ATTR_SC_END - 1,
+};
+
+enum macsec_sa_attrs {
+	MACSEC_ATTR_SA_UNSPEC,
+	/* use the same value to allow generic helper function, see
+	 * get_*_from_nl in drivers/net/macsec.c */
+	MACSEC_ATTR_SA_IFINDEX = MACSEC_ATTR_IFINDEX,
+	MACSEC_ATTR_SA_SCI = MACSEC_ATTR_SCI,
+	MACSEC_ATTR_SA_AN,
+	MACSEC_ATTR_SA_ACTIVE,
+	MACSEC_ATTR_SA_PN,
+	MACSEC_ATTR_SA_KEY,
+	MACSEC_ATTR_SA_KEYID,
+	MACSEC_SA_STATS,
+	__MACSEC_ATTR_SA_END,
+	NUM_MACSEC_SA_ATTR = __MACSEC_ATTR_SA_END,
+	MACSEC_ATTR_SA_MAX = __MACSEC_ATTR_SA_END - 1,
+};
+
+enum macsec_nl_commands {
+	MACSEC_CMD_GET_TXSC,
+	MACSEC_CMD_ADD_RXSC,
+	MACSEC_CMD_DEL_RXSC,
+	MACSEC_CMD_UPD_RXSC,
+	MACSEC_CMD_ADD_TXSA,
+	MACSEC_CMD_DEL_TXSA,
+	MACSEC_CMD_UPD_TXSA,
+	MACSEC_CMD_ADD_RXSA,
+	MACSEC_CMD_DEL_RXSA,
+	MACSEC_CMD_UPD_RXSA,
+};
+
+enum validation_type {
+	MACSEC_VALIDATE_DISABLED = 0,
+	MACSEC_VALIDATE_CHECK = 1,
+	MACSEC_VALIDATE_STRICT = 2,
+	__MACSEC_VALIDATE_MAX,
+};
+#define MACSEC_VALIDATE_MAX (__MACSEC_VALIDATE_MAX - 1)
+
+struct macsec_rx_sc_stats {
+	__u64 InOctetsValidated;
+	__u64 InOctetsDecrypted;
+	__u64 InPktsUnchecked;
+	__u64 InPktsDelayed;
+	__u64 InPktsOK;
+	__u64 InPktsInvalid;
+	__u64 InPktsLate;
+	__u64 InPktsNotValid;
+	__u64 InPktsNotUsingSA;
+	__u64 InPktsUnusedSA;
+};
+
+struct macsec_rx_sa_stats {
+	__u32 InPktsOK;
+	__u32 InPktsInvalid;
+	__u32 InPktsNotValid;
+	__u32 InPktsNotUsingSA;
+	__u32 InPktsUnusedSA;
+};
+
+struct macsec_tx_sc_stats {
+	__u64 OutPktsProtected;
+	__u64 OutPktsEncrypted;
+	__u64 OutOctetsProtected;
+	__u64 OutOctetsEncrypted;
+};
+
+struct macsec_tx_sa_stats {
+	__u32 OutPktsProtected;
+	__u32 OutPktsEncrypted;
+};
+
+struct macsec_dev_stats {
+	__u64 OutPktsUntagged;
+	__u64 InPktsUntagged;
+	__u64 OutPktsTooLong;
+	__u64 InPktsNoTag;
+	__u64 InPktsBadTag;
+	__u64 InPktsUnknownSCI;
+	__u64 InPktsNoSCI;
+	__u64 InPktsOverrun;
+};
+
+#endif /* _UAPI_MACSEC_H */
-- 
2.7.0
