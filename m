From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] vrf: Add ethernet header for pass through VRF
 device
Date: Wed, 26 Aug 2015 12:36:15 -0700
Message-ID: <55DE152F.10701@cumulusnetworks.com>
References: <1440355260-16528-1-git-send-email-dsa@cumulusnetworks.com>	<20150825.140220.156958823239060297.davem@davemloft.net>	<55DCEE43.4000200@cumulusnetworks.com> <20150825.155108.983138344238637012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36034 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbbHZTgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 15:36:17 -0400
Received: by padfo6 with SMTP id fo6so1678182pad.3
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 12:36:17 -0700 (PDT)
In-Reply-To: <20150825.155108.983138344238637012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/15 3:51 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Tue, 25 Aug 2015 15:37:55 -0700
>
>> On 8/25/15 2:02 PM, David Miller wrote:
>>> From: David Ahern <dsa@cumulusnetworks.com>
>>> Date: Sun, 23 Aug 2015 12:41:00 -0600
>>>
>>>> @@ -250,6 +253,17 @@ static netdev_tx_t vrf_xmit(struct sk_buff *skb,
>>>> struct net_device *dev)
>>>>
>>>>    static netdev_tx_t vrf_finish(struct sock *sk, struct sk_buff *skb)
>>>>    {
>>>> +	int err;
>>>> +
>>>> +	__skb_pull(skb, skb_network_offset(skb));
>>>> +	err = dev_hard_header(skb, skb->dev, ntohs(skb->protocol),
>>>> +			      NULL, NULL, skb->len);
>>>> +
>>>> +	if (err < 0) {
>>>> +		vrf_tx_error(skb->dev, skb);
>>>> +		return -EINVAL;
>>>> +	}
>>>> +
>>>>    	return dev_queue_xmit(skb);
>>>
>>> This is expensive and rediculous to do for every TX frame.
>>>
>>> You'll need to find another way.
>>>
>>
>> The packet is directed here from the IP layer via the custom dst, so
>> there is no L2 header on the skb. So while the push and pop of the
>> header seems silly it is part and parcel of the feature to run tcpdump
>> on the VRF device. I don't see how it could be done any other way.
>
> You're losing a significant optimization on the transmit path by not
> using the neighbour table entry hard header cache.
>
> That's what I want you to fix.
>
> See dst_neigh_output() and in particular neigh_hh_output().
>

I'm sure you'll correct me if I am wrong ...

For VRF device we don't need dst_neigh_output or neigh_hh_output or a 
neighbor cache. The packet never hits a wire with the VRF device header; 
it just hits tcpdump and then recirculates in the stack. i.e, the vrf 
device xmit just hides the eth header via the skb_pull and recirculates 
the packet back in the stack with the dst pointing to the real device. 
That's just the game for tc, netfilter, tcpdump to work with the VRF device.

As such all we need is to push an eth header to the front of the skb for 
1 loop through the stack and eth_header via dev_hard_header with NULL 
daddr is the simplest path to accomplish that. Any other path is just 
extra overhead.

David
