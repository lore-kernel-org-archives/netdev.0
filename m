From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] 9p: disconnect channel when PCI device is removed
Date: Sun, 15 Apr 2012 17:57:26 +0530
Message-ID: <87iph118pd.fsf@skywalker.in.ibm.com>
References: <1334353716-19483-1-git-send-email-levinsasha928@gmail.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com, Sasha Levin <levinsasha928@gmail.com>
To: Sasha Levin <levinsasha928@gmail.com>, davem@davemloft.net,
	ericvh@gmail.com, jvrao@linux.vnet.ibm.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:37475 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157Ab2DOM1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 08:27:39 -0400
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 15 Apr 2012 17:57:35 +0530
In-Reply-To: <1334353716-19483-1-git-send-email-levinsasha928@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sasha Levin <levinsasha928@gmail.com> writes:

> When a virtio_9p pci device is being removed, we should close down any
> active channels and free up resources, we're not supposed to BUG() if there's
> still an open channel since it's a valid case when removing the PCI device.
>
> Otherwise, removing the PCI device with an open channel would cause the
> following BUG():
>
...

> diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
> index 3d43206..5af18d1 100644
> --- a/net/9p/trans_virtio.c
> +++ b/net/9p/trans_virtio.c
> @@ -615,7 +615,8 @@ static void p9_virtio_remove(struct virtio_device *vdev)
>  {
>  	struct virtio_chan *chan = vdev->priv;
>
> -	BUG_ON(chan->inuse);
> +	if (chan->inuse)
> +		p9_virtio_close(chan->client);
>  	vdev->config->del_vqs(vdev);
>
>  	mutex_lock(&virtio_9p_lock);

But an umount should have resulted in p9_virtio_close ? How are you
removing the device ? Are you removing the device with file system
mounted  ?. In that case may be we should return EBUSY ?

-aneesh
