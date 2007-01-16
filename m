From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH -mm 4/10][RFC] aio: convert aio_complete to file_endio_t
Date: Mon, 15 Jan 2007 21:53:46 -0800
Message-ID: <200701152153.49260.david-b@pacbell.net>
References: <20070116015450.9764.38389.patchbomb.py@nate-64.agami.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nate Diller <nate.diller@gmail.com>, Andrew Morton <akpm@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Suparna Bhattacharya <suparna@in.ibm.com>,
	Kenneth W Chen <kenneth.w.chen@intel.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, ocfs2-devel@oss.oracle.com,
	linux-aio@kvack.org, xfs-masters@oss.sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp113.sbc.mail.mud.yahoo.com ([68.142.198.212]:42531 "HELO
	smtp113.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932333AbXAPHYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 02:24:51 -0500
To: Nate Diller <nate@agami.com>
In-Reply-To: <20070116015450.9764.38389.patchbomb.py@nate-64.agami.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 15 January 2007 5:54 pm, Nate Diller wrote:
> --- a/drivers/usb/gadget/inode.c	2007-01-12 14:42:29.000000000 -0800
> +++ b/drivers/usb/gadget/inode.c	2007-01-12 14:25:34.000000000 -0800
> @@ -559,35 +559,32 @@ static int ep_aio_cancel(struct kiocb *i
>  	return value;
>  }
>  
> -static ssize_t ep_aio_read_retry(struct kiocb *iocb)
> +static int ep_aio_read_retry(struct kiocb *iocb)
>  {
>  	struct kiocb_priv	*priv = iocb->private;
> -	ssize_t			len, total;
> -	int			i;
> +	ssize_t			total;
> +	int			i, err = 0;
>  
>    	/* we "retry" to get the right mm context for this: */
>  
>   	/* copy stuff into user buffers */
>   	total = priv->actual;
> - 	len = 0;
>   	for (i=0; i < priv->nr_segs; i++) {
>   		ssize_t this = min((ssize_t)(priv->iv[i].iov_len), total);
>  
>   		if (copy_to_user(priv->iv[i].iov_base, priv->buf, this)) {
> - 			if (len == 0)
> - 				len = -EFAULT;
> + 			err = -EFAULT;

Discarding the capability to report partial success, e.g. that the first N
bytes were properly transferred?  I don't see any virtue in that change.
Quite the opposite in fact.

I think you're also expecting that if N bytes were requested, that's always
how many will be received.  That's not true for packetized I/O such as USB
isochronous transfers ... where it's quite legit (and in some cases routine)
for the other end to send packets that are shorter than the maximum allowed.
Sending a zero length packet is not the same as sending no packet at all,
for another example.
