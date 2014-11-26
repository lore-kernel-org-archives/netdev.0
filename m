From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 2/5] ethernet/intel: Use eth_skb_pad helper
Date: Tue, 25 Nov 2014 16:44:19 -0800
Message-ID: <54752263.2040204@gmail.com>
References: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>	 <20141125224406.1867.97911.stgit@ahduyck-vm-fedora20> <1416957251.29427.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:32964 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbaKZAoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 19:44:21 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so1624648pdi.31
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 16:44:20 -0800 (PST)
In-Reply-To: <1416957251.29427.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/2014 03:14 PM, Eric Dumazet wrote:
> On Tue, 2014-11-25 at 14:44 -0800, Alexander Duyck wrote:
>> Update the Intel Ethernet drivers to use eth_skb_pad() instead of doing
>> their own implementations of the function.
>>
>> Also this cleans up two other spots where skb_pad was called but the length
>> and tail pointers were being manipulated directly instead of just having
>> the padding length added via __skb_put.
>>
>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>> ---
>>  drivers/net/ethernet/intel/e1000/e1000_main.c     |    8 ++------
>>  drivers/net/ethernet/intel/fm10k/fm10k_main.c     |   11 +++--------
>>  drivers/net/ethernet/intel/igb/igb_main.c         |   11 +++--------
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   11 +++--------
>>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   11 +++--------
>>  5 files changed, 14 insertions(+), 38 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
>> index 24f3986..862d198 100644
>> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
>> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
>> @@ -3136,12 +3136,8 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
>>  	 * packets may get corrupted during padding by HW.
>>  	 * To WA this issue, pad all small packets manually.
>>  	 */
>> -	if (skb->len < ETH_ZLEN) {
>> -		if (skb_pad(skb, ETH_ZLEN - skb->len))
>> -			return NETDEV_TX_OK;
>> -		skb->len = ETH_ZLEN;
>> -		skb_set_tail_pointer(skb, ETH_ZLEN);
>> -	}
>> +	if (eth_skb_pad(skb))
>> +		return NETDEV_TX_OK;
>>  
> Its a bit sad almost no driver increments some drop counter.
>
> This probably could be generically done in eth_skb_pad()
>
> atomic_long_inc(&skb->dev->tx_dropped)

The only problem is eth_skb_pad is called in the Rx path of some drivers
as well.

I wonder if we couldn't make this some sort of netdevice attribute to
indicate what the smallest frame we can handle is and then just pad the
frame to that as a part of __dev_xmit_skb.  Then we could do that
outside of the locks and take care of it before we even hit the qdisc layer.

- Alex
