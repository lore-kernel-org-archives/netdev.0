From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host
	communication.
Date: Wed, 17 Dec 2008 16:31:46 +0200
Message-ID: <20081217143146.GA20505@redhat.com>
References: <4946717F.2090809@codemonkey.ws> <20081215.114315.165733593.davem@davemloft.net> <4946C1AA.4080404@codemonkey.ws> <20081215.142918.190909950.davem@davemloft.net> <4946E1BA.80206@codemonkey.ws> <20081215234511.GA24579@ioremap.net> <20081216065727.GD13794@redhat.com> <20081216212532.GA15360@ioremap.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="TB36FDmn/VVEgNH/"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081216212532.GA15360@ioremap.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Dec 17, 2008 at 12:25:32AM +0300, Evgeniy Polyakov wrote:
> On Tue, Dec 16, 2008 at 08:57:27AM +0200, Gleb Natapov (gleb@redhat.com) wrote:
> > > Another approach is to implement that virtio backend with netlink based
> > > userspace interface (like using connector or genetlink). This does not
> > > differ too much from what you have with special socket family, but at
> > > least it does not duplicate existing functionality of
> > > userspace-kernelspace communications.
> > > 
> > I implemented vmchannel using connector initially (the downside is that
> > message can be dropped). Is this more expectable for upstream? The
> > implementation was 300 lines of code.
> 
> Hard to tell, it depends on implementation. But if things are good, I
> have no objections as connector maintainer :)
> 
Here it is. Sorry it is not in a patch format yet, but it gives
general idea how it looks. The problem with connector is that 
we need different IDX for different channels and there is no way
to dynamically allocate them.

--
			Gleb.

--TB36FDmn/VVEgNH/
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="vmchannel_connector.c"

/*
 *  Copyright (c) 2008 Red Hat, Inc.
 *
 *  Author(s): Gleb Natapov <gleb@redhat.com>
 */

#include <linux/module.h>
#include <linux/interrupt.h>
#include <linux/connector.h>
#include <linux/virtio.h>
#include <linux/scatterlist.h>
#include <linux/virtio_config.h>
#include <linux/list.h>
#include <linux/spinlock.h>
#include "vmchannel_connector.h"

static struct vmchannel_dev vmc_dev;

static int add_recq_buf(struct vmchannel_dev *vmc, struct vmchannel_hdr *hdr)
{
	struct scatterlist sg[2];

	sg_init_table(sg, 2);
	sg_init_one(&sg[0], hdr, sizeof(struct vmchannel_desc));
	sg_init_one(&sg[1], hdr->msg.data, MAX_PACKET_LEN);

	if (!vmc->rq->vq_ops->add_buf(vmc->rq, sg, 0, 2, hdr))
		return 1;

	kfree(hdr);
	return 0;
}

static int try_fill_recvq(struct vmchannel_dev *vmc)
{
	int num = 0;

	for (;;) {
		struct vmchannel_hdr *hdr;

		hdr = kmalloc(sizeof(*hdr) + MAX_PACKET_LEN, GFP_KERNEL);

		if (unlikely(!hdr))
			break;

		if (!add_recq_buf(vmc, hdr))
			break;

		num++;
	}

	if (num)
		vmc->rq->vq_ops->kick(vmc->rq);

	return num;
}

static void vmchannel_recv(unsigned long data)
{
	struct vmchannel_dev *vmc = (struct vmchannel_dev *)data;
	struct vmchannel_hdr *hdr;
	unsigned int len;
	int posted = 0;

	while ((hdr = vmc->rq->vq_ops->get_buf(vmc->rq, &len))) {
		hdr->msg.len = le32_to_cpu(hdr->desc.len);
		len -= sizeof(struct vmchannel_desc);
		if (hdr->msg.len == len) {
			hdr->msg.id.idx = VMCHANNEL_CONNECTOR_IDX;
			hdr->msg.id.val = le32_to_cpu(hdr->desc.id);
			hdr->msg.seq = vmc->seq++;
			hdr->msg.ack = random32();

			cn_netlink_send(&hdr->msg, VMCHANNEL_CONNECTOR_IDX,
					GFP_ATOMIC);
		} else
			dev_printk(KERN_ERR, &vmc->vdev->dev,
					"wrong length in received descriptor"
					" (%d instead of %d)\n", hdr->msg.len,
					len);

		posted += add_recq_buf(vmc, hdr);
	}

	if (posted)
		vmc->rq->vq_ops->kick(vmc->rq);
}

