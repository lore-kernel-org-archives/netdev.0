From: Romain Francoise <romain@orebokech.com>
Subject: Re: [PULL] vhost: infrastructure changes for 3.16
Date: Thu, 12 Jun 2014 10:42:34 +0200
Message-ID: <87mwdiwmbp.fsf@kima.orebokech.com>
References: <20140611134447.GA8208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-scsi@vger.kernel.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Al Viro <viro@zeniv.linux.org.uk>, nab@daterainc.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140611134447.GA8208@redhat.com> (Michael S. Tsirkin's message
	of "Wed, 11 Jun 2014 16:44:47 +0300")
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

"Michael S. Tsirkin" <mst@redhat.com> writes:

> Memory allocation for vhost-net now supports fallback on vmalloc (same
> as for vhost-scsi) this makes it possible to create the device on
> systems where memory is very fragmented, with slightly lower
> performance.

Thanks Michael, I'm glad to see that this change made its way into
mainline after all! Would you be willing to take the following on top?


From: Romain Francoise <romain@orebokech.com>
Date: Thu, 12 Jun 2014 10:26:40 +0200
Subject: [PATCH] vhost-net: don't open-code kvfree

Commit 23cc5a991c ("vhost-net: extend device allocation to vmalloc")
added another open-coded version of kvfree (which is available since
v3.15-rc5), nuke it.

Signed-off-by: Romain Francoise <romain@orebokech.com>
---
 drivers/vhost/net.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 971a760..8dae2f7 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -700,14 +700,6 @@ static void handle_rx_net(struct vhost_work *work)
 	handle_rx(net);
 }
 
-static void vhost_net_free(void *addr)
-{
-	if (is_vmalloc_addr(addr))
-		vfree(addr);
-	else
-		kfree(addr);
-}
-
 static int vhost_net_open(struct inode *inode, struct file *f)
 {
 	struct vhost_net *n;
@@ -723,7 +715,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	}
 	vqs = kmalloc(VHOST_NET_VQ_MAX * sizeof(*vqs), GFP_KERNEL);
 	if (!vqs) {
-		vhost_net_free(n);
+		kvfree(n);
 		return -ENOMEM;
 	}
 
@@ -840,7 +832,7 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 	 * since jobs can re-queue themselves. */
 	vhost_net_flush(n);
 	kfree(n->dev.vqs);
-	vhost_net_free(n);
+	kvfree(n);
 	return 0;
 }
 
-- 
2.0.0
