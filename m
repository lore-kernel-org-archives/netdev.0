From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 03/12] i40e: Handle a single mss packet with more
 than 8 frags
Date: Sat, 15 Nov 2014 10:21:35 -0800
Message-ID: <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Serey Kong <serey.kong@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Shannon Nelson <shannon.nelson@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:52489 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbaKOSVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 13:21:38 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so1383524igd.8
        for <netdev@vger.kernel.org>; Sat, 15 Nov 2014 10:21:38 -0800 (PST)
In-Reply-To: <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-14 at 22:08 -0800, Jeff Kirsher wrote:
> From: Serey Kong <serey.kong@intel.com>
> 
> This handles the case where a single packet with more than 8 data
> descriptors triggers a Malicious Driver Detect event in the device.
> 
> Change-ID: I2bfd657fd036bed616863e121f6aa86a35d2194c
> Signed-off-by: Serey Kong <serey.kong@intel.com>
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 14 ++++++++++----
>  drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  1 +
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 14 ++++++++++----
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.h |  1 +
>  4 files changed, 22 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index 3195d82..9731026 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -2113,12 +2113,12 @@ static void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
>  			const u8 hdr_len, u32 td_cmd, u32 td_offset)
>  #endif
>  {
> -	unsigned int data_len = skb->data_len;
> -	unsigned int size = skb_headlen(skb);
>  	struct skb_frag_struct *frag;
>  	struct i40e_tx_buffer *tx_bi;
>  	struct i40e_tx_desc *tx_desc;
>  	u16 i = tx_ring->next_to_use;
> +	unsigned int data_len;
> +	unsigned int size;
>  	u32 td_tag = 0;
>  	dma_addr_t dma;
>  	u16 gso_segs;
> @@ -2129,10 +2129,16 @@ static void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
>  			 I40E_TX_FLAGS_VLAN_SHIFT;
>  	}
>  
> -	if (tx_flags & (I40E_TX_FLAGS_TSO | I40E_TX_FLAGS_FSO))
> +	if (tx_flags & (I40E_TX_FLAGS_TSO | I40E_TX_FLAGS_FSO)) {
>  		gso_segs = skb_shinfo(skb)->gso_segs;
> -	else
> +	} else {
>  		gso_segs = 1;
> +		if (skb_shinfo(skb)->nr_frags >= I40E_MAX_BUFFER_TXD)
> +			skb_linearize(skb);

What exactly happens if skb_linearize() fails ?

Is this "Malicious Driver Detect event" fatal or simply packet is
dropped without additional harm ?
