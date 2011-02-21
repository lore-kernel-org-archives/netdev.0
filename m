From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 3/3] ethtool: Report additional offload flag
 changes made automatically
Date: Mon, 21 Feb 2011 16:59:35 +0000
Message-ID: <1298307575.2608.51.camel@bwh-desktop>
References: <1298307282.2608.47.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56923 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756110Ab1BUQ7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 11:59:38 -0500
In-Reply-To: <1298307282.2608.47.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turning off checksum offloads or SG will cause the kernel to turn off
other offloads that depend on them.  On some hardware, other offload
features may have to be turned on or off together.  Therefore, check
the offload flags before and after making changes and report any
additional changes beyond those requested.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |  114 +++++++++++++++++++++++++++++++++++-------------------------
 1 files changed, 66 insertions(+), 48 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 25601a5..4e6bd41 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1890,13 +1890,16 @@ static const struct {
 	{ "receive-hashing",		  0,		   NETIF_F_RXHASH },
 };
 
-static int dump_offload(const struct ethtool_get_features_block *features)
+static int
+dump_offload(const struct ethtool_get_features_block *features, u32 mask)
 {
 	u32 value;
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
 		value = off_feature_def[i].value;
+		if (!(mask & value))
+			continue;
 		printf("%s: %s%s%s\n",
 		       off_feature_def[i].long_name,
 		       (features->active & value) ? "on" : "off",
@@ -2229,7 +2232,8 @@ static const u32 flags_dup_features =
 	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |
 	 ETH_FLAG_RXHASH);
 
-static int do_goffload(int fd, struct ifreq *ifr)
+static int get_offload(int fd, struct ifreq *ifr,
+		       struct ethtool_get_features_block *pfeatures)
 {
 	struct {
 		struct ethtool_gfeatures cmd;
@@ -2240,24 +2244,23 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	u32 value;
 	int i;
 
-	fprintf(stdout, "Offload parameters for %s:\n", devname);
-
 	features.cmd.cmd = ETHTOOL_GFEATURES;
 	features.cmd.size = ARRAY_SIZE(features.data);
 	ifr->ifr_data = (caddr_t)&features;
 	err = ioctl(fd, SIOCETHTOOL, ifr);
 	if (err == 0) {
 		allfail = 0;
+		pfeatures[0] = features.data[0];
 	} else if (errno != EOPNOTSUPP && errno != EPERM) {
 		perror("Cannot get device offload settings");
 	} else {
-		memset(&features.data, 0, sizeof(features.data));
+		memset(pfeatures, 0, sizeof(*pfeatures));
 
 		for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
 			value = off_feature_def[i].value;
 
 			/* Assume that anything we can get is changeable */
-			features.data[0].available |= value;
+			pfeatures[0].available |= value;
 
 			if (!off_feature_def[i].cmd)
 				continue;
@@ -2271,7 +2274,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 					off_feature_def[i].long_name);
 			} else {
 				if (eval.data)
-					features.data[0].active |= value;
+					pfeatures[0].active |= value;
 				allfail = 0;
 			}
 		}
@@ -2282,28 +2285,34 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		if (err) {
 			perror("Cannot get device flags");
 		} else {
-			features.data[0].active |=
+			pfeatures[0].active |=
 				eval.data & flags_dup_features;
 			allfail = 0;
 		}
 
-		features.data[0].requested = features.data[0].active;
+		pfeatures[0].requested = pfeatures[0].active;
 	}
 
-	if (allfail) {
+	return allfail;
+}
+
+static int do_goffload(int fd, struct ifreq *ifr)
+{
+	struct ethtool_get_features_block features;
+
+	fprintf(stdout, "Offload parameters for %s:\n", devname);
+
+	if (get_offload(fd, ifr, &features)) {
 		fprintf(stdout, "no offload info available\n");
 		return 83;
 	}
 
-	return dump_offload(features.data);
+	return dump_offload(&features, ~(u32)0);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
 {
-	struct {
-		struct ethtool_gfeatures cmd;
-		struct ethtool_get_features_block data[1];
-	} get_features;
+	struct ethtool_get_features_block old_features, new_features;
 	struct {
 		struct ethtool_sfeatures cmd;
 		struct ethtool_set_features_block data[1];
@@ -2313,42 +2322,37 @@ static int do_soffload(int fd, struct ifreq *ifr)
 	u32 value;
 	int i;
 
-	get_features.cmd.cmd = ETHTOOL_GFEATURES;
-	get_features.cmd.size = ARRAY_SIZE(get_features.data);
-	ifr->ifr_data = (caddr_t)&get_features;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
-	if (err == 0) {
-		set_features.cmd.cmd = ETHTOOL_SFEATURES;
-		set_features.cmd.size = ARRAY_SIZE(set_features.data);
-		set_features.data[0] = off_features;
+	if (get_offload(fd, ifr, &old_features)) {
+		fprintf(stderr, "no offload info available\n");
+		return 1;
+	}
 
-		for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
-			value = off_feature_def[i].value;
-			if (!(off_features.valid & value))
-				continue;
-			if (!(get_features.data[0].available & value)) {
-				/* None of these features can be changed */
-				fprintf(stderr,
-					"Cannot set device %s settings: "
-					"Operation not supported\n",
-					off_feature_def[i].long_name);
-			} else if (off_features.requested & value) {
-				/* Some of these features can be
-				 * enabled; mask out any that cannot
-				 */
-				set_features.data[0].requested &=
-					~(value &
-					  ~get_features.data[0].available);
-			}
-		}
+	set_features.cmd.cmd = ETHTOOL_SFEATURES;
+	set_features.cmd.size = ARRAY_SIZE(set_features.data);
+	set_features.data[0] = off_features;
 
-		ifr->ifr_data = (caddr_t)&set_features;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err < 0) {
-			perror("Cannot set device offload settings");
-			return 1;
+	for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
+		value = off_feature_def[i].value;
+		if (!(off_features.valid & value))
+			continue;
+		if (!(old_features.available & value)) {
+			/* None of these features can be changed */
+			fprintf(stderr,
+				"Cannot set device %s settings: "
+				"Operation not supported\n",
+				off_feature_def[i].long_name);
+		} else if (off_features.requested & value) {
+			/* Some of these features can be
+			 * enabled; mask out any that cannot
+			 */
+			set_features.data[0].requested &=
+				~(value & ~old_features.available);
 		}
+	}
 
+	ifr->ifr_data = (caddr_t)&set_features;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err >= 0) {
 		changed = !!set_features.data[0].valid;
 
 		if (err & ETHTOOL_F_WISH)
@@ -2367,7 +2371,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 				"warning flags %#x",
 				err & ~ETHTOOL_F_WISH);
 	} else if (errno != EOPNOTSUPP && errno != EPERM) {
-		perror("Cannot get device offload settings");
+		perror("Cannot set device offload settings");
 		return 1;
 	} else {
 		for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
@@ -2415,6 +2419,20 @@ static int do_soffload(int fd, struct ifreq *ifr)
 
 	if (!changed) {
 		fprintf(stdout, "no offload settings changed\n");
+		return 0;
+	}
+
+	/* Were any additional changes made automatically? */
+	if (get_offload(fd, ifr, &new_features)) {
+		fprintf(stderr, "no offload info available\n");
+		return 1;
+	}
+	value = ((old_features.active & ~off_features.valid) |
+		 off_features.requested) ^
+		new_features.active;
+	if (value) {
+		printf("Additional changes:\n");
+		dump_offload(&new_features, value);
 	}
 
 	return 0;
-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

