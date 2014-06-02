From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL 2/2] vhost: replace rcu with mutex
Date: Tue, 3 Jun 2014 00:30:18 +0300
Message-ID: <1401744482-17764-3-git-send-email-mst@redhat.com>
References: <1401744482-17764-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1401744482-17764-1-git-send-email-mst@redhat.com>
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

All memory accesses are done under some VQ mutex.
So lock/unlock all VQs is a faster equivalent of synchronize_rcu()
for memory access changes.
Some guests cause a lot of these changes, so it's helpful
to make them faster.

Reported-by: "Gonglei (Arei)" <arei.gonglei@huawei.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 78987e4..1c05e60 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -593,6 +593,7 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 {
 	struct vhost_memory mem, *newmem, *oldmem;
 	unsigned long size = offsetof(struct vhost_memory, regions);
+	int i;
 
 	if (copy_from_user(&mem, m, size))
 		return -EFAULT;
@@ -619,7 +620,14 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 	oldmem = rcu_dereference_protected(d->memory,
 					   lockdep_is_held(&d->mutex));
 	rcu_assign_pointer(d->memory, newmem);
-	synchronize_rcu();
+
+	/* All memory accesses are done under some VQ mutex.
+	 * So below is a faster equivalent of synchronize_rcu()
+	 */
+	for (i = 0; i < d->nvqs; ++i) {
+		mutex_lock(&d->vqs[i]->mutex);
+		mutex_unlock(&d->vqs[i]->mutex);
+	}
 	kfree(oldmem);
 	return 0;
 }
-- 
MST
