From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ip netns: Make sure netns name is sane
Date: Mon, 10 Jul 2017 13:19:12 +0200
Message-ID: <20170710111912.22537-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41931 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753620AbdGJLTU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Jul 2017 07:19:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to keep track of created netns, 'ip netns' creates a mount
point inside NETNS_RUN_DIR. By not checking the user-specified name, it
allowed to create that mount point outside of NETNS_RUN_DIR and hence
lose track of it afterwards:

| # ip netns add ../../tmp/foobar
| # ip netns list
| # mount | grep foobar
| nsfs on /tmp/foobar type nsfs (rw)

Prevent this by making sure basename() does not see a need to alter the
given netns name.

Fixes: 0dc34c7713bb7 ("iproute2: Add processless network namespace support")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipnetns.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 0b0378ab6560c..4eee85e146b3d 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -595,6 +595,21 @@ static int create_netns_dir(void)
 	return 0;
 }
 
+static bool is_basename(const char *name)
+{
+	char *name_dup = strdup(name);
+	bool rc = true;
+
+	if (!name_dup)
+		return false;
+
+	if (strcmp(basename(name_dup), name))
+		rc = false;
+
+	free(name_dup);
+	return rc;
+}
+
 static int netns_add(int argc, char **argv)
 {
 	/* This function creates a new network namespace and
@@ -616,6 +631,11 @@ static int netns_add(int argc, char **argv)
 	}
 	name = argv[0];
 
+	if (!is_basename(name)) {
+		fprintf(stderr, "Invalid netns name: contains path components\n");
+		return -1;
+	}
+
 	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, name);
 
 	if (create_netns_dir())
-- 
2.13.1
