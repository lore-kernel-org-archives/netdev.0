From: Rick Jones <rick.jones2@hp.com>
Subject: Re: twice past the taps, thence out to net?
Date: Thu, 15 Dec 2011 14:22:06 -0800
Message-ID: <4EEA730E.5010405@hp.com>
References: <4EE8F884.1010304@hp.com> <CAGK4HS-+jj9cvvirDm96oRvRJdwC+2kjE_LnSOXBuQy0pfnQjg@mail.gmail.com> <1323970998.2769.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4EEA3D58.5010101@hp.com> <20111215104440.1eef9e47@s6510.linuxnetplumber.net> <1323975606.2769.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:3191 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932652Ab1LOWWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 17:22:09 -0500
In-Reply-To: <1323975606.2769.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2011 11:00 AM, Eric Dumazet wrote:
>> Device's work better if the driver proactively manages stop_queue/wake_queue.
>> Old devices used TX_BUSY, but newer devices tend to manage the queue
>> themselves.
>>
>
> Some 'new' drivers like igb can be fooled in case skb is gso segmented ?
>
> Because igb_xmit_frame_ring() needs skb_shinfo(skb)->nr_frags + 4
> descriptors, igb should stop its queue not at MAX_SKB_FRAGS + 4, but
> MAX_SKB_FRAGS*4
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index 89d576c..989da36 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -4370,7 +4370,7 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
>   	igb_tx_map(tx_ring, first, hdr_len);
>
>   	/* Make sure there is space in the ring for the next send. */
> -	igb_maybe_stop_tx(tx_ring, MAX_SKB_FRAGS + 4);
> +	igb_maybe_stop_tx(tx_ring, MAX_SKB_FRAGS * 4);
>
>   	return NETDEV_TX_OK;


Is there a minimum transmit queue length here?  I get the impression 
that MAX_SKB_FRAGS is at least 16 and is 18 on a system with 4096 byte 
pages.  The previous addition then would be OK so long as the TX queue 
was always at least 22 entries in size, but now it would have to always 
be at least 72?

I guess things are "OK" at the moment:

raj@tardy:~/net-next/drivers/net/ethernet/intel/igb$ grep IGB_MIN_TXD *.[ch]
igb_ethtool.c:	new_tx_count = max_t(u16, new_tx_count, IGB_MIN_TXD);
igb.h:#define IGB_MIN_TXD                       80

but is that getting a little close?

rick jones
