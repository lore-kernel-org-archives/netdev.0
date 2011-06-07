From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2 RFC 4/4] Revert "virtio: make add_buf return
 capacity remaining:
Date: Tue, 7 Jun 2011 18:54:57 +0300
Message-ID: <20110607155457.GA17436@redhat.com>
References: <cover.1307029008.git.mst@redhat.com>
	<7572d6fb81181e349af4a8b203ea0977f6e91ae1.1307029009.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7572d6fb81181e349af4a8b203ea0977f6e91ae1.1307029009.git.mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 02, 2011 at 06:43:25PM +0300, Michael S. Tsirkin wrote:
> This reverts commit 3c1b27d5043086a485f8526353ae9fe37bfa1065.
> The only user was virtio_net, and it switched to
> min_capacity instead.
> 
> Signed-off-by: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

It turns out another place in virtio_net: receive
buf processing - relies on the old behaviour:

try_fill_recv:
	do {
		if (vi->mergeable_rx_bufs)
			err = add_recvbuf_mergeable(vi, gfp);
		else if (vi->big_packets)
			err = add_recvbuf_big(vi, gfp);
		else
			err = add_recvbuf_small(vi, gfp);

		oom = err == -ENOMEM;
		if (err < 0)
			break;
		++vi->num;
	} while (err > 0);

The point is to avoid allocating a buf if
the ring is out of space and we are sure
add_buf will fail.

It works well for mergeable buffers and for big
packets if we are not OOM. small packets and
oom will do extra get_page/put_page calls
(but maybe we don't care).

So this is RX, I intend to drop it from this patchset and focus on the
TX side for starters.

> ---
>  drivers/virtio/virtio_ring.c |    2 +-
>  include/linux/virtio.h       |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> index 23422f1..a6c21eb 100644
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -233,7 +233,7 @@ add_head:
>  	pr_debug("Added buffer head %i to %p\n", head, vq);
>  	END_USE(vq);
>  
> -	return vq->num_free;
> +	return 0;
>  }
>  EXPORT_SYMBOL_GPL(virtqueue_add_buf_gfp);
>  
> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
> index 209220d..63c4908 100644
> --- a/include/linux/virtio.h
> +++ b/include/linux/virtio.h
> @@ -34,7 +34,7 @@ struct virtqueue {
>   *	in_num: the number of sg which are writable (after readable ones)
>   *	data: the token identifying the buffer.
>   *	gfp: how to do memory allocations (if necessary).
> - *      Returns remaining capacity of queue (sg segments) or a negative error.
> + *      Returns 0 on success or a negative error.
>   * virtqueue_kick: update after add_buf
>   *	vq: the struct virtqueue
>   *	After one or more add_buf calls, invoke this to kick the other side.
> -- 
> 1.7.5.53.gc233e
