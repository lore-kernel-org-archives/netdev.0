From: Christoph Egger <chegger@amazon.de>
Subject: Re: [Xen-devel] [PATCH 2/4] xen-netfront: drop skb when skb->len
 > 65535
Date: Tue, 9 Apr 2013 16:53:13 +0200
Message-ID: <51642B59.4080407@amazon.de>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com> <1363602955-24790-3-git-send-email-wei.liu2@citrix.com> <1363606970.30193.22.camel@zakaz.uk.xensource.com> <1363617642.29093.203.camel@zion.uk.xensource.com> <1363618459.2963.10.camel@zakaz.uk.xensource.com> <1363619098.29093.205.camel@zion.uk.xensource.com> <1363619244.2963.11.camel@zakaz.uk.xensource.com> <1363728289.31336.7.camel@deadeye.wl.decadent.org.uk> <1363728480.31336.10.camel@deadeye.wl.decadent.org.uk> <1365517818.10725.44.camel@zakaz.uk.xensource.com> <1365518703.2623.6.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-2101.amazon.com ([72.21.196.25]:5519 "EHLO
	smtp-fw-2101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765005Ab3DIOxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 10:53:30 -0400
In-Reply-To: <1365518703.2623.6.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.04.13 16:45, Ben Hutchings wrote:
> On Tue, 2013-04-09 at 15:30 +0100, Ian Campbell wrote:
>> On Tue, 2013-03-19 at 21:28 +0000, Ben Hutchings wrote:
>>> On Tue, 2013-03-19 at 21:24 +0000, Ben Hutchings wrote:
>>>> On Mon, 2013-03-18 at 15:07 +0000, Ian Campbell wrote:
>>>>> On Mon, 2013-03-18 at 15:04 +0000, Wei Liu wrote:
>>>>>> On Mon, 2013-03-18 at 14:54 +0000, Ian Campbell wrote:
>>>>>>> On Mon, 2013-03-18 at 14:40 +0000, Wei Liu wrote:
>>>>>>>> On Mon, 2013-03-18 at 11:42 +0000, Ian Campbell wrote:
>>>>>>>>> On Mon, 2013-03-18 at 10:35 +0000, Wei Liu wrote:
>>>>>>>>>> The `size' field of Xen network wire format is uint16_t, anything bigger than
>>>>>>>>>> 65535 will cause overflow.
>>>>>>>>>>
>>>>>>>>>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>>>>>>>>>> ---
>>>>>>>>>>   drivers/net/xen-netfront.c |   12 ++++++++++++
>>>>>>>>>>   1 file changed, 12 insertions(+)
>>>>>>>>>>
>>>>>>>>>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>>>>>>>>>> index 5527663..8c3d065 100644
>>>>>>>>>> --- a/drivers/net/xen-netfront.c
>>>>>>>>>> +++ b/drivers/net/xen-netfront.c
>>>>>>>>>> @@ -547,6 +547,18 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>>>>>>>>>   	unsigned int len = skb_headlen(skb);
>>>>>>>>>>   	unsigned long flags;
>>>>>>>>>>
>>>>>>>>>> +	/*
>>>>>>>>>> +	 * wire format of xen_netif_tx_request only supports skb->len
>>>>>>>>>> +	 * < 64K, because size field in xen_netif_tx_request is
>>>>>>>>>> +	 * uint16_t.
>>>>>>>>>
>>>>>>>>> Is there some field we can set e.g. in struct ethernet_device which
>>>>>>>>> would stop this from happening?
>>>>>>>>>
>>>>>>>>
>>>>>>>> struct ethernet_device? I could not find it.
>>>>>>>>
>>>>>>>> And for struct net_device,
>>>>>>>
>>>>>>> I meant struct net_device.
>>>>>>>
>>>>>>>>   there is no field for this AFAICT.
>>>>>>>
>>>>>>> Interesting. Are hardware devices expected to cope with arbitrary sized
>>>>>>> GSO skbs then I wonder.
>>>>>>>
>>>>>>
>>>>>> No idea. But there is a macro called GSO_MAX_SIZE (65536) in struct
>>>>>> net_device. :-)
>>>>>
>>>>> But aren't we seeing skb's bigger than that?
>>>>>
>>>>> Maybe this is just a historical bug in some older guests?
>>>>
>>>> GSO_MAX_SIZE is the maximum payload length, not the maximum total length
>>>> of an skb.
>>>
>>> ...and it's actually just the default value assigned to
>>> dev->gso_max_size.  You'll want to change it to your actual maximum
>>> (65535 - maximum length of headers) before registering your net devices.
>>
>> Thanks.
>>
>> "maximum length of headers" might be a bit tricky to determine
>> generically :-(.
>
> Well you don't need to be generic, you need to know the maximum length
> of headers that might appear in a TSO skb.
>
> Ethernet + VLAN tag + IPv6 + TCP + timestamp option = 90 bytes, but I'm
> not sure whether there can be other IP or TCP options in a TSO skb.  I'd
> really like to get the TSO requirements clearly documented somewhere.

What about encapsulated IPSEC, IP-in-IP-tunnels, etc. ?

Christoph
