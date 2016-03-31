From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 6/6] vhost_net: net device rx busy polling support
Date: Thu, 31 Mar 2016 13:50:39 +0800
Message-ID: <1459403439-6011-7-git-send-email-jasowang@redhat.com>
References: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch let vhost_net try rx busy polling of underlying net device
when busy polling is enabled. Test shows some improvement on TCP_RR:

smp=1 queue=1
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
    1/     1/   +4%/   +3%/   +3%/   +3%/  +22%
    1/    50/   +2%/   +2%/   +2%/   +2%/    0%
    1/   100/   +1%/    0%/   +1%/   +1%/   -1%
    1/   200/   +2%/   +1%/   +2%/   +2%/    0%
   64/     1/   +1%/   +3%/   +1%/   +1%/   +1%
   64/    50/    0%/    0%/    0%/    0%/   -1%
   64/   100/   +1%/    0%/   +1%/   +1%/    0%
   64/   200/    0%/    0%/   +2%/   +2%/    0%
  256/     1/   +2%/   +2%/   +2%/   +2%/   +2%
  256/    50/   +3%/   +3%/   +3%/   +3%/    0%
  256/   100/   +1%/   +1%/   +2%/   +2%/    0%
  256/   200/    0%/    0%/   +1%/   +1%/   +1%
 1024/     1/   +2%/   +2%/   +2%/   +2%/   +2%
 1024/    50/   -1%/   -1%/   -1%/   -1%/   -2%
 1024/   100/   +1%/   +1%/    0%/    0%/   -1%
 1024/   200/   +2%/   +1%/   +2%/   +2%/    0%

smp=8 queue=1
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
    1/     1/   +1%/   -5%/   +1%/   +1%/    0%
    1/    50/   +1%/    0%/   +1%/   +1%/   -1%
    1/   100/   -1%/   -1%/   -2%/   -2%/   -4%
    1/   200/    0%/    0%/    0%/    0%/   -1%
   64/     1/   -2%/  -10%/   -2%/   -2%/   -2%
   64/    50/   -1%/   -1%/   -1%/   -1%/   -2%
   64/   100/   -1%/    0%/    0%/    0%/   -1%
   64/   200/   -1%/   -1%/    0%/    0%/    0%
  256/     1/   +7%/  +25%/   +7%/   +7%/   +7%
  256/    50/   +2%/   +2%/   +2%/   +2%/   -1%
  256/   100/   -1%/   -1%/   -1%/   -1%/   -3%
  256/   200/   +1%/    0%/    0%/    0%/    0%
 1024/     1/   +5%/  +15%/   +5%/   +5%/   +4%
 1024/    50/    0%/    0%/   -1%/   -1%/   -1%
 1024/   100/   -1%/   -1%/   -1%/   -1%/   -2%
 1024/   200/   -1%/    0%/   -1%/   -1%/   -1%

smp=8 queue=8
size/session/+thu%/+normalize%/+tpkts%/+rpkts%/+ioexits%/
    1/     1/   +5%/   +2%/   +5%/   +5%/    0%
    1/    50/   +2%/   +2%/   +3%/   +3%/  -20%
    1/   100/   +5%/   +5%/   +5%/   +5%/  -13%
    1/   200/   +8%/   +8%/   +6%/   +6%/  -12%
   64/     1/    0%/   +4%/    0%/    0%/  +18%
   64/    50/   +6%/   +5%/   +5%/   +5%/   -7%
   64/   100/   +4%/   +4%/   +5%/   +5%/  -12%
   64/   200/   +5%/   +5%/   +5%/   +5%/  -12%
  256/     1/    0%/   -3%/    0%/    0%/   +1%
  256/    50/   +3%/   +3%/   +3%/   +3%/   -2%
  256/   100/   +6%/   +5%/   +5%/   +5%/  -11%
  256/   200/   +4%/   +4%/   +4%/   +4%/  -13%
 1024/     1/    0%/   -3%/    0%/    0%/   -6%
 1024/    50/   +1%/   +1%/   +1%/   +1%/  -10%
 1024/   100/   +4%/   +4%/   +5%/   +5%/  -11%
 1024/   200/   +4%/   +5%/   +4%/   +4%/  -12%

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index f744eeb..7350f6c 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -27,6 +27,7 @@
 #include <linux/if_vlan.h>
 
 #include <net/sock.h>
+#include <net/busy_poll.h>
 
 #include "vhost.h"
 
@@ -307,15 +308,24 @@ static int vhost_net_tx_get_vq_desc(struct vhost_net *net,
 				    unsigned int *out_num, unsigned int *in_num)
 {
 	unsigned long uninitialized_var(endtime);
+	struct socket *sock = vq->private_data;
+	struct sock *sk = sock->sk;
+	struct napi_struct *napi;
 	int r = vhost_get_vq_desc(vq, vq->iov, ARRAY_SIZE(vq->iov),
 				    out_num, in_num, NULL, NULL);
 
 	if (r == vq->num && vq->busyloop_timeout) {
 		preempt_disable();
+		rcu_read_lock();
+		napi = napi_by_id(sk->sk_napi_id);
 		endtime = busy_clock() + vq->busyloop_timeout;
 		while (vhost_can_busy_poll(vq->dev, endtime) &&
-		       vhost_vq_avail_empty(vq->dev, vq))
+		       vhost_vq_avail_empty(vq->dev, vq)) {
+			if (napi)
+				sk_busy_loop_once(sk, napi);
 			cpu_relax_lowlatency();
+		}
+		rcu_read_unlock();
 		preempt_enable();
 		r = vhost_get_vq_desc(vq, vq->iov, ARRAY_SIZE(vq->iov),
 					out_num, in_num, NULL, NULL);
@@ -476,6 +486,7 @@ static int vhost_net_rx_peek_head_len(struct vhost_net *net, struct sock *sk)
 	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
 	struct vhost_virtqueue *vq = &nvq->vq;
 	unsigned long uninitialized_var(endtime);
+	struct napi_struct *napi;
 	int len = peek_head_len(sk);
 
 	if (!len && vq->busyloop_timeout) {
@@ -484,13 +495,20 @@ static int vhost_net_rx_peek_head_len(struct vhost_net *net, struct sock *sk)
 		vhost_disable_notify(&net->dev, vq);
 
 		preempt_disable();
+		rcu_read_lock();
+
+		napi = napi_by_id(sk->sk_napi_id);
 		endtime = busy_clock() + vq->busyloop_timeout;
 
 		while (vhost_can_busy_poll(&net->dev, endtime) &&
 		       skb_queue_empty(&sk->sk_receive_queue) &&
-		       vhost_vq_avail_empty(&net->dev, vq))
+		       vhost_vq_avail_empty(&net->dev, vq)) {
+			if (napi)
+				sk_busy_loop_once(sk, napi);
 			cpu_relax_lowlatency();
+		}
 
+		rcu_read_unlock();
 		preempt_enable();
 
 		if (vhost_enable_notify(&net->dev, vq))
-- 
2.5.0
