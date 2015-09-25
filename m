From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: [PATCH RESEND] bnx2x:Add proper protection from concurrent
 users in	the function bnx2_open
Date: Fri, 25 Sep 2015 09:38:38 +0000
Message-ID: <31AFFC7280259C4184970ABA9AFE8B93E46FB0FF@avmb3.qlogic.org>
References: <1443133499-9456-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>,
	Sony Chacko <sony.chacko@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443133499-9456-1-git-send-email-xerofoify@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: dept_hsg_linux_nic_dev-bounces@qlclistserver.qlogic.com
> [mailto:dept_hsg_linux_nic_dev-bounces@qlclistserver.qlogic.com] On Behalf
> Of Nicholas Krause
> Sent: Friday, September 25, 2015 3:55 AM
> To: Sony Chacko
> Cc: Dept-GE Linux NIC Dev; linux-kernel; netdev
> Subject: [PATCH RESEND] bnx2x:Add proper protection from concurrent users in
> the function bnx2_open
> 
> This fixes bnx2_open to have proper protection from concurrent users as it is
> never properly locked with rtnl_lock/unlock before executing its code that can
> have issues with other threads of execution executing on these data structures
> at the same time. Due to this fix it by making this locking internal to the function
> bnx2_open by unlocking before and after the critical region with the function
> pair rtnl_lock/unlock.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c
> b/drivers/net/ethernet/broadcom/bnx2.c
> index 2b66ef3..0c31c49 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -6331,13 +6331,13 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
>  	return netif_set_real_num_rx_queues(bp->dev, bp->num_rx_rings);  }
> 
> -/* Called with rtnl_lock */
>  static int
>  bnx2_open(struct net_device *dev)
>  {
>  	struct bnx2 *bp = netdev_priv(dev);
>  	int rc;
> 
> +	rtnl_lock();
>  	rc = bnx2_request_firmware(bp);
>  	if (rc < 0)
>  		goto out;
> @@ -6411,6 +6411,7 @@ open_err:
>  	bnx2_free_mem(bp);
>  	bnx2_del_napi(bp);
>  	bnx2_release_firmware(bp);
> +	rtnl_unlock();
>  	goto out;
>  }
> 
> --

It's not an appropriate change. Acquiring rtnl_lock() in device's ndo_open() handler will cause deadlock
as OS already take this lock before calling ndo_open().

Also, the subject line is not correct - it was supposed to be bnx2 change, not bnx2x.

Thanks,
Manish
