From: Liu ping fan <kernelfans@gmail.com>
Subject: vhost-net: is there a race for sock in handle_tx/rx?
Date: Thu, 3 May 2012 16:33:55 +0800
Message-ID: <CAFgQCTtKWR6F3D_mPcGe69HvZbYmmAdXreSWLZQrdi+0T3i2ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

During reading the vhost-net code, I find the following,

static void handle_tx(struct vhost_net *net)
{
	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
	unsigned out, in, s;
	int head;
	struct msghdr msg = {
		.msg_name = NULL,
		.msg_namelen = 0,
		.msg_control = NULL,
		.msg_controllen = 0,
		.msg_iov = vq->iov,
		.msg_flags = MSG_DONTWAIT,
	};
	size_t len, total_len = 0;
	int err, wmem;
	size_t hdr_size;
	struct socket *sock;
	struct vhost_ubuf_ref *uninitialized_var(ubufs);
	bool zcopy;

	/* TODO: check that we are running from vhost_worker? */
	sock = rcu_dereference_check(vq->private_data, 1);
	if (!sock)
		return;

           --------------------------------> Qemu calls
vhost_net_set_backend() to set a new backend fd, and close
@oldsock->file. And  sock->file refcnt==0.

                                              Can vhost_worker prevent
itself from such situation? And how?

	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
       .........................................................................

Is it a race?

Thanks and regards,
pingfan
