From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 2/4] Remove strings based approach for displaying
	ntuple
Date: Fri, 25 Feb 2011 15:48:50 -0800
Message-ID: <20110225234850.8409.66534.stgit@gitlad.jf.intel.com>
References: <20110225233902.8409.74474.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32829 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756303Ab1BYXsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:48:51 -0500
In-Reply-To: <20110225233902.8409.74474.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to remove the strings based approach for displaying
ntuple filters.  A follow-on patch will replace that functionality with a
network flow classification based approach that will get the number of
filters, get their locations, and then request and display them
individually.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool-copy.h |    3 +--
 ethtool.c      |   44 --------------------------------------------
 2 files changed, 1 insertions(+), 46 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 75c3ae7..dd1080b 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -250,7 +250,6 @@ enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
 	ETH_SS_STATS,
 	ETH_SS_PRIV_FLAGS,
-	ETH_SS_NTUPLE_FILTERS,
 };
 
 /* for passing string sets for data tagging */
@@ -580,7 +579,7 @@ struct ethtool_flash {
 #define ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 #define ETHTOOL_RESET		0x00000034 /* Reset hardware */
 #define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
-#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+/* ETHTOOL_GRXNTUPLE		0x00000036 disabled due to multiple issues */
 #define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
 #define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table */
 #define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table */
diff --git a/ethtool.c b/ethtool.c
index 14740d5..2a084db 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3162,50 +3162,6 @@ static int do_srxntuple(int fd, struct ifreq *ifr)
 
 static int do_grxntuple(int fd, struct ifreq *ifr)
 {
-	struct ethtool_sset_info *sset_info;
-	struct ethtool_gstrings *strings;
-	int sz_str, n_strings, err, i;
-
-	sset_info = malloc(sizeof(struct ethtool_sset_info) + sizeof(u32));
-	sset_info->cmd = ETHTOOL_GSSET_INFO;
-	sset_info->sset_mask = (1ULL << ETH_SS_NTUPLE_FILTERS);
-	ifr->ifr_data = (caddr_t)sset_info;
-	err = send_ioctl(fd, ifr);
-
-	if ((err < 0) ||
-	    (!(sset_info->sset_mask & (1ULL << ETH_SS_NTUPLE_FILTERS)))) {
-		perror("Cannot get driver strings info");
-		return 100;
-	}
-
-	n_strings = sset_info->data[0];
-	free(sset_info);
-	sz_str = n_strings * ETH_GSTRING_LEN;
-
-	strings = calloc(1, sz_str + sizeof(struct ethtool_gstrings));
-	if (!strings) {
-		fprintf(stderr, "no memory available\n");
-		return 95;
-	}
-
-	strings->cmd = ETHTOOL_GRXNTUPLE;
-	strings->string_set = ETH_SS_NTUPLE_FILTERS;
-	strings->len = n_strings;
-	ifr->ifr_data = (caddr_t) strings;
-	err = send_ioctl(fd, ifr);
-	if (err < 0) {
-		perror("Cannot get Rx n-tuple information");
-		free(strings);
-		return 101;
-	}
-
-	n_strings = strings->len;
-	fprintf(stdout, "Rx n-tuple filters:\n");
-	for (i = 0; i < n_strings; i++)
-		fprintf(stdout, "%s", &strings->data[i * ETH_GSTRING_LEN]);
-
-	free(strings);
-
 	return 0;
 }
 

