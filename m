From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5] ibmveth: Add support for Large Receive Offload
Date: Tue, 14 Apr 2015 15:00:22 -0700
Message-ID: <1429048822.7346.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429043704-22552-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
	 <1429043704-22552-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Brian King <brking@linux.vnet.ibm.com>
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:33234 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbbDNWAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 18:00:24 -0400
Received: by igbpi8 with SMTP id pi8so55805991igb.0
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 15:00:23 -0700 (PDT)
In-Reply-To: <1429043704-22552-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-14 at 15:35 -0500, Thomas Falcon wrote:
> Enables receiving large packets from other LPARs. These packets
> have a -1 IP header checksum, so we must recalculate to have
> a valid checksum.
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/ibm/ibmveth.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
> index 08970c7..05eaca6a 100644
> --- a/drivers/net/ethernet/ibm/ibmveth.c
> +++ b/drivers/net/ethernet/ibm/ibmveth.c
> @@ -1092,6 +1092,7 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
>  	struct net_device *netdev = adapter->netdev;
>  	int frames_processed = 0;
>  	unsigned long lpar_rc;
> +	struct iphdr *iph;
>  
>  restart_poll:
>  	while (frames_processed < budget) {
> @@ -1134,8 +1135,20 @@ restart_poll:
>  			skb_put(skb, length);
>  			skb->protocol = eth_type_trans(skb, netdev);
>  
> -			if (csum_good)
> +			if (csum_good) {
>  				skb->ip_summed = CHECKSUM_UNNECESSARY;
> +				if (be16_to_cpu(skb->protocol) == ETH_P_IP) {
> +					skb_set_network_header(skb, 0);
> +					skb_set_transport_header(skb, sizeof(struct iphdr));
> +					iph = ip_hdr(skb);
> +
> +					/* If the IP checksum is not offloaded and if the packet
> +					 *  is large send, the checksum must be rebuilt.
> +					 */
> +					if (iph->check == 0xffff)
> +						iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);


How can this possibly work ?

Normally you would have to set iph->check to 0 before calling
ip_fast_csum(), as done in ip_send_check()
