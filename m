From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH net-next v2 4/9] nfp: extend flower add flow offload
Date: Thu, 29 Jun 2017 14:18:07 +0800
Message-ID: <ceb96fbd-c768-5bb2-cb44-f1bc7ecb4849@huawei.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-5-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <oss-drivers@netronome.com>,
        "Pieter Jansen van Vuuren" <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:9320 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751669AbdF2GVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 02:21:39 -0400
In-Reply-To: <1498681802-2897-5-git-send-email-simon.horman@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +
> +	if (mask_basic->n_proto) {
cpu_to_be16（mask_basic->n_proto）
remove cpu_to_be16 in case.
> +		/* Ethernet type is present in the key. */
> +		switch (key_basic->n_proto) {
> +		case cpu_to_be16(ETH_P_IP):
> +			key_layer |= NFP_FLOWER_LAYER_IPV4;
> +			key_size += sizeof(struct nfp_flower_ipv4);
> +			break;
> +
> +		case cpu_to_be16(ETH_P_IPV6):
> +			key_layer |= NFP_FLOWER_LAYER_IPV6;
> +			key_size += sizeof(struct nfp_flower_ipv6);
> +			break;
> +
> +		/* Currently we do not offload ARP
> +		 * because we rely on it to get to the host.
> +		 */
> +		case cpu_to_be16(ETH_P_ARP):
> +			return -EOPNOTSUPP;
> +
> +		/* Will be included in layer 2. */
> +		case cpu_to_be16(ETH_P_8021Q):
> +			break;
> +
> +		default:
> +			/* Other ethtype - we need check the masks for the
> +			 * remainer of the key to ensure we can offload.
> +			 */
> +			if (nfp_flower_check_higher_than_mac(flow))
> +				return -EOPNOTSUPP;
> +			break;
> +		}
> +	}
> +
> +	if (mask_basic->ip_proto) {
> +		/* Ethernet type is present in the key. */
> +		switch (key_basic->ip_proto) {
> +		case IPPROTO_TCP:
> +		case IPPROTO_UDP:
> +		case IPPROTO_SCTP:
> +		case IPPROTO_ICMP:
> +		case IPPROTO_ICMPV6:
> +			key_layer |= NFP_FLOWER_LAYER_TP;
> +			key_size += sizeof(struct nfp_flower_tp_ports);
> +			break;
> +		default:
> +			/* Other ip proto - we need check the masks for the
> +			 * remainer of the key to ensure we can offload.
> +			 */
> +			return -EOPNOTSUPP;
> +		}
> +	}
> +
> +	ret_key_ls->key_layer = key_layer;
> +	ret_key_ls->key_layer_two = key_layer_two;
> +	ret_key_ls->key_size = key_size;
> +
> +	return 0;
> +}
> +
> +static struct nfp_fl_payload *
> +nfp_flower_allocate_new(struct nfp_fl_key_ls *key_layer)
> +{
> +	struct nfp_fl_payload *flow_pay;
> +
> +	flow_pay = kmalloc(sizeof(*flow_pay), GFP_KERNEL);
> +	if (!flow_pay)
> +		return NULL;
> +
> +	flow_pay->meta.key_len = key_layer->key_size;
> +	flow_pay->unmasked_data = kmalloc(key_layer->key_size, GFP_KERNEL);
> +	if (!flow_pay->unmasked_data)
> +		goto err_free_flow;
> +
> +	flow_pay->meta.mask_len = key_layer->key_size;
> +	flow_pay->mask_data = kmalloc(key_layer->key_size, GFP_KERNEL);
> +	if (!flow_pay->mask_data)
> +		goto err_free_unmasked;
> +
> +	flow_pay->meta.flags = 0;
> +
> +	return flow_pay;
> +
> +err_free_unmasked:
> +	kfree(flow_pay->unmasked_data);
> +err_free_flow:
> +	kfree(flow_pay);
> +	return NULL;
> +}
> +
> +static void nfp_flower_deallocate_nfp(struct nfp_fl_payload *flow_pay)
> +{
> +	kfree(flow_pay->mask_data);
> +	kfree(flow_pay->unmasked_data);
> +	kfree(flow_pay);
> +}
> +
>  /**
>   * nfp_flower_add_offload() - Adds a new flow to hardware.
>   * @app:	Pointer to the APP handle
> @@ -58,7 +197,32 @@ static int
>  nfp_flower_add_offload(struct nfp_app *app, struct net_device *netdev,
>  		       struct tc_cls_flower_offload *flow)
>  {
> -	return -EOPNOTSUPP;
> +	struct nfp_fl_payload *flow_pay;
> +	struct nfp_fl_key_ls *key_layer;
> +	int err;
> +
> +	key_layer = kmalloc(sizeof(*key_layer), GFP_KERNEL);
> +	if (!key_layer)
> +		return -ENOMEM;
> +
> +	err = nfp_flower_calculate_key_layers(key_layer, flow);
> +	if (err)
> +		goto err_free_key_ls;
> +
> +	flow_pay = nfp_flower_allocate_new(key_layer);
> +	if (!flow_pay) {
> +		err = -ENOMEM;
> +		goto err_free_key_ls;
> +	}
> +
> +	/* TODO: Complete flower_add_offload. */
> +	err = -EOPNOTSUPP;
> +
> +	nfp_flower_deallocate_nfp(flow_pay);
> +
> +err_free_key_ls:
> +	kfree(key_layer);
> +	return err;
>  }
>  
>  /**
> 
