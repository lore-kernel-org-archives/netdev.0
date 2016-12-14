From: marcelo.leitner@gmail.com
Subject: Re: [PATCH net] ibmveth: calculate gso_segs for large packets
Date: Wed, 14 Dec 2016 18:39:04 -0200
Message-ID: <20161214203904.GA13422@localhost.localdomain>
References: <1481674509-14256-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
        pradeeps@linux.vnet.ibm.com, jmaxwell37@gmail.com, zdai@us.ibm.com,
        eric.dumazet@gmail.com
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60446 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756681AbcLNUjI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Dec 2016 15:39:08 -0500
Content-Disposition: inline
In-Reply-To: <1481674509-14256-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 06:15:09PM -0600, Thomas Falcon wrote:
> Include calculations to compute the number of segments
> that comprise an aggregated large packet.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>


> ---
>  drivers/net/ethernet/ibm/ibmveth.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
> index fbece63..a831f94 100644
> --- a/drivers/net/ethernet/ibm/ibmveth.c
> +++ b/drivers/net/ethernet/ibm/ibmveth.c
> @@ -1181,7 +1181,9 @@ static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
>  
>  static void ibmveth_rx_mss_helper(struct sk_buff *skb, u16 mss, int lrg_pkt)
>  {
> +	struct tcphdr *tcph;
>  	int offset = 0;
> +	int hdr_len;
>  
>  	/* only TCP packets will be aggregated */
>  	if (skb->protocol == htons(ETH_P_IP)) {
> @@ -1208,14 +1210,20 @@ static void ibmveth_rx_mss_helper(struct sk_buff *skb, u16 mss, int lrg_pkt)
>  	/* if mss is not set through Large Packet bit/mss in rx buffer,
>  	 * expect that the mss will be written to the tcp header checksum.
>  	 */
> +	tcph = (struct tcphdr *)(skb->data + offset);
>  	if (lrg_pkt) {
>  		skb_shinfo(skb)->gso_size = mss;
>  	} else if (offset) {
> -		struct tcphdr *tcph = (struct tcphdr *)(skb->data + offset);
> -
>  		skb_shinfo(skb)->gso_size = ntohs(tcph->check);
>  		tcph->check = 0;
>  	}
> +
> +	if (skb_shinfo(skb)->gso_size) {
> +		hdr_len = offset + tcph->doff * 4;
> +		skb_shinfo(skb)->gso_segs =
> +				DIV_ROUND_UP(skb->len - hdr_len,
> +					     skb_shinfo(skb)->gso_size);
> +	}
>  }
>  
>  static int ibmveth_poll(struct napi_struct *napi, int budget)
> -- 
> 1.8.3.1
> 
