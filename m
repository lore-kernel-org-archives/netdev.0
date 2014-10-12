From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 13/25] virtio_console: enable VQs early
Date: Sun, 12 Oct 2014 14:47:32 +0300
Message-ID: <1413114332-626-14-git-send-email-mst@redhat.com>
References: <1413114332-626-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	linux-scsi@vger.kernel.org, linux-s390@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Amit Shah <amit.shah@redhat.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752949AbaJLLof (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Oct 2014 07:44:35 -0400
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

virtio spec requires drivers to set DRIVER_OK before using VQs.
This is set automatically after probe returns, virtio console violated this
rule by adding inbufs, which causes the VQ to be used directly within
probe.

To fix, call virtio_enable_vqs_early before using VQs.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/char/virtio_console.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
index b585b47..6ebe8f6 100644
--- a/drivers/char/virtio_console.c
+++ b/drivers/char/virtio_console.c
@@ -1449,6 +1449,8 @@ static int add_port(struct ports_device *portdev, u32 id)
 	spin_lock_init(&port->outvq_lock);
 	init_waitqueue_head(&port->waitqueue);
 
+	virtio_enable_vqs_early(portdev->vdev);
+
 	/* Fill the in_vq with buffers so the host can send us data. */
 	nr_added_bufs = fill_queue(port->in_vq, &port->inbuf_lock);
 	if (!nr_added_bufs) {
-- 
MST
