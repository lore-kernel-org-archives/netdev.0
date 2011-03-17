From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] ethtool: Compat handling for struct ethtool_rxnfc
Date: Thu, 17 Mar 2011 17:34:32 +0000
Message-ID: <1300383272.2569.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Santwona Behera <santwona.behera@sun.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:58749 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754831Ab1CQRgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 13:36:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This structure was accidentally defined such that its layout can
differ between 32-bit and 64-bit processes.  Add compat structure
definitions and an ioctl wrapper function.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Cc: stable@kernel.org [2.6.30+]
---
David,

I still haven't received any response on whether the ETHTOOL_GRXCLSRLALL
wrapping works with a real driver, but perhaps you could test it against
niu?  I think sparc32 and sparc64 have the same alignment for u64 so
this wrapper isn't strictly necessary, but it would still be used.  (Or
we can arrange to disable the conversion when compat_ethtool_rxnfc is
equivalent to ethtool_rxnfc.)

Ben.

 include/linux/ethtool.h |   34 ++++++++++++++
 net/socket.c            |  114 ++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 141 insertions(+), 7 deletions(-)

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
diff --git a/net/socket.c b/net/socket.c
index 937d0fcf..5212447 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2588,23 +2588,123 @@ static int dev_ifconf(struct net *net, struct compat_ifconf __user *uifc32)
 
 static int ethtool_ioctl(struct net *net, struct compat_ifreq __user *ifr32)
 {
+	struct compat_ethtool_rxnfc __user *compat_rxnfc;
+	bool convert_in = false, convert_out = false;
+	size_t buf_size = ALIGN(sizeof(struct ifreq), 8);
+	struct ethtool_rxnfc __user *rxnfc;
 	struct ifreq __user *ifr;
+	u32 rule_cnt = 0, actual_rule_cnt;
+	u32 ethcmd;
 	u32 data;
-	void __user *datap;
+	int ret;
+
+	if (get_user(data, &ifr32->ifr_ifru.ifru_data))
+		return -EFAULT;
 
-	ifr = compat_alloc_user_space(sizeof(*ifr));
+	compat_rxnfc = compat_ptr(data);
 
-	if (copy_in_user(&ifr->ifr_name, &ifr32->ifr_name, IFNAMSIZ))
+	if (get_user(ethcmd, &compat_rxnfc->cmd))
 		return -EFAULT;
 
-	if (get_user(data, &ifr32->ifr_ifru.ifru_data))
+	/* Most ethtool structures are defined without padding.
+	 * Unfortunately struct ethtool_rxnfc is an exception.
+	 */
+	switch (ethcmd) {
+	default:
+		break;
+	case ETHTOOL_GRXCLSRLALL:
+		/* Buffer size is variable */
+		if (get_user(rule_cnt, &compat_rxnfc->rule_cnt))
+			return -EFAULT;
+		if (rule_cnt > KMALLOC_MAX_SIZE / sizeof(u32))
+			return -ENOMEM;
+		buf_size += rule_cnt * sizeof(u32);
+		/* fall through */
+	case ETHTOOL_GRXRINGS:
+	case ETHTOOL_GRXCLSRLCNT:
+	case ETHTOOL_GRXCLSRULE:
+		convert_out = true;
+		/* fall through */
+	case ETHTOOL_SRXCLSRLDEL:
+	case ETHTOOL_SRXCLSRLINS:
+		buf_size += sizeof(struct ethtool_rxnfc);
+		convert_in = true;
+		break;
+	}
+
+	ifr = compat_alloc_user_space(buf_size);
+	rxnfc = (void *)ifr + ALIGN(sizeof(struct ifreq), 8);
+
+	if (copy_in_user(&ifr->ifr_name, &ifr32->ifr_name, IFNAMSIZ))
 		return -EFAULT;
 
-	datap = compat_ptr(data);
-	if (put_user(datap, &ifr->ifr_ifru.ifru_data))
+	if (put_user(convert_in ? rxnfc : compat_ptr(data),
+		     &ifr->ifr_ifru.ifru_data))
 		return -EFAULT;
 
-	return dev_ioctl(net, SIOCETHTOOL, ifr);
+	if (convert_in) {
+		/* We expect there to be holes between fs.m_u and
+		 * fs.ring_cookie and at the end of fs, but nowhere else.
+		 */
+		BUILD_BUG_ON(offsetof(struct compat_ethtool_rxnfc, fs.m_u) +
+			     sizeof(compat_rxnfc->fs.m_u) !=
+			     offsetof(struct ethtool_rxnfc, fs.m_u) +
+			     sizeof(rxnfc->fs.m_u));
+		BUILD_BUG_ON(
+			offsetof(struct compat_ethtool_rxnfc, fs.location) -
+			offsetof(struct compat_ethtool_rxnfc, fs.ring_cookie) !=
+			offsetof(struct ethtool_rxnfc, fs.location) -
+			offsetof(struct ethtool_rxnfc, fs.ring_cookie));
+
+		if (copy_in_user(rxnfc, compat_rxnfc,
+				 (void *)(&rxnfc->fs.m_u + 1) -
+				 (void *)rxnfc) ||
+		    copy_in_user(&rxnfc->fs.ring_cookie,
+				 &compat_rxnfc->fs.ring_cookie,
+				 (void *)(&rxnfc->fs.location + 1) -
+				 (void *)&rxnfc->fs.ring_cookie) ||
+		    copy_in_user(&rxnfc->rule_cnt, &compat_rxnfc->rule_cnt,
+				 sizeof(rxnfc->rule_cnt)))
+			return -EFAULT;
+	}
+
+	ret = dev_ioctl(net, SIOCETHTOOL, ifr);
+	if (ret)
+		return ret;
+
+	if (convert_out) {
+		if (copy_in_user(compat_rxnfc, rxnfc,
+				 (const void *)(&rxnfc->fs.m_u + 1) -
+				 (const void *)rxnfc) ||
+		    copy_in_user(&compat_rxnfc->fs.ring_cookie,
+				 &rxnfc->fs.ring_cookie,
+				 (const void *)(&rxnfc->fs.location + 1) -
+				 (const void *)&rxnfc->fs.ring_cookie) ||
+		    copy_in_user(&compat_rxnfc->rule_cnt, &rxnfc->rule_cnt,
+				 sizeof(rxnfc->rule_cnt)))
+			return -EFAULT;
+
+		if (ethcmd == ETHTOOL_GRXCLSRLALL) {
+			/* As an optimisation, we only copy the actual
+			 * number of rules that the underlying
+			 * function returned.  Since Mallory might
+			 * change the rule count in user memory, we
+			 * check that it is less than the rule count
+			 * originally given (as the user buffer size),
+			 * which has been range-checked.
+			 */
+			if (get_user(actual_rule_cnt, &rxnfc->rule_cnt))
+				return -EFAULT;
+			if (actual_rule_cnt < rule_cnt)
+				rule_cnt = actual_rule_cnt;
+			if (copy_in_user(&compat_rxnfc->rule_locs[0],
+					 &rxnfc->rule_locs[0],
+					 rule_cnt * sizeof(u32)))
+				return -EFAULT;
+		}
+	}
+
+	return 0;
 }
 
 static int compat_siocwandev(struct net *net, struct compat_ifreq __user *uifr32)
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

