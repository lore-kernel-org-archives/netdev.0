From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH net v2] xen-netback: fix fragment detection in checksum
 setup
Date: Fri, 29 Nov 2013 13:35:56 +0800
Message-ID: <529827BC.8050207@oracle.com>
References: <1385645032-29848-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45651 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878Ab3K2FgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 00:36:07 -0500
In-Reply-To: <1385645032-29848-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013/11/28 21:23, Paul Durrant wrote:
> The code to detect fragments in checksum_setup() was missing for IPv4 and
> too eager for IPv6. (It transpires that Windows seems to send IPv6 packets
> with a fragment header even if they are not a fragment - i.e. offset is zero,
> and M bit is not set).
>
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> ---
> v2
>
> - Added comments noting what fragment/offset masks mean
>    
>   drivers/net/xen-netback/netback.c |   33 ++++++++++++++++++++++++++++++---
>   1 file changed, 30 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 919b650..c7464d8 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1165,15 +1165,28 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
>   	struct iphdr *iph = (void *)skb->data;
>   	unsigned int header_size;
>   	unsigned int off;
> +	bool fragment;
>   	int err = -EPROTO;
>   
> +	fragment = false;

Is it better to initialize fragment directly as following?
bool fragment = false;

> +
>   	off = sizeof(struct iphdr);
>   
>   	header_size = skb->network_header + off + MAX_IPOPTLEN;
>   	maybe_pull_tail(skb, header_size);
>   
> +	/* 3fff -> fragment offset != 0 OR more fragments */
> +	if (ntohs(iph->frag_off) & 0x3fff)
> +		fragment = true;
> +
>   	off = iph->ihl * 4;
>   
> +	if (fragment) {
> +		if (net_ratelimit())
> +			netdev_err(vif->dev, "Packet is a fragment!\n");
> +		goto out;
> +	}
> +
>   	switch (iph->protocol) {
>   	case IPPROTO_TCP:
>   		if (!skb_partial_csum_set(skb, off,
> @@ -1237,6 +1250,7 @@ static int checksum_setup_ipv6(struct xenvif *vif, struct sk_buff *skb,
>   	bool fragment;
>   	bool done;
>   
> +	fragment = false;
>   	done = false;

Same as above for "done" and "fragment"...

Thanks
Annie
