From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v2 3/9] nfp: provide infrastructure for
 offloading flower based TC filters
Date: Wed, 28 Jun 2017 18:35:07 -0700
Message-ID: <20170628183507.3b3720ce@cakuba.netronome.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
        <1498681802-2897-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35442 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbdF2BfK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 21:35:10 -0400
Received: by mail-pf0-f179.google.com with SMTP id c73so42028211pfk.2
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 18:35:10 -0700 (PDT)
In-Reply-To: <1498681802-2897-4-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jun 2017 22:29:56 +0200, Simon Horman wrote:
> From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> 
> Adds a flower based TC offload handler for representor devices, this
> is in addition to the bpf based offload handler. The changes in this
> patch will be used in a follow-up patch to add tc flower offload to
> the NFP.
> 
> The flower app enables tc offloads on representors by default.
> 
> Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Thanks, two nits, since it seems like there will have to be another
respin.

> @@ -313,6 +317,8 @@ static int nfp_flower_vnic_init(struct nfp_app *app, struct nfp_net *nn,
>  static int nfp_flower_init(struct nfp_app *app)
>  {
>  	const struct nfp_pf *pf = app->pf;
> +	u64 version;
> +	int err;
>  
>  	if (!pf->eth_tbl) {
>  		nfp_warn(app->cpp, "FlowerNIC requires eth table\n");
> @@ -329,6 +335,18 @@ static int nfp_flower_init(struct nfp_app *app)
>  		return -EINVAL;
>  	}
>  
> +	version = nfp_rtsym_read_le(app->pf->rtbl, "hw_flower_version", &err);
> +	if (err) {
> +		nfp_warn(app->cpp, "FlowerNIC requires hw_flower_version memory symbol\n");
> +		return err;
> +	}
> +
> +	/* We need to ensure hardware has enough flower capabilities. */
> +	if (version != NFP_FLOWER_ALLOWED_VER) {
> +		nfp_warn(app->cpp, "FlowerNIC: unspported firmware version\n");

s/unspported/unsupported/

> +		return -EINVAL;
> +	}
> +
>  	app->priv = kzalloc(sizeof(struct nfp_flower_priv), GFP_KERNEL);
>  	if (!app->priv)
>  		return -ENOMEM;

> diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
> index de60cacd3362..f3552da3c277 100644
> --- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
> @@ -37,6 +37,7 @@
>  #include <net/devlink.h>
>  #include <net/switchdev.h>
>  
> +struct tc_to_netdev;
>  struct net_device;
>  struct nfp_app;
>  struct nfp_pf;
> @@ -109,6 +110,10 @@ struct nfp_port {
>  
>  extern const struct switchdev_ops nfp_port_switchdev_ops;
>  
> +int
> +nfp_port_setup_tc(struct net_device *netdev, u32 handle, u32 chain_index,

int can be on the same line
