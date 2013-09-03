From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net] bnx2x: bail out if unable to acquire stats_sema
Date: Tue, 3 Sep 2013 15:51:59 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20D8F504@SJEXCHMB06.corp.ad.broadcom.com>
References: <1378223159-8710-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4492 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754607Ab3ICPwO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 11:52:14 -0400
In-Reply-To: <1378223159-8710-1-git-send-email-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Michal Schmidt [mailto:mschmidt@redhat.com]
> Sent: Tuesday, September 03, 2013 6:46 PM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org; Dmitry Kravkov; Ariel Elior; Eilon Greenstein
> Subject: [PATCH net] bnx2x: bail out if unable to acquire stats_sema
> 
> If we fail to acquire stats_sema in the specified time limit, the chip is
> probably dead. It probably does not matter whether we try to continue or
> not, but certainly we should not up() the semaphore afterwards.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 24
> +++++++++++++++++------
>  1 file changed, 18 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
> index 86436c7..d60bb8b 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
> @@ -538,16 +538,20 @@ static void __bnx2x_stats_start(struct bnx2x *bp)
> 
>  static void bnx2x_stats_start(struct bnx2x *bp)  {
> -	if (down_timeout(&bp->stats_sema, HZ/10))
> +	if (down_timeout(&bp->stats_sema, HZ/10)) {
>  		BNX2X_ERR("Unable to acquire stats lock\n");
> +		return;
> +	}
>  	__bnx2x_stats_start(bp);
>  	up(&bp->stats_sema);
>  }
> 
>  static void bnx2x_stats_pmf_start(struct bnx2x *bp)  {
> -	if (down_timeout(&bp->stats_sema, HZ/10))
> +	if (down_timeout(&bp->stats_sema, HZ/10)) {
>  		BNX2X_ERR("Unable to acquire stats lock\n");
> +		return;
> +	}
>  	bnx2x_stats_comp(bp);
>  	__bnx2x_stats_pmf_update(bp);
>  	__bnx2x_stats_start(bp);
> @@ -556,8 +560,10 @@ static void bnx2x_stats_pmf_start(struct bnx2x *bp)
> 
>  static void bnx2x_stats_pmf_update(struct bnx2x *bp)  {
> -	if (down_timeout(&bp->stats_sema, HZ/10))
> +	if (down_timeout(&bp->stats_sema, HZ/10)) {
>  		BNX2X_ERR("Unable to acquire stats lock\n");
> +		return;
> +	}
>  	__bnx2x_stats_pmf_update(bp);
>  	up(&bp->stats_sema);
>  }
> @@ -569,8 +575,10 @@ static void bnx2x_stats_restart(struct bnx2x *bp)
>  	 */
>  	if (IS_VF(bp))
>  		return;
> -	if (down_timeout(&bp->stats_sema, HZ/10))
> +	if (down_timeout(&bp->stats_sema, HZ/10)) {
>  		BNX2X_ERR("Unable to acquire stats lock\n");
> +		return;
> +	}
>  	bnx2x_stats_comp(bp);
>  	__bnx2x_stats_start(bp);
>  	up(&bp->stats_sema);
> @@ -1361,8 +1369,10 @@ static void bnx2x_stats_stop(struct bnx2x *bp)  {
>  	int update = 0;
> 
> -	if (down_timeout(&bp->stats_sema, HZ/10))
> +	if (down_timeout(&bp->stats_sema, HZ/10)) {
>  		BNX2X_ERR("Unable to acquire stats lock\n");
> +		return;
> +	}
> 
>  	bp->stats_started = false;
> 
> @@ -1997,8 +2007,10 @@ void bnx2x_afex_collect_stats(struct bnx2x *bp,
> void *void_afex_stats,  void bnx2x_stats_safe_exec(struct bnx2x *bp,
>  			   void (func_to_exec)(void *cookie),
>  			   void *cookie){
> -	if (down_timeout(&bp->stats_sema, HZ/10))
> +	if (down_timeout(&bp->stats_sema, HZ/10)) {
>  		BNX2X_ERR("Unable to acquire stats lock\n");
> +		return;
> +	}
>  	bnx2x_stats_comp(bp);
>  	func_to_exec(cookie);
>  	__bnx2x_stats_start(bp);
> --
> 1.8.3.1
> 
Acked-by: Dmitry Kravkov <dmitry@broadcom.com>
