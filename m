From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC] [Patch 3/4] dccp: Add unregister function
Date: Sat, 20 Dec 2008 22:35:33 -0200
Message-ID: <20081221003533.GB5700@ghostprotocols.net>
References: <20081218053349.GA6172@gerrit.erg.abdn.ac.uk> <20081218.191534.194793981.davem@davemloft.net> <20081219052446.GA3651@gerrit.erg.abdn.ac.uk> <20081218.222842.174783235.davem@davemloft.net> <20081220080821.GD3853@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52158 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752047AbYLUAfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2008 19:35:38 -0500
Content-Disposition: inline
In-Reply-To: <20081220080821.GD3853@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Dec 20, 2008 at 09:08:21AM +0100, Gerrit Renker escreveu:
> dccp: Add unregister function
> 
> This adds an unregister function to facilitate unloading the DCCP module.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/ccid.h  |    3 ++-
>  net/dccp/ccid.c  |   48 +++++++++++++++++++++++++++---------------------
>  net/dccp/proto.c |    3 ++-
>  3 files changed, 31 insertions(+), 23 deletions(-)
> 
> --- a/net/dccp/ccid.h
> +++ b/net/dccp/ccid.h
> @@ -91,7 +91,8 @@ extern struct ccid_operations ccid2_ops;
>  extern struct ccid_operations ccid3_ops;
>  #endif
>  
> -extern int ccids_register_builtins(void);
> +extern int  ccid_register_builtins(void);
> +extern void ccid_unregister_builtins(void);
>  
>  struct ccid {
>  	struct ccid_operations *ccid_ops;
> --- a/net/dccp/ccid.c
> +++ b/net/dccp/ccid.c
> @@ -123,7 +123,7 @@ static int ccid_register(struct ccid_ope
>  	return 0;
>  }
>  
> -static int ccid_unregister(struct ccid_operations *ccid_ops)
> +static void ccid_unregister(struct ccid_operations *ccid_ops)
>  {
>  	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_tx_slab);
>  	ccid_ops->ccid_hc_tx_slab = NULL;
> @@ -132,28 +132,8 @@ static int ccid_unregister(struct ccid_o
>  
>  	pr_info("CCID: Unregistered CCID %d (%s)\n",
>  		ccid_ops->ccid_id, ccid_ops->ccid_name);
> -	return 0;
> -}
> -
> -int ccids_register_builtins(void)
> -{
> -	int i, err;
> -
> -	for (i = 0; i < ARRAY_SIZE(ccids); i++) {
> -		err = ccid_register(ccids[i]);
> -		if (err)
> -			goto unwind_registrations;
> -	}
> -
> -	return 0;
> -
> -unwind_registrations:
> -	while(--i >= 0)
> -		ccid_unregister(ccids[i]);
> -	return err;
>  }

Why remove this?
  
> -
>  static struct ccid_operations *ccid_find_by_id(const u8 id)
>  {
>  	int i;
> @@ -231,3 +211,29 @@ void ccid_hc_tx_delete(struct ccid *ccid
>  }
>  
>  EXPORT_SYMBOL_GPL(ccid_hc_tx_delete);
> +
> +int __init ccid_register_builtins(void)
> +{
> +	int i, err;
> +
> +	for (i = 0; i < ARRAY_SIZE(ccids); i++) {
> +		err = ccid_register(ccids[i]);
> +		if (err)
> +			goto unwind_registrations;
> +	}
> +
> +	return 0;
> +
> +unwind_registrations:
> +	while(--i >= 0)
> +		ccid_unregister(ccids[i]);
> +	return err;
> +}

Ah, just moved it around.

> +void ccid_unregister_builtins(void)
> +{
> +	int i;
> +
> +	for (i = 0; i < ARRAY_SIZE(ccids); i++)
> +		ccid_unregister(ccids[i]);
> +}
> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -1119,7 +1119,7 @@ static int __init dccp_init(void)
>  	if (rc)
>  		goto out_ackvec_exit;
>  
> -	rc = ccids_register_builtins();
> +	rc = ccid_register_builtins();
>  	if (rc)
>  		goto out_sysctl_exit;
>  
> @@ -1148,6 +1148,7 @@ out_free_bind_bucket_cachep:
>  
>  static void __exit dccp_fini(void)
>  {
> +	ccid_unregister_builtins();
>  	dccp_mib_exit();
>  	free_pages((unsigned long)dccp_hashinfo.bhash,
>  		   get_order(dccp_hashinfo.bhash_size *

OK:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
