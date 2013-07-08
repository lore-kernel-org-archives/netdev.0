From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] virtio_net: fix race in RX VQ processing
Date: Mon, 8 Jul 2013 16:08:54 +0300
Message-ID: <20130708130854.GA25442@redhat.com>
References: <1373274069-4301-1-git-send-email-mst@redhat.com>
	<1373274069-4301-3-git-send-email-mst@redhat.com>
	<51DAB60A.5080305@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <51DAB60A.5080305@cogentembedded.com>
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

On Mon, Jul 08, 2013 at 04:52:26PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 08-07-2013 13:04, Michael S. Tsirkin wrote:
> 
> >virtio net called virtqueue_enable_cq on RX path after napi_complete, so
> >with NAPI_STATE_SCHED clear - outside the implicit napi lock.
> >This violates the requirement to synchronize virtqueue_enable_cq wrt
> >virtqueue_add_buf.  In particular, used event can move backwards,
> >causing us to lose interrupts.
> >In a debug build, this can trigger panic within START_USE.
> 
> >Jason Wang reports that he can trigger the races artificially,
> >by adding udelay() in virtqueue_enable_cb() after virtio_mb().
> 
> >However, we must call napi_complete to clear NAPI_STATE_SCHED before
> >polling the virtqueue for used buffers, otherwise napi_schedule_prep in
> >a callback will fail, causing us to lose RX events.
> 
> >To fix, call virtqueue_enable_cb_prepare with NAPI_STATE_SCHED
> >set (under napi lock), later call virtqueue_poll with
> >NAPI_STATE_SCHED clear (outside the lock).
> 
> >Reported-by: Jason Wang <jasowang@redhat.com>
> >Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >---
> >  drivers/net/virtio_net.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> >diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> >index 5305bd1..fbdd79a 100644
> >--- a/drivers/net/virtio_net.c
> >+++ b/drivers/net/virtio_net.c
> >@@ -622,8 +622,9 @@ again:
> >
> >  	/* Out of packets? */
> >  	if (received < budget) {
> >+		unsigned r = virtqueue_enable_cb_prepare(rq->vq);
> 
>    Empty line wouldn't hurt here, after declaration.
> 
> WBR, Sergei

I don't like an empty line here - it breaks _prepare
away from _poll which is in the same logical code block.

Is there some rule that says we must have empty
lines after declarations? If yes I'd rather split
initialization away from declaration, though that's
more verbose than it needs to be.

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fbdd79a..edcffc6 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -622,7 +622,9 @@ again:
 
 	/* Out of packets? */
 	if (received < budget) {
-		unsigned r = virtqueue_enable_cb_prepare(rq->vq);
+		unsigned r;
+
+		r = virtqueue_enable_cb_prepare(rq->vq);
 		napi_complete(napi);
 		if (unlikely(virtqueue_poll(rq->vq, r)) &&
 		    napi_schedule_prep(napi)) {
