From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v2 3/5] e100:  Support receiving errored frames.
Date: Mon, 20 Jun 2011 11:06:24 -0700
Message-ID: <4DFF8C20.8060606@candelatech.com>
References: <1308430045-24816-1-git-send-email-greearb@candelatech.com>	 <1308430045-24816-4-git-send-email-greearb@candelatech.com> <1308592672.2701.146.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54291 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838Ab1FTSG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 14:06:26 -0400
In-Reply-To: <1308592672.2701.146.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2011 10:57 AM, Ben Hutchings wrote:
> On Sat, 2011-06-18 at 13:47 -0700, greearb@candelatech.com wrote:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This can be helpful when sniffing dodgy networks.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>> ---
>> :100644 100644 647d8c6... aad303d... M	drivers/net/e100.c
>>   drivers/net/e100.c |   42 ++++++++++++++++++++++++++++++++++++++++--
>>   1 files changed, 40 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
>> index 647d8c6..aad303d 100644
>> --- a/drivers/net/e100.c
>> +++ b/drivers/net/e100.c
>> @@ -588,6 +588,7 @@ struct nic {
>>   		wol_magic          = (1<<  3),
>>   		ich_10h_workaround = (1<<  4),
>>   		save_rxfcs         = (1<<  5),
>> +		save_rxerr         = (1<<  6),
>>   	} flags					____cacheline_aligned;
>>
>>   	enum mac mac;
>> @@ -1126,9 +1127,13 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
>>   		config->full_duplex_force = 0x1;	/* 1=force, 0=auto */
>>
>>   	if (nic->flags&  promiscuous || nic->loopback) {
>> +		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
>> +	}
>> +
>> +	if (nic->flags&  save_rxerr) {
>> +		config->rx_discard_overruns = 0x1;	/* 1=save, 0=discard */
>>   		config->rx_save_bad_frames = 0x1;	/* 1=save, 0=discard */
>>   		config->rx_discard_short_frames = 0x0;	/* 1=discard, 0=save */
>
> Any idea why these were previously set in promiscuous or loopback mode?

No, but it appears they would have been thrown away anyway, so I
think this change is safe.

>> -		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
>>   	}
>>
>>   	if (nic->flags&  save_rxfcs)
>> @@ -1983,7 +1988,18 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
>>   	skb_put(skb, actual_size);
>>   	skb->protocol = eth_type_trans(skb, nic->netdev);
>>
>> -	if (unlikely(!(rfd_status&  cb_ok))) {
>> +	if (unlikely(nic->flags&  save_rxerr)) {
>> +		if (!(rfd_status&  cb_ok)) {
>> +			skb->pkt_type = PACKET_INVALID;
>> +		} else if (actual_size>
>> +			   ETH_DATA_LEN + VLAN_ETH_HLEN + rxfcs_pad) {
>> +			nic->rx_over_length_errors++;
>> +			skb->pkt_type = PACKET_INVALID;
>> +		}
>> +		goto process_skb;
>> +	}
>> +
>> +	if (unlikely((nic->flags&  save_rxerr)&&  !(rfd_status&  cb_ok))) {
> [...]
>
> You're adding an if-statement to cover the save_rxerr case, and the
> existing if-else-statement should cover the !save_rxerr case - so you
> are missing a '!'.  But since the new if-statement's body ends with a
> goto, there should be no need to change the condition for the existing
> if-else statement at all.

Right..I will fix that.  I forgot to back that last chunk out
of some previous attempts at that code.

I'm going to have to re-spin this entire series after somehow
dealing with the FEATURES extension, so it will likely be a while.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

