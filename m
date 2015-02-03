From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 16/18] vhost: don't bother with copying iovec in
 handle_tx()
Date: Tue, 3 Feb 2015 11:14:27 +0200
Message-ID: <20150203091427.GE2830@redhat.com>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
 <1422863977-17668-16-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1422863977-17668-16-git-send-email-viro@ZenIV.linux.org.uk>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 02, 2015 at 07:59:35AM +0000, Al Viro wrote:
> From: Al Viro <viro@zeniv.linux.org.uk>
> 
> just advance the msg.msg_iter and be done with that.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: kvm@vger.kernel.org
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Nice.

Acked-by: Michael S. Tsirkin <mst@redhat.com>

But, can you pls copy virtualization@lists.linux-foundation.org ?
I think some guys working on virtio might only hang out there.


> ---
>  drivers/vhost/net.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 6906f76..d86cc9b 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -336,7 +336,7 @@ static void handle_tx(struct vhost_net *net)
>  {
>  	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
>  	struct vhost_virtqueue *vq = &nvq->vq;
> -	unsigned out, in, s;
> +	unsigned out, in;
>  	int head;
>  	struct msghdr msg = {
>  		.msg_name = NULL,
> @@ -395,16 +395,17 @@ static void handle_tx(struct vhost_net *net)
>  			break;
>  		}
>  		/* Skip header. TODO: support TSO. */
> -		s = move_iovec_hdr(vq->iov, nvq->hdr, hdr_size, out);
>  		len = iov_length(vq->iov, out);
>  		iov_iter_init(&msg.msg_iter, WRITE, vq->iov, out, len);
> +		iov_iter_advance(&msg.msg_iter, hdr_size);
>  		/* Sanity check */
> -		if (!len) {
> +		if (!iov_iter_count(&msg.msg_iter)) {
>  			vq_err(vq, "Unexpected header len for TX: "
>  			       "%zd expected %zd\n",
> -			       iov_length(nvq->hdr, s), hdr_size);
> +			       len, hdr_size);
>  			break;
>  		}
> +		len = iov_iter_count(&msg.msg_iter);
>  
>  		zcopy_used = zcopy && len >= VHOST_GOODCOPY_LEN
>  				   && (nvq->upend_idx + 1) % UIO_MAXIOV !=
> -- 
> 2.1.4
