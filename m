From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC PATCH ethtool 3/3] ethtool: Use ETHTOOL_{G,S}FEATURES where
 available
Date: Mon, 16 May 2011 16:58:03 +0100
Message-ID: <1305561483.2885.17.camel@bwh-desktop>
References: <BANLkTi=Q_RrGgw0H=OeNeJ4JkkCgyYckFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:24236 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756423Ab1EPP6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 11:58:06 -0400
In-Reply-To: <BANLkTi=Q_RrGgw0H=OeNeJ4JkkCgyYckFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also use the new structures in any case.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |  294 +++++++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 199 insertions(+), 95 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 5eeca64..db1873c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -297,8 +297,7 @@ static void show_usage(void)
 static char *devname = NULL;
 
 static int goffload_changed = 0;
-static u32 off_features_wanted = 0;
-static u32 off_features_mask = 0;
+struct ethtool_set_features_block off_features;
 
 static struct ethtool_pauseparam epause;
 static int gpause_changed = 0;
@@ -439,30 +438,30 @@ static struct cmdline_info cmdline_seeprom[] = {
 };
 
 static struct cmdline_info cmdline_offload[] = {
-	{ "rx", CMDL_FLAG, &off_features_wanted, NULL,
-	  NETIF_F_RXCSUM, &off_features_mask },
-	{ "tx", CMDL_FLAG, &off_features_wanted, NULL,
-	  NETIF_F_ALL_CSUM, &off_features_mask },
-	{ "sg", CMDL_FLAG, &off_features_wanted, NULL,
-	  NETIF_F_SG, &off_features_mask },
-	{ "tso", CMDL_FLAG, &off_features_wanted, NULL,
-	  NETIF_F_ALL_TSO, &off_features_mask },
-	{ "ufo", CMDL_FLAG, &off_features_wanted, NULL,
-	  NETIF_F_UFO, &off_features_mask },
-	{ "gso", CMDL_FLAG, &off_features_wanted, NULL,
-	  NETIF_F_GSO, &off_features_mask },
-	{ "lro", CMDL_FLAG, &off_features_wanted, NULL,
-	  NETIF_F_LRO, &off_features_mask },
-	{ "gro", CMDL_FLAG, &off_features_wanted, NULL,
-	  NETIF_F_GRO, &off_features_mask },
-	{ "rxvlan", CMDL_FLAG, &off_features_wanted, NULL,
-	  NETIF_F_HW_VLAN_TX, &off_features_mask },
-	{ "txvlan", CMDL_FLAG, &off_features_wanted, NULL,
-	  NETIF_F_HW_VLAN_TX, &off_features_mask },
-	{ "ntuple", CMDL_FLAG, &off_features_wanted, NULL,
-	  NETIF_F_NTUPLE, &off_features_mask },
-	{ "rxhash", CMDL_FLAG, &off_features_wanted, NULL,
-	  NETIF_F_RXHASH, &off_features_mask },
+	{ "rx", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_RXCSUM, &off_features.valid },
+	{ "tx", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_ALL_CSUM, &off_features.valid },
+	{ "sg", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_SG, &off_features.valid },
+	{ "tso", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_ALL_TSO, &off_features.valid },
+	{ "ufo", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_UFO, &off_features.valid },
+	{ "gso", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_GSO, &off_features.valid },
+	{ "lro", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_LRO, &off_features.valid },
+	{ "gro", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_GRO, &off_features.valid },
+	{ "rxvlan", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_HW_VLAN_TX, &off_features.valid },
+	{ "txvlan", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_HW_VLAN_TX, &off_features.valid },
+	{ "ntuple", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_NTUPLE, &off_features.valid },
+	{ "rxhash", CMDL_FLAG, &off_features.requested, NULL,
+	  NETIF_F_RXHASH, &off_features.valid },
 };
 
 static struct cmdline_info cmdline_pause[] = {
@@ -1807,7 +1806,8 @@ static const struct {
 	{ "receive-hashing",		  0,		   NETIF_F_RXHASH },
 };
 
-static int dump_offload(u32 active, u32 mask)
+static int
+dump_offload(const struct ethtool_get_features_block *features, u32 mask)
 {
 	u32 value;
 	int i;
@@ -1816,9 +1816,12 @@ static int dump_offload(u32 active, u32 mask)
 		value = off_feature_def[i].value;
 		if (!(mask & value))
 			continue;
-		printf("%s: %s\n",
+		printf("%s: %s%s%s\n",
 		       off_feature_def[i].long_name,
-		       (active & value) ? "on" : "off");
+		       (features->active & value) ? "on" : "off",
+		       (features->requested & ~features->active & value) ?
+		       " [requested on]" : "",
+		       !(features->available & value) ? " [unchangeable]" : "");
 	}
 
 	return 0;
@@ -2149,41 +2152,65 @@ static const u32 flags_dup_features =
 	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |
 	 ETH_FLAG_RXHASH);
 
