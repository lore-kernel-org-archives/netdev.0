From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 07/11] ieee802154: add dgram
	sockopts for security control
Date: Fri, 16 May 2014 17:46:41 +0200
Message-ID: <1400255205-9031-8-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1400255205-9031-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Allow datagram sockets to override the security settings of the device
they send from on a per-socket basis. Requires CAP_NET_ADMIN or
CAP_NET_RAW, since raw sockets can send arbitrary packets anyway.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 include/net/af_ieee802154.h |   10 ++++++-
 net/ieee802154/dgram.c      |   66 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/include/net/af_ieee802154.h b/include/net/af_ieee802154.h
index f79ae2a..085940f 100644
--- a/include/net/af_ieee802154.h
+++ b/include/net/af_ieee802154.h
@@ -57,6 +57,14 @@ struct sockaddr_ieee802154 {
 /* get/setsockopt */
 #define SOL_IEEE802154	0
 
-#define WPAN_WANTACK	0
+#define WPAN_WANTACK		0
+#define WPAN_SECURITY		1
+#define WPAN_SECURITY_LEVEL	2
+
+#define WPAN_SECURITY_DEFAULT	0
+#define WPAN_SECURITY_OFF	1
+#define WPAN_SECURITY_ON	2
+
+#define WPAN_SECURITY_LEVEL_DEFAULT	(-1)
 
 #endif
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 76c7725..4f0ed87 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -21,6 +21,7 @@
  * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
  */
 
+#include <linux/capability.h>
 #include <linux/net.h>
 #include <linux/module.h>
 #include <linux/if_arp.h>
@@ -47,6 +48,10 @@ struct dgram_sock {
 	unsigned int bound:1;
 	unsigned int connected:1;
 	unsigned int want_ack:1;
+	unsigned int secen:1;
+	unsigned int secen_override:1;
+	unsigned int seclevel:3;
+	unsigned int seclevel_override:1;
 };
 
 static inline struct dgram_sock *dgram_sk(const struct sock *sk)
@@ -264,6 +269,11 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 		dst_addr = ro->dst_addr;
 	}
 
+	cb->secen = ro->secen;
+	cb->secen_override = ro->secen_override;
+	cb->seclevel = ro->seclevel;
+	cb->seclevel_override = ro->seclevel_override;
+
 	err = dev_hard_header(skb, dev, ETH_P_IEEE802154, &dst_addr,
 			      ro->bound ? &ro->src_addr : NULL, size);
 	if (err < 0)
@@ -427,6 +437,20 @@ static int dgram_getsockopt(struct sock *sk, int level, int optname,
 	case WPAN_WANTACK:
 		val = ro->want_ack;
 		break;
+	case WPAN_SECURITY:
+		if (!ro->secen_override)
+			val = WPAN_SECURITY_DEFAULT;
+		else if (ro->secen)
+			val = WPAN_SECURITY_ON;
+		else
+			val = WPAN_SECURITY_OFF;
+		break;
+	case WPAN_SECURITY_LEVEL:
+		if (!ro->seclevel_override)
+			val = WPAN_SECURITY_LEVEL_DEFAULT;
+		else
+			val = ro->seclevel;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -442,6 +466,7 @@ static int dgram_setsockopt(struct sock *sk, int level, int optname,
 		    char __user *optval, unsigned int optlen)
 {
 	struct dgram_sock *ro = dgram_sk(sk);
+	struct net *net = sock_net(sk);
 	int val;
 	int err = 0;
 
@@ -457,6 +482,47 @@ static int dgram_setsockopt(struct sock *sk, int level, int optname,
 	case WPAN_WANTACK:
 		ro->want_ack = !!val;
 		break;
+	case WPAN_SECURITY:
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN) &&
+		    !ns_capable(net->user_ns, CAP_NET_RAW)) {
+			err = -EPERM;
+			break;
+		}
+
+		switch (val) {
+		case WPAN_SECURITY_DEFAULT:
+			ro->secen_override = 0;
+			break;
+		case WPAN_SECURITY_ON:
+			ro->secen_override = 1;
+			ro->secen = 1;
+			break;
+		case WPAN_SECURITY_OFF:
+			ro->secen_override = 1;
+			ro->secen = 0;
+			break;
+		default:
+			err = -EINVAL;
+			break;
+		}
+		break;
+	case WPAN_SECURITY_LEVEL:
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN) &&
+		    !ns_capable(net->user_ns, CAP_NET_RAW)) {
+			err = -EPERM;
+			break;
+		}
+
+		if (val < WPAN_SECURITY_LEVEL_DEFAULT ||
+		    val > IEEE802154_SCF_SECLEVEL_ENC_MIC128) {
+			err = -EINVAL;
+		} else if (val == WPAN_SECURITY_LEVEL_DEFAULT) {
+			ro->seclevel_override = 0;
+		} else {
+			ro->seclevel_override = 1;
+			ro->seclevel = val;
+		}
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
