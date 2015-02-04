From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 16/18] vhost: don't bother with copying iovec in
	handle_tx()
Date: Wed, 4 Feb 2015 10:13:52 +0100
Message-ID: <20150204091352.GF9920@redhat.com>
References: <20150204063730.GG29656@ZenIV.linux.org.uk>
	<1423032009-18367-16-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1423032009-18367-16-git-send-email-viro@ZenIV.linux.org.uk>
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

On Wed, Feb 04, 2015 at 06:40:07AM +0000, Al Viro wrote:
> From: Al Viro <viro@zeniv.linux.org.uk>
> 
> just advance the msg.msg_iter and be done with that.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: kvm@vger.kernel.org
> Cc: virtualization@lists.linux-foundation.org
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

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
