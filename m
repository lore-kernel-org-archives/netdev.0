From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/6] [NET-NEXT]qlge: Cleanup chip reset path.
Date: Sat, 11 Oct 2008 23:30:00 +0200
Message-ID: <20081011213000.GB29496@electric-eye.fr.zoreil.com>
References: <20081011171614.GA26384@susedev.qlogic.org> <1223745433-26440-4-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56159 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754620AbYJKVaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 17:30:09 -0400
Content-Disposition: inline
In-Reply-To: <1223745433-26440-4-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Mercer <ron.mercer@qlogic.com> :
[...]
> diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> index c257546..1788e5c 100755
> --- a/drivers/net/qlge/qlge_main.c
> +++ b/drivers/net/qlge/qlge_main.c
[...]
> @@ -3471,14 +3449,29 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
>  static void qlge_tx_timeout(struct net_device *ndev)
>  {
>  	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
> -	queue_delayed_work(qdev->workqueue, &qdev->asic_reset_work, 0);
> +	ql_queue_asic_error(qdev);
>  }
>  
>  static void ql_asic_reset_work(struct work_struct *work)
>  {
>  	struct ql_adapter *qdev =
>  	    container_of(work, struct ql_adapter, asic_reset_work.work);
> -	ql_cycle_adapter(qdev);
> +	int status;
> +
> +	status = ql_adapter_down(qdev);
> +	if (status)
> +		goto error;
> +
> +	status = ql_adapter_up(qdev);
> +	if (status)
> +		goto error;
> +	return;
> +error:
> +	QPRINTK(qdev, IFUP, ALERT,
> +		"Driver up/down cycle failed, closing device\n");
> +	rtnl_lock();
> +	dev_close(qdev->ndev);
> +	rtnl_unlock();

ql_asic_reset_work
-> dev_close
   -> qlge_close
      -> ql_adapter_down
         -> cancel_delayed_work_sync(&qdev->asic_reset_work);
            -> __cancel_work_timer
               -> wait_on_work
                  -> wait_on_cpu_work
                     -> wait_for_completion

Imho it will wait forever.

-- 
Ueimor
