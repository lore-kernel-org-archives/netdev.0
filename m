From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] vhost-net: fix use-after-free in vhost_net_flush
Date: Fri, 21 Jun 2013 14:50:09 +0800
Message-ID: <51C3F7A1.5000602@redhat.com>
References: <20130620114813.GA17373@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130620114813.GA17373@redhat.com>
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

On 06/20/2013 07:48 PM, Michael S. Tsirkin wrote:
> vhost_net_ubuf_put_and_wait has a confusing name:
> it will actually also free it's argument.
> Thus since commit 1280c27f8e29acf4af2da914e80ec27c3dbd5c01
> vhost_net_flush tries to use the argument after passing it
> to vhost_net_ubuf_put_and_wait, this results
> in use after free.
> To fix, don't free the argument in vhost_net_ubuf_put_and_wait,
> add an new API for callers that want to free ubufs.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>
> Dave, this is needed for stable as well, but
> the code has moved a bit since then.
> I'll post a patch tweaked to apply against 3.9 and 3.8 separately.
>
>  drivers/vhost/net.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 5c77d6a..534adb0 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -149,6 +149,11 @@ static void vhost_net_ubuf_put_and_wait(struct vhost_net_ubuf_ref *ubufs)
>  {
>  	kref_put(&ubufs->kref, vhost_net_zerocopy_done_signal);
>  	wait_event(ubufs->wait, !atomic_read(&ubufs->kref.refcount));
> +}
> +
> +static void vhost_net_ubuf_put_wait_and_free(struct vhost_net_ubuf_ref *ubufs)
> +{
> +	vhost_net_ubuf_put_and_wait(ubufs);
>  	kfree(ubufs);
>  }
>  
> @@ -1073,7 +1078,7 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
>  	mutex_unlock(&vq->mutex);
>  
>  	if (oldubufs) {
> -		vhost_net_ubuf_put_and_wait(oldubufs);
> +		vhost_net_ubuf_put_wait_and_free(oldubufs);
>  		mutex_lock(&vq->mutex);
>  		vhost_zerocopy_signal_used(n, vq);
>  		mutex_unlock(&vq->mutex);
> @@ -1091,7 +1096,7 @@ err_used:
>  	vq->private_data = oldsock;
>  	vhost_net_enable_vq(n, vq);
>  	if (ubufs)
> -		vhost_net_ubuf_put_and_wait(ubufs);
> +		vhost_net_ubuf_put_wait_and_free(ubufs);
>  err_ubufs:
>  	fput(sock->file);
>  err_vq:

Acked-by: Jason Wang <jasowang@redhat.com>
