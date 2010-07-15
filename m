From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost-net: avoid flush under lock
Date: Thu, 15 Jul 2010 15:19:12 +0300
Message-ID: <20100715121912.GA7176@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Sridhar Samudrala <samudrala@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We flush under vq mutex when changing backends.
This creates a deadlock as workqueue being flushed
needs this lock as well.

https://bugzilla.redhat.com/show_bug.cgi?id=612421

Drop the vq mutex before flush: we have the device mutex
which is sufficient to prevent another ioctl from touching
the vq.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 28d7786..50df58e6 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -534,11 +534,16 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 	rcu_assign_pointer(vq->private_data, sock);
 	vhost_net_enable_vq(n, vq);
 done:
+	mutex_unlock(&vq->mutex);
+
 	if (oldsock) {
 		vhost_net_flush_vq(n, index);
 		fput(oldsock->file);
 	}
 
+	mutex_unlock(&n->dev.mutex);
+	return 0;
+
 err_vq:
 	mutex_unlock(&vq->mutex);
 err:
-- 
1.7.2.rc0.14.g41c1c
