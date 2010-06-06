From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: indicate oom when addbuf returns failure
Date: Sun, 6 Jun 2010 23:13:00 +0300
Message-ID: <20100606201258.GA21196@redhat.com>
References: <201006041028.56798.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.hengli.com.au>, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org, stable@kernel.org,
        Bruce Rogers <brogers@novell.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <201006041028.56798.rusty@rustcorp.com.au>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 04, 2010 at 10:28:56AM +0930, Rusty Russell wrote:
> This patch is a subset of an already upstream patch, but this portion
> is useful in earlier releases.
> 
> Please consider for the 2.6.32 and 2.6.33 stable trees.
> 
> If the add_buf operation fails, indicate failure to the caller.
> 
> Signed-off-by: Bruce Rogers <brogers@novell.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Actually this code looks strange:
Note that add_buf inicates out of memory
condition with a positive return value, and ring full
(which is not an error!) with -ENOSPC.

So it seems that this patch (and upstream code) will fill
the ring and then end up setting oom = true and rescheduling the work
forever.  And I suspect I actually saw this at some point
on one of my systems: observed BW would drop
with high CPU usage until reboot.
Can't reproduce it now anymore ..


> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> 
> @@ -318,6 +318,7 @@ static bool try_fill_recv_maxbufs(struct
>                         skb_unlink(skb, &vi->recv);
>                         trim_pages(vi, skb);
>                         kfree_skb(skb);
> +                       oom = true;
>                         break;
>                 }
>                 vi->num++;
> @@ -368,6 +369,7 @@ static bool try_fill_recv(struct virtnet
>                 if (err < 0) {
>                         skb_unlink(skb, &vi->recv);
>                         kfree_skb(skb);
> +                       oom = true;
>                         break;
>                 }
>                 vi->num++;


Possibly the right thing to do is to
1. handle ENOMEM specially
2. fix add_buf to return ENOMEM on error

Something like the below for upstream (warning: compile
tested only) and a similar one later for stable:


diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 06c30df..85615a3 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -416,7 +416,7 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
 static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 {
 	int err;
-	bool oom = false;
+	bool oom;
 
 	do {
 		if (vi->mergeable_rx_bufs)
@@ -426,10 +426,9 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 		else
 			err = add_recvbuf_small(vi, gfp);
 
-		if (err < 0) {
-			oom = true;
+		oom = err == -ENOMEM;
+		if (err < 0)
 			break;
-		}
 		++vi->num;
 	} while (err > 0);
 	if (unlikely(vi->num > vi->max))
diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index f9e6fbb..3c7f10a 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -119,7 +119,7 @@ static int vring_add_indirect(struct vring_virtqueue *vq,
 
 	desc = kmalloc((out + in) * sizeof(struct vring_desc), gfp);
 	if (!desc)
-		return vq->vring.num;
+		return -ENOMEM;
 
 	/* Transfer entries from the sg list into the indirect page */
 	for (i = 0; i < out; i++) {
