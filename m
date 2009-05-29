From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: [PATCH 4/4] lguest: don't force VIRTIO_F_NOTIFY_ON_EMPTY
Date: Fri, 29 May 2009 23:46:37 +0930
Message-ID: <200905292346.38017.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

VIRTIO_F_NOTIFY_ON_EMPTY indicates to the Guest that we will hit them with
an interrupt every time the xmit queue is emptied.

Because it results in lots of tx interrupts, modern Guests probably don't
want it, so let's only force it when they accept the option.

Signed-off-by: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
---
 Documentation/lguest/lguest.c |   27 ++++++++++++++++++++++-----
 1 file changed, 22 insertions(+), 5 deletions(-)

diff --git a/Documentation/lguest/lguest.c b/Documentation/lguest/lguest.c
--- a/Documentation/lguest/lguest.c
+++ b/Documentation/lguest/lguest.c
@@ -130,6 +130,9 @@ struct device
 	/* Is it operational */
 	bool running;
 
+	/* Does Guest want an intrrupt on empty? */
+	bool irq_on_empty;
+
 	/* Device-specific data. */
 	void *priv;
 };
@@ -569,11 +572,14 @@ static void trigger_irq(struct virtqueue
 		return;
 	vq->pending_used = 0;
 
-	/* If they don't want an interrupt, don't send one, unless empty. */
-	if ((vq->vring.avail->flags & VRING_AVAIL_F_NO_INTERRUPT)
-	    && lg_last_avail(vq) != vq->vring.avail->idx) {
-		(*vq->irq_suppressed)++;
-		return;
+	/* If they don't want an interrupt, don't send one... */
+	if (vq->vring.avail->flags & VRING_AVAIL_F_NO_INTERRUPT) {
+		/* ... unless they've asked us to force one on empty. */
+		if (!vq->dev->irq_on_empty ||
+		    lg_last_avail(vq) != vq->vring.avail->idx) {
+			(*vq->irq_suppressed)++;
+			return;
+		}
 	}
 
 	/* Send the Guest an interrupt tell them we used something up. */
@@ -925,6 +930,15 @@ static void create_thread(struct virtque
 	close(vq->eventfd);
 }
 
+static bool accepted_feature(struct device *dev, unsigned int bit)
+{
+	const u8 *features = get_feature_bits(dev) + dev->feature_len;
+
+	if (dev->feature_len < bit / CHAR_BIT)
+		return false;
+	return features[bit / CHAR_BIT] & (1 << (bit % CHAR_BIT));
+}
+
 static void start_device(struct device *dev)
 {
 	unsigned int i;
@@ -938,6 +952,8 @@ static void start_device(struct device *
 		verbose(" %02x", get_feature_bits(dev)
 			[dev->feature_len+i]);
 
+	dev->irq_on_empty = accepted_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY);
+
 	for (vq = dev->vq; vq; vq = vq->next) {
 		if (vq->service)
 			create_thread(vq);
