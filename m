From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool PATCH 1/2] ethtool: Correctly pull n-tuple string length for
	get_rx_ntuple
Date: Fri, 26 Feb 2010 03:55:45 -0800
Message-ID: <20100226115544.20259.36760.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:35899
	"EHLO qmta03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935516Ab0BZL4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 06:56:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch fixes inconsistencies with the kernel header files, while
correctly gets the variable length string counts for the get_rx_ntuple
return value.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 ethtool-copy.h |    3 +--
 ethtool.c      |   13 +++++++++++--
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 8681f5e..7d4e80a 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -63,6 +63,7 @@ struct ethtool_drvinfo {
 	char	reserved2[12];
 	__u32	n_priv_flags;	/* number of flags valid in ETHTOOL_GPFLAGS */
 	__u32	n_stats;	/* number of u64's from ETHTOOL_GSTATS */
+	__u32	n_ntuples;	/* number of n-tuple filters from GSTRINGS */
 	__u32	testinfo_len;
 	__u32	eedump_len;	/* Size of data from ETHTOOL_GEEPROM (bytes) */
 	__u32	regdump_len;	/* Size of data from ETHTOOL_GREGS (bytes) */
@@ -389,8 +390,6 @@ struct ethtool_rx_ntuple_flow_spec {
 #define ETHTOOL_RXNTUPLE_ACTION_DROP -1
 };
 
-#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
-#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
 struct ethtool_rx_ntuple {
 	__u32					cmd;
 	struct ethtool_rx_ntuple_flow_spec	fs;
diff --git a/ethtool.c b/ethtool.c
index fc9e419..4f39263 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2657,11 +2657,20 @@ static int do_srxntuple(int fd, struct ifreq *ifr)
 
 static int do_grxntuple(int fd, struct ifreq *ifr)
 {
+	struct ethtool_drvinfo drvinfo;
 	struct ethtool_gstrings *strings;
 	int sz_str, n_strings, err, i;
 
-	n_strings = ETHTOOL_MAX_NTUPLE_LIST_ENTRY *
-	            ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY;
+	drvinfo.cmd = ETHTOOL_GDRVINFO;
+	ifr->ifr_data = (caddr_t)&drvinfo;
+	err = send_ioctl(fd, ifr);
+
+	if (err < 0) {
+		perror("Cannot get driver information");
+		return 71;
+	}
+
+	n_strings = drvinfo.n_ntuples;
 	sz_str = n_strings * ETH_GSTRING_LEN;
 
 	strings = calloc(1, sz_str + sizeof(struct ethtool_gstrings));

