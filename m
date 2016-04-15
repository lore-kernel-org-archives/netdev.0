From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 07/11] devlink: introduce dump filtering function
Date: Fri, 15 Apr 2016 09:51:49 +0200
Message-ID: <1460706713-5942-8-git-send-email-jiri@resnulli.us>
References: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35940 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407AbcDOHwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 03:52:05 -0400
Received: by mail-wm0-f48.google.com with SMTP id v188so19290614wme.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 00:52:04 -0700 (PDT)
In-Reply-To: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This function is to be used from dump callbacks to decide if the output
currect output should be filtered off or not. Filtering is based on
previously parsed and stored command line options.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index 0c2132f..d436bbf 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -563,6 +563,36 @@ static int dl_argv_parse_put(struct nlmsghdr *nlh, struct dl *dl,
 	return 0;
 }
 
+static bool dl_dump_filter(struct dl *dl, struct nlattr **tb)
+{
+	struct dl_opts *opts = &dl->opts;
+	struct nlattr *attr_bus_name = tb[DEVLINK_ATTR_BUS_NAME];
+	struct nlattr *attr_dev_name = tb[DEVLINK_ATTR_DEV_NAME];
+	struct nlattr *attr_port_index = tb[DEVLINK_ATTR_PORT_INDEX];
+
+	if (opts->present & DL_OPT_HANDLE &&
+	    attr_bus_name && attr_dev_name) {
+		const char *bus_name = mnl_attr_get_str(attr_bus_name);
+		const char *dev_name = mnl_attr_get_str(attr_dev_name);
+
+		if (strcmp(bus_name, opts->bus_name) != 0 ||
+		    strcmp(dev_name, opts->dev_name) != 0)
+			return false;
+	}
+	if (opts->present & DL_OPT_HANDLEP &&
+	    attr_bus_name && attr_dev_name && attr_port_index) {
+		const char *bus_name = mnl_attr_get_str(attr_bus_name);
+		const char *dev_name = mnl_attr_get_str(attr_dev_name);
+		uint32_t port_index = mnl_attr_get_u32(attr_port_index);
+
+		if (strcmp(bus_name, opts->bus_name) != 0 ||
+		    strcmp(dev_name, opts->dev_name) != 0 ||
+		    port_index != opts->port_index)
+			return false;
+	}
+	return true;
+}
+
 static void cmd_dev_help(void)
 {
 	pr_out("Usage: devlink dev show [ DEV ]\n");
-- 
2.5.5
