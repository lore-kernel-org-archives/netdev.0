From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/12] tipc: Add "max_ports" configuration parameter
Date: Thu, 30 May 2013 15:36:07 -0400
Message-ID: <1369942577-39563-3-git-send-email-paul.gortmaker@windriver.com>
References: <1369942577-39563-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:51482 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759830Ab3E3Tgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 15:36:36 -0400
In-Reply-To: <1369942577-39563-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Introduce the "max_ports" module parameter, which allows the maximum
number of ports supported by TIPC to be changed from the default value
at boot, or at module load time. Because of the way the port reference
table is structured and initiated, this value must be known at module
start time, and can not be changed later.

Until now this value has been set via a macro, and hence things
have to be recompiled if the value is to be changed. The Kconfig
knob and the dead code intended to change this parameter at runtime
are dropped.

Considering TIPC node addresses are unique on the entire node, the
64k port limit has proven to be a little too strict.  We increase the
allowed max to 128k. This is safe since the protocol headers allow
for up to 2^32 -1 ports.

Usage for module: "insmod tipc.ko max_ports=<value>" ; at boot, append
"tipc.max_ports=<value>" to the kernel command line.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/Kconfig  | 12 ------------
 net/tipc/config.c | 20 +-------------------
 net/tipc/core.c   |  9 +++++++--
 net/tipc/core.h   |  5 ++++-
 4 files changed, 12 insertions(+), 34 deletions(-)

diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index c890848..91c8a8e 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -20,18 +20,6 @@ menuconfig TIPC
 
 	  If in doubt, say N.
 
-config TIPC_PORTS
-	int "Maximum number of ports in a node"
-	depends on TIPC
-	range 127 65535
-	default "8191"
-	help
-	  Specifies how many ports can be supported by a node.
-	  Can range from 127 to 65535 ports; default is 8191.
-
-	  Setting this to a smaller value saves some memory,
-	  setting it to higher allows for more ports.
-
 config TIPC_MEDIA_IB
 	bool "InfiniBand media type support"
 	depends on TIPC && INFINIBAND_IPOIB
diff --git a/net/tipc/config.c b/net/tipc/config.c
index f67866c..79cada1 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -208,22 +208,6 @@ static struct sk_buff *cfg_set_remote_mng(void)
 	return tipc_cfg_reply_none();
 }
 
-static struct sk_buff *cfg_set_max_ports(void)
-{
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value == tipc_max_ports)
-		return tipc_cfg_reply_none();
-	if (value < 127 || value > 65535)
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (max ports must be 127-65535)");
-	return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-		" (cannot change max ports while TIPC is active)");
-}
-
 static struct sk_buff *cfg_set_netid(void)
 {
 	u32 value;
@@ -324,9 +308,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_SET_REMOTE_MNG:
 		rep_tlv_buf = cfg_set_remote_mng();
 		break;
-	case TIPC_CMD_SET_MAX_PORTS:
-		rep_tlv_buf = cfg_set_max_ports();
-		break;
 	case TIPC_CMD_SET_NETID:
 		rep_tlv_buf = cfg_set_netid();
 		break;
@@ -356,6 +337,7 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_SET_MAX_PUBL:
 	case TIPC_CMD_GET_MAX_PUBL:
 	case TIPC_CMD_SET_LOG_SIZE:
+	case TIPC_CMD_SET_MAX_PORTS:
 	case TIPC_CMD_DUMP_LOG:
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 							  " (obsolete command)");
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 7ec2c1e..f8abe8e 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -47,10 +47,11 @@ int tipc_random __read_mostly;
 
 /* configurable TIPC parameters */
 u32 tipc_own_addr __read_mostly;
-int tipc_max_ports __read_mostly;
+unsigned int tipc_max_ports __read_mostly;
 int tipc_net_id __read_mostly;
 int tipc_remote_management __read_mostly;
 
+static unsigned int max_ports = TIPC_DEFAULT_PORTS;
 
 /**
  * tipc_buf_acquire - creates a TIPC message buffer
@@ -157,7 +158,8 @@ static int __init tipc_init(void)
 
 	tipc_own_addr = 0;
 	tipc_remote_management = 1;
-	tipc_max_ports = CONFIG_TIPC_PORTS;
+	tipc_max_ports = clamp_t(unsigned int, max_ports,
+				 TIPC_MIN_PORTS, TIPC_MAX_PORTS);
 	tipc_net_id = 4711;
 
 	res = tipc_core_start();
@@ -181,3 +183,6 @@ module_exit(tipc_exit);
 MODULE_DESCRIPTION("TIPC: Transparent Inter Process Communication");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(TIPC_MOD_VER);
+
+module_param(max_ports, uint, S_IRUGO);
+MODULE_PARM_DESC(max_ports, "Maximum number of ports (127 - 128K)");
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 0207db0..9d6a47e 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -63,6 +63,9 @@
 #define ULTRA_STRING_MAX_LEN	32768
 #define TIPC_MAX_SUBSCRIPTIONS	65535
 #define TIPC_MAX_PUBLICATIONS	65535
+#define TIPC_DEFAULT_PORTS	8192
+#define TIPC_MIN_PORTS		127
+#define TIPC_MAX_PORTS		131072
 
 struct tipc_msg;	/* msg.h */
 
@@ -77,7 +80,7 @@ int tipc_snprintf(char *buf, int len, const char *fmt, ...);
  * Global configuration variables
  */
 extern u32 tipc_own_addr __read_mostly;
-extern int tipc_max_ports __read_mostly;
+extern unsigned int tipc_max_ports __read_mostly;
 extern int tipc_net_id __read_mostly;
 extern int tipc_remote_management __read_mostly;
 
-- 
1.8.1.2
