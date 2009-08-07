From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 08/10] af_ieee802154: add support for
	WANT_ACK socket option
Date: Fri,  7 Aug 2009 16:58:43 +0400
Message-ID: <1249649925-11996-9-git-send-email-dbaryshkov@gmail.com>
References: <1249649925-11996-1-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-2-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-3-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-4-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-5-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-6-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-7-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-8-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1249649925-11996-8-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/af_ieee802154.h |    5 +++
 net/ieee802154/dgram.c      |   58 ++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 59 insertions(+), 4 deletions(-)

diff --git a/include/net/af_ieee802154.h b/include/net/af_ieee802154.h
index e9c70ea..75e64c7 100644
--- a/include/net/af_ieee802154.h
+++ b/include/net/af_ieee802154.h
@@ -54,4 +54,9 @@ struct sockaddr_ieee802154 {
 	struct ieee802154_addr addr;
 };
 
+/* get/setsockopt */
+#define SOL_IEEE802154	0
+
+#define WPAN_WANTACK	0
+
 #endif
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 25018a9..77ae685 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -44,6 +44,7 @@ struct dgram_sock {
 	struct ieee802154_addr dst_addr;
 
 	unsigned bound:1;
+	unsigned want_ack:1;
 };
 
 static inline struct dgram_sock *dgram_sk(const struct sock *sk)
@@ -51,7 +52,6 @@ static inline struct dgram_sock *dgram_sk(const struct sock *sk)
 	return container_of(sk, struct dgram_sock, sk);
 }
 
-
 static void dgram_hash(struct sock *sk)
 {
 	write_lock_bh(&dgram_lock);
@@ -74,6 +74,7 @@ static int dgram_init(struct sock *sk)
 
 	ro->dst_addr.addr_type = IEEE802154_ADDR_LONG;
 	ro->dst_addr.pan_id = 0xffff;
+	ro->want_ack = 1;
 	memset(&ro->dst_addr.hwaddr, 0xff, sizeof(ro->dst_addr.hwaddr));
 	return 0;
 }
@@ -237,7 +238,10 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 	skb_reset_network_header(skb);
 
-	mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA | MAC_CB_FLAG_ACKREQ;
+	mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
+	if (ro->want_ack)
+		mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
+
 	mac_cb(skb)->seq = ieee802154_mlme_ops(dev)->get_dsn(dev);
 	err = dev_hard_header(skb, dev, ETH_P_IEEE802154, &ro->dst_addr,
 			ro->bound ? &ro->src_addr : NULL, size);
@@ -382,13 +386,59 @@ int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb)
 static int dgram_getsockopt(struct sock *sk, int level, int optname,
 		    char __user *optval, int __user *optlen)
 {
-	return -EOPNOTSUPP;
+	struct dgram_sock *ro = dgram_sk(sk);
+
+	int val, len;
+
+	if (level != SOL_IEEE802154)
+		return -EOPNOTSUPP;
+
+	if (get_user(len, optlen))
+		return -EFAULT;
+
+	len = min_t(unsigned int, len, sizeof(int));
+
+	switch (optname) {
+	case WPAN_WANTACK:
+		val = ro->want_ack;
+		break;
+	default:
+		return -ENOPROTOOPT;
+	}
+
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, &val, len))
+		return -EFAULT;
+	return 0;
 }
 
 static int dgram_setsockopt(struct sock *sk, int level, int optname,
 		    char __user *optval, int __user optlen)
 {
-	return -EOPNOTSUPP;
+	struct dgram_sock *ro = dgram_sk(sk);
+	int val;
+	int err = 0;
+
+	if (optlen < sizeof(int))
+		return -EINVAL;
+
+	if (get_user(val, (int __user *)optval))
+		return -EFAULT;
+
+	lock_sock(sk);
+
+	switch (optname) {
+	case WPAN_WANTACK:
+		ro->want_ack = !!val;
+		break;
+	default:
+		err = -ENOPROTOOPT;
+		break;
+	}
+
+	release_sock(sk);
+	return err;
 }
 
 struct proto ieee802154_dgram_prot = {
-- 
1.6.3.3


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
