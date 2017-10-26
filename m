From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2] tap: double-free in error path in tap_open()
Date: Thu, 26 Oct 2017 13:56:23 +0800
Message-ID: <c7dd6239-787e-6f71-f6d5-f61664fb09ca@redhat.com>
References: <1508916184-17473-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: Girish Moodalbail <girish.moodalbail@oracle.com>,
        netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60742 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750919AbdJZF41 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 01:56:27 -0400
In-Reply-To: <1508916184-17473-1-git-send-email-girish.moodalbail@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年10月25日 15:23, Girish Moodalbail wrote:
> Double free of skb_array in tap module is causing kernel panic. When
> tap_set_queue() fails we free skb_array right away by calling
> skb_array_cleanup(). However, later on skb_array_cleanup() is called
> again by tap_sock_destruct through sock_put(). This patch fixes that
> issue.
>
> Fixes: 362899b8725b35e3 (macvtap: switch to use skb array)
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
> ---
> v1 -> v2:
>    - took care of an another issue in failure path of skb_array_init
> ---
>   drivers/net/tap.c | 18 +++++++++---------
>   1 file changed, 9 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/tap.c b/drivers/net/tap.c
> index 21b71ae..98ee6cc 100644
> --- a/drivers/net/tap.c
> +++ b/drivers/net/tap.c
> @@ -517,6 +517,10 @@ static int tap_open(struct inode *inode, struct file *file)
>   					     &tap_proto, 0);
>   	if (!q)
>   		goto err;
> +	if (skb_array_init(&q->skb_array, tap->dev->tx_queue_len, GFP_KERNEL)) {
> +		sk_free(&q->sk);
> +		goto err;
> +	}
>   
>   	RCU_INIT_POINTER(q->sock.wq, &q->wq);
>   	init_waitqueue_head(&q->wq.wait);
> @@ -540,22 +544,18 @@ static int tap_open(struct inode *inode, struct file *file)
>   	if ((tap->dev->features & NETIF_F_HIGHDMA) && (tap->dev->features & NETIF_F_SG))
>   		sock_set_flag(&q->sk, SOCK_ZEROCOPY);
>   
> -	err = -ENOMEM;
> -	if (skb_array_init(&q->skb_array, tap->dev->tx_queue_len, GFP_KERNEL))
> -		goto err_array;
> -
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

Acked-by: Jason Wang <jasowang@redhat.com>

This patch is needed for -stable.

Thanks
