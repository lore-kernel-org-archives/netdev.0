From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] virtio_net: fix refill related races
Date: Thu, 22 Dec 2011 14:23:26 +1030
Message-ID: <87d3bhjm89.fsf@rustcorp.com.au>
References: <20111211144428.GB14381@redhat.com>
	<878vmioh10.fsf@rustcorp.com.au> <20111212115405.GB7946@redhat.com>
	<87iplltd0g.fsf@rustcorp.com.au>
	<20111220190908.GC25689@redhat.com>
	<20111220190946.GD10752@google.com>
	<20111220193055.GA26392@redhat.com>
	<20111220193154.GG10752@google.com>
	<20111220194518.GB26692@redhat.com>
	<87hb0udd2h.fsf@rustcorp.com.au>
	<20111221090637.GA31592@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, Amit Shah <amit.shah@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111221090637.GA31592@redhat.com>
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

On Wed, 21 Dec 2011 11:06:37 +0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> On Wed, Dec 21, 2011 at 10:13:18AM +1030, Rusty Russell wrote:
> > On Tue, 20 Dec 2011 21:45:19 +0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > > On Tue, Dec 20, 2011 at 11:31:54AM -0800, Tejun Heo wrote:
> > > > On Tue, Dec 20, 2011 at 09:30:55PM +0200, Michael S. Tsirkin wrote:
> > > > > Hmm, in that case it looks like a nasty race could get
> > > > > triggered, with try_fill_recv run on multiple CPUs in parallel,
> > > > > corrupting the linked list within the vq.
> > > > > 
> > > > > Using the mutex as my patch did will fix that naturally, as well.
> > > > 
> > > > Don't know the code but just use nrt wq.  There's even a system one
> > > > called system_nrq_wq.
> > > > 
> > > > Thanks.
> > > 
> > > We can, but we need the mutex for other reasons, anyway.
> > 
> > Well, here's the alternate approach.  What do you think?
> 
> It looks very clean, thanks. Some documentation suggestions below.
> Also - Cc stable on this and the block patch?

AFAICT we haven't seen this bug, and theoretical bugs don't get into
-stable.

> > Finding two wq issues makes you justifiably cautious, but it almost
> > feels like giving up to simply wrap it in a lock.  The APIs are designed
> > to let us do it without a lock; I was just using them wrong.
> 
> One thing I note is that this scheme works because there's a single
> entity disabling/enabling napi and the refill thread.
> So it's possible that Amit will need to add a lock and track NAPI
> state anyway to make suspend work. But we'll see.

Fixed typo, documented the locking, queued for -next.

Thanks!
Rusty.

From: Rusty Russell <rusty@rustcorp.com.au>
Subject: virtio_net: set/cancel work on ndo_open/ndo_stop

Michael S. Tsirkin noticed that we could run the refill work after
ndo_close, which can re-enable napi - we don't disable it until
virtnet_remove.  This is clearly wrong, so move the workqueue control
to ndo_open and ndo_stop (aka. virtnet_open and virtnet_close).

One subtle point: virtnet_probe() could simply fail if it couldn't
allocate a receive buffer, but that's less polite in virtnet_open() so
we schedule a refill as we do in the normal receive path if we run out
of memory.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -439,7 +439,13 @@ static int add_recvbuf_mergeable(struct 
 	return err;
 }
 
-/* Returns false if we couldn't fill entirely (OOM). */
+/*
+ * Returns false if we couldn't fill entirely (OOM).
+ *
+ * Normally run in the receive path, but can also be run from ndo_open
+ * before we're receiving packets, or from refill_work which is
+ * careful to disable receiving (using napi_disable).
+ */
 static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 {
 	int err;
@@ -719,6 +725,10 @@ static int virtnet_open(struct net_devic
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
+	/* Make sure we have some buffers: if oom use wq. */
+	if (!try_fill_recv(vi, GFP_KERNEL))
+		schedule_delayed_work(&vi->refill, 0);
+
 	virtnet_napi_enable(vi);
 	return 0;
 }
@@ -772,6 +782,8 @@ static int virtnet_close(struct net_devi
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
+	/* Make sure refill_work doesn't re-enable napi! */
+	cancel_delayed_work_sync(&vi->refill);
 	napi_disable(&vi->napi);
 
 	return 0;
@@ -1082,7 +1094,6 @@ static int virtnet_probe(struct virtio_d
 
 unregister:
 	unregister_netdev(dev);
-	cancel_delayed_work_sync(&vi->refill);
 free_vqs:
 	vdev->config->del_vqs(vdev);
 free_stats:
@@ -1121,9 +1132,7 @@ static void __devexit virtnet_remove(str
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
 
-
 	unregister_netdev(vi->dev);
-	cancel_delayed_work_sync(&vi->refill);
 
 	/* Free unused buffers in both send and recv, if any. */
 	free_unused_bufs(vi);
