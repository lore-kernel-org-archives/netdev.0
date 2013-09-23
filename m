From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/2] Hide state of VLAN tag offload and LRO if the
 kernel is too old
Date: Tue, 24 Sep 2013 00:26:31 +0100
Message-ID: <1379978791.2485.87.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63828 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942Ab3IWX0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 19:26:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Starting with Linux 2.6.37 and ethtool 2.6.36 it was possible to show
the state of VLAN tag offload (using ETHTOOL_GFLAGS).  But the state
would always be shown as 'off' for older kernel versions, even though
VLAN tag offload had been implemented long before this.

In ethtool 3.4.2 I attempted to fix this by also reading the state of
VLAN tag offload from the 'features' attribute in sysfs.  But this had
to be reverted because it causes 'ethtool -K' to pass the flags back
into ETHTOOL_SFLAGS.

Instead, hide the VLAN tag offload flags if the kernel is older than
2.6.37.

Similarly, LRO was implemented some time before it was exposed through
ETHTOOL_GFLAGS in Linux 2.6.24.  So hide the LRO flag if the kernel
is older than that.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c | 58 ++++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 46 insertions(+), 12 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 2dc07d3..b06dfa3 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -113,6 +113,8 @@ enum {
 };
 #endif
 
+#define KERNEL_VERSION(a,b,c) (((a) << 16) + ((b) << 8) + (c))
+
 static void exit_bad_args(void) __attribute__((noreturn));
 
 static void exit_bad_args(void)
@@ -183,32 +185,43 @@ struct off_flag_def {
 	const char *kernel_name;
 	u32 get_cmd, set_cmd;
 	u32 value;
+	/* For features exposed through ETHTOOL_GFLAGS, the oldest
+	 * kernel version for which we can trust the result.  Where
+	 * the flag was added at the same time the kernel started
+	 * supporting the feature, this is 0 (to allow for backports).
+	 * Where the feature was supported before the flag was added,
+	 * it is the version that introduced the flag.
+	 */
+	u32 min_kernel_ver;
 };
 static const struct off_flag_def off_flag_def[] = {
 	{ "rx",     "rx-checksumming",		    "rx-checksum",
-	  ETHTOOL_GRXCSUM, ETHTOOL_SRXCSUM, ETH_FLAG_RXCSUM },
+	  ETHTOOL_GRXCSUM, ETHTOOL_SRXCSUM, ETH_FLAG_RXCSUM,	0 },
 	{ "tx",     "tx-checksumming",		    "tx-checksum-*",
-	  ETHTOOL_GTXCSUM, ETHTOOL_STXCSUM, ETH_FLAG_TXCSUM },
+	  ETHTOOL_GTXCSUM, ETHTOOL_STXCSUM, ETH_FLAG_TXCSUM,	0 },
 	{ "sg",     "scatter-gather",		    "tx-scatter-gather*",
-	  ETHTOOL_GSG,	   ETHTOOL_SSG,     ETH_FLAG_SG },
+	  ETHTOOL_GSG,	   ETHTOOL_SSG,     ETH_FLAG_SG,	0 },
 	{ "tso",    "tcp-segmentation-offload",	    "tx-tcp*-segmentation",
-	  ETHTOOL_GTSO,	   ETHTOOL_STSO,    ETH_FLAG_TSO },
+	  ETHTOOL_GTSO,	   ETHTOOL_STSO,    ETH_FLAG_TSO,	0 },
 	{ "ufo",    "udp-fragmentation-offload",    "tx-udp-fragmentation",
-	  ETHTOOL_GUFO,	   ETHTOOL_SUFO,    ETH_FLAG_UFO },
+	  ETHTOOL_GUFO,	   ETHTOOL_SUFO,    ETH_FLAG_UFO,	0 },
 	{ "gso",    "generic-segmentation-offload", "tx-generic-segmentation",
-	  ETHTOOL_GGSO,	   ETHTOOL_SGSO,    ETH_FLAG_GSO },
+	  ETHTOOL_GGSO,	   ETHTOOL_SGSO,    ETH_FLAG_GSO,	0 },
 	{ "gro",    "generic-receive-offload",	    "rx-gro",
-	  ETHTOOL_GGRO,	   ETHTOOL_SGRO,    ETH_FLAG_GRO },
+	  ETHTOOL_GGRO,	   ETHTOOL_SGRO,    ETH_FLAG_GRO,	0 },
 	{ "lro",    "large-receive-offload",	    "rx-lro",
-	  0,		   0,		    ETH_FLAG_LRO },
+	  0,		   0,		    ETH_FLAG_LRO,
+	  KERNEL_VERSION(2,6,24) },
 	{ "rxvlan", "rx-vlan-offload",		    "rx-vlan-hw-parse",
-	  0,		   0,		    ETH_FLAG_RXVLAN },
+	  0,		   0,		    ETH_FLAG_RXVLAN,
+	  KERNEL_VERSION(2,6,37) },
 	{ "txvlan", "tx-vlan-offload",		    "tx-vlan-hw-insert",
-	  0,		   0,		    ETH_FLAG_TXVLAN },
+	  0,		   0,		    ETH_FLAG_TXVLAN,
+	  KERNEL_VERSION(2,6,37) },
 	{ "ntuple", "ntuple-filters",		    "rx-ntuple-filter",
-	  0,		   0,		    ETH_FLAG_NTUPLE },
+	  0,		   0,		    ETH_FLAG_NTUPLE,	0 },
 	{ "rxhash", "receive-hashing",		    "rx-hashing",
-	  0,		   0,		    ETH_FLAG_RXHASH },
+	  0,		   0,		    ETH_FLAG_RXHASH,	0 },
 };
 
 struct feature_def {
@@ -1179,15 +1192,36 @@ static void dump_one_feature(const char *indent, const char *name,
 	       : "");
 }
 
+static int linux_version_code(void)
+{
+	struct utsname utsname;
+	unsigned version, patchlevel, sublevel = 0;
+
+	if (uname(&utsname))
+		return -1;
+	if (sscanf(utsname.release, "%u.%u.%u", &version, &patchlevel, &sublevel) < 2)
+		return -1;
+	return KERNEL_VERSION(version, patchlevel, sublevel);
+}
+
 static void dump_features(const struct feature_defs *defs,
 			  const struct feature_state *state,
 			  const struct feature_state *ref_state)
 {
+	int kernel_ver = linux_version_code();
 	u32 value;
 	int indent;
 	int i, j;
 
 	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
+		/* Don't show features whose state is unknown on this
+		 * kernel version
+		 */
+		if (defs->off_flag_matched[i] == 0 &&
+		    off_flag_def[i].get_cmd == 0 &&
+		    kernel_ver < off_flag_def[i].min_kernel_ver)
+			continue;
+
 		value = off_flag_def[i].value;
 
 		/* If this offload flag matches exactly one generic
-- 
1.8.1.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
