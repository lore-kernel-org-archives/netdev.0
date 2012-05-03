From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: vhost-net: is there a race for sock in handle_tx/rx?
Date: Thu, 3 May 2012 11:41:15 +0300
Message-ID: <20120503084115.GM8266@redhat.com>
References: <CAFgQCTtKWR6F3D_mPcGe69HvZbYmmAdXreSWLZQrdi+0T3i2ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Liu ping fan <kernelfans@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49513 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754741Ab2ECIlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 04:41:10 -0400
Content-Disposition: inline
In-Reply-To: <CAFgQCTtKWR6F3D_mPcGe69HvZbYmmAdXreSWLZQrdi+0T3i2ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 03, 2012 at 04:33:55PM +0800, Liu ping fan wrote:
> Hi,
> 
> During reading the vhost-net code, I find the following,
> 
> static void handle_tx(struct vhost_net *net)
> {
> 	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
> 	unsigned out, in, s;
> 	int head;
> 	struct msghdr msg = {
> 		.msg_name = NULL,
> 		.msg_namelen = 0,
> 		.msg_control = NULL,
> 		.msg_controllen = 0,
> 		.msg_iov = vq->iov,
> 		.msg_flags = MSG_DONTWAIT,
> 	};
> 	size_t len, total_len = 0;
> 	int err, wmem;
> 	size_t hdr_size;
> 	struct socket *sock;
> 	struct vhost_ubuf_ref *uninitialized_var(ubufs);
> 	bool zcopy;
> 
> 	/* TODO: check that we are running from vhost_worker? */
> 	sock = rcu_dereference_check(vq->private_data, 1);
> 	if (!sock)
> 		return;
> 
>            --------------------------------> Qemu calls
> vhost_net_set_backend() to set a new backend fd, and close
> @oldsock->file. And  sock->file refcnt==0.
> 
>                                               Can vhost_worker prevent
> itself from such situation? And how?
> 
> 	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
>        .........................................................................
> 
> Is it a race?
> 
> Thanks and regards,
> pingfan

See comment before void __rcu *private_data in vhost.h
