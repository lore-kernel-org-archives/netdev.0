From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] tap: double-free in error path in tap_open()
Date: Wed, 25 Oct 2017 09:55:40 +0800
Message-ID: <e5816501-b58c-506c-161f-8ee7a80ea347@redhat.com>
References: <1508881270-4124-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: Girish Moodalbail <girish.moodalbail@oracle.com>,
        netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48307 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751323AbdJYBzo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 21:55:44 -0400
In-Reply-To: <1508881270-4124-1-git-send-email-girish.moodalbail@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年10月25日 05:41, Girish Moodalbail wrote:
> Double free of skb_array in tap module is causing kernel panic. When
> tap_set_queue() fails we free skb_array right away by calling
> skb_array_cleanup(). However, later on skb_array_cleanup() is called
> again by tap_sock_destruct through sock_put(). This patch fixes that
> issue.
>
> Fixes: 362899b8725b35e3 (macvtap: switch to use skb array)
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
> ---
>   drivers/net/tap.c | 12 ++++++------
>   1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/tap.c b/drivers/net/tap.c
> index 21b71ae..878520b 100644
> --- a/drivers/net/tap.c
> +++ b/drivers/net/tap.c
> @@ -542,20 +542,20 @@ static int tap_open(struct inode *inode, struct file *file)
>   
>   	err = -ENOMEM;
>   	if (skb_array_init(&q->skb_array, tap->dev->tx_queue_len, GFP_KERNEL))
> -		goto err_array;
> +		goto err_put;

Looks like this will cause skb_array_cleanup() to be called when skb 
array was uninitialized?

Thanks

>   
>   	err = tap_set_queue(tap, file, q);
> -	if (err)
> -		goto err_queue;
> +	if (err) {
> +		/* tap_sock_destruct() will take care of freeing skb_array */
> +		goto err_put;
> +	}
>   
>   	dev_put(tap->dev);
>   
>   	rtnl_unlock();
>   	return err;
>   
> -err_queue:
> -	skb_array_cleanup(&q->skb_array);
> -err_array:
> +err_put:
>   	sock_put(&q->sk);
>   err:
>   	if (tap)
