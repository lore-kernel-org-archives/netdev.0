From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 10/10] 9P: Add cancelled() to the transport functions.
Date: Tue, 02 Jul 2013 20:49:25 +0400
Message-ID: <51D30495.6060103@cogentembedded.com>
References: <1372770684-25573-1-git-send-email-simon.derr@bull.net> <1372770684-25573-11-git-send-email-simon.derr@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ericvh@gmail.com
To: Simon Derr <simon.derr@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:48472 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515Ab3GBQtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 12:49:31 -0400
Received: by mail-lb0-f174.google.com with SMTP id x10so3596364lbi.33
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 09:49:29 -0700 (PDT)
In-Reply-To: <1372770684-25573-11-git-send-email-simon.derr@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02-07-2013 17:11, Simon Derr wrote:

> RDMA needs to post a buffer for each incoming reply.
> Hence it needs to keep count of these and needs to be
> aware of whether a flushed request has received a reply
> or not.

> This patch adds the cancelled() callback to the transport modules.
> It is called when RFLUSH has been received and that the corresponding
> request will never receive a reply.

> Signed-off-by: Simon Derr <simon.derr@bull.net>
> ---
>   include/net/9p/transport.h |    3 +++
>   net/9p/client.c            |   11 ++++++++---
>   net/9p/trans_rdma.c        |   10 ++++++++++
>   3 files changed, 21 insertions(+), 3 deletions(-)

> diff --git a/include/net/9p/transport.h b/include/net/9p/transport.h
> index adcbb20..77a0578 100644
> --- a/include/net/9p/transport.h
> +++ b/include/net/9p/transport.h
[...]
> @@ -55,6 +57,7 @@ struct p9_trans_module {
>   	void (*close) (struct p9_client *);
>   	int (*request) (struct p9_client *, struct p9_req_t *req);
>   	int (*cancel) (struct p9_client *, struct p9_req_t *req);
> +	int (*cancelled) (struct p9_client *, struct p9_req_t *req);

    There should be no space before ( opening the parameter list.
scripts/checkpatch.pl should have warned you here.

>   	int (*zc_request)(struct p9_client *, struct p9_req_t *,
>   			  char *, char *, int , int, int, int);
>   };
> diff --git a/net/9p/client.c b/net/9p/client.c
> index 44691b9..61e0455 100644
> --- a/net/9p/client.c
> +++ b/net/9p/client.c
> @@ -676,11 +676,16 @@ static int p9_client_flush(struct p9_client *c, struct p9_req_t *oldreq)
>
>
>   	/* if we haven't received a response for oldreq,
> -	   remove it from the list. */
> +	   remove it from the list, and notify the transport
> +	   layer that the reply will never arrive. */

    The preferred style of the multi-line commnets in the networking 
code is:

	/* bla
	 * bla
	 */

>   	spin_lock(&c->lock);
> -	if (oldreq->status == REQ_STATUS_FLSH)
> +	if (oldreq->status == REQ_STATUS_FLSH) {
>   		list_del(&oldreq->req_list);
> -	spin_unlock(&c->lock);
> +		spin_unlock(&c->lock);
> +		if (c->trans_mod->cancelled)
> +			c->trans_mod->cancelled(c, req);
> +	} else
> +		spin_unlock(&c->lock);

    According to Documentation/CodingStyle chapter 3, both arms of the 
*if* statment should have {} if one arm has it.

> diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
> index 8f68df5..9e6c220 100644
> --- a/net/9p/trans_rdma.c
> +++ b/net/9p/trans_rdma.c
> @@ -588,6 +588,16 @@ static int rdma_cancel(struct p9_client *client, struct p9_req_t *req)
>   	return 1;
>   }
>
> +/* A request has been fully flushed without a reply.
> + * That means we have posted one buffer in excess.
> + */
> +static int rdma_cancelled(struct p9_client *client, struct p9_req_t *req)
> +{
> +	struct p9_trans_rdma *rdma = client->trans;

    Empty line wouldn't hurt here, after declaration.

> +	atomic_inc(&rdma->excess_rc);
> +	return 0;
> +}
> +

WBR, Sergei
