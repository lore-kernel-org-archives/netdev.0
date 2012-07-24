From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 15/17] Tools: hv: Implement the KVP verb - KVP_OP_GET_IP_INFO
Date: Tue, 24 Jul 2012 09:01:39 -0700
Message-ID: <1343145701-3691-15-git-send-email-kys@microsoft.com>
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

Now implement the KVP verb - KVP_OP_GET_IP_INFO. This operation retrieves IP
information for the specified interface.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 tools/hv/hv_kvp_daemon.c |   94 ++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 91 insertions(+), 3 deletions(-)

diff --git a/tools/hv/hv_kvp_daemon.c b/tools/hv/hv_kvp_daemon.c
index 87cfc64..3bce574 100644
--- a/tools/hv/hv_kvp_daemon.c
+++ b/tools/hv/hv_kvp_daemon.c
@@ -601,6 +601,69 @@ static char *kvp_if_name_to_mac(char *if_name)
 }
 
 
+/*
+ * Retrieve the interface name given tha MAC address.
+ */
+
+static char *kvp_mac_to_if_name(char *mac)
+{
+	DIR *dir;
+	struct dirent *entry;
+	FILE    *file;
+	char    *p, *q, *x;
+	char    *if_name = NULL;
+	char    buf[256];
+	char *kvp_net_dir = "/sys/class/net/";
+	char dev_id[100];
+	int i;
+
+	dir = opendir(kvp_net_dir);
+	if (dir == NULL)
+		return NULL;
+
+	memset(dev_id, 0, sizeof(dev_id));
+	strcat(dev_id, kvp_net_dir);
+	q = dev_id + strlen(kvp_net_dir);
+
+	while ((entry = readdir(dir)) != NULL) {
+		/*
+		 * Set the state for the next pass.
+		 */
+		*q = '\0';
+
+		strcat(dev_id, entry->d_name);
+		strcat(dev_id, "/address");
+
+		file = fopen(dev_id, "r");
+		if (file == NULL)
+			continue;
+
+		p = fgets(buf, sizeof(buf), file);
+		if (p) {
+			x = strchr(p, '\n');
+			if (x)
+				*x = '\0';
+
+			for (i = 0; i < strlen(p); i++)
+				p[i] = toupper(p[i]);
+
+			if (!strcmp(p, mac)) {
+				/*
+				 * Found the MAC match; return the interface
+				 * name. The caller will free the memory.
+				 */
+				if_name = strdup(entry->d_name);
+				break;
+			}
+		}
+		fclose(file);
+	}
+
+	closedir(dir);
+	return if_name;
+}
+
+
 static void kvp_process_ipconfig_file(char *cmd,
 					char *config_buf, int len,
 					int element_size, int offset)
@@ -757,10 +820,10 @@ static int kvp_process_ip_address(void *addrp,
 	}
 
 	if ((length - *offset) < addr_length + 1)
-		return 1;
+		return HV_E_FAIL;
 	if (str == NULL) {
 		strcpy(buffer, "inet_ntop failed\n");
-		return 1;
+		return HV_E_FAIL;
 	}
 	if (*offset == 0)
 		strcpy(buffer, tmp);
@@ -804,7 +867,7 @@ kvp_get_ip_info(int family, char *if_name, int op,
 
 	if (getifaddrs(&ifap)) {
 		strcpy(buffer, "getifaddrs failed\n");
-		return 1;
+		return HV_E_FAIL;
 	}
 
 	curp = ifap;
@@ -1392,6 +1455,31 @@ int main(void)
 		}
 
 		switch (op) {
+		case KVP_OP_GET_IP_INFO:
+			kvp_ip_val = &hv_msg->body.kvp_ip_val;
+			if_name =
+			kvp_mac_to_if_name((char *)kvp_ip_val->adapter_id);
+
+			if (if_name == NULL) {
+				/*
+				 * We could not map the mac address to an
+				 * interface name; return error.
+				 */
+				*((int *)(&hv_msg->kvp_hdr.operation)) =
+					HV_E_FAIL;
+				break;
+			}
+			error = kvp_get_ip_info(
+						0, if_name, KVP_OP_GET_IP_INFO,
+						kvp_ip_val,
+						(MAX_IP_ADDR_SIZE * 2));
+
+			if (error)
+				*((int *)(&hv_msg->kvp_hdr.operation)) = error;
+
+			free(if_name);
+			break;
+
 		case KVP_OP_SET_IP_INFO:
 			kvp_ip_val = &hv_msg->body.kvp_ip_val;
 			if_name = kvp_get_if_name(
-- 
1.7.4.1
