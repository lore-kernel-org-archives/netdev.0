From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Avoid NULL pointer dereference in tg3_get_nstats()
Date: Thu, 05 Jan 2017 12:33:37 -0500 (EST)
Message-ID: <20170105.123337.2237827308340782208.davem@davemloft.net>
References: <1483625601-10552-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: siva.kallam@broadcom.com, prashant@broadcom.com,
        mchan@broadcom.com, netdev@vger.kernel.org
To: wangyufen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41662 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034320AbdAERdl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 12:33:41 -0500
In-Reply-To: <1483625601-10552-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>
Date: Thu, 5 Jan 2017 22:13:21 +0800

> From: Yufen Wang <wangyufen@huawei.com>
> 
> A possible NULL pointer dereference in tg3_get_stats64 while doing
> tg3_free_consistent.
 ...
> This patch avoids the NULL pointer dereference by using !tg3_flag(tp, INIT_COMPLETE)
> instate of !tp->hw_stats.
> 
> Signed-off-by: Yufen Wang <wangyufen@huawei.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 185e9e0..012f18d 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -14148,7 +14148,7 @@ static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
>  	struct tg3 *tp = netdev_priv(dev);
>  
>  	spin_lock_bh(&tp->lock);
> -	if (!tp->hw_stats) {
> +	if (!tg3_flag(tp, INIT_COMPLETE)) {

The real issue is the manner and order in which the driver performs
initialization actions relative to netif_device_{attach,detach}().

That is what needs to be fixed here, instead of adding more and more
ad-hoc tests to the various methods which can be invoked once the
netif_device_attach() occurs.
