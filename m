From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: [PATCH 1/2] virtio: fix net driver loop case where we fail
	to restart
Date: Mon, 19 Nov 2007 11:20:15 +1100
Message-ID: <200711191120.15596.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lguest <lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

skb is only NULL the first time around: it's more correct to test for
being under-budget.

Signed-off-by: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>

diff -r 2a94425ac7d5 drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Thu Nov 15 13:47:28 2007 +1100
+++ b/drivers/net/virtio_net.c	Thu Nov 15 23:10:44 2007 +1100
@@ -198,8 +198,8 @@ again:
 	if (vi->num < vi->max / 2)
 		try_fill_recv(vi);
 
-	/* All done? */
-	if (!skb) {
+	/* Out of packets? */
+	if (received < budget) {
 		netif_rx_complete(vi->dev, napi);
 		if (unlikely(!vi->rvq->vq_ops->restart(vi->rvq))
 		    && netif_rx_reschedule(vi->dev, napi))