static void recvq_notify(struct virtqueue *recvq)
{
	struct vmchannel_dev *vmc = recvq->vdev->priv;

	tasklet_schedule(&vmc->tasklet);
}

static void cleanup_sendq(struct vmchannel_dev *vmc)
{
	char *buf;
	unsigned int len;

	spin_lock(&vmc->sq_lock);
	while ((buf = vmc->sq->vq_ops->get_buf(vmc->sq, &len)))
		kfree(buf);
	spin_unlock(&vmc->sq_lock);
}

static void sendq_notify(struct virtqueue *sendq)
{
	struct vmchannel_dev *vmc = sendq->vdev->priv;

	cleanup_sendq(vmc);
}

static void vmchannel_cn_callback(void *data)
{
	struct vmchannel_desc *desc;
	struct cn_msg *msg = data;
	struct scatterlist sg;
	char *buf;
	int err;
	unsigned long flags;

	desc = kmalloc(msg->len + sizeof(*desc), GFP_KERNEL);

	if (!desc)
		return;

	desc->id = cpu_to_le32(msg->id.val);
	desc->len = cpu_to_le32(msg->len);

	buf = (char *)(desc + 1);

	memcpy(buf, msg->data, msg->len);

	sg_init_one(&sg, desc, msg->len + sizeof(*desc));

	spin_lock_irqsave(&vmc_dev.sq_lock, flags);
	err = vmc_dev.sq->vq_ops->add_buf(vmc_dev.sq, &sg, 1, 0, desc);

	if (err)
		kfree(desc);
	else
		vmc_dev.sq->vq_ops->kick(vmc_dev.sq);
	spin_unlock_irqrestore(&vmc_dev.sq_lock, flags);
}

static int vmchannel_probe(struct virtio_device *vdev)
{
	struct vmchannel_dev *vmc = &vmc_dev;
	struct cb_id cn_id;
	int r, i;
	__le32 count;
	unsigned offset;

	cn_id.idx = VMCHANNEL_CONNECTOR_IDX;
	vdev->priv = vmc;
	vmc->vdev = vdev;

	vdev->config->get(vdev, 0, &count, sizeof(count));

	vmc->channel_count = le32_to_cpu(count);
	if (vmc->channel_count == 0) {
		dev_printk(KERN_ERR, &vdev->dev, "No channels present\n");
		return -ENODEV;
	}

	pr_debug("vmchannel: %d channel detected\n", vmc->channel_count);

	vmc->channels =
		kzalloc(vmc->channel_count * sizeof(struct vmchannel_info),
				GFP_KERNEL);
	if (!vmc->channels)
		return -ENOMEM;

	offset = sizeof(count);
	for (i = 0; i < vmc->channel_count; i++) {
		__u32 len;
		__le32 tmp;
		vdev->config->get(vdev, offset, &tmp, 4);
		vmc->channels[i].id = le32_to_cpu(tmp);
		offset += 4;
		vdev->config->get(vdev, offset, &tmp, 4);
		len = le32_to_cpu(tmp);
		if (len > VMCHANNEL_NAME_MAX) {
			dev_printk(KERN_ERR, &vdev->dev,
					"Wrong device configuration. "
					"Channel name is too long");
			r = -ENODEV;
			goto out;
		}
		vmc->channels[i].name = kmalloc(len, GFP_KERNEL);
		if (!vmc->channels[i].name) {
			r = -ENOMEM;
			goto out;
		}
		offset += 4;
		vdev->config->get(vdev, offset, vmc->channels[i].name, len);
		offset += len;
		pr_debug("vmhannel: found channel '%s' id %d\n",
				vmc->channels[i].name,
				vmc->channels[i].id);
	}

	vmc->rq = vdev->config->find_vq(vdev, 0, recvq_notify);
	if (IS_ERR(vmc->rq)) {
		r = PTR_ERR(vmc->rq);
		goto out;
	}

	vmc->sq = vdev->config->find_vq(vdev, 1, sendq_notify);
	if (IS_ERR(vmc->sq)) {
		r = PTR_ERR(vmc->sq);
		goto out;
	}

	spin_lock_init(&vmc->sq_lock);

	for (i = 0; i < vmc->channel_count; i++) {
		cn_id.val = vmc->channels[i].id;
		r = cn_add_callback(&cn_id, "vmchannel", vmchannel_cn_callback);
		if (r)
			goto cn_unreg;
	}

	tasklet_init(&vmc->tasklet, vmchannel_recv, (unsigned long)vmc);

	if (!try_fill_recvq(vmc)) {
		r = -ENOMEM;
		goto kill_task;
	}

	return 0;
kill_task:
	tasklet_kill(&vmc->tasklet);
cn_unreg:
	for (i = 0; i < vmc->channel_count; i++) {
		cn_id.val = vmc->channels[i].id;
		cn_del_callback(&cn_id);
	}
out:
	if (vmc->sq)
		vdev->config->del_vq(vmc->sq);
	if (vmc->rq)
		vdev->config->del_vq(vmc->rq);

	for (i = 0; i < vmc->channel_count; i++) {
		if (!vmc->channels[i].name)
			break;
		kfree(vmc->channels[i].name);
	}

	kfree(vmc->channels);
	return r;
}

