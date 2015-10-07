From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net-next] cxgb4: Enhance driver to update FW, when FW is too old
Date: Wed, 7 Oct 2015 15:09:57 -0400
Message-ID: <20151007190956.GA26590@hmsreliant.think-freely.org>
References: <1444189900-5940-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	nirranjan@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60424 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbbJGTKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 15:10:13 -0400
Content-Disposition: inline
In-Reply-To: <1444189900-5940-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 07, 2015 at 09:21:40AM +0530, Hariprasad Shenai wrote:
> t4_check_fw_version() can return several error codes (-EINVAL, -EBUSY,
> -EAGAIN). The present code sets the adapter state to UNINIT only if its
> an EFAULT. In all the error cases set the adapter to uninitialized state.
> 
> In t4_check_fw_version() if call to t4_read_flash() fails, repeat the
> operation a few times before returning failure.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 +-
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 6 +++++-
>  2 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index 9f1f5b2..c29227e 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -3698,7 +3698,7 @@ static int adap_init0(struct adapter *adap)
>  	t4_get_tp_version(adap, &adap->params.tp_vers);
>  	ret = t4_check_fw_version(adap);
>  	/* If firmware is too old (not supported by driver) force an update. */
> -	if (ret == -EFAULT)
> +	if (ret)
>  		state = DEV_STATE_UNINIT;
>  	if ((adap->flags & MASTER_PF) && state != DEV_STATE_INIT) {
>  		struct fw_info *fw_info;
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> index dc6ce31..874b599 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> @@ -2981,11 +2981,15 @@ int t4_get_exprom_version(struct adapter *adap, u32 *vers)
>   */
>  int t4_check_fw_version(struct adapter *adap)
>  {
> -	int ret, major, minor, micro;
> +	int i, ret, major, minor, micro;
>  	int exp_major, exp_minor, exp_micro;
>  	unsigned int chip_version = CHELSIO_CHIP_VERSION(adap->params.chip);
>  
>  	ret = t4_get_fw_version(adap, &adap->params.fw_vers);
> +	/* Try multiple times before returning error */
> +	for (i = 0; ret && i < 3; i++)
> +		ret = t4_get_fw_version(adap, &adap->params.fw_vers);
> +
Shouldn't you only retry if you get an error that indicates the error is
transient (i.e. EBUSY or EAGAIN)?
Neil


>  	if (ret)
>  		return ret;
>  
