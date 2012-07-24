From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 12/17] Tools: hv: Gather DHCP information
Date: Tue, 24 Jul 2012 09:01:36 -0700
Message-ID: <1343145701-3691-12-git-send-email-kys@microsoft.com>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, virtualization@lists.osdl.org,
	olaf@aepfle.de, apw@canonical.com, netdev@vger.kernel.org,
	ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343145701-3691-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Collect information on dhcp setting for the specified interface.
We invoke an exyernal script to get this information.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 tools/hv/hv_kvp_daemon.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/tools/hv/hv_kvp_daemon.c b/tools/hv/hv_kvp_daemon.c
index 9500cff..2d01ccd 100644
--- a/tools/hv/hv_kvp_daemon.c
+++ b/tools/hv/hv_kvp_daemon.c
@@ -525,6 +525,9 @@ static void kvp_get_ipconfig_info(char *if_name,
 				 struct hv_kvp_ipaddr_value *buffer)
 {
 	char cmd[512];
+	char dhcp_info[128];
+	char *p;
+	FILE *file;
 
 	/*
 	 * Get the address of default gateway (ipv4).
@@ -581,6 +584,36 @@ static void kvp_get_ipconfig_info(char *if_name,
 	 */
 	kvp_process_ipconfig_file(cmd, (char *)buffer->dns_addr,
 				(MAX_IP_ADDR_SIZE * 2), INET_ADDRSTRLEN, 0);
+
+	/*
+	 * Gather the DHCP state.
+	 * We will gather this state by invoking an external script.
+	 * The parameter to the script is the interface name.
+	 * Here is the expected output:
+	 *
+	 * Enabled: DHCP enabled.
+	 */
+
+	memset(cmd, 0, sizeof(cmd));
+	strcat(cmd, "/sbin/hv_get_dhcp_info ");
+	strcat(cmd, if_name);
+
+	file = popen(cmd, "r");
+	if (file == NULL)
+		return;
+
+	p = fgets(dhcp_info, sizeof(dhcp_info), file);
+	if (p == NULL) {
+		pclose(file);
+		return;
+	}
+
+	if (!strncmp(p, "Enabled", 7))
+		buffer->dhcp_enabled = 1;
+	else
+		buffer->dhcp_enabled = 0;
+
+	pclose(file);
 }
 
 
-- 
1.7.4.1
