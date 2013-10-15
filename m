From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH 2/2] be2net: drop non-tso frames longer than mtu
Date: Tue, 15 Oct 2013 16:30:35 +0200
Message-ID: <525D518B.5010901@redhat.com>
References: <1381838188-9625-1-git-send-email-sathya.perla@emulex.com>  <1381838188-9625-2-git-send-email-sathya.perla@emulex.com> <1381844840.2045.37.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sathya Perla <sathya.perla@emulex.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22695 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932673Ab3JOOao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 10:30:44 -0400
In-Reply-To: <1381844840.2045.37.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/2013 03:47 PM, Eric Dumazet wrote:
> On Tue, 2013-10-15 at 17:26 +0530, Sathya Perla wrote:
>> From: Vasundhara Volam <vasundhara.volam@emulex.com>
>>
>> Pktgen can generate non-TSO frames of arbitrary length disregarding
>> the MTU value of the physical interface. Drop such frames in the driver
>> instead of sending them to HW as it cannot handle such frames.
>>
>> Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
>> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
>> ---
>>   drivers/net/ethernet/emulex/benet/be_main.c |    9 +++++++--
>>   1 files changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
>> index 2c38cc4..76057b8 100644
>> --- a/drivers/net/ethernet/emulex/benet/be_main.c
>> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
>> @@ -855,6 +855,13 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
>>   	unsigned int eth_hdr_len;
>>   	struct iphdr *ip;
>>
>> +	/* Don't allow non-TSO packets longer than MTU */
>> +	eth_hdr_len = (ntohs(skb->protocol) == ETH_P_8021Q) ?
>> +			VLAN_ETH_HLEN : ETH_HLEN;
>> +	if (!skb_is_gso(skb) &&
>> +	    (skb->len - eth_hdr_len) > adapter->netdev->mtu)
>> +			goto tx_drop;
>> +
>
> When you say 'cannot handle them', is it some kind of nasty thing like
> hang / crash ?
AFAIK, the firmware in the card becomes unresponsive and reboot is 
needed to make the NIC working.

Ivan
