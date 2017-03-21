From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 8/8] vhost_net: use lockless peeking for skb array
	during busy polling
Date: Tue, 21 Mar 2017 12:04:47 +0800
Message-ID: <1490069087-4783-9-git-send-email-jasowang@redhat.com>
References: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
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

For the socket that exports its skb array, we can use lockless polling
to avoid touching spinlock during busy polling.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 53f09f2..41153a3 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -551,10 +551,13 @@ static int peek_head_len(struct vhost_net_virtqueue *rvq, struct sock *sk)
 	return len;
 }
 
-static int sk_has_rx_data(struct sock *sk)
+static int sk_has_rx_data(struct vhost_net_virtqueue *rvq, struct sock *sk)
 {
 	struct socket *sock = sk->sk_socket;
 
+	if (rvq->rx_array)
+		return !__skb_array_empty(rvq->rx_array);
+
 	if (sock->ops->peek_len)
 		return sock->ops->peek_len(sock);
 
@@ -579,7 +582,7 @@ static int vhost_net_rx_peek_head_len(struct vhost_net *net,
 		endtime = busy_clock() + vq->busyloop_timeout;
 
 		while (vhost_can_busy_poll(&net->dev, endtime) &&
-		       !sk_has_rx_data(sk) &&
+		       !sk_has_rx_data(rvq, sk) &&
 		       vhost_vq_avail_empty(&net->dev, vq))
 			cpu_relax();
 
-- 
2.7.4
