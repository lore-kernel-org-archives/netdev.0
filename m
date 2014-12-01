From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH v7 31/46] vhost: virtio 1.0 endian-ness support
Date: Mon, 1 Dec 2014 13:33:53 +0100
Message-ID: <20141201133353.0bbaa2e1.cornelia.huck@de.ibm.com>
References: <1417359787-10138-1-git-send-email-mst@redhat.com>
	<1417359787-10138-32-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, kvm@vger.kernel.org, rusty@au1.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1417359787-10138-32-git-send-email-mst@redhat.com>
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

On Sun, 30 Nov 2014 17:11:49 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/vhost/vhost.c | 93 +++++++++++++++++++++++++++++++--------------------
>  1 file changed, 56 insertions(+), 37 deletions(-)
> 

> @@ -1113,18 +1120,19 @@ static int get_indirect(struct vhost_virtqueue *vq,
>  {
>  	struct vring_desc desc;
>  	unsigned int i = 0, count, found = 0;
> +	u32 len = vhost32_to_cpu(vq, indirect->len);
>  	int ret;
> 
>  	/* Sanity check */
> -	if (unlikely(indirect->len % sizeof desc)) {
> +	if (unlikely(len % sizeof desc)) {
>  		vq_err(vq, "Invalid length in indirect descriptor: "
>  		       "len 0x%llx not multiple of 0x%zx\n",
> -		       (unsigned long long)indirect->len,
> +		       (unsigned long long)vhost32_to_cpu(vq, indirect->len),

Can't you use len here?

>  		       sizeof desc);
>  		return -EINVAL;
>  	}
> 
> -	ret = translate_desc(vq, indirect->addr, indirect->len, vq->indirect,
> +	ret = translate_desc(vq, vhost64_to_cpu(vq, indirect->addr), len, vq->indirect,
>  			     UIO_MAXIOV);
>  	if (unlikely(ret < 0)) {
>  		vq_err(vq, "Translation failure %d in indirect.\n", ret);


> @@ -1404,7 +1422,7 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
> 
>  	/* Make sure buffer is written before we update index. */
>  	smp_wmb();
> -	if (put_user(vq->last_used_idx, &vq->used->idx)) {
> +	if (__put_user(cpu_to_vhost16(vq, vq->last_used_idx), &vq->used->idx)) {

Why s/put_user/__put_user/ - I don't see how endianness conversions
should have an influence there?

>  		vq_err(vq, "Failed to increment used idx");
>  		return -EFAULT;
>  	}

> @@ -1449,11 +1468,11 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  	if (unlikely(!v))
>  		return true;
> 
> -	if (get_user(event, vhost_used_event(vq))) {
> +	if (__get_user(event, vhost_used_event(vq))) {

Dito: why the change?

>  		vq_err(vq, "Failed to get used event idx");
>  		return true;
>  	}
> -	return vring_need_event(event, new, old);
> +	return vring_need_event(vhost16_to_cpu(vq, event), new, old);
>  }
> 
>  /* This actually signals the guest, using eventfd. */
