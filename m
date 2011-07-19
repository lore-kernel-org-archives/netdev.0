From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH] vhost: clean up outstanding buffers before setting vring
Date: Tue, 19 Jul 2011 11:02:26 -0700
Message-ID: <1311098546.8573.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com
To: David Miller <davem@davemloft.net>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:55931 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab1GSSCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 14:02:50 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6JHm2Da030138
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 11:48:02 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p6JI2iZq122010
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 12:02:45 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6JI2aIk018827
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 12:02:38 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The outstanding DMA buffers need to be clean up before setting vring in
vhost. Otherwise the vring would be out of sync.

Signed-off-by: Shirley Ma<xma@us.ibm.com>
---

 drivers/vhost/vhost.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c14c42b..d6315b4 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -445,8 +445,10 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 			vhost_poll_flush(&dev->vqs[i].poll);
 		}
 		/* Wait for all lower device DMAs done. */
-		if (dev->vqs[i].ubufs)
+		if (dev->vqs[i].ubufs) {
 			vhost_ubuf_put_and_wait(dev->vqs[i].ubufs);
+			kfree(dev->vqs[i].ubufs);
+		}
 
 		/* Signal guest as appropriate. */
 		vhost_zerocopy_signal_used(&dev->vqs[i]);
@@ -651,6 +653,12 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 	vq = d->vqs + idx;
 
 	mutex_lock(&vq->mutex);
+	/* Wait for all lower device DMAs done. */
+	if (vq->ubufs)
+		vhost_ubuf_put_and_wait(vq->ubufs);
+
+	/* Signal guest as appropriate. */
+	vhost_zerocopy_signal_used(vq);
 
 	switch (ioctl) {
 	case VHOST_SET_VRING_NUM:
@@ -1592,7 +1600,6 @@ void vhost_ubuf_put_and_wait(struct vhost_ubuf_ref *ubufs)
 {
 	kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
 	wait_event(ubufs->wait, !atomic_read(&ubufs->kref.refcount));
-	kfree(ubufs);
 }
 
 void vhost_zerocopy_callback(void *arg)




