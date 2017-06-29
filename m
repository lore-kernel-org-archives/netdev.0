From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v2 8/9] nfp: add a stats handler for flower
 offloads
Date: Wed, 28 Jun 2017 18:28:17 -0700
Message-ID: <20170628182817.13f9d7c7@cakuba.netronome.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
        <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36095 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751557AbdF2B2V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 21:28:21 -0400
Received: by mail-pf0-f180.google.com with SMTP id q86so41878953pfl.3
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 18:28:21 -0700 (PDT)
In-Reply-To: <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jun 2017 22:30:01 +0200, Simon Horman wrote:
> @@ -288,7 +292,21 @@ nfp_flower_del_offload(struct nfp_app *app, struct net_device *netdev,
>  static int
>  nfp_flower_get_stats(struct nfp_app *app, struct tc_cls_flower_offload *flow)
>  {
> -	return -EOPNOTSUPP;
> +	struct nfp_fl_payload *nfp_flow;
> +
> +	nfp_flow = nfp_flower_find_in_fl_table(app, flow->cookie);
> +	if (!nfp_flow)
> +		return -EINVAL;
> +
> +	spin_lock(&nfp_flow->lock);
> +	tcf_exts_stats_update(flow->exts, nfp_flow->stats.bytes,
> +			      nfp_flow->stats.pkts, nfp_flow->stats.used);
> +
> +	nfp_flow->stats.pkts = 0;
> +	nfp_flow->stats.bytes = 0;
> +	spin_unlock(&nfp_flow->lock);
> +
> +	return 0;
>  }

This needs to take spin_lock_bh() to lock out the RX path safely :(
