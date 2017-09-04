From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 2/2] tun: rename generic_xdp to skb_xdp
Date: Mon,  4 Sep 2017 11:36:09 +0800
Message-ID: <1504496169-31190-2-git-send-email-jasowang@redhat.com>
References: <1504496169-31190-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504496169-31190-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename "generic_xdp" to "skb_xdp" to avoid confusing it with the
generic XDP which will be done at netif_receive_skb().

Cc: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 80ac18f..3c9985f 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1267,7 +1267,7 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 				     struct tun_file *tfile,
 				     struct iov_iter *from,
 				     struct virtio_net_hdr *hdr,
-				     int len, int *generic_xdp)
+				     int len, int *skb_xdp)
 {
 	struct page_frag *alloc_frag = &current->task_frag;
 	struct sk_buff *skb;
@@ -1301,13 +1301,13 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 	 * we do XDP on skb in case the headroom is not enough.
 	 */
 	if (hdr->gso_type || !xdp_prog)
-		*generic_xdp = 1;
+		*skb_xdp = 1;
 	else
-		*generic_xdp = 0;
+		*skb_xdp = 0;
 
 	rcu_read_lock();
 	xdp_prog = rcu_dereference(tun->xdp_prog);
-	if (xdp_prog && !*generic_xdp) {
+	if (xdp_prog && !*skb_xdp) {
 		struct xdp_buff xdp;
 		void *orig_data;
 		u32 act;
@@ -1389,7 +1389,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	bool zerocopy = false;
 	int err;
 	u32 rxhash;
-	int generic_xdp = 1;
+	int skb_xdp = 1;
 
 	if (!(tun->dev->flags & IFF_UP))
 		return -EIO;
@@ -1448,7 +1448,11 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	}
 
 	if (tun_can_build_skb(tun, tfile, len, noblock, zerocopy)) {
-		skb = tun_build_skb(tun, tfile, from, &gso, len, &generic_xdp);
+		/* For the packet that is not easy to be processed
+		 * (e.g gso or jumbo packet), we will do it at after
+		 * skb was created with generic XDP routine.
+		 */
+		skb = tun_build_skb(tun, tfile, from, &gso, len, &skb_xdp);
 		if (IS_ERR(skb)) {
 			this_cpu_inc(tun->pcpu_stats->rx_dropped);
 			return PTR_ERR(skb);
@@ -1528,7 +1532,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	skb_reset_network_header(skb);
 	skb_probe_transport_header(skb, 0);
 
-	if (generic_xdp) {
+	if (skb_xdp) {
 		struct bpf_prog *xdp_prog;
 		int ret;
 
-- 
2.7.4
