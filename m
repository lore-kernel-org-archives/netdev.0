From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 3/3] devlink: Check return code of strslashrsplit()
Date: Mon, 21 Aug 2017 18:36:52 +0200
Message-ID: <20170821163652.23752-4-phil@nwl.cc>
References: <20170821163652.23752-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38069 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753726AbdHUQhE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 12:37:04 -0400
In-Reply-To: <20170821163652.23752-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function shouldn't fail because all callers of
__dl_argv_handle_port() make sure the passed string contains enough
slashes already, but better make sure if this changes in future the
function won't access uninitialized data.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 devlink/devlink.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index f9bc16c350c40..de41a9f4aae10 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -526,18 +526,26 @@ static int __dl_argv_handle_port(char *str,
 				 char **p_bus_name, char **p_dev_name,
 				 uint32_t *p_port_index)
 {
-	char *handlestr = handlestr;
-	char *portstr = portstr;
+	char *handlestr;
+	char *portstr;
 	int err;
 
-	strslashrsplit(str, &handlestr, &portstr);
+	err = strslashrsplit(str, &handlestr, &portstr);
+	if (err) {
+		pr_err("Port identification \"%s\" is invalid\n", str);
+		return err;
+	}
 	err = strtouint32_t(portstr, p_port_index);
 	if (err) {
 		pr_err("Port index \"%s\" is not a number or not within range\n",
 		       portstr);
 		return err;
 	}
-	strslashrsplit(handlestr, p_bus_name, p_dev_name);
+	err = strslashrsplit(handlestr, p_bus_name, p_dev_name);
+	if (err) {
+		pr_err("Port identification \"%s\" is invalid\n", str);
+		return err;
+	}
 	return 0;
 }
 
-- 
2.13.1
