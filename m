From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH net-next 2/8] netlink: Avoid netlink mmap alloc if
	msg size exceeds frame size
Date: Fri, 22 Nov 2013 17:56:05 +0100
Message-ID: <21435b02616aca6f1442d343e53b69abc2d88b4d.1385137618.git.tgraf@suug.ch>
References: <cover.1385137618.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, fleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <cover.1385137618.git.tgraf-G/eBtMaohhA@public.gmane.org>
In-Reply-To: <cover.1385137618.git.tgraf-G/eBtMaohhA@public.gmane.org>
References: <cover.1385137618.git.tgraf-G/eBtMaohhA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

An insufficent ring frame size configuration can lead to an
unnecessary skb allocation for every Netlink message. Check frame
size before taking the queue lock and allocating the skb and
re-check with lock to be safe.

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Reviewed-by: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 net/netlink/af_netlink.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index bca50b9..6433489 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1769,6 +1769,9 @@ struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
 	if (ring->pg_vec == NULL)
 		goto out_put;
 
+	if (ring->frame_size - NL_MMAP_HDRLEN < size)
+		goto out_put;
+
 	skb = alloc_skb_head(gfp_mask);
 	if (skb == NULL)
 		goto err1;
@@ -1778,6 +1781,7 @@ struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
 	if (ring->pg_vec == NULL)
 		goto out_free;
 
+	/* check again under lock */
 	maxlen = ring->frame_size - NL_MMAP_HDRLEN;
 	if (maxlen < size)
 		goto out_free;
-- 
1.8.3.1
