From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 08/11] devlink: allow to parse both devlink and port handle in the same time
Date: Fri, 15 Apr 2016 09:51:50 +0200
Message-ID: <1460706713-5942-9-git-send-email-jiri@resnulli.us>
References: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37957 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620AbcDOHwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 03:52:06 -0400
Received: by mail-wm0-f50.google.com with SMTP id u206so20030693wme.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 00:52:05 -0700 (PDT)
In-Reply-To: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

For filtering purposes, it makes sense for used to either specify
devlink handle of port handle.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 109 ++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 90 insertions(+), 19 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index d436bbf..e2e0413 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -363,6 +363,12 @@ static int strtouint32_t(const char *str, uint32_t *p_val)
 	return 0;
 }
 
+static int __dl_argv_handle(char *str, char **p_bus_name, char **p_dev_name)
+{
+	strslashrsplit(str, p_bus_name, p_dev_name);
+	return 0;
+}
+
 static int dl_argv_handle(struct dl *dl, char **p_bus_name, char **p_dev_name)
 {
 	char *str = dl_argv_next(dl);
@@ -376,8 +382,40 @@ static int dl_argv_handle(struct dl *dl, char **p_bus_name, char **p_dev_name)
 		pr_err("Expected \"bus_name/dev_name\".\n");
 		return -EINVAL;
 	}
+	return __dl_argv_handle(str, p_bus_name, p_dev_name);
+}
 
-	strslashrsplit(str, p_bus_name, p_dev_name);
+static int __dl_argv_handle_port(char *str,
+				 char **p_bus_name, char **p_dev_name,
+				 uint32_t *p_port_index)
+{
+	char *handlestr = handlestr;
+	char *portstr = portstr;
+	int err;
+
+	strslashrsplit(str, &handlestr, &portstr);
+	err = strtouint32_t(portstr, p_port_index);
+	if (err) {
+		pr_err("Port index \"%s\" is not a number or not within range\n",
+		       portstr);
+		return err;
+	}
+	strslashrsplit(handlestr, p_bus_name, p_dev_name);
+	return 0;
+}
+
+static int __dl_argv_handle_port_ifname(struct dl *dl, char *str,
+					char **p_bus_name, char **p_dev_name,
+					uint32_t *p_port_index)
+{
+	int err;
+
+	err = ifname_map_lookup(dl, str, p_bus_name, p_dev_name,
+				p_port_index);
+	if (err) {
+		pr_err("Netdevice \"%s\" not found\n", str);
+		return err;
+	}
 	return 0;
 }
 
@@ -386,7 +424,6 @@ static int dl_argv_handle_port(struct dl *dl, char **p_bus_name,
 {
 	char *str = dl_argv_next(dl);
 	unsigned int slash_count;
-	int err;
 
 	if (!str) {
 		pr_err("Port identification (\"bus_name/dev_name/port_index\" or \"netdev ifname\") expected.\n");
@@ -398,26 +435,52 @@ static int dl_argv_handle_port(struct dl *dl, char **p_bus_name,
 		pr_err("Expected \"bus_name/dev_name/port_index\" or \"netdev_ifname\".\n");
 		return -EINVAL;
 	}
-
 	if (slash_count == 2) {
-		char *handlestr = handlestr;
-		char *portstr = portstr;
-
-		err = strslashrsplit(str, &handlestr, &portstr);
-		err = strtouint32_t(portstr, p_port_index);
-		if (err) {
-			pr_err("Port index \"%s\" is not a number or not within range\n",
-			       portstr);
+		return __dl_argv_handle_port(str, p_bus_name,
+					     p_dev_name, p_port_index);
+	} else if (slash_count == 0) {
+		return __dl_argv_handle_port_ifname(dl, str, p_bus_name,
+						    p_dev_name, p_port_index);
+	}
+	return 0;
+}
+
+static int dl_argv_handle_both(struct dl *dl, char **p_bus_name,
+			       char **p_dev_name, uint32_t *p_port_index,
+			       uint32_t *p_handle_bit)
+{
+	char *str = dl_argv_next(dl);
+	unsigned int slash_count;
+	int err;
+
+	if (!str) {
+		pr_err("One of following identifications expected:\n"
+		       "Devlink identification (\"bus_name/dev_name\")\n"
+		       "Port identification (\"bus_name/dev_name/port_index\" or \"netdev ifname\")\n");
+		return -EINVAL;
+	}
+	slash_count = strslashcount(str);
+	if (slash_count == 1) {
+		err = __dl_argv_handle(str, p_bus_name, p_dev_name);
+		if (err)
 			return err;
-		}
-		strslashrsplit(handlestr, p_bus_name, p_dev_name);
+		*p_handle_bit = DL_OPT_HANDLE;
+	} else if (slash_count == 2) {
+		err = __dl_argv_handle_port(str, p_bus_name,
+					    p_dev_name, p_port_index);
+		if (err)
+			return err;
+		*p_handle_bit = DL_OPT_HANDLEP;
 	} else if (slash_count == 0) {
-		err = ifname_map_lookup(dl, str, p_bus_name, p_dev_name,
-					p_port_index);
-		if (err) {
-			pr_err("Netdevice \"%s\" not found\n", str);
+		err = __dl_argv_handle_port_ifname(dl, str, p_bus_name,
+						   p_dev_name, p_port_index);
+		if (err)
 			return err;
-		}
+		*p_handle_bit = DL_OPT_HANDLEP;
+	} else {
+		pr_err("Wrong port identification string format.\n");
+		pr_err("Expected \"bus_name/dev_name\" or \"bus_name/dev_name/port_index\" or \"netdev_ifname\".\n");
+		return -EINVAL;
 	}
 	return 0;
 }
@@ -475,7 +538,15 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 	uint32_t o_found = 0;
 	int err;
 
-	if (o_required & DL_OPT_HANDLE) {
+	if (o_required & DL_OPT_HANDLE && o_required & DL_OPT_HANDLEP) {
+		uint32_t handle_bit = handle_bit;
+
+		err = dl_argv_handle_both(dl, &opts->bus_name, &opts->dev_name,
+					  &opts->port_index, &handle_bit);
+		if (err)
+			return err;
+		o_found |= handle_bit;
+	} else if (o_required & DL_OPT_HANDLE) {
 		err = dl_argv_handle(dl, &opts->bus_name, &opts->dev_name);
 		if (err)
 			return err;
-- 
2.5.5
