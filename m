From: kys@exchange.microsoft.com
Subject: [PATCH 2/6] tools: hv: properly handle long paths
Date: Sun, 30 Apr 2017 16:21:15 -0700
Message-ID: <1493594479-25329-2-git-send-email-kys@exchange.microsoft.com>
References: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
Reply-To: kys@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, leann.ogasawara@canonical.comi,
 marcelo.cerri@canonical.com, sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>

Paths can be up to PATH_MAX long and PATH_MAX is usually greater than 256.
While on it, simplify path reconstruction to a simple snprintf(), define
and reuse KVP_NET_DIR.

Suggested-by: Tomas Hozza <thozza@redhat.com>
Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 tools/hv/hv_kvp_daemon.c |   44 ++++++++++++++++++--------------------------
 1 files changed, 18 insertions(+), 26 deletions(-)

diff --git a/tools/hv/hv_kvp_daemon.c b/tools/hv/hv_kvp_daemon.c
index f1758fc..88b20e0 100644
--- a/tools/hv/hv_kvp_daemon.c
+++ b/tools/hv/hv_kvp_daemon.c
@@ -39,6 +39,7 @@
 #include <fcntl.h>
 #include <dirent.h>
 #include <net/if.h>
+#include <limits.h>
 #include <getopt.h>
 
 /*
@@ -97,6 +98,8 @@ enum {
 #define KVP_SCRIPTS_PATH "/usr/libexec/hypervkvpd/"
 #endif
 
+#define KVP_NET_DIR "/sys/class/net/"
+
 #define MAX_FILE_NAME 100
 #define ENTRIES_PER_BLOCK 50
 
@@ -596,26 +599,21 @@ void kvp_get_os_info(void)
 	DIR *dir;
 	struct dirent *entry;
 	FILE    *file;
-	char    *p, *q, *x;
+	char    *p, *x;
 	char    *if_name = NULL;
 	char    buf[256];
-	char *kvp_net_dir = "/sys/class/net/";
-	char dev_id[256];
+	char dev_id[PATH_MAX];
 
-	dir = opendir(kvp_net_dir);
+	dir = opendir(KVP_NET_DIR);
 	if (dir == NULL)
 		return NULL;
 
-	snprintf(dev_id, sizeof(dev_id), "%s", kvp_net_dir);
-	q = dev_id + strlen(kvp_net_dir);
-
 	while ((entry = readdir(dir)) != NULL) {
 		/*
 		 * Set the state for the next pass.
 		 */
-		*q = '\0';
-		strcat(dev_id, entry->d_name);
-		strcat(dev_id, "/device/device_id");
+		snprintf(dev_id, sizeof(dev_id), "%s%s/device/device_id",
+			 KVP_NET_DIR, entry->d_name);
 
 		file = fopen(dev_id, "r");
 		if (file == NULL)
@@ -653,12 +651,12 @@ void kvp_get_os_info(void)
 	FILE    *file;
 	char    *p, *x;
 	char    buf[256];
-	char addr_file[256];
+	char addr_file[PATH_MAX];
 	unsigned int i;
 	char *mac_addr = NULL;
 
-	snprintf(addr_file, sizeof(addr_file), "%s%s%s", "/sys/class/net/",
-		if_name, "/address");
+	snprintf(addr_file, sizeof(addr_file), "%s%s%s", KVP_NET_DIR,
+		 if_name, "/address");
 
 	file = fopen(addr_file, "r");
 	if (file == NULL)
@@ -688,28 +686,22 @@ void kvp_get_os_info(void)
 	DIR *dir;
 	struct dirent *entry;
 	FILE    *file;
-	char    *p, *q, *x;
+	char    *p, *x;
 	char    *if_name = NULL;
 	char    buf[256];
-	char *kvp_net_dir = "/sys/class/net/";
-	char dev_id[256];
+	char dev_id[PATH_MAX];
 	unsigned int i;
 
-	dir = opendir(kvp_net_dir);
+	dir = opendir(KVP_NET_DIR);
 	if (dir == NULL)
 		return NULL;
 
-	snprintf(dev_id, sizeof(dev_id), "%s", kvp_net_dir);
-	q = dev_id + strlen(kvp_net_dir);
-
 	while ((entry = readdir(dir)) != NULL) {
 		/*
 		 * Set the state for the next pass.
 		 */
-		*q = '\0';
-
-		strcat(dev_id, entry->d_name);
-		strcat(dev_id, "/address");
+		snprintf(dev_id, sizeof(dev_id), "%s%s/address", KVP_NET_DIR,
+			 entry->d_name);
 
 		file = fopen(dev_id, "r");
 		if (file == NULL)
@@ -1218,9 +1210,9 @@ static int process_ip_string(FILE *f, char *ip_string, int type)
 static int kvp_set_ip_info(char *if_name, struct hv_kvp_ipaddr_value *new_val)
 {
 	int error = 0;
-	char if_file[128];
+	char if_file[PATH_MAX];
 	FILE *file;
-	char cmd[512];
+	char cmd[PATH_MAX];
 	char *mac_addr;
 
 	/*
-- 
1.7.1