-static int get_offload(int fd, struct ifreq *ifr, u32 *features)
+static int get_offload(int fd, struct ifreq *ifr,
+		       struct ethtool_get_features_block *pfeatures)
 {
+	struct {
+		struct ethtool_gfeatures cmd;
+		struct ethtool_get_features_block data[1];
+	} features;
 	struct ethtool_value eval;
 	int err, allfail = 1;
 	u32 value;
 	int i;
 
-	*features = 0; 
+	features.cmd.cmd = ETHTOOL_GFEATURES;
+	features.cmd.size = ARRAY_SIZE(features.data);
+	ifr->ifr_data = (caddr_t)&features;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err == 0) {
+		allfail = 0;
+		pfeatures[0] = features.data[0];
+	} else if (errno != EOPNOTSUPP && errno != EPERM) {
+		perror("Cannot get device offload settings");
+	} else {
+		memset(pfeatures, 0, sizeof(*pfeatures));
 
-	for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
-		value = off_feature_def[i].value;
-		if (!off_feature_def[i].cmd)
-			continue;
-		eval.cmd = off_feature_def[i].cmd;
+		for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
+			value = off_feature_def[i].value;
+
+			/* Assume that anything we can get is changeable */
+			pfeatures[0].available |= value;
+
+			if (!off_feature_def[i].cmd)
+				continue;
+
+			eval.cmd = off_feature_def[i].cmd;
+			ifr->ifr_data = (caddr_t)&eval;
+			err = send_ioctl(fd, ifr);
+			if (err) {
+				fprintf(stderr,
+					"Cannot get device %s settings: %m\n",
+					off_feature_def[i].long_name);
+			} else {
+				if (eval.data)
+					pfeatures[0].active |= value;
+				allfail = 0;
+			}
+		}
+
+		eval.cmd = ETHTOOL_GFLAGS;
 		ifr->ifr_data = (caddr_t)&eval;
-		err = send_ioctl(fd, ifr);
+		err = ioctl(fd, SIOCETHTOOL, ifr);
 		if (err) {
-			fprintf(stderr,
-				"Cannot get device %s settings: %m\n",
-				off_feature_def[i].long_name);
+			perror("Cannot get device flags");
 		} else {
-			if (eval.data)
-				*features |= value;
+			pfeatures[0].active |=
+				eval.data & flags_dup_features;
 			allfail = 0;
 		}
-	}
 
-	eval.cmd = ETHTOOL_GFLAGS;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
-	if (err) {
-		perror("Cannot get device flags");
-	} else {
-		*features |= eval.data & flags_dup_features;
-		allfail = 0;
+		pfeatures[0].requested = pfeatures[0].active;
 	}
 
 	return allfail;
@@ -2191,7 +2218,7 @@ static int get_offload(int fd, struct ifreq *ifr, u32 *features)
 
 static int do_goffload(int fd, struct ifreq *ifr)
 {
-	u32 features;
+	struct ethtool_get_features_block features;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
@@ -2200,79 +2227,156 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		return 83;
 	}
 
