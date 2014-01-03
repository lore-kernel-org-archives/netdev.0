From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH net-next 3/4] veth: backup classid befor switch net_ns
Date: Fri, 3 Jan 2014 11:11:14 +0800
Message-ID: <52C62A52.8050003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, honkiko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org


dev_forward_skb will clear skb->sk, so we need save classid
before that, otherwise the skb can not be under control by
net_cls.

Signed-off-by: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/veth.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 2ec2041..ce43a2d 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -18,6 +18,7 @@
 #include <net/xfrm.h>
 #include <linux/veth.h>
 #include <linux/module.h>
+#include <net/cls_cgroup.h>

 #define DRV_NAME	"veth"
 #define DRV_VERSION	"1.0"
@@ -123,6 +124,12 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	    rcv->features & NETIF_F_RXCSUM)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;

+	/**
+	 * dev_forward_sbk will clear skb->sk, so save
+	 * skb->sk->sk_classid for Qos
+	 */
+	bk_cls_classid(skb);
+
 	if (likely(dev_forward_skb(rcv, skb) == NET_RX_SUCCESS)) {
 		struct pcpu_vstats *stats = this_cpu_ptr(dev->vstats);

-- 
1.8.2.2
