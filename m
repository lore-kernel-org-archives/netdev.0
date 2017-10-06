From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC 2/3] tun: expand ethtool stats with zerocopy
Date: Fri,  6 Oct 2017 18:25:15 -0400
Message-ID: <20171006222516.90654-3-willemdebruijn.kernel@gmail.com>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:44130 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752890AbdJFWZV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 18:25:21 -0400
Received: by mail-qt0-f193.google.com with SMTP id v28so25267226qtv.1
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 15:25:20 -0700 (PDT)
In-Reply-To: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add two counters to tun ethool stats to count zerocopy completions.
- tx_zerocopy counts completions that succeeded without copy.
- tx_zerocopy_err counts those that triggered a copy.

Tun intercepts completions by replacing the zerocopy completion
handler (ubuf_info) prepared by the packet source (vhost-net)
with its own.

To avoid adding another ubuf_info alloc/free in the datapath, only
enter this mode if the packet source passed an array of two ubuf_info
to the tun device.

Pass msg_controllen to tun_get_user to detect this.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/tun.c | 79 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 69 insertions(+), 10 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index df6ef9670d05..286787d8e875 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -149,6 +149,8 @@ struct tun_pcpu_stats {
 	u32 rx_dropped;
 	u32 tx_dropped;
 	u32 rx_frame_errors;
+	u64 tx_zerocopy;
+	u64 tx_zerocopy_err;
 };
 
 /* A tun_file connects an open character device to a tuntap netdevice. It
@@ -201,6 +203,8 @@ static const struct {
 	{ "tx_packets" },
 	{ "rx_bytes" },
 	{ "tx_bytes" },
+	{ "tx_zerocopy" },
+	{ "tx_zerocopy_err" },
 };
 
 /* Since the socket were moved to tun_file, to preserve the behavior of persist
@@ -1082,8 +1086,9 @@ static void tun_set_headroom(struct net_device *dev, int new_hr)
 	tun->align = new_hr;
 }
 
-static void
-tun_net_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
+static void __tun_net_get_stats64(struct net_device *dev,
+				  struct rtnl_link_stats64 *stats,
+				  u64 *ethtool_stats)
 {
 	u32 rx_dropped = 0, tx_dropped = 0, rx_frame_errors = 0;
 	struct tun_struct *tun = netdev_priv(dev);
@@ -1103,6 +1108,16 @@ tun_net_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 			txbytes		= p->tx_bytes;
 		} while (u64_stats_fetch_retry(&p->syncp, start));
 
+		if (ethtool_stats) {
+			ethtool_stats[0] += rxpackets;
+			ethtool_stats[1] += txpackets;
+			ethtool_stats[2] += rxbytes;
+			ethtool_stats[3] += txbytes;
+			ethtool_stats[4] += p->tx_zerocopy;
+			ethtool_stats[5] += p->tx_zerocopy_err;
+			continue;
+		}
+
 		stats->rx_packets	+= rxpackets;
 		stats->rx_bytes		+= rxbytes;
 		stats->tx_packets	+= txpackets;
@@ -1113,11 +1128,21 @@ tun_net_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		rx_frame_errors	+= p->rx_frame_errors;
 		tx_dropped	+= p->tx_dropped;
 	}
+
+	if (ethtool_stats)
+		return;
+
 	stats->rx_dropped  = rx_dropped;
 	stats->rx_frame_errors = rx_frame_errors;
 	stats->tx_dropped = tx_dropped;
 }
 
+static void tun_net_get_stats64(struct net_device *dev,
+				struct rtnl_link_stats64 *stats)
+{
+	__tun_net_get_stats64(dev, stats, NULL);
+}
+
 static int tun_xdp_set(struct net_device *dev, struct bpf_prog *prog,
 		       struct netlink_ext_ack *extack)
 {
@@ -1537,10 +1562,44 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 	return NULL;
 }
 
+static void tun_zerocopy_callback(struct ubuf_info *ubuf, bool success)
+{
+	struct tun_struct *tun = ubuf->ctx;
+
+	if (success)
+		this_cpu_inc(tun->pcpu_stats->tx_zerocopy);
+	else
+		this_cpu_inc(tun->pcpu_stats->tx_zerocopy_err);
+
+	ubuf = ubuf - 1;
+	ubuf->callback(ubuf, success);
+}
+
+static void tun_set_zerocopy(struct tun_struct *tun, struct sk_buff *skb,
+			     struct ubuf_info *ubuf, size_t len)
+{
+	const int ulen = sizeof(*ubuf);
+
+	if (len != ulen && len != ulen * 2) {
+		WARN_ON_ONCE(1);
+		return;
+	}
+
+	/* if caller passed two ubuf, one is for tun to interpose callback */
+	if (len == ulen * 2) {
+		ubuf = ubuf + 1;
+		ubuf->callback = tun_zerocopy_callback;
+		ubuf->ctx = tun;
+		refcount_set(&ubuf->refcnt, 1);
+	}
+
+	skb_shinfo(skb)->destructor_arg = ubuf;
+}
+
 /* Get packet from user space buffer */
 static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
-			    void *msg_control, struct iov_iter *from,
-			    int noblock, bool more)
+			    void *msg_control, size_t msg_controllen,
+			    struct iov_iter *from, int noblock, bool more)
 {
 	struct tun_pi pi = { 0, cpu_to_be16(ETH_P_IP) };
 	struct sk_buff *skb;
@@ -1713,7 +1772,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 
 	/* copy skb_ubuf_info for callback when skb has no error */
 	if (zerocopy) {
-		skb_shinfo(skb)->destructor_arg = msg_control;
+		tun_set_zerocopy(tun, skb, (void *)msg_control, msg_controllen);
 		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
 		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
 	} else if (msg_control) {
@@ -1798,7 +1857,7 @@ static ssize_t tun_chr_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	if (!tun)
 		return -EBADFD;
 
-	result = tun_get_user(tun, tfile, NULL, from,
+	result = tun_get_user(tun, tfile, NULL, 0, from,
 			      file->f_flags & O_NONBLOCK, false);
 
 	tun_put(tun);
@@ -2058,7 +2117,8 @@ static int tun_sendmsg(struct socket *sock, struct msghdr *m, size_t total_len)
 	if (!tun)
 		return -EBADFD;
 
-	ret = tun_get_user(tun, tfile, m->msg_control, &m->msg_iter,
+	ret = tun_get_user(tun, tfile, m->msg_control, m->msg_controllen,
+			   &m->msg_iter,
 			   m->msg_flags & MSG_DONTWAIT,
 			   m->msg_flags & MSG_MORE);
 	tun_put(tun);
@@ -2983,10 +3043,9 @@ static void tun_get_ethtool_stats(struct net_device *dev,
 {
 	const int ethtool_stats_bytelen =
 		ARRAY_SIZE(tun_ethtool_stats_keys) * sizeof(u64);
-	struct rtnl_link_stats64 link_stats64 = {0};
 
-	tun_net_get_stats64(dev, &link_stats64);
-	memcpy(data, &link_stats64, ethtool_stats_bytelen);
+	memset(data, 0, ethtool_stats_bytelen);
+	__tun_net_get_stats64(dev, NULL, data);
 }
 
 static const struct ethtool_ops tun_ethtool_ops = {
-- 
2.14.2.920.gcf0c67979c-goog
