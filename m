From: Jonathan Davies <jonathan.davies@citrix.com>
Subject: Re: [PATCH] xen-netfront: transmit fully GSO-sized packets
Date: Tue, 31 Mar 2015 10:16:19 +0100
Message-ID: <551A65E3.9030904@citrix.com>
References: <1427368406-28084-1-git-send-email-jonathan.davies@citrix.com>
 <1427371537.25985.136.camel@edumazet-glaptop2.roam.corp.google.com>
 <5514210A.6020808@citrix.com> <20150330134639.GF25911@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45280 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbbCaJQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 05:16:23 -0400
In-Reply-To: <20150330134639.GF25911@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/03/15 14:46, Wei Liu wrote:
> On Thu, Mar 26, 2015 at 03:08:58PM +0000, Jonathan Davies wrote:
>>
>> On 26/03/15 12:05, Eric Dumazet wrote:
>>> On Thu, 2015-03-26 at 11:13 +0000, Jonathan Davies wrote:
>>>> xen-netfront limits transmitted skbs to be at most 44 segments in size. However,
>>>> GSO permits up to 65536 bytes, which means a maximum of 45 segments of 1448
>>>> bytes each. This slight reduction in the size of packets means a slight loss in
>>>> efficiency.
>>>>
>>>> Since c/s 9ecd1a75d, xen-netfront sets gso_max_size to
>>>>      XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER,
>>>> where XEN_NETIF_MAX_TX_SIZE is 65535 bytes.
>>>>
>>>> The calculation used by tcp_tso_autosize (and also tcp_xmit_size_goal since c/s
>>>> 6c09fa09d) in determining when to split an skb into two is
>>>>      sk->sk_gso_max_size - 1 - MAX_TCP_HEADER.
>>>>
>>>> So the maximum permitted size of an skb is calculated to be
>>>>      (XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER) - 1 - MAX_TCP_HEADER.
>>>>
>>>> Intuitively, this looks like the wrong formula -- we don't need two TCP headers.
>>>> Instead, there is no need to deviate from the default gso_max_size of 65536 as
>>>> this already accommodates the size of the header.
>>>>
>>>> Currently, the largest skb transmitted by netfront is 63712 bytes (44 segments
>>>> of 1448 bytes each), as observed via tcpdump. This patch makes netfront send
>>>> skbs of up to 65160 bytes (45 segments of 1448 bytes each).
>>>>
>>>> Fixes: 9ecd1a75d977 ("xen-netfront: reduce gso_max_size to account for max TCP header")
>>>> Signed-off-by: Jonathan Davies <jonathan.davies@citrix.com>
>>>> ---
>>>>   drivers/net/xen-netfront.c | 2 --
>>>>   1 file changed, 2 deletions(-)
>>>>
>>>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>>>> index e9b960f..fb6e978 100644
>>>> --- a/drivers/net/xen-netfront.c
>>>> +++ b/drivers/net/xen-netfront.c
>>>> @@ -1279,8 +1279,6 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
>>>>   	netdev->ethtool_ops = &xennet_ethtool_ops;
>>>>   	SET_NETDEV_DEV(netdev, &dev->dev);
>>>>
>>>> -	netif_set_gso_max_size(netdev, XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER);
>>>> -
>>>>   	np->netdev = netdev;
>>>>
>>>>   	netif_carrier_off(netdev);
>>>
>>> Hmm, this partially reverts commit
>>> 9ecd1a75d977e2e8c48139c7d3efed183f898d94
>>>
>>>
>>>
>>> Why xennet_change_mtu() is not changed by your patch ?
>>
>> I think you are right: the mtu calculation suffers from the same problem. I
>> believe the value of mtu relates to the size of the whole packet, including
>> the header (which is why the value of dev->mtu is normally 1500 rather than
>> 1448).
>>
>> Wei, as the author of commit 9ecd1a75d977 ("xen-netfront: reduce
>> gso_max_size to account for max TCP header"), do you agree that the max mtu
>> formula should not need to subtract MAX_TCP_HEADER?
>>
>
> IIRC at the time I wrote that patch I needed to subtract MAX_TCP_HEADER
> otherwise netfront would generate oversized packets then get marked as
> malicious by backend.
>
> I think your reasoning is straightforward. Probably other core driver
> changes have somehow mitigated the issues I saw.
>
> Presuming you tested this change and saw no problems, I'm of course
> happy with making netfront more efficient. :-)

Okay, thanks for confirming.

I'll post a v2 including the change to xennet_change_mtu.

Jonathan
