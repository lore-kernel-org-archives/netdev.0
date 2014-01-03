From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] bridge: Fix crash with vlan filtering and tcpdump
Date: Fri, 03 Jan 2014 21:06:37 +0300
Message-ID: <52C6FC2D.1000800@cogentembedded.com>
References: <1388765553-12965-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:63060 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbaACRGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 12:06:34 -0500
Received: by mail-lb0-f181.google.com with SMTP id q8so8349193lbi.12
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 09:06:33 -0800 (PST)
In-Reply-To: <1388765553-12965-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/03/2014 07:12 PM, Vlad Yasevich wrote:

> When the vlan filtering is enabled on the bridge, but
> the filter is not configured on the bridge device itself,
> running tcpdump on the bridge device will result in a
> an Ooops with NULL pointer dereference.  The reason
> is that br_pass_frame_up() will bypass the vlan
> check because promisc flag is set.  It will then try
> to get the table pointer and process the packet based
> on the table.  Since the table pointer is NULL, we oops.
> Catch this special condition in br_handle_vlan().

> Reported-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
[...]

> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index af5ebd1..ea0c29b 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -144,6 +144,18 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
>   	if (!br->vlan_enabled)
>   		goto out;
>
> +	/* Vlan filter table must be configrured at this point.  The

    Only "configured".

> +	 * only exception is the bridge is set in promisc mode and the
> +	 * packet is destined for the bridge device.  In this case
> +	 * pass the packet as is.
> +	 */
> +	if (!pv) {
> +       		if ((br->dev->flags & IFF_PROMISC) && skb->dev == br->dev)

    You've indented this *if* too much.

> +			goto out;
> +		else
> +			BUG();
> +	}
> +

WBR, Sergei
