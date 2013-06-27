From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC 4/5] VSOCK: Introduce vhost-vsock.ko
Date: Thu, 27 Jun 2013 13:42:46 +0300
Message-ID: <20130627104246.GC20215@redhat.com>
References: <1372320004-20502-1-git-send-email-asias@redhat.com>
	<1372320004-20502-5-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andy King <acking@vmware.com>, kvm@vger.kernel.org,
	Dmitry Torokhov <dtor@vmware.com>, netdev@vger.kernel.org,
	Reilly Grant <grantr@vmware.com>,
	virtualization@lists.linux-foundation.org,
	Pekka Enberg <penberg@kernel.org>, Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
To: Asias He <asias@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1372320004-20502-5-git-send-email-asias@redhat.com>
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

On Thu, Jun 27, 2013 at 04:00:03PM +0800, Asias He wrote:
> VM sockets vhost transport implementation. This module runs in host
> kernel.
> 
> Signed-off-by: Asias He <asias@redhat.com>

Has any thought been given to how this affects migration?
I don't see any API for an application to
move to a different host and reconnect to a running
vsock in guest.

I think we could merge without this, there are more
pressing issues, but it's probably a requirement
if you want this to replace e.g. serial in many
scenarious.

> ---
>  drivers/vhost/vsock.c | 534 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/vhost/vsock.h |   4 +
>  2 files changed, 538 insertions(+)
>  create mode 100644 drivers/vhost/vsock.c
>  create mode 100644 drivers/vhost/vsock.h
> 
> diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
> new file mode 100644
> index 0000000..cb54090
> --- /dev/null
> +++ b/drivers/vhost/vsock.c
> @@ -0,0 +1,534 @@
> +/*
> + * vhost transport for vsock
> + *
> + * Copyright (C) 2013 Red Hat, Inc.
> + * Author: Asias He <asias@redhat.com>
> + *
> + * This work is licensed under the terms of the GNU GPL, version 2.
> + */
> +#include <linux/miscdevice.h>
> +#include <linux/module.h>
> +#include <linux/mutex.h>
> +#include <net/sock.h>
> +#include <linux/virtio_vsock.h>
> +#include <linux/vhost.h>
> +
> +#include "../../../net/vmw_vsock/af_vsock.h"

Send patch to move this to include/linux ?

> +#include "vhost.h"
> +#include "vsock.h"
> +
> +#define VHOST_VSOCK_DEFAULT_HOST_CID	2;

Sure you want that ; there? This can result in strange code, e.g.

	int a = VHOST_VSOCK_DEFAULT_HOST_CID + 1;
	set's a to 2.

> +
> +static int vhost_transport_socket_init(struct vsock_sock *vsk,
> +				       struct vsock_sock *psk);
> +
> +enum {
> +	VHOST_VSOCK_FEATURES = VHOST_FEATURES,
> +};
> +
> +/* Used to track all the vhost_vsock instacne on the system. */

typo

> +static LIST_HEAD(vhost_vsock_list);
> +static DEFINE_MUTEX(vhost_vsock_mutex);
> +
> +struct vhost_vsock_virtqueue {
> +	struct vhost_virtqueue vq;
> +};
> +
> +struct vhost_vsock {
> +	/* Vhost device */
> +	struct vhost_dev dev;
> +	/* Vhost vsock virtqueue*/
> +	struct vhost_vsock_virtqueue vqs[VSOCK_VQ_MAX];
> +	/* Link to global vhost_vsock_list*/
> +	struct list_head list;
> +	/* Head for pkt from host to guest */
> +	struct list_head send_pkt_list;
> +	/* Work item to send pkt */
> +	struct vhost_work send_pkt_work;
> +	/* Guest contex id this vhost_vsock instance handles */
> +	u32 guest_cid;
> +};
> +
> +static u32 vhost_transport_get_local_cid(void)
> +{
> +	u32 cid = VHOST_VSOCK_DEFAULT_HOST_CID;
> +	return cid;
> +}
> +

Interesting. So all hosts in fact have the same CID?

