From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 10/17] Tools: hv: Gather ipv[4,6] gateway information
Date: Tue, 24 Jul 2012 09:01:34 -0700
Message-ID: <1343145701-3691-10-git-send-email-kys@microsoft.com>
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

Gather information on the default gateways - ipv4/ipv6.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 tools/hv/hv_kvp_daemon.c |   72 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/tools/hv/hv_kvp_daemon.c b/tools/hv/hv_kvp_daemon.c
index 007e698..b627236 100644
--- a/tools/hv/hv_kvp_daemon.c
+++ b/tools/hv/hv_kvp_daemon.c
@@ -491,6 +491,72 @@ done:
 	return;
 }
 
+static void kvp_process_ipconfig_file(char *cmd,
+					char *config_buf, int len,
+					int element_size, int offset)
+{
+	char buf[256];
+	char *p;
+	char *x;
+	FILE *file;
+
+	/*
+	 * First execute the command.
+	 */
+	file = popen(cmd, "r");
+	if (file == NULL)
+		return;
+
+	if (offset == 0)
+		memset(config_buf, 0, len);
+	while ((p = fgets(buf, sizeof(buf), file)) != NULL) {
+		if ((len - strlen(config_buf)) < (element_size + 1))
+			break;
+
+		x = strchr(p, '\n');
+		*x = '\0';
+		strcat(config_buf, p);
+		strcat(config_buf, ";");
+	}
+	pclose(file);
+}
+
+static void kvp_get_ipconfig_info(char *if_name,
+				 struct hv_kvp_ipaddr_value *buffer)
+{
+	char cmd[512];
+
+	/*
+	 * Get the address of default gateway (ipv4).
+	 */
+	memset(cmd, 0, sizeof(cmd));
+	strcat(cmd, "/sbin/ip -f inet  route | grep -w ");
+	strcat(cmd, if_name);
+	strcat(cmd, " | awk '/default/ {print $3 }'");
+
+	/*
+	 * Execute the command to gather gateway info.
+	 */
+	kvp_process_ipconfig_file(cmd, (char *)buffer->gate_way,
+				(MAX_GATEWAY_SIZE * 2), INET_ADDRSTRLEN, 0);
+
+	/*
+	 * Get the address of default gateway (ipv6).
+	 */
+	memset(cmd, 0, sizeof(cmd));
+	strcat(cmd, "/sbin/ip -f inet6  route | grep -w ");
+	strcat(cmd, if_name);
+	strcat(cmd, " | awk '/default/ {print $3 }'");
+
+	/*
+	 * Execute the command to gather gateway info (ipv6).
+	 */
+	kvp_process_ipconfig_file(cmd, (char *)buffer->gate_way,
+				(MAX_GATEWAY_SIZE * 2), INET6_ADDRSTRLEN, 1);
+
+}
+
+
 static unsigned int hweight32(unsigned int *w)
 {
 	unsigned int res = *w - ((*w >> 1) & 0x55555555);
@@ -649,6 +715,12 @@ kvp_get_ip_address(int family, char *if_name, int op,
 				strcat((char *)ip_buffer->sub_net, ";");
 				sn_offset += strlen(sn_str) + 1;
 			}
+
+			/*
+			 * Collect other ip related configuration info.
+			 */
+
+			kvp_get_ipconfig_info(if_name, ip_buffer);
 		}
 
 gather_ipaddr:
-- 
1.7.4.1
