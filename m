From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] route: allow to route in a peer netns via lwt
 framework
Date: Fri, 24 Jul 2015 08:28:43 -0600
Message-ID: <55B24B9B.4080001@cumulusnetworks.com>
References: <1437661349-17620-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com, tgraf@suug.ch
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38277 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbbGXO2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 10:28:46 -0400
Received: by iggf3 with SMTP id f3so17985727igg.1
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 07:28:46 -0700 (PDT)
In-Reply-To: <1437661349-17620-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/23/15 8:22 AM, Nicolas Dichtel wrote:
>   static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>   				 struct net_device *dev)
>   {
> +	int nsid = skb_lwt_netns_info(skb);
>   	struct pcpu_lstats *lb_stats;
>   	int len;
>
> +	if (nsid >= 0) {
> +		struct net *peernet = get_net_ns_by_id(dev_net(dev), nsid);
> +
> +		if (!peernet) {

If nsid is > 0 then the peer namespace should exist right? So for this 
failure path why not increment tx_error stat?


> +			kfree_skb(skb);
> +			goto end;
> +		}
> +
> +		dev_forward_skb(peernet->loopback_dev, skb);
> +		put_net(peernet);
> +		goto end;
> +	}
> +
>   	skb_orphan(skb);
>
>   	/* Before queueing this packet to netif_rx(),
