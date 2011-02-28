From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] ethtool: Compat handling for struct
 ethtool_rxnfc
Date: Mon, 28 Feb 2011 18:22:26 +0000
Message-ID: <1298917347.2569.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Santwona Behera <santwona.behera@sun.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:33519 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752975Ab1B1SWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 13:22:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This structure was accidentally defined such that its layout can
differ between 32-bit and 64-bit processes.  Add compat structure
definitions and functions to copy from/to user-space with the
necessary adjustments.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I have not tested this with a driver that implements the
ETHTOOL_{G,S}RXCLSRL* operations.  However I have tested the new
functions in a simple userland test harness.

Ben.

 include/linux/ethtool.h |   34 ++++++++++++
 net/core/ethtool.c      |  131 ++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 134 insertions(+), 31 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index aac3e2e..b297f28 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -13,6 +13,9 @@
 #ifndef _LINUX_ETHTOOL_H
 #define _LINUX_ETHTOOL_H
 
+#ifdef __KERNEL__
+#include <linux/compat.h>
+#endif
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
@@ -450,6 +453,37 @@ struct ethtool_rxnfc {
 	__u32				rule_locs[0];
 };
 
+#ifdef __KERNEL__
+#ifdef CONFIG_COMPAT
+
+struct compat_ethtool_rx_flow_spec {
+	u32		flow_type;
+	union {
+		struct ethtool_tcpip4_spec		tcp_ip4_spec;
+		struct ethtool_tcpip4_spec		udp_ip4_spec;
+		struct ethtool_tcpip4_spec		sctp_ip4_spec;
+		struct ethtool_ah_espip4_spec		ah_ip4_spec;
+		struct ethtool_ah_espip4_spec		esp_ip4_spec;
+		struct ethtool_usrip4_spec		usr_ip4_spec;
+		struct ethhdr				ether_spec;
+		u8					hdata[72];
+	} h_u, m_u;
+	compat_u64	ring_cookie;
+	u32		location;
+};
+
+struct compat_ethtool_rxnfc {
+	u32				cmd;
+	u32				flow_type;
+	compat_u64			data;
+	struct compat_ethtool_rx_flow_spec fs;
+	u32				rule_cnt;
+	u32				rule_locs[0];
+};
+
+#endif /* CONFIG_COMPAT */
+#endif /* __KERNEL__ */
+
 /**
  * struct ethtool_rxfh_indir - command to get or set RX flow hash indirection
  * @cmd: Specific command number - %ETHTOOL_GRXFHINDIR or %ETHTOOL_SRXFHINDIR
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c1a71bb..982f252 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -673,24 +673,111 @@ out:
 	return ret;
 }
 
+static unsigned long copy_ethtool_rxnfc_from_user(struct ethtool_rxnfc *info,
+						  const void __user *useraddr)
+{
+	unsigned long ret;
+
+	/* struct ethtool_rxnfc was originally defined for
+	 * ETHTOOL_{G,S}RXFH with only the cmd, flow_type and data
+	 * members.  User-space might still be using that
+	 * definition. */
+	ret = copy_from_user(info, useraddr,
+			     (void *)(&info->data + 1) - (void *)info);
+	if (info->cmd == ETHTOOL_GRXFH || info->cmd == ETHTOOL_SRXFH)
+		return ret;
+
+#ifdef CONFIG_COMPAT
+	if (is_compat_task()) {
+		const struct compat_ethtool_rxnfc __user *user_info = useraddr;
+
+		/* We expect there to be holes between fs.m_u and
+		 * fs.ring_cookie and at the end of fs, but nowhere
+		 * else.
+		 */
+		BUILD_BUG_ON(offsetof(struct compat_ethtool_rxnfc, fs.m_u) +
+			     sizeof(user_info->fs.m_u) !=
+			     offsetof(struct ethtool_rxnfc, fs.m_u) +
+			     sizeof(info->fs.m_u));
+		BUILD_BUG_ON(
+			offsetof(struct compat_ethtool_rxnfc, fs.location) -
+			offsetof(struct compat_ethtool_rxnfc, fs.ring_cookie) !=
+			offsetof(struct ethtool_rxnfc, fs.location) -
+			offsetof(struct ethtool_rxnfc, fs.ring_cookie));
+
+		ret += copy_from_user(&info->fs, &user_info->fs,
+				      (void *)(&info->fs.m_u + 1) -
+				      (void *)&info->fs);
+		ret += copy_from_user(&info->fs.ring_cookie,
+				      &user_info->fs.ring_cookie,
+				      (void *)(&info->fs.location + 1) -
+				      (void *)&info->fs.ring_cookie);
+		ret += copy_from_user(&info->rule_cnt, &user_info->rule_cnt,
+				      sizeof(info->rule_cnt));
+	} else
+#endif
+	{
+		const struct ethtool_rxnfc __user *user_info = useraddr;
+		ret += copy_from_user(&info->fs, &user_info->fs,
+				      (void *)(info + 1) - (void *)&info->fs);
+	}
+
+	return ret;
+}
+
+static unsigned long
+copy_ethtool_rxnfc_to_user(void __user *useraddr,
+			   const struct ethtool_rxnfc *info,
+			   const u32 *rule_buf)
+{
+	u32 __user *user_rule_buf;
+	unsigned long ret;
+
+	ret = copy_to_user(useraddr, info,
+			   (const void *)(&info->data + 1) -
+			   (const void *)info);
+	if (info->cmd == ETHTOOL_GRXFH)
+		return ret;
+
+#ifdef CONFIG_COMPAT
+	if (is_compat_task()) {
+		struct compat_ethtool_rxnfc __user *user_info = useraddr;
+		ret += copy_to_user(&user_info->fs, &info->fs,
+				    (const void *)(&info->fs.m_u + 1) -
+				    (const void *)&info->fs);
+		ret += copy_to_user(&user_info->fs.ring_cookie,
+				    &info->fs.ring_cookie,
+				    (const void *)(&info->fs.location + 1) -
+				    (const void *)&info->fs.ring_cookie);
+		ret += copy_to_user(&user_info->rule_cnt, &info->rule_cnt,
+				    sizeof(info->rule_cnt));
+		user_rule_buf = &user_info->rule_locs[0];
+	} else
+#endif
+	{
+		struct ethtool_rxnfc __user *user_info = useraddr;
+		ret += copy_to_user(&user_info->fs, &info->fs,
+				    (const void *)(info + 1) -
+				    (const void *)&info->fs);
+		user_rule_buf = &user_info->rule_locs[0];
+	}
+
+	if (rule_buf)
+		ret += copy_to_user(user_rule_buf, rule_buf,
+				    info->rule_cnt * sizeof(u32));
+
+	return ret;
+}
+
 static noinline_for_stack int ethtool_set_rxnfc(struct net_device *dev,
 						u32 cmd, void __user *useraddr)
 {
 	struct ethtool_rxnfc info;
-	size_t info_size = sizeof(info);
 
 	if (!dev->ethtool_ops->set_rxnfc)
 		return -EOPNOTSUPP;
 
-	/* struct ethtool_rxnfc was originally defined for
-	 * ETHTOOL_{G,S}RXFH with only the cmd, flow_type and data
-	 * members.  User-space might still be using that
-	 * definition. */
-	if (cmd == ETHTOOL_SRXFH)
-		info_size = (offsetof(struct ethtool_rxnfc, data) +
-			     sizeof(info.data));
-
-	if (copy_from_user(&info, useraddr, info_size))
+	if (copy_ethtool_rxnfc_from_user(&info, useraddr))
 		return -EFAULT;
 
 	return dev->ethtool_ops->set_rxnfc(dev, &info);
@@ -700,7 +787,6 @@ static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
 						u32 cmd, void __user *useraddr)
 {
 	struct ethtool_rxnfc info;
-	size_t info_size = sizeof(info);
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 	int ret;
 	void *rule_buf = NULL;
@@ -708,15 +794,7 @@ static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
 	if (!ops->get_rxnfc)
 		return -EOPNOTSUPP;
 
-	/* struct ethtool_rxnfc was originally defined for
-	 * ETHTOOL_{G,S}RXFH with only the cmd, flow_type and data
-	 * members.  User-space might still be using that
-	 * definition. */
-	if (cmd == ETHTOOL_GRXFH)
-		info_size = (offsetof(struct ethtool_rxnfc, data) +
-			     sizeof(info.data));
-
-	if (copy_from_user(&info, useraddr, info_size))
+	if (copy_ethtool_rxnfc_from_user(&info, useraddr))
 		return -EFAULT;
 
 	if (info.cmd == ETHTOOL_GRXCLSRLALL) {
@@ -733,17 +811,8 @@ static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
 	if (ret < 0)
 		goto err_out;
 
-	ret = -EFAULT;
-	if (copy_to_user(useraddr, &info, info_size))
-		goto err_out;
-
-	if (rule_buf) {
-		useraddr += offsetof(struct ethtool_rxnfc, rule_locs);
-		if (copy_to_user(useraddr, rule_buf,
-				 info.rule_cnt * sizeof(u32)))
-			goto err_out;
-	}
-	ret = 0;
+	if (copy_ethtool_rxnfc_to_user(useraddr, &info, rule_buf))
+		ret = -EFAULT;
 
 err_out:
 	kfree(rule_buf);
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

