From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: dsa: Keep a reference count on ethernet_dev
Date: Tue, 24 Jan 2017 14:29:08 -0800
Message-ID: <eb8d674d-3e58-5700-38a8-c8247a8b5fde@gmail.com>
References: <20170121174055.27560-1-f.fainelli@gmail.com>
 <20170124.123911.330293119907498159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34243 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdAXW3K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 17:29:10 -0500
In-Reply-To: <20170124.123911.330293119907498159.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/2017 09:39 AM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Sat, 21 Jan 2017 09:40:54 -0800
> 
>> of_find_net_device_by_node() just returns a reference to a net_device but does
>> not increment its reference count, which means that the master network device
>> can just vanish under our feet.
>>
>> Fixes: 83c0afaec7b7 ("net: dsa: Add new binding implementation")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> This is fine, except now this netdev is completely locked into place with
> no way to dynamically unload it.
> 
> If someone tries to modunload the driver for this ethernet device,
> their screen will fill up with warning messages indicating that the
> reference taken here in the DSA code is not going away.
> 
> You need to implement a netdev notifier that tears down this DSA
> instance during an unregister event and releases the ethernet_dev.
> Similar to how we handle protocol addresses bound to a netdev, etc.

I have been thinking about this a bit more, and this is what is going on:

- upon master network device unregister we can look up the
dsa_switch_tree in dev->dsa_ptr and call dsa_dst_unapply() that is
actually exactly what we want since it detaches the dsa_switch_tree from
the master network device

- upon master network device register, we can look up whether this
master netdev is the one of interest and re-attach the dangling switch
tree, but here we have two cases:

	- if we have an OF enabled system, doing a reverse look up of
net_device to device to device_node, and then looking it up in the
Device Tree is possible and reasonably simple, this works

	- if we have a platform data enabled system, doing a reverse lookup is
possible, but won't necessarily yield the expected results, because
platform data will have a device reference to the original master
netdev, and this one could be totally different the second time we probe
the master network device due to to unregister/register

Thoughts?
-- 
Florian
