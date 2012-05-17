From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [net-next 3/4] e1000: look in the page and not in skb->data for
 the last byte
Date: Thu, 17 May 2012 13:38:55 +0200
Message-ID: <4FB4E34F.2050004@linutronix.de>
References: <1337254070-32500-1-git-send-email-jeffrey.t.kirsher@intel.com> <1337254070-32500-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:43958 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757895Ab2EQLjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 07:39:02 -0400
In-Reply-To: <1337254070-32500-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2012 01:27 PM, Jeff Kirsher wrote:
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index fefbf4d..6ac80c8 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -4066,7 +4066,11 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
>   		/* errors is only valid for DD + EOP descriptors */
>   		if (unlikely((status&  E1000_RXD_STAT_EOP)&&
>   		(rx_desc->errors&  E1000_RXD_ERR_FRAME_ERR_MASK))) {
> -			u8 last_byte = *(skb->data + length - 1);
> +			u8 *mapped;
> +			u8 last_byte;
> +
> +			mapped = kmap_atomic(buffer_info->page);
> +			last_byte = *(mapped + length - 1);
>   			if (TBI_ACCEPT(hw, status, rx_desc->errors, length,
>   				       last_byte)) {
>   				spin_lock_irqsave(&adapter->stats_lock,

This is not what I've sent. My original patch [0] hat a unmap as well. 
One comment was, that kmap_atomic() is too much overhead because the 
page can never be highmem. So I changed it to page_address() [1].

[0] http://permalink.gmane.org/gmane.linux.drivers.e1000.devel/10008
[1] http://permalink.gmane.org/gmane.linux.drivers.e1000.devel/10012

Sebastian
