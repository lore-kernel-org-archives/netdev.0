From: Hyong-Youb Kim <hykim@myri.com>
Subject: Re: myri10ge: fix sleeping with bh disabled
Date: Tue, 26 Apr 2016 11:22:35 +0900
Message-ID: <20160426022235.GA1945@gtest01.arcus>
References: <20160425085918.GB2608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0128.outbound.protection.outlook.com ([157.56.112.128]:2048
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750843AbcDZCjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 22:39:12 -0400
Content-Disposition: inline
In-Reply-To: <20160425085918.GB2608@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 25, 2016 at 10:59:19AM +0200, Stanislaw Gruszka wrote:
> napi_disable() can not be called with bh disabled, move locking just
> around myri10ge_ss_lock_napi() .

Acked-by: Hyong-Youb Kim <hykim@myri.com>

Thanks.

> 
> Patches fixes following bug:
> 
> [  114.278378] BUG: sleeping function called from invalid context at net/core/dev.c:4383 
> <snip>
> [  114.313712] Call Trace: 
> [  114.314943]  [<ffffffff817010ce>] dump_stack+0x19/0x1b 
> [  114.317673]  [<ffffffff810ce7f3>] __might_sleep+0x173/0x230 
> [  114.320566]  [<ffffffff815b3117>] napi_disable+0x27/0x90 
> [  114.323254]  [<ffffffffa01e437f>] myri10ge_close+0xbf/0x3f0 [myri10ge] 
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
> diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> index 270c9ee..6d1a956 100644
> --- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> +++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> @@ -2668,9 +2668,9 @@ static int myri10ge_close(struct net_device *dev)
>  
>  	del_timer_sync(&mgp->watchdog_timer);
>  	mgp->running = MYRI10GE_ETH_STOPPING;
> -	local_bh_disable(); /* myri10ge_ss_lock_napi needs bh disabled */
>  	for (i = 0; i < mgp->num_slices; i++) {
>  		napi_disable(&mgp->ss[i].napi);
> +		local_bh_disable(); /* myri10ge_ss_lock_napi needs this */
>  		/* Lock the slice to prevent the busy_poll handler from
>  		 * accessing it.  Later when we bring the NIC up, myri10ge_open
>  		 * resets the slice including this lock.
> @@ -2679,8 +2679,8 @@ static int myri10ge_close(struct net_device *dev)
>  			pr_info("Slice %d locked\n", i);
>  			mdelay(1);
>  		}
> +		local_bh_enable();
>  	}
> -	local_bh_enable();
>  	netif_carrier_off(dev);
>  
>  	netif_tx_stop_all_queues(dev);
