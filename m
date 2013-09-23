From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/2] Revert "Fix reporting of VLAN tag offload flags
 on Linux < 2.6.37"
Date: Tue, 24 Sep 2013 00:24:58 +0100
Message-ID: <1379978698.2485.85.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63800 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007Ab3IWXZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 19:25:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 1cddbe64cfc66b58988c85086d6df3a77c0c61a5.
It causes 'ethtool -K' to pass the VLAN tag offload flags to
ETHTOOL_SFLAGS when they are not supported and will be rejected.
---
 ethtool.c | 41 -----------------------------------------
 1 file changed, 41 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index dcdc0a9..2dc07d3 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -35,8 +35,6 @@
 #include <sys/utsname.h>
 #include <limits.h>
 #include <ctype.h>
-#include <assert.h>
-#include <sys/fcntl.h>
 
 #include <sys/socket.h>
 #include <netinet/in.h>
@@ -1506,31 +1504,6 @@ static struct feature_defs *get_feature_defs(struct cmd_context *ctx)
 	return defs;
 }
 
-static int get_netdev_attr(struct cmd_context *ctx, const char *name,
-		    char *buf, size_t buf_len)
-{
-#ifdef TEST_ETHTOOL
-	errno = ENOENT;
-	return -1;
-#else
-	char path[40 + IFNAMSIZ];
-	ssize_t len;
-	int fd;
-
-	len = snprintf(path, sizeof(path), "/sys/class/net/%s/%s",
-		       ctx->devname, name);
-	assert(len < sizeof(path));
-	fd = open(path, O_RDONLY);
-	if (fd < 0)
-		return fd;
-	len = read(fd, buf, buf_len - 1);
-	if (len >= 0)
-		buf[len] = 0;
-	close(fd);
-	return len;
-#endif
-}
-
 static int do_gdrv(struct cmd_context *ctx)
 {
 	int err;
@@ -1972,20 +1945,6 @@ get_features(struct cmd_context *ctx, const struct feature_defs *defs)
 			perror("Cannot get device generic features");
 		else
 			allfail = 0;
-	} else {
-		/* We should have got VLAN tag offload flags through
-		 * ETHTOOL_GFLAGS.  However, prior to Linux 2.6.37
-		 * they were not exposed in this way - and since VLAN
-		 * tag offload was defined and implemented by many
-		 * drivers, we shouldn't assume they are off.
-		 * Instead, since these feature flag values were
-		 * stable, read them from sysfs.
-		 */
-		char buf[20];
-		if (get_netdev_attr(ctx, "features", buf, sizeof(buf)) > 0)
-			state->off_flags |=
-				strtoul(buf, NULL, 0) &
-				(ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN);
 	}
 
 	if (allfail) {
-- 
1.8.1.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
