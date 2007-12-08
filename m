From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2/8] [TFRC]: Put RX/TX initialisation into tfrc.c
Date: Sat, 8 Dec 2007 15:13:17 -0200
Message-ID: <20071208171317.GC3180@ghostprotocols.net>
References: <11971083882331-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881862-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881667-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52146 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473AbXLHRNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Dec 2007 12:13:21 -0500
Content-Disposition: inline
In-Reply-To: <11971083881667-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Dec 08, 2007 at 10:06:22AM +0000, Gerrit Renker escreveu:
> This separates RX/TX initialisation and puts all packet history / loss intervals
> initialisation into tfrc.c.
> The organisation is uniform: slab declaration -> {rx,tx}_init() -> {rx,tx}_exit()

NAK, you can't call a __exit marked routine from a __init marked
routine.

- Arnaldo
 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/ccids/lib/packet_history.c |   68 ++++++++++++++++------------------
>  net/dccp/ccids/lib/tfrc.c           |   31 ++++++++++++----
>  2 files changed, 55 insertions(+), 44 deletions(-)
> 
> diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
> index 54cd23e..af0db71 100644
> --- a/net/dccp/ccids/lib/packet_history.c
> +++ b/net/dccp/ccids/lib/packet_history.c
> @@ -57,6 +57,22 @@ struct tfrc_tx_hist_entry {
>   */

<SNIP>

> +
> +void __exit tfrc_tx_packet_history_exit(void)
> +{
> +	if (tfrc_tx_hist_slab != NULL) {
> +		kmem_cache_destroy(tfrc_tx_hist_slab);
> +		tfrc_tx_hist_slab = NULL;
> +	}
> +}
> +

<SNIP>

> diff --git a/net/dccp/ccids/lib/tfrc.c b/net/dccp/ccids/lib/tfrc.c
> index 3a7a183..20763fa 100644
> --- a/net/dccp/ccids/lib/tfrc.c
> +++ b/net/dccp/ccids/lib/tfrc.c
> @@ -14,27 +14,42 @@ module_param(tfrc_debug, bool, 0444);
>  MODULE_PARM_DESC(tfrc_debug, "Enable debug messages");
>  #endif
>  
> +extern int  tfrc_tx_packet_history_init(void);
> +extern void tfrc_tx_packet_history_exit(void);
> +extern int  tfrc_rx_packet_history_init(void);
> +extern void tfrc_rx_packet_history_exit(void);
> +
>  extern int  dccp_li_init(void);
>  extern void dccp_li_exit(void);
> -extern int packet_history_init(void);
> -extern void packet_history_exit(void);
>  
>  static int __init tfrc_module_init(void)
>  {
>  	int rc = dccp_li_init();
>  
> -	if (rc == 0) {
> -		rc = packet_history_init();
> -		if (rc != 0)
> -			dccp_li_exit();
> -	}
> +	if (rc)
> +		goto out;
> +
> +	rc = tfrc_tx_packet_history_init();
> +	if (rc)
> +		goto out_free_loss_intervals;
>  
> +	rc = tfrc_rx_packet_history_init();
> +	if (rc)
> +		goto out_free_tx_history;
> +	return 0;
> +
> +out_free_tx_history:
> +	tfrc_tx_packet_history_exit();
> +out_free_loss_intervals:
> +	dccp_li_exit();
> +out:
>  	return rc;
>  }

<SNIP>
