From: Rick Jones <rick.jones2@hp.com>
Subject: Re: twice past the taps, thence out to net?
Date: Fri, 16 Dec 2011 11:35:00 -0800
Message-ID: <4EEB9D64.5080901@hp.com>
References: <4EE8F884.1010304@hp.com> <CAGK4HS-+jj9cvvirDm96oRvRJdwC+2kjE_LnSOXBuQy0pfnQjg@mail.gmail.com> <1323970998.2769.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4EEA3D58.5010101@hp.com> <20111215104440.1eef9e47@s6510.linuxnetplumber.net> <1323975606.2769.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4EEA730E.5010405@hp.com> <1324009676.2562.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org,
	Matthew Vick <matthew.vick@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:7190 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760583Ab1LPTfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 14:35:04 -0500
In-Reply-To: <1324009676.2562.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> but is that getting a little close?
>>
>> rick jones
>
> Sure !
>
> I only pointed out a possible problem, and not gave a full patch, since
> we also need to change the opposite threshold (when we XON the queue at
> TX completion)
>
> You can see its not even consistent with the minimum for a single TSO
> frame ! Most probably your high requeue numbers come from this too low
> value given the real requirements of the hardware (4 + nr_frags
> descriptors per skb)
>
> /* How many Tx Descriptors do we need to call netif_wake_queue ? */
> #define IGB_TX_QUEUE_WAKE   16
>
>
> Maybe we should CC Intel guys
>
> Could you try following patch ?

I would *love* to.  All my accessible igb-driven hardware is in an 
environment locked to the kernels already there :(  Not that it makes it 
more possible for me to do it, but I suspect it does not require 30 
receivers to reproduce the dups with netperf TCP_STREAM.  Particularly 
if the tx queue len is at 256 it may only take 6 or 8. In fact let me 
try that now...

Yep, with just 8 destinations/concurrent TCP_STREAM tests from the one 
system one can still see the duplicates in the packet trace taken on the 
sender.

Perhaps we can trouble the Intel guys to try to reproduce what I've seen?

rick

>
> Thanks !
>
> diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
> index c69feeb..93ce118 100644
> --- a/drivers/net/ethernet/intel/igb/igb.h
> +++ b/drivers/net/ethernet/intel/igb/igb.h
> @@ -51,8 +51,8 @@ struct igb_adapter;
>   /* TX/RX descriptor defines */
>   #define IGB_DEFAULT_TXD                  256
>   #define IGB_DEFAULT_TX_WORK		 128
> -#define IGB_MIN_TXD                       80
> -#define IGB_MAX_TXD                     4096
> +#define IGB_MIN_TXD		max_t(unsigned, 80U, IGB_TX_QUEUE_WAKE * 2)
> +#define IGB_MAX_TXD             4096
>
>   #define IGB_DEFAULT_RXD                  256
>   #define IGB_MIN_RXD                       80
> @@ -121,8 +121,11 @@ struct vf_data_storage {
>   #define IGB_RXBUFFER_16384 16384
>   #define IGB_RX_HDR_LEN     IGB_RXBUFFER_512
>
> -/* How many Tx Descriptors do we need to call netif_wake_queue ? */
> -#define IGB_TX_QUEUE_WAKE	16
> +/* How many Tx Descriptors should be available
> + * before calling netif_wake_subqueue() ?
> + */
> +#define IGB_TX_QUEUE_WAKE	(MAX_SKB_FRAGS * 4)
> +
>   /* How many Rx Buffers do we bundle into one write to the hardware ? */
>   #define IGB_RX_BUFFER_WRITE	16	/* Must be power of 2 */
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
