From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH net-next V7 3/4] xen-netback: coalesce
 slots in TX path and fix regressions
Date: Tue, 30 Apr 2013 14:55:49 +0100
Message-ID: <517FE98502000078000D21FC@nat28.tlf.novell.com>
References: <1366633243-17775-1-git-send-email-wei.liu2@citrix.com>
 <1366633243-17775-4-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <ian.campbell@citrix.com>, <davem@davemloft.net>,
	<xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:55156 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760643Ab3D3NzI convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Tue, 30 Apr 2013 09:55:08 -0400
In-Reply-To: <1366633243-17775-4-git-send-email-wei.liu2@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 22.04.13 at 14:20, Wei Liu <wei.liu2@citrix.com> wrote:
> @@ -1256,11 +1394,12 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
>  	struct sk_buff *skb;
>  	int ret;
>  
> -	while (((nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS) &&
> +	while ((nr_pending_reqs(netbk) + XEN_NETIF_NR_SLOTS_MIN
> +		< MAX_PENDING_REQS) &&
>  		!list_empty(&netbk->net_schedule_list)) {
>  		struct xenvif *vif;
>  		struct xen_netif_tx_request txreq;
> -		struct xen_netif_tx_request txfrags[MAX_SKB_FRAGS];
> +		struct xen_netif_tx_request txfrags[max_skb_slots];

With max_skb_slots only having a lower limit enforced, this
basically gives the admin a way to crash the kernel without
necessarily being aware (and, considering that this would be
memory corruption, without necessarily being able to readily
connect the crash to the too high module parameter).

I was anyway of the opinion that dynamically sized stack
objects aren't really desirable to have in the kernel.

In any event, with a few tweaks netbk_count_requests() could
certainly be made not touch txp-s past XEN_NETIF_NR_SLOTS_MIN
(maybe XEN_NETIF_NR_SLOTS_MIN + 1).

Jan

>  		struct page *page;
>  		struct xen_netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX-1];
>  		u16 pending_idx;
