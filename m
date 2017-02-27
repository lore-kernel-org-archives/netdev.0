From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH v1 4/4] iscsi-target: use generic inet_pton_with_scope
Date: Mon, 27 Feb 2017 19:39:24 +0200
Message-ID: <1488217164-9221-5-git-send-email-sagi@grimberg.me>
References: <1488217164-9221-1-git-send-email-sagi@grimberg.me>
To: linux-nvme@lists.infradead.org, target-devel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <1488217164-9221-1-git-send-email-sagi@grimberg.me>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: Nicholas Bellinger <nab@linux-iscsi.org>
Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
---
 drivers/target/iscsi/iscsi_target_configfs.c | 46 ++++++++--------------------
 1 file changed, 12 insertions(+), 34 deletions(-)

diff --git a/drivers/target/iscsi/iscsi_target_configfs.c b/drivers/target/iscsi/iscsi_target_configfs.c
index bf40f03755dd..f30c27b83c5e 100644
--- a/drivers/target/iscsi/iscsi_target_configfs.c
+++ b/drivers/target/iscsi/iscsi_target_configfs.c
@@ -167,10 +167,7 @@ static struct se_tpg_np *lio_target_call_addnptotpg(
 	struct iscsi_portal_group *tpg;
 	struct iscsi_tpg_np *tpg_np;
 	char *str, *str2, *ip_str, *port_str;
-	struct sockaddr_storage sockaddr;
-	struct sockaddr_in *sock_in;
-	struct sockaddr_in6 *sock_in6;
-	unsigned long port;
+	struct sockaddr_storage sockaddr = { };
 	int ret;
 	char buf[MAX_PORTAL_LEN + 1];
 
@@ -182,21 +179,19 @@ static struct se_tpg_np *lio_target_call_addnptotpg(
 	memset(buf, 0, MAX_PORTAL_LEN + 1);
 	snprintf(buf, MAX_PORTAL_LEN + 1, "%s", name);
 
-	memset(&sockaddr, 0, sizeof(struct sockaddr_storage));
-
 	str = strstr(buf, "[");
 	if (str) {
-		const char *end;
-
 		str2 = strstr(str, "]");
 		if (!str2) {
 			pr_err("Unable to locate trailing \"]\""
 				" in IPv6 iSCSI network portal address\n");
 			return ERR_PTR(-EINVAL);
 		}
-		str++; /* Skip over leading "[" */
+
+		ip_str = str + 1; /* Skip over leading "[" */
 		*str2 = '\0'; /* Terminate the unbracketed IPv6 address */
 		str2++; /* Skip over the \0 */
+
 		port_str = strstr(str2, ":");
 		if (!port_str) {
 			pr_err("Unable to locate \":port\""
@@ -205,23 +200,8 @@ static struct se_tpg_np *lio_target_call_addnptotpg(
 		}
 		*port_str = '\0'; /* Terminate string for IP */
 		port_str++; /* Skip over ":" */
-
-		ret = kstrtoul(port_str, 0, &port);
-		if (ret < 0) {
-			pr_err("kstrtoul() failed for port_str: %d\n", ret);
-			return ERR_PTR(ret);
-		}
-		sock_in6 = (struct sockaddr_in6 *)&sockaddr;
-		sock_in6->sin6_family = AF_INET6;
-		sock_in6->sin6_port = htons((unsigned short)port);
-		ret = in6_pton(str, -1,
-				(void *)&sock_in6->sin6_addr.in6_u, -1, &end);
-		if (ret <= 0) {
-			pr_err("in6_pton returned: %d\n", ret);
-			return ERR_PTR(-EINVAL);
-		}
 	} else {
-		str = ip_str = &buf[0];
+		ip_str = &buf[0];
 		port_str = strstr(ip_str, ":");
 		if (!port_str) {
 			pr_err("Unable to locate \":port\""
@@ -230,17 +210,15 @@ static struct se_tpg_np *lio_target_call_addnptotpg(
 		}
 		*port_str = '\0'; /* Terminate string for IP */
 		port_str++; /* Skip over ":" */
+	}
 
-		ret = kstrtoul(port_str, 0, &port);
-		if (ret < 0) {
-			pr_err("kstrtoul() failed for port_str: %d\n", ret);
-			return ERR_PTR(ret);
-		}
-		sock_in = (struct sockaddr_in *)&sockaddr;
-		sock_in->sin_family = AF_INET;
-		sock_in->sin_port = htons((unsigned short)port);
-		sock_in->sin_addr.s_addr = in_aton(ip_str);
+	ret = inet_pton_with_scope(&init_net, AF_UNSPEC, ip_str,
+			port_str, &sockaddr);
+	if (ret) {
+		pr_err("malformed ip/port passed: %s\n", name);
+		return ERR_PTR(ret);
 	}
+
 	tpg = container_of(se_tpg, struct iscsi_portal_group, tpg_se_tpg);
 	ret = iscsit_get_tpg(tpg);
 	if (ret < 0)
-- 
2.7.4
