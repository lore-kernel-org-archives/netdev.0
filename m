From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V4 5/6] net: introduce NETDEV_CHANGE_TX_QUEUE_LEN
Date: Thu, 30 Jun 2016 14:45:35 +0800
Message-ID: <1467269136-8082-6-git-send-email-jasowang@redhat.com>
References: <1467269136-8082-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, eric.dumazet@gmail.com,
	virtualization@lists.linux-foundation.org,
	John Fastabend <john.r.fastabend@intel.com>, brouer@redhat.com
To: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1467269136-8082-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This patch introduces a new event - NETDEV_CHANGE_TX_QUEUE_LEN, this
will be triggered when tx_queue_len. It could be used by net device
who want to do some processing at that time. An example is tun who may
want to resize tx array when tx_queue_len is changed.

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/netdevice.h |  1 +
 net/core/net-sysfs.c      | 15 ++++++++++++++-
 net/core/rtnetlink.c      | 16 ++++++++++++----
 3 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e84d9d2..7dc2ec7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2237,6 +2237,7 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_PRECHANGEUPPER	0x001A
 #define NETDEV_CHANGELOWERSTATE	0x001B
 #define NETDEV_UDP_TUNNEL_PUSH_INFO	0x001C
+#define NETDEV_CHANGE_TX_QUEUE_LEN	0x001E
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 7a0b616..6e4f347 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -322,7 +322,20 @@ NETDEVICE_SHOW_RW(flags, fmt_hex);
 
 static int change_tx_queue_len(struct net_device *dev, unsigned long new_len)
 {
-	dev->tx_queue_len = new_len;
+	int res, orig_len = dev->tx_queue_len;
+
+	if (new_len != orig_len) {
+		dev->tx_queue_len = new_len;
+		res = call_netdevice_notifiers(NETDEV_CHANGE_TX_QUEUE_LEN, dev);
+		res = notifier_to_errno(res);
+		if (res) {
+			netdev_err(dev,
+				   "refused to change device tx_queue_len\n");
+			dev->tx_queue_len = orig_len;
+			return -EFAULT;
+		}
+	}
+
 	return 0;
 }
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index eb49ca2..b16b779 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1927,11 +1927,19 @@ static int do_setlink(const struct sk_buff *skb,
 
 	if (tb[IFLA_TXQLEN]) {
 		unsigned long value = nla_get_u32(tb[IFLA_TXQLEN]);
-
-		if (dev->tx_queue_len ^ value)
+		unsigned long orig_len = dev->tx_queue_len;
+
+		if (dev->tx_queue_len ^ value) {
+			dev->tx_queue_len = value;
+			err = call_netdevice_notifiers(
+			      NETDEV_CHANGE_TX_QUEUE_LEN, dev);
+			err = notifier_to_errno(err);
+			if (err) {
+				dev->tx_queue_len = orig_len;
+				goto errout;
+			}
 			status |= DO_SETLINK_NOTIFY;
-
-		dev->tx_queue_len = value;
+		}
 	}
 
 	if (tb[IFLA_OPERSTATE])
-- 
2.7.4
