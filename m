From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH v2] ethtool: Correctly pull n-tuple string length
	for get_rx_ntuple
Date: Fri, 26 Feb 2010 19:50:46 -0800
Message-ID: <20100227035046.1160.52295.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:46654
	"EHLO qmta12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S967749Ab0B0DvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 22:51:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch fixes inconsistencies with the kernel header files, while
correctly gets the variable length string counts for the get_rx_ntuple
return value.  It does this by using the new GSSET_INFO ioctl.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 ethtool-copy.h |   22 ++++++++++++++++------
 ethtool.c      |   18 +++++++++++++++---
 2 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 8681f5e..c8e56b1 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -239,10 +239,10 @@ struct ethtool_pauseparam {
 
 #define ETH_GSTRING_LEN		32
 enum ethtool_stringset {
-	ETH_SS_TEST		= 0,
-	ETH_SS_STATS,
-	ETH_SS_PRIV_FLAGS,
-	ETH_SS_NTUPLE_FILTERS,
+	ETH_SS_TEST		= (1 << 0),
+	ETH_SS_STATS		= (1 << 1),
+	ETH_SS_PRIV_FLAGS	= (1 << 2),
+	ETH_SS_NTUPLE_FILTERS	= (1 << 3),
 };
 
 /* for passing string sets for data tagging */
@@ -253,6 +253,17 @@ struct ethtool_gstrings {
 	__u8	data[0];
 };
 
+struct ethtool_sset_info {
+	__u32   cmd;		/* ETHTOOL_GSSET_INFO */
+	__u32   reserved;
+	__u64   sset_mask;	/* input: each bit selects an sset to query */
+				/* output: each bit a returned sset */
+	__u32   data[0];	/* ETH_SS_xxx count, in order, based on bits
+				   in sset_mask.  One bit implies one
+				   __u32, two bits implies two
+				   __u32's, etc. */
+};
+
 enum ethtool_test_flags {
 	ETH_TEST_FL_OFFLINE	= (1 << 0),	/* online / offline */
 	ETH_TEST_FL_FAILED	= (1 << 1),	/* test passed / failed */
@@ -389,8 +400,6 @@ struct ethtool_rx_ntuple_flow_spec {
 #define ETHTOOL_RXNTUPLE_ACTION_DROP -1
 };
 
-#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
-#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
 struct ethtool_rx_ntuple {
 	__u32					cmd;
 	struct ethtool_rx_ntuple_flow_spec	fs;
@@ -466,6 +475,7 @@ struct ethtool_flash {
 
 #define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
 #define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+#define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.c b/ethtool.c
index fc9e419..12e0430 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2657,11 +2657,23 @@ static int do_srxntuple(int fd, struct ifreq *ifr)
 
 static int do_grxntuple(int fd, struct ifreq *ifr)
 {
+	struct ethtool_sset_info *sset_info;
 	struct ethtool_gstrings *strings;
 	int sz_str, n_strings, err, i;
 
-	n_strings = ETHTOOL_MAX_NTUPLE_LIST_ENTRY *
-	            ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY;
+	sset_info = malloc(sizeof(struct ethtool_sset_info) + sizeof(u32));
+	sset_info->cmd = ETHTOOL_GSSET_INFO;
+	sset_info->sset_mask = ETH_SS_NTUPLE_FILTERS;
+	ifr->ifr_data = (caddr_t)sset_info;
+	err = send_ioctl(fd, ifr);
+
+	if (err < 0) {
+		perror("Cannot get driver strings info");
+		return 100;
+	}
+
+	n_strings = sset_info->data[0];
+	free(sset_info);
 	sz_str = n_strings * ETH_GSTRING_LEN;
 
 	strings = calloc(1, sz_str + sizeof(struct ethtool_gstrings));
@@ -2678,7 +2690,7 @@ static int do_grxntuple(int fd, struct ifreq *ifr)
 	if (err < 0) {
 		perror("Cannot get Rx n-tuple information");
 		free(strings);
-		return 100;
+		return 101;
 	}
 
 	n_strings = strings->len;

