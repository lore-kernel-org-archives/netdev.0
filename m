From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] net: rocker: Add basic netdev counters
Date: Fri, 16 Jan 2015 11:53:07 -0800
Message-ID: <CAE4R7bB+tsGjvfGMtZDVf7ipvCXNdPSaFQ9mwB4nSpSTvsRE8w@mail.gmail.com>
References: <1421275161-99434-1-git-send-email-dsahern@gmail.com>
	<54B6F43C.4030207@gmail.com>
	<54B701C9.50500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:38184 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbbAPTxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 14:53:08 -0500
Received: by mail-wi0-f182.google.com with SMTP id n3so4339849wiv.3
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 11:53:07 -0800 (PST)
In-Reply-To: <54B701C9.50500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 3:54 PM, David Ahern <dsahern@gmail.com> wrote:
> On 1/14/15 3:57 PM, Florian Fainelli wrote:
>>
>> On 14/01/15 14:39, David Ahern wrote:
>>>
>>> Add packet and byte counters for RX and TX paths.
>>>
>>> $ ifconfig eth1
>>> eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
>>>          inet6 fe80::5054:ff:fe12:3501  prefixlen 64  scopeid 0x20<link>
>>>          ether 52:54:00:12:35:01  txqueuelen 1000  (Ethernet)
>>>          RX packets 63  bytes 15813 (15.4 KiB)
>>>          RX errors 0  dropped 0  overruns 0  frame 0
>>>          TX packets 79  bytes 17991 (17.5 KiB)
>>>          TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
>>>
>>> Signed-off-by: David Ahern <dsahern@gmail.com>
>>> Cc: Scott Feldman <sfeldma@gmail.com>
>>> Cc: Jiri Pirko <jiri@resnulli.us>
>>> ---
>>>   drivers/net/ethernet/rocker/rocker.c | 8 ++++++++
>>>   1 file changed, 8 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/rocker/rocker.c
>>> b/drivers/net/ethernet/rocker/rocker.c
>>> index 2f398fa4b9e6..9743279d9121 100644
>>> --- a/drivers/net/ethernet/rocker/rocker.c
>>> +++ b/drivers/net/ethernet/rocker/rocker.c
>>> @@ -3557,6 +3557,9 @@ static netdev_tx_t rocker_port_xmit(struct sk_buff
>>> *skb, struct net_device *dev)
>>>         if (!desc_info)
>>>                 netif_stop_queue(dev);
>>>
>>> +       dev->stats.tx_packets++;
>>> +       dev->stats.tx_bytes += skb->len;
>>
>>
>> Potential use after free, the skb pointer is certainly not valid anymore
>> here.
>>
>> BTW, increasing statistics here is valid because this is a driver for a
>> virtual piece of HW, which does not have TX reclaim/completion logic,
>> but if it did, statistics update should occur there, not in the
>> ndo_start_xmit() function.
>
>
> sure. I had considered putting in the rocker_port_poll_tx function like
> this:
>
> -       dev_kfree_skb_any(rocker_desc_cookie_ptr_get(desc_info));
> +
> +       skb = rocker_desc_cookie_ptr_get(desc_info);
> +       rocker_port->dev->stats.tx_packets++;
> +       rocker_port->dev->stats.tx_bytes += skb->len;
> +
> +       dev_kfree_skb_any(skb);
>
> I think this the reclaim point.

This is better.  But also need to consider err code returned from
device in same routine.  If the desc was marked with err, then I think
we can assume pkt wasn't sent so tx_packets/bytes stats should not be
incremented, but some tx err stat should, based on desc err code.

-scott