-	return dump_offload(features, ~(u32)0);
+	return dump_offload(&features, ~(u32)0);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
 {
-	u32 old_features, new_features, diff;
-	struct ethtool_value eval;
+	struct ethtool_get_features_block old_features, new_features;
+	struct {
+		struct ethtool_sfeatures cmd;
+		struct ethtool_set_features_block data[1];
+	} set_features;
+	int failed;
+	u32 diff;
 	int err;
 	int i;
 
+	if (off_features.valid == 0) {
+		fprintf(stdout, "no offload settings changed\n");
+		return 0;
+	}
+
 	if (get_offload(fd, ifr, &old_features)) {
 		fprintf(stderr, "no offload info available\n");
 		return 1;
 	}
 
+	set_features.cmd.cmd = ETHTOOL_SFEATURES;
+	set_features.cmd.size = ARRAY_SIZE(set_features.data);
+	set_features.data[0] = off_features;
+
 	for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
-		if (!off_feature_def[i].cmd)
+		u32 value = off_feature_def[i].value;
+
+		if (!(off_features.valid & value))
 			continue;
-		if (off_features_mask & off_feature_def[i].value) {
-			eval.cmd = off_feature_def[i].cmd + 1;
-			eval.data = !!(off_features_wanted &
-				       off_feature_def[i].value);
-			ifr->ifr_data = (caddr_t)&eval;
-			err = send_ioctl(fd, ifr);
-			if (err) {
-				fprintf(stderr,
-					"Cannot set device %s settings: %m\n",
-					off_feature_def[i].long_name);
-				return 1;
-			}
+		if (!(old_features.available & value)) {
+			/* None of these features can be changed */
+			fprintf(stderr,
+				"Cannot set device %s settings: "
+				"Operation not supported\n",
+				off_feature_def[i].long_name);
+			return 1;
 		}
+		/* At least some of these features can be
+		 * enabled; mask out any that cannot
+		 */
+		set_features.data[0].valid &=
+			~(value & ~old_features.available);
 	}
-	if (off_features_mask & flags_dup_features) {
-		eval.cmd = ETHTOOL_GFLAGS;
-		eval.data = 0;
-		ifr->ifr_data = (caddr_t)&eval;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot get device flag settings");
-			return 91;
+
+	ifr->ifr_data = (caddr_t)&set_features;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err >= 0) {
+		/* We'll break down the warnings/errors below */
+	} else if (errno != EOPNOTSUPP && errno != EPERM) {
+		perror("Cannot set device offload settings");
+		return 1;
+	} else {
+		struct ethtool_value eval;
+
+		for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
+			if (!off_feature_def[i].cmd)
+				continue;
+			if (off_features.valid & off_feature_def[i].value) {
+				eval.cmd = off_feature_def[i].cmd + 1;
+				eval.data = !!(off_features.requested &
+					       off_feature_def[i].value);
+				ifr->ifr_data = (caddr_t)&eval;
+				err = send_ioctl(fd, ifr);
+				if (err) {
+					fprintf(stderr,
+						"Cannot set device %s settings: %m\n",
+						off_feature_def[i].long_name);
+					return 1;
+				}
+			}
 		}
+		if (off_features.valid & flags_dup_features) {
+			eval.cmd = ETHTOOL_GFLAGS;
+			eval.data = 0;
+			ifr->ifr_data = (caddr_t)&eval;
+			err = ioctl(fd, SIOCETHTOOL, ifr);
+			if (err) {
+				perror("Cannot get device flag settings");
+				return 91;
+			}
 
-		eval.cmd = ETHTOOL_SFLAGS;
-		eval.data &= ~(off_features_mask & flags_dup_features);
-		eval.data |= (off_features_wanted &
-			      flags_dup_features);
+			eval.cmd = ETHTOOL_SFLAGS;
+			eval.data &= ~(off_features.valid & flags_dup_features);
+			eval.data |= (off_features.requested &
+				      flags_dup_features);
 
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot set device flag settings");
-			return 92;
+			err = ioctl(fd, SIOCETHTOOL, ifr);
+			if (err) {
+				perror("Cannot set device flag settings");
+				return 92;
+			}
 		}
 	}
 
-	if (off_features_mask == 0) {
-		fprintf(stdout, "no offload settings changed\n");
-		return 0;
-	}
-
-	/* Were any additional changes made automatically? */
 	if (get_offload(fd, ifr, &new_features)) {
 		fprintf(stderr, "no offload info available\n");
 		return 1;
 	}
-	diff = ((old_features & ~off_features_mask) |
-		(off_features_wanted & off_features_mask)) ^
-		new_features;
+
+	failed = 0;
+
+	/* Report specific failures */
+	for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
+		if (!(off_feature_def[i].value & off_features.valid))
+			continue;
+
+		/* For offloads where we have one name for multiple
+		 * feature flags, squash them into a boolean.
+		 */
+		if (!(off_features.requested & off_feature_def[i].value) != 
+		    !(new_features.active & off_feature_def[i].value)) {
+			int did1 = 0;
+
+			fprintf(stderr,
+				"Cannot set device %s settings",
+				off_feature_def[i].long_name);
+			if (err & ETHTOOL_F_WISH) {
+				fprintf(stderr,
+					": Feature depends on other settings");
+				did1++;
+			}
+			/* Report any remaining warning flags (including
+			 * ETHTOOL_F_UNSUPPORTED, which should not be set
+			 * since we checked for unsupported flags above).
+			 */
+			if (err & ~ETHTOOL_F_WISH) {
+				fprintf(stderr, "%s Warning flags %#x",
+					did1 ? ";" : ":",
+					err & ~ETHTOOL_F_WISH);
+			}
+			fprintf(stderr, "\n");
+
+			failed = 1;
+		}
+	}
+
+	/* Were any additional changes made automatically? */
+	diff = (new_features.active ^ old_features.active) &
+		    ~off_features.valid;
 	if (diff) {
 		printf("Additional changes:\n");
-		dump_offload(new_features, diff);
+		dump_offload(&new_features, diff);
 	}
 
-	return 0;
+	return failed;
 }
 
 static int do_gset(int fd, struct ifreq *ifr)
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

