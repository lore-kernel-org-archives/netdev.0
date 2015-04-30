From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/3] etherdev: Avoid unnecessary byte swap in check for
 Ethertype
Date: Thu, 30 Apr 2015 16:24:16 -0700
Message-ID: <5542B9A0.70605@gmail.com>
References: <20150430214917.1798.49769.stgit@ahduyck-vm-fedora22>	 <20150430215348.1798.15509.stgit@ahduyck-vm-fedora22> <1430435029.3711.106.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33506 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbbD3XYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 19:24:20 -0400
Received: by pdbnk13 with SMTP id nk13so75273235pdb.0
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 16:24:17 -0700 (PDT)
In-Reply-To: <1430435029.3711.106.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2015 04:03 PM, Eric Dumazet wrote:
> On Thu, 2015-04-30 at 14:53 -0700, Alexander Duyck wrote:
>> This change takes advantage of the fact that ETH_P_802_3_MIN is aligned to
>> 512 so as a result we can actually ignore the lower 8b when comparing the
>> Ethertype to ETH_P_802_3_MIN.  This allows us to avoid a byte swap by simply
>> masking the value and comparing it to the byte swapped value for
>> ETH_P_802_3_MIN.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>> ---
>>   net/ethernet/eth.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
>> index f3bad41d725f..60069318d5d1 100644
>> --- a/net/ethernet/eth.c
>> +++ b/net/ethernet/eth.c
>> @@ -178,7 +178,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
>>   	if (unlikely(netdev_uses_dsa(dev)))
>>   		return htons(ETH_P_XDSA);
>>   
>> -	if (likely(ntohs(eth->h_proto) >= ETH_P_802_3_MIN))
>> +	if (likely((eth->h_proto & htons(0xFF00)) >= htons(ETH_P_802_3_MIN)))
>>   		return eth->h_proto;
> Then, a byte operation on x86 is shorter/faster than u16 one.
>
> You also could use
>
> if (likely(*(u8 *)&eth->h_proto >= (ETH_P_802_3_MIN>>8)))
> 	return eth->h_proto;
>
> I would at least leave a comment here to explain the logic.

Actually a byte operation itself is not faster.  Note in the next line 
we are returning the value.  So what you typically end up with by doing 
it that way would be 2 reads, one for the u8 and one for the u16 return 
value.  That is actually what I am trying to address in the second patch 
in the set since we were doing a 8b test on the first byte of the 
address followed by a 64b read.

The advantage with the way I wrote this is that the compiler itself 
should be able to sort out how it wants to test the value while 
accessing it in a 16b size.  So at worst case it is a mask and compare, 
followed by a return of the value.  From what I have seen the compiler 
seems to be smart enough on x86 anyway to just convert this into a one 
byte compare on AL and then return the result in AX.  I would suspect 
that for bit-endian systems it would likely just perform the compare.

- Alex
