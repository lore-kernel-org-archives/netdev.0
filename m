From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Wed, 12 Aug 2009 19:03:22 +0200
Message-ID: <200908121903.22325.arnd@arndb.de>
References: <cover.1249930169.git.mst@redhat.com> <20090810185340.GC13924@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: virtualization@lists.linux-foundation.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:54229 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbZHLRDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 13:03:36 -0400
In-Reply-To: <20090810185340.GC13924@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 10 August 2009, Michael S. Tsirkin wrote:

> +struct workqueue_struct *vhost_workqueue;

[nitpicking] This could be static. 

> +/* The virtqueue structure describes a queue attached to a device. */
> +struct vhost_virtqueue {
> +	struct vhost_dev *dev;
> +
> +	/* The actual ring of buffers. */
> +	struct mutex mutex;
> +	unsigned int num;
> +	struct vring_desc __user *desc;
> +	struct vring_avail __user *avail;
> +	struct vring_used __user *used;
> +	struct file *kick;
> +	struct file *call;
> +	struct file *error;
> +	struct eventfd_ctx *call_ctx;
> +	struct eventfd_ctx *error_ctx;
> +
> +	struct vhost_poll poll;
> +
> +	/* The routine to call when the Guest pings us, or timeout. */
> +	work_func_t handle_kick;
> +
> +	/* Last available index we saw. */
> +	u16 last_avail_idx;
> +
> +	/* Last index we used. */
> +	u16 last_used_idx;
> +
> +	/* Outstanding buffers */
> +	unsigned int inflight;
> +
> +	/* Is this blocked? */
> +	bool blocked;
> +
> +	struct iovec iov[VHOST_NET_MAX_SG];
> +
> +} ____cacheline_aligned;

We discussed this before, and I still think this could be directly derived
from struct virtqueue, in the same way that vring_virtqueue is derived from
struct virtqueue. That would make it possible for simple device drivers
to use the same driver in both host and guest, similar to how Ira Snyder
used virtqueues to make virtio_net run between two hosts running the
same code [1].

Ideally, I guess you should be able to even make virtio_net work in the
host if you do that, but that could bring other complexities.

	Arnd <><

[1] http://lkml.org/lkml/2009/2/23/353
