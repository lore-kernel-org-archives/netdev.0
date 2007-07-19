From: Paul Clements <paul.clements@steeleye.com>
Subject: Re: [PATCH 2/2] nbd: change a parameter's type to remove a memcpy
 call
Date: Thu, 19 Jul 2007 13:35:53 -0400
Message-ID: <469FA0F9.9090001@steeleye.com>
References: <11848376711601-git-send-email-crquan@gmail.com> <11848377013773-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pavel Machek <pavel@ucw.cz>,
	Steven Whitehouse <steve@chygwyn.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Denis Cheng <crquan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hancock.steeleye.com ([71.30.118.248]:60523 "EHLO
	hancock.sc.steeleye.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754667AbXGSRfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 13:35:55 -0400
In-Reply-To: <11848377013773-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis Cheng wrote:
> this memcpy looks so strange, in fact it's merely a pointer dereference,
> so I change the parameter's type to refer it more directly,
> this could make the memcpy not needed anymore.
> 
> in the function nbd_read_stat where nbd_find_request is only once called,
> the parameter served should be transformed accordingly.

This is really a matter of preference. The generated code ends up being 
about the same, I think, while your patch makes the call to 
nbd_find_request kind of obtuse. Also, the memcpy's are balanced between 
send_req and find_request, so you can quickly see how the data is being 
transferred (from req into handle, and then back again). Your patch 
makes this less clear, at least to me.

--
Paul


> Signed-off-by: Denis Cheng <crquan@gmail.com>
> ---
>  drivers/block/nbd.c |    7 ++-----
>  1 files changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
> index 86639c0..a4d8508 100644
> --- a/drivers/block/nbd.c
> +++ b/drivers/block/nbd.c
> @@ -235,14 +235,11 @@ error_out:
>  	return 1;
>  }
>  
> -static struct request *nbd_find_request(struct nbd_device *lo, char *handle)
> +static struct request *nbd_find_request(struct nbd_device *lo, struct request *xreq)
>  {
>  	struct request *req, *n;
> -	struct request *xreq;
>  	int err;
>  
> -	memcpy(&xreq, handle, sizeof(xreq));
> -
>  	err = wait_event_interruptible(lo->active_wq, lo->active_req != xreq);
>  	if (unlikely(err))
>  		goto out;
> @@ -297,7 +294,7 @@ static struct request *nbd_read_stat(struct nbd_device *lo)
>  		goto harderror;
>  	}
>  
> -	req = nbd_find_request(lo, reply.handle);
> +	req = nbd_find_request(lo, *(struct request **)reply.handle);
>  	if (unlikely(IS_ERR(req))) {
>  		result = PTR_ERR(req);
>  		if (result != -ENOENT)

