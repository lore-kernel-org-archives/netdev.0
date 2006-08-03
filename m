From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take3 3/4] kevent: Network AIO, socket notifications.
Date: Thu, 3 Aug 2006 11:54:26 +0200
Message-ID: <200608031154.27152.dada1@cosmosbay.com>
References: <11545983601447@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:8082 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S932362AbWHCJya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 05:54:30 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11545983601447@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 03 August 2006 11:46, Evgeniy Polyakov wrote:
> Network AIO, socket notifications.
>
> This patchset includes socket notifications and network asynchronous IO.
> Network AIO is based on kevent and works as usual kevent storage on top
> of inode.
>  						          (3 * TCP_RTO_MIN) / 4,
> diff --git a/kernel/kevent/kevent_naio.c b/kernel/kevent/kevent_naio.c
+
> +static int kevent_naio_enqueue(struct kevent *k)
> +{
> +	int err, i;
> +	struct page **page;
> +	void *addr;
> +	unsigned int size = k->event.id.raw[1];
> +	int num = size/PAGE_SIZE;
> +	struct file *file;
> +	struct sock *sk = NULL;
> +	int fput_needed;
> +
> +	file = fget_light(k->event.id.raw[0], &fput_needed);
> +	if (!file)
> +		return -ENODEV;
> +
> +	err = -EINVAL;
> +	if (!file->f_dentry || !file->f_dentry->d_inode)
> +		goto err_out_fput;

How can you be 100% sure this file is actually a socket here ?
(Another thread could close the fd and this fd can now point to another file)

You should do
if (file->f_op != &socket_file_ops)
	goto err_out_fput;
sk = file->private_data;  /* set in sock_map_fd */ 

> +
> +	sk = SOCKET_I(file->f_dentry->d_inode)->sk;
> +


Eric