static void vmchannel_remove(struct virtio_device *vdev)
{
	struct vmchannel_dev *vmc = vdev->priv;
	struct cb_id cn_id;
	int i;

	/* Stop all the virtqueues. */
	vdev->config->reset(vdev);

	tasklet_kill(&vmc->tasklet);
	cn_id.idx = VMCHANNEL_CONNECTOR_IDX;
	for (i = 0; i < vmc->channel_count; i++) {
		cn_id.val = vmc->channels[i].id;
		cn_del_callback(&cn_id);
	}
	vdev->config->del_vq(vmc->rq);
	vdev->config->del_vq(vmc->sq);

	for (i = 0; i < vmc_dev.channel_count; i++)
		kfree(vmc_dev.channels[i].name);

	kfree(vmc_dev.channels);
}

static struct virtio_device_id id_table[] = {
	{ VIRTIO_ID_VMCHANNEL, VIRTIO_DEV_ANY_ID }, { 0 },
};

static struct virtio_driver virtio_vmchannel = {
	.driver.name =	"virtio-vmchannel",
	.driver.owner =	THIS_MODULE,
	.id_table =	id_table,
	.probe =	vmchannel_probe,
	.remove =	__devexit_p(vmchannel_remove),
};

static int __init init(void)
{
	return register_virtio_driver(&virtio_vmchannel);
}

static void __exit fini(void)
{
	unregister_virtio_driver(&virtio_vmchannel);
}

module_init(init);
module_exit(fini);

MODULE_AUTHOR("Gleb Natapov");
MODULE_DEVICE_TABLE(virtio, id_table);
MODULE_DESCRIPTION("Virtio vmchannel driver");
MODULE_LICENSE("GPL");

--TB36FDmn/VVEgNH/
Content-Type: text/x-chdr; charset=us-ascii
Content-Disposition: attachment; filename="vmchannel_connector.h"

/*
 *  Copyright (c) 2008 Red Hat, Inc.
 *
 *  Author(s): Gleb Natapov <gleb@redhat.com>
 */

#ifndef VMCHANNEL_H
#define VMCHANNEL_H

#define VMCHANNEL_NAME_MAX 80
#define VMCHANNEL_CONNECTOR_IDX 10
#define VIRTIO_ID_VMCHANNEL 6
#define MAX_PACKET_LEN 1024

struct vmchannel_info {
	__u32 id;
	char *name;
};

struct vmchannel_dev {
	struct virtio_device *vdev;
	struct virtqueue *rq;
	struct virtqueue *sq;
	spinlock_t sq_lock;
	struct tasklet_struct tasklet;
	__u16 channel_count;
	struct vmchannel_info *channels;
	__u32 seq;
};

struct vmchannel_desc {
	__u32 id;
	__u32 len;
};

struct vmchannel_hdr {
	struct vmchannel_desc desc;
	struct cn_msg msg;
};

#endif

--TB36FDmn/VVEgNH/--
