From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/2] Fix reporting of VLAN tag offload flags for
 Linux 2.6.24-2.6.36
Date: Mon, 16 Jul 2012 23:20:20 +0100
Message-ID: <1342477220.2523.43.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342477041.2523.40.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52447 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752540Ab2GPWUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 18:20:23 -0400
In-Reply-To: <1342477041.2523.40.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These kernel versions implement ETHTOOL_GFLAGS but do not include the
flags for VLAN tag offload (and do not implement ETHTOOL_GFEATURES).
Since the VLAN tag offload features were already defined and
implemented by many drivers, we shouldn't assume they are off.
Instead, since these feature flag values were stable, read them from
sysfs.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index b424756..9991ce2 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -33,6 +33,8 @@
 #include <sys/utsname.h>
 #include <limits.h>
 #include <ctype.h>
+#include <assert.h>
+#include <sys/fcntl.h>
 
 #include <sys/socket.h>
 #include <netinet/in.h>
@@ -1417,6 +1419,31 @@ static struct feature_defs *get_feature_defs(struct cmd_context *ctx)
 	return defs;
 }
 
+static int get_netdev_attr(struct cmd_context *ctx, const char *name,
+		    char *buf, size_t buf_len)
+{
+#ifdef TEST_ETHTOOL
+	errno = ENOENT;
+	return -1;
+#else
+	char path[40 + IFNAMSIZ];
+	ssize_t len;
+	int fd;
+
+	len = snprintf(path, sizeof(path), "/sys/class/net/%s/%s",
+		       ctx->devname, name);
+	assert(len < sizeof(path));
+	fd = open(path, O_RDONLY);
+	if (fd < 0)
+		return fd;
+	len = read(fd, buf, buf_len - 1);
+	if (len >= 0)
+		buf[len] = 0;
+	close(fd);
+	return len;
+#endif
+}
+
 static int do_gdrv(struct cmd_context *ctx)
 {
 	int err;
@@ -1858,6 +1885,20 @@ get_features(struct cmd_context *ctx, const struct feature_defs *defs)
 			perror("Cannot get device generic features");
 		else
 			allfail = 0;
+	} else {
+		/* We should have got VLAN tag offload flags through
+		 * ETHTOOL_GFLAGS.  However, prior to Linux 2.6.37
+		 * they were not exposed in this way - and since VLAN
+		 * tag offload was defined and implemented by many
+		 * drivers, we shouldn't assume they are off.
+		 * Instead, since these feature flag values were
+		 * stable, read them from sysfs.
+		 */
+		char buf[20];
+		if (get_netdev_attr(ctx, "features", buf, sizeof(buf)) > 0)
+			state->off_flags |=
+				strtoul(buf, NULL, 0) &
+				(ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN);
 	}
 
 	if (allfail) {
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
