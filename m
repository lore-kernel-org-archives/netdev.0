From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 1/5] etherdevice: Add function for handling padding
 frame to ETH_ZLEN
Date: Tue, 25 Nov 2014 18:44:46 -0800
Message-ID: <54753E9E.9040801@gmail.com>
References: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20> <20141125224400.1867.48907.stgit@ahduyck-vm-fedora20> <54752525.4040509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:39124 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbaKZCor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 21:44:47 -0500
Received: by mail-pd0-f179.google.com with SMTP id w10so1819824pde.38
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 18:44:47 -0800 (PST)
In-Reply-To: <54752525.4040509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/2014 04:56 PM, Florian Fainelli wrote:
> On 25/11/14 14:44, Alexander Duyck wrote:
>> This patch adds a simple function for padding a frame up to the minimum
>> size for for Ethernet.  The motivation behind it is that there are a number
>> of implementations throughout the network device drivers that are all doing
>> the same thing, but each a little bit differently and as a result several
>> implementations contain bugs such as updating the length without updating
>> the tail offset and other similar issues.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>> ---
>>  include/linux/etherdevice.h |   21 +++++++++++++++++++++
>>  1 file changed, 21 insertions(+)
>>
>> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
>> index 733980f..7e436f3 100644
>> --- a/include/linux/etherdevice.h
>> +++ b/include/linux/etherdevice.h
>> @@ -392,4 +392,25 @@ static inline unsigned long compare_ether_header(const void *a, const void *b)
>>  #endif
>>  }
>>  
>> +/**
>> + * eth_skb_pad - Pad buffer to mininum number of octets for Ethernet frame
>> + * @skb: Buffer to pad
>> + *
>> + * An Ethernet frame should have a minimum size of 60 bytes.  This function
>> + * takes short frames and pads them with zeros up to the 60 byte limit.
> 
> minimum size without FCS
> 
>> + */
>> +static inline int eth_skb_pad(struct sk_buff *skb)
>> +{
>> +	unsigned int size = skb->len;
>> +
>> +	if (unlikely(size < ETH_ZLEN)) {
>> +		size = ETH_ZLEN - size;
>> +		if (skb_pad(skb, size))
>> +			return -ENOMEM;
>> +		__skb_put(skb, size);
>> +	}
> 
> most drivers call skb_padto(skb, ETH_ZLEN), besides the extra
> __skb_put() here, this is not different.

Yes, but the __skb_put is the difference.  Calling skb_padto() only
zeros out the bytes following the tail, but it doesn't add the extra
bytes to the frame nor does it update the tail.  As such if we only call
skb_padto() before handing a short frame off to the network stack the
network stack will still have issues with it being too short.

The difference between the two is that skb_padto() is really meant for
transmit, whereas eth_skb_pad is really meant for receive.

- Alex
