From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC PATCH ethtool 2/3] ethtool: Report any consequential offload
 feature changes
Date: Mon, 16 May 2011 16:57:45 +0100
Message-ID: <1305561465.2885.16.camel@bwh-desktop>
References: <BANLkTi=Q_RrGgw0H=OeNeJ4JkkCgyYckFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:24188 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756247Ab1EPP5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 11:57:52 -0400
In-Reply-To: <BANLkTi=Q_RrGgw0H=OeNeJ4JkkCgyYckFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an offload feature is enabled or disabled, this can change the
state of other features that depend on it.  Report any such changes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   47 +++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 39 insertions(+), 8 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 419f349..5eeca64 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1807,13 +1807,15 @@ static const struct {
 	{ "receive-hashing",		  0,		   NETIF_F_RXHASH },
 };
 
-static int dump_offload(u32 active)
+static int dump_offload(u32 active, u32 mask)
 {
 	u32 value;
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
 		value = off_feature_def[i].value;
+		if (!(mask & value))
+			continue;
 		printf("%s: %s\n",
 		       off_feature_def[i].long_name,
 		       (active & value) ? "on" : "off");
@@ -2147,14 +2149,14 @@ static const u32 flags_dup_features =
 	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |
 	 ETH_FLAG_RXHASH);
 
-static int do_goffload(int fd, struct ifreq *ifr)
+static int get_offload(int fd, struct ifreq *ifr, u32 *features)
 {
 	struct ethtool_value eval;
 	int err, allfail = 1;
-	u32 features = 0, value;
+	u32 value;
 	int i;
 
-	fprintf(stdout, "Offload parameters for %s:\n", devname);
+	*features = 0; 
 
 	for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
 		value = off_feature_def[i].value;
@@ -2169,7 +2171,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 				off_feature_def[i].long_name);
 		} else {
 			if (eval.data)
-				features |= value;
+				*features |= value;
 			allfail = 0;
 		}
 	}
@@ -2180,24 +2182,39 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	if (err) {
 		perror("Cannot get device flags");
 	} else {
-		features |= eval.data & flags_dup_features;
+		*features |= eval.data & flags_dup_features;
 		allfail = 0;
 	}
 
-	if (allfail) {
+	return allfail;
+}
+
+static int do_goffload(int fd, struct ifreq *ifr)
+{
+	u32 features;
+
+	fprintf(stdout, "Offload parameters for %s:\n", devname);
+
+	if (get_offload(fd, ifr, &features)) {
 		fprintf(stdout, "no offload info available\n");
 		return 83;
 	}
 
-	return dump_offload(features);
+	return dump_offload(features, ~(u32)0);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
 {
+	u32 old_features, new_features, diff;
 	struct ethtool_value eval;
 	int err;
 	int i;
 
+	if (get_offload(fd, ifr, &old_features)) {
+		fprintf(stderr, "no offload info available\n");
+		return 1;
+	}
+
 	for (i = 0; i < ARRAY_SIZE(off_feature_def); i++) {
 		if (!off_feature_def[i].cmd)
 			continue;
@@ -2239,6 +2256,20 @@ static int do_soffload(int fd, struct ifreq *ifr)
 
 	if (off_features_mask == 0) {
 		fprintf(stdout, "no offload settings changed\n");
+		return 0;
+	}
+
+	/* Were any additional changes made automatically? */
+	if (get_offload(fd, ifr, &new_features)) {
+		fprintf(stderr, "no offload info available\n");
+		return 1;
+	}
+	diff = ((old_features & ~off_features_mask) |
+		(off_features_wanted & off_features_mask)) ^
+		new_features;
+	if (diff) {
+		printf("Additional changes:\n");
+		dump_offload(new_features, diff);
 	}
 
 	return 0;
-- 
1.7.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