> +static struct vhost_vsock *vhost_vsock_get(u32 guest_cid)
> +{
> +	struct vhost_vsock *vsock;
> +
> +	mutex_lock(&vhost_vsock_mutex);
> +	list_for_each_entry(vsock, &vhost_vsock_list, list) {
> +		if (vsock->guest_cid == guest_cid) {
> +			mutex_unlock(&vhost_vsock_mutex);
> +			return vsock;
> +		}
> +	}
> +	mutex_unlock(&vhost_vsock_mutex);
> +
> +	return NULL;
> +}
> +
> +static void
> +vhost_transport_do_send_pkt(struct vhost_vsock *vsock,
> +			    struct vhost_virtqueue *vq)
> +{
> +	struct virtio_vsock_pkt *pkt;
> +	unsigned out, in;
> +	struct sock *sk;
> +	int head, ret;
> +
> +	mutex_lock(&vq->mutex);
> +	vhost_disable_notify(&vsock->dev, vq);
> +	for (;;) {
> +		if (list_empty(&vsock->send_pkt_list)) {
> +			vhost_enable_notify(&vsock->dev, vq);
> +			break;
> +		}
> +
> +		head = vhost_get_vq_desc(&vsock->dev, vq, vq->iov,
> +					ARRAY_SIZE(vq->iov), &out, &in,
> +					NULL, NULL);
> +		pr_debug("%s: head = %d\n", __func__, head);
> +		if (head < 0)
> +			break;
> +
> +		if (head == vq->num) {
> +			if (unlikely(vhost_enable_notify(&vsock->dev, vq))) {
> +				vhost_disable_notify(&vsock->dev, vq);
> +				continue;
> +			}
> +			break;
> +		}
> +
> +		pkt = list_first_entry(&vsock->send_pkt_list,
> +				       struct virtio_vsock_pkt, list);
> +		list_del_init(&pkt->list);
> +
> +		/* FIXME: no assumption of frame layout */

Pls fix. memcpy_from_iovec is not harder.

> +		ret = __copy_to_user(vq->iov[0].iov_base, &pkt->hdr,
> +				     sizeof(pkt->hdr));
> +		if (ret) {
> +			virtio_transport_free_pkt(pkt);
> +			vq_err(vq, "Faulted on copying pkt hdr\n");
> +			break;
> +		}
> +		if (pkt->buf && pkt->len > 0) {
> +			ret = __copy_to_user(vq->iov[1].iov_base, pkt->buf,
> +					    pkt->len);
> +			if (ret) {
> +				virtio_transport_free_pkt(pkt);
> +				vq_err(vq, "Faulted on copying pkt buf\n");
> +				break;
> +			}
> +		}
> +
> +		vhost_add_used(vq, head, pkt->len);
> +
> +		virtio_transport_dec_tx_pkt(pkt);
> +
> +		sk = sk_vsock(pkt->trans->vsk);
> +		/* Release refcnt taken in vhost_transport_send_pkt */
> +		sock_put(sk);
> +
> +		virtio_transport_free_pkt(pkt);
> +	}
> +	vhost_signal(&vsock->dev, vq);

I think you should not signal if used was not updated.

> +	mutex_unlock(&vq->mutex);
> +}
> +
> +static void vhost_transport_send_pkt_work(struct vhost_work *work)
> +{
> +	struct vhost_virtqueue *vq;
> +	struct vhost_vsock *vsock;
> +
> +	vsock = container_of(work, struct vhost_vsock, send_pkt_work);
> +	vq = &vsock->vqs[VSOCK_VQ_RX].vq;
> +
> +	vhost_transport_do_send_pkt(vsock, vq);
> +}
> +
> +static int
> +vhost_transport_send_pkt(struct vsock_sock *vsk,
> +			 struct virtio_vsock_pkt_info *info)
> +{
> +	u32 src_cid, src_port, dst_cid, dst_port;
> +	struct virtio_transport *trans;
> +	struct virtio_vsock_pkt *pkt;
> +	struct vhost_virtqueue *vq;
> +	struct vhost_vsock *vsock;
> +	u64 credit;
> +
> +	src_cid = vhost_transport_get_local_cid();

interestingly this is the only place cid
is used. Shouldn't we validate it?

> +	src_port = vsk->local_addr.svm_port;
> +	dst_cid = vsk->remote_addr.svm_cid;
> +	dst_port = vsk->remote_addr.svm_port;
> +
> +	/* Find the vhost_vsock according to guest context id  */
> +	vsock = vhost_vsock_get(dst_cid);

Confused. There's a single socket per dst cid?

> +	if (!vsock)
> +		return -ENODEV;
> +
> +	trans = vsk->trans;
> +	vq = &vsock->vqs[VSOCK_VQ_RX].vq;
> +
> +	if (info->type == SOCK_STREAM) {
> +		credit = virtio_transport_get_credit(trans);
> +		if (info->len > credit)
> +			info->len = credit;

Is there support for non stream sockets?
Without credits, you get all kind of nasty
starvation issues.

> +	}
> +	if (info->len > VIRTIO_VSOCK_DEFAULT_RX_BUF_SIZE)
> +		info->len = VIRTIO_VSOCK_DEFAULT_RX_BUF_SIZE;
> +	/* Do not send zero length OP_RW pkt*/
> +	if (info->len == 0 && info->op == VIRTIO_VSOCK_OP_RW)
> +		return info->len;
> +
> +	pkt = virtio_transport_alloc_pkt(vsk, info, info->len,
> +					 src_cid, src_port,
> +					 dst_cid, dst_port);

We also need global limit on amount of memory per
socket. Even if remote is OK with getting 20G from us,
we might not have so much kernel memory.

> +	if (!pkt)
> +		return -ENOMEM;
> +
> +	pr_debug("%s:info->len= %d\n", __func__, info->len);
> +	/* Released in vhost_transport_do_send_pkt */
> +	sock_hold(&trans->vsk->sk);
> +	virtio_transport_inc_tx_pkt(pkt);
> +
> +	/* queue it up in vhost work */
> +	mutex_lock(&vq->mutex);
> +	list_add_tail(&pkt->list, &vsock->send_pkt_list);
> +	vhost_work_queue(&vsock->dev, &vsock->send_pkt_work);
> +	mutex_unlock(&vq->mutex);
> +
> +	return info->len;
> +}
> +
> +static struct virtio_transport_pkt_ops vhost_ops = {
> +	.send_pkt = vhost_transport_send_pkt,
> +};
> +
> +static struct virtio_vsock_pkt *
> +vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq)
> +{
> +	struct virtio_vsock_pkt *pkt;
> +	int ret;
> +	int len;
> +
> +	pkt = kzalloc(sizeof(*pkt), GFP_KERNEL);
> +	if (!pkt)
> +		return NULL;
> +
> +	len = sizeof(pkt->hdr);
> +	if (unlikely(vq->iov[0].iov_len != len)) {
> +		vq_err(vq, "Expecting pkt->hdr = %d, got %zu bytes\n",
> +		       len, vq->iov[0].iov_len);
> +		kfree(pkt);
> +		return NULL;
> +	}
> +	ret = __copy_from_user(&pkt->hdr, vq->iov[0].iov_base, len);
> +	if (ret) {
> +		vq_err(vq, "Faulted on virtio_vsock_hdr\n");
> +		kfree(pkt);
> +		return NULL;
> +	}
> +
> +	pkt->len = pkt->hdr.len;
> +	pkt->off = 0;
> +
> +	/* No payload */
> +	if (!pkt->len)
> +		return pkt;
> +
> +	/* The pkt is too big */
> +	if (pkt->len > VIRTIO_VSOCK_MAX_PKT_BUF_SIZE) {
> +		kfree(pkt);
> +		return NULL;
> +	}
> +
> +	pkt->buf = kmalloc(pkt->len, GFP_KERNEL);
> +	if (!pkt->buf) {
> +		kfree(pkt);
> +		return NULL;
> +	}
> +
> +	ret = __copy_from_user(pkt->buf, vq->iov[1].iov_base, pkt->len);
> +	if (ret) {
> +		vq_err(vq, "Faulted on virtio_vsock_hdr\n");
> +		virtio_transport_free_pkt(pkt);
> +	}
> +
> +	return pkt;
> +}
> +
> +static void vhost_vsock_handle_ctl_kick(struct vhost_work *work)
> +{
> +	struct vhost_virtqueue *vq = container_of(work, struct vhost_virtqueue,
> +						  poll.work);
> +	struct vhost_vsock *vsock = container_of(vq->dev, struct vhost_vsock,
> +						 dev);
> +
> +	pr_debug("%s vq=%p, vsock=%p\n", __func__, vq, vsock);
> +}
> +
> +static void vhost_vsock_handle_tx_kick(struct vhost_work *work)
> +{
> +	struct vhost_virtqueue *vq = container_of(work, struct vhost_virtqueue,
> +						  poll.work);
> +	struct vhost_vsock *vsock = container_of(vq->dev, struct vhost_vsock,
> +						 dev);
> +	struct virtio_vsock_pkt *pkt;
> +	int head, out, in;
> +	u32 len;
> +
> +	mutex_lock(&vq->mutex);
> +	vhost_disable_notify(&vsock->dev, vq);
> +	for (;;) {
> +		head = vhost_get_vq_desc(&vsock->dev, vq, vq->iov,
> +					ARRAY_SIZE(vq->iov), &out, &in,
> +					NULL, NULL);
> +		if (head < 0)
> +			break;
> +
> +		if (head == vq->num) {
> +			if (unlikely(vhost_enable_notify(&vsock->dev, vq))) {
> +				vhost_disable_notify(&vsock->dev, vq);
> +				continue;
> +			}
> +			break;
> +		}
> +
> +		pkt = vhost_vsock_alloc_pkt(vq);
> +		if (!pkt) {
> +			vq_err(vq, "Faulted on pkt\n");
> +			continue;
> +		}
> +
> +		len = pkt->len;
> +		virtio_transport_recv_pkt(pkt);
> +		vhost_add_used(vq, head, len);
> +	}
> +	vhost_signal(&vsock->dev, vq);
> +	mutex_unlock(&vq->mutex);
> +}
> +
> +static void vhost_vsock_handle_rx_kick(struct vhost_work *work)
> +{
> +	struct vhost_virtqueue *vq = container_of(work, struct vhost_virtqueue,
> +						poll.work);
> +	struct vhost_vsock *vsock = container_of(vq->dev, struct vhost_vsock,
> +						 dev);
> +
> +	vhost_transport_do_send_pkt(vsock, vq);
> +}
> +
> +static int vhost_vsock_dev_open(struct inode *inode, struct file *file)
> +{
> +	struct vhost_virtqueue **vqs;
> +	struct vhost_vsock *vsock;
> +	int ret;
> +
> +	vsock = kzalloc(sizeof(*vsock), GFP_KERNEL);
> +	if (!vsock)
> +		return -ENOMEM;
> +
> +	pr_debug("%s:vsock=%p\n", __func__, vsock);
> +
> +	vqs = kmalloc(VSOCK_VQ_MAX * sizeof(*vqs), GFP_KERNEL);
> +	if (!vqs) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	vqs[VSOCK_VQ_CTRL] = &vsock->vqs[VSOCK_VQ_CTRL].vq;
> +	vqs[VSOCK_VQ_TX] = &vsock->vqs[VSOCK_VQ_TX].vq;
> +	vqs[VSOCK_VQ_RX] = &vsock->vqs[VSOCK_VQ_RX].vq;
> +	vsock->vqs[VSOCK_VQ_CTRL].vq.handle_kick = vhost_vsock_handle_ctl_kick;
> +	vsock->vqs[VSOCK_VQ_TX].vq.handle_kick = vhost_vsock_handle_tx_kick;
> +	vsock->vqs[VSOCK_VQ_RX].vq.handle_kick = vhost_vsock_handle_rx_kick;
> +
> +	ret = vhost_dev_init(&vsock->dev, vqs, VSOCK_VQ_MAX);
> +	if (ret < 0)
> +		goto out_vqs;
> +
> +	file->private_data = vsock;
> +	INIT_LIST_HEAD(&vsock->send_pkt_list);
> +	vhost_work_init(&vsock->send_pkt_work, vhost_transport_send_pkt_work);
> +
> +	mutex_lock(&vhost_vsock_mutex);
> +	list_add_tail(&vsock->list, &vhost_vsock_list);
> +	mutex_unlock(&vhost_vsock_mutex);
> +	return ret;
> +
> +out_vqs:
> +	kfree(vqs);
> +out:
> +	kfree(vsock);
> +	return ret;
> +}
> +
> +static void vhost_vsock_flush(struct vhost_vsock *vsock)
> +{
> +	int i;
> +
> +	for (i = 0; i < VSOCK_VQ_MAX; i++)
> +		vhost_poll_flush(&vsock->vqs[i].vq.poll);
> +	vhost_work_flush(&vsock->dev, &vsock->send_pkt_work);
> +}
> +
> +static int vhost_vsock_dev_release(struct inode *inode, struct file *file)
> +{
> +	struct vhost_vsock *vsock = file->private_data;
> +
> +	mutex_lock(&vhost_vsock_mutex);
> +	list_del(&vsock->list);
> +	mutex_unlock(&vhost_vsock_mutex);
> +
> +	vhost_dev_stop(&vsock->dev);
> +	vhost_vsock_flush(vsock);
> +	vhost_dev_cleanup(&vsock->dev, false);
> +	kfree(vsock->dev.vqs);
> +	kfree(vsock);
> +	return 0;
> +}
> +
> +static int vhost_vsock_set_cid(struct vhost_vsock *vsock, u32 guest_cid)
> +{
> +	mutex_lock(&vhost_vsock_mutex);
> +	vsock->guest_cid = guest_cid;
> +	pr_debug("%s:guest_cid=%d\n", __func__, guest_cid);
> +	mutex_unlock(&vhost_vsock_mutex);
> +
> +	return 0;
> +}
> +
> +static long vhost_vsock_dev_ioctl(struct file *f, unsigned int ioctl,
> +				  unsigned long arg)
> +{
> +	struct vhost_vsock *vsock = f->private_data;
> +	void __user *argp = (void __user *)arg;
> +	u64 __user *featurep = argp;
> +	u32 __user *cidp = argp;
> +	u32 guest_cid;
> +	u64 features;
> +	int r;
> +
> +	switch (ioctl) {
> +	case VHOST_VSOCK_SET_GUEST_CID:
> +		if (get_user(guest_cid, cidp))
> +			return -EFAULT;
> +		return vhost_vsock_set_cid(vsock, guest_cid);
> +	case VHOST_GET_FEATURES:
> +		features = VHOST_VSOCK_FEATURES;
> +		if (copy_to_user(featurep, &features, sizeof(features)))
> +			return -EFAULT;
> +		return 0;
> +	case VHOST_SET_FEATURES:
> +		if (copy_from_user(&features, featurep, sizeof(features)))
> +			return -EFAULT;
> +		return 0;
> +	default:
> +		mutex_lock(&vsock->dev.mutex);
> +		r = vhost_dev_ioctl(&vsock->dev, ioctl, argp);
> +		if (r == -ENOIOCTLCMD)
> +			r = vhost_vring_ioctl(&vsock->dev, ioctl, argp);
> +		else
> +			vhost_vsock_flush(vsock);
> +		mutex_unlock(&vsock->dev.mutex);
> +		return r;
> +	}
> +}
> +
> +static const struct file_operations vhost_vsock_fops = {
> +	.owner          = THIS_MODULE,
> +	.open           = vhost_vsock_dev_open,
> +	.release        = vhost_vsock_dev_release,
> +	.llseek		= noop_llseek,
> +	.unlocked_ioctl = vhost_vsock_dev_ioctl,
> +};
> +
> +static struct miscdevice vhost_vsock_misc = {
> +	.minor = MISC_DYNAMIC_MINOR,
> +	.name = "vhost-vsock",
> +	.fops = &vhost_vsock_fops,
> +};
> +
> +static int
> +vhost_transport_socket_init(struct vsock_sock *vsk, struct vsock_sock *psk)
> +{
> +	struct virtio_transport *trans;
> +	int ret;
> +
> +	ret = virtio_transport_do_socket_init(vsk, psk);
> +	if (ret)
> +		return ret;
> +
> +	trans = vsk->trans;
> +	trans->ops = &vhost_ops;
> +
> +	return ret;
> +}
> +
> +static struct vsock_transport vhost_transport = {
> +	.get_local_cid            = vhost_transport_get_local_cid,
> +
> +	.init                     = vhost_transport_socket_init,
> +	.destruct                 = virtio_transport_destruct,
> +	.release                  = virtio_transport_release,
> +	.connect                  = virtio_transport_connect,
> +	.shutdown                 = virtio_transport_shutdown,
> +
> +	.dgram_enqueue            = virtio_transport_dgram_enqueue,
> +	.dgram_dequeue            = virtio_transport_dgram_dequeue,
> +	.dgram_bind               = virtio_transport_dgram_bind,
> +	.dgram_allow              = virtio_transport_dgram_allow,
> +
> +	.stream_enqueue           = virtio_transport_stream_enqueue,
> +	.stream_dequeue           = virtio_transport_stream_dequeue,
> +	.stream_has_data          = virtio_transport_stream_has_data,
> +	.stream_has_space         = virtio_transport_stream_has_space,
> +	.stream_rcvhiwat          = virtio_transport_stream_rcvhiwat,
> +	.stream_is_active         = virtio_transport_stream_is_active,
> +	.stream_allow             = virtio_transport_stream_allow,
> +
> +	.notify_poll_in           = virtio_transport_notify_poll_in,
> +	.notify_poll_out          = virtio_transport_notify_poll_out,
> +	.notify_recv_init         = virtio_transport_notify_recv_init,
> +	.notify_recv_pre_block    = virtio_transport_notify_recv_pre_block,
> +	.notify_recv_pre_dequeue  = virtio_transport_notify_recv_pre_dequeue,
> +	.notify_recv_post_dequeue = virtio_transport_notify_recv_post_dequeue,
> +	.notify_send_init         = virtio_transport_notify_send_init,
> +	.notify_send_pre_block    = virtio_transport_notify_send_pre_block,
> +	.notify_send_pre_enqueue  = virtio_transport_notify_send_pre_enqueue,
> +	.notify_send_post_enqueue = virtio_transport_notify_send_post_enqueue,
> +
> +	.set_buffer_size          = virtio_transport_set_buffer_size,
> +	.set_min_buffer_size      = virtio_transport_set_min_buffer_size,
> +	.set_max_buffer_size      = virtio_transport_set_max_buffer_size,
> +	.get_buffer_size          = virtio_transport_get_buffer_size,
> +	.get_min_buffer_size      = virtio_transport_get_min_buffer_size,
> +	.get_max_buffer_size      = virtio_transport_get_max_buffer_size,
> +};
> +
> +static int __init vhost_vsock_init(void)
> +{
> +	int ret;
> +
> +	ret = vsock_core_init(&vhost_transport);
> +	if (ret < 0)
> +		return ret;
> +	return misc_register(&vhost_vsock_misc);
> +};
> +
> +static void __exit vhost_vsock_exit(void)
> +{
> +	misc_deregister(&vhost_vsock_misc);
> +	vsock_core_exit();
> +};
> +
> +module_init(vhost_vsock_init);
> +module_exit(vhost_vsock_exit);
> +MODULE_LICENSE("GPL v2");
> +MODULE_AUTHOR("Asias He");
> +MODULE_DESCRIPTION("vhost transport for vsock ");
> diff --git a/drivers/vhost/vsock.h b/drivers/vhost/vsock.h
> new file mode 100644
> index 0000000..0ddb107
> --- /dev/null
> +++ b/drivers/vhost/vsock.h
> @@ -0,0 +1,4 @@
> +#ifndef VHOST_VSOCK_H
> +#define VHOST_VSOCK_H
> +#define VHOST_VSOCK_SET_GUEST_CID _IOW(VHOST_VIRTIO, 0x60, __u32)

No SET without GET please.

> +#endif
> -- 
> 1.8.1.4
