From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH net v4 1/6] bnx2x: properly initialize statistic counters
Date: Mon, 12 Aug 2013 16:08:18 -0400
Message-ID: <20130812200818.GA20031@d2.synalogic.ca>
References: <1375738544-8695-1-git-send-email-dmitry@broadcom.com>
 <1375738544-8695-2-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	Ariel Elior <ariele@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:37951 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938Ab3HLUIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 16:08:23 -0400
Received: by mail-qc0-f180.google.com with SMTP id j10so3680727qcx.11
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 13:08:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1375738544-8695-2-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/08/06 00:35, Dmitry Kravkov wrote:
> This prevent second statistics query be sent before first one is complete.
> This is required since two outstanding queries may cause FW assert.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
> index 98366ab..a22ad61 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
> @@ -1589,12 +1589,17 @@ void bnx2x_memset_stats(struct bnx2x *bp)
>  
>  void bnx2x_stats_init(struct bnx2x *bp)
>  {
> -	int /*abs*/port = BP_PORT(bp);
> +	struct stats_counter *counters = &bp->fw_stats_data->storm_counters;
>  	int mb_idx = BP_FW_MB_IDX(bp);
> +	int port = BP_PORT(bp);
>  
>  	bp->stats_pending = 0;
>  	bp->executer_idx = 0;
>  	bp->stats_counter = 0;
> +	counters->xstats_counter = cpu_to_le16(0xFFFF);
> +	counters->tstats_counter = cpu_to_le16(0xFFFF);
> +	counters->ustats_counter = cpu_to_le16(0xFFFF);
> +	counters->cstats_counter = cpu_to_le16(0xFFFF);

I think the following code executed a little later becomes redundant:

static void bnx2x_prep_fw_stats_req(struct bnx2x *bp)
{
[...]
	/* prepare to the first stats ramrod (will be completed with
	 * the counters equal to zero) - init counters to somethig different.
	 */
	memset(&bp->fw_stats_data->storm_counters, 0xff,
	       sizeof(struct stats_counter));
