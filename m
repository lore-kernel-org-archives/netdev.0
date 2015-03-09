From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] 9p/trans_virtio: fix hot-unplug
Date: Mon, 9 Mar 2015 15:48:14 +0100
Message-ID: <20150309154814-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Van Hensbergen <ericvh@gmail.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	v9fs-developer@lists.sourceforge.net, Ron Minnich <rminnich@sandia.gov>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

On device hot-unplug, 9p/virtio currently will kfree channel while
it might still be in use.

Of course, it might stay used forever, so it's an extremely ugly hack,
but it seems better than use-after-free that we have now.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/9p/trans_virtio.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index d8e376a..d1b2f306 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -658,14 +658,31 @@ p9_virtio_create(struct p9_client *client, const char *devname, char *args)
 static void p9_virtio_remove(struct virtio_device *vdev)
 {
 	struct virtio_chan *chan = vdev->priv;
-
-	if (chan->inuse)
-		p9_virtio_close(chan->client);
-	vdev->config->del_vqs(vdev);
+	unsigned long warning_time;
+	bool inuse;
 
 	mutex_lock(&virtio_9p_lock);
+
+	/* Remove self from list so we don't get new users. */
 	list_del(&chan->chan_list);
+	warning_time = jiffies;
+
+	/* Wait for existing users to close. */
+	while (chan->inuse) {
+		mutex_unlock(&virtio_9p_lock);
+		msleep(250);
+               if (time_after(jiffies, warning_time + 10 * HZ)) {
+			dev_emerg(&vdev->dev, "p9_virtio_remove: "
+				  "waiting for device in use.\n");
+			warning_time = jiffies;
+               }
+		mutex_lock(&virtio_9p_lock);
+	}
+
 	mutex_unlock(&virtio_9p_lock);
+
+	vdev->config->del_vqs(vdev);
+
 	sysfs_remove_file(&(vdev->dev.kobj), &dev_attr_mount_tag.attr);
 	kobject_uevent(&(vdev->dev.kobj), KOBJ_CHANGE);
 	kfree(chan->tag);
-- 
MST
