From: Patrick McHardy <kaber@trash.net>
Subject: Re: ~3 hours old git tree: Virtual device lo asks to queue packet!
Date: Sat, 21 Jul 2007 05:38:10 +0200
Message-ID: <46A17FA2.8010906@trash.net>
References: <200707190819.53364.arekm@maven.pl>	<469F2E14.9050200@trash.net>	<469F38BE.4030401@trash.net> <20070720.194743.71090882.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, arekm@maven.pl,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42511 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758934AbXGUDjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 23:39:42 -0400
In-Reply-To: <20070720.194743.71090882.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 19 Jul 2007 12:11:10 +0200
> 
> 
>>The easiest fix would be to use egress_subqueue[1] in struct
>>net_device, but I think that may cause warnings with newer gccs
>>when using a constant index that is > 0. OTOH using constant
>>indices doesn't seem to make much sense for the subqueue array.
>>
>>Arkadiusz, does this patch fix the problem?
> 
> 
> I've applied this, but long term we should either:
> 
> 1) Make loopback_dev dynamically allocated just like every
>    other netdev, so make loopback_init() a postcore_initcall()
>    to make sure that is setup early enough.
> 
>    Then have to walk over the tree making everything able
>    to handle the fact that it's a pointer.  Several data
>    structures are compile time initialized to "&loopback_dev"
>    for example, and therefore will have to be transformed into
>    a run-time initialization.
> 
> 2) Pick some arbitrary limit for the queues, and just have that
>    many of them allocated in every netdev.
> 
> I like #2 because it allows us to get back the netdev_priv()
> optimization.


Yes, some constant limit definitely makes sense. The Tx batching
patches motivated me to work through struct net_device with pahole
and I have some patches that rearrange it to save about 64 bytes and
move some members from very unfortunate positions to better ones,
but they still leave two 32 byte holes on SMP (with 64 byte
cachelines). Plugging one of these with a statically sized subqueue
array would be perfect since one of the holes is within the Tx
cachelines anyway (at least for now, until we add subqueue locks ..).

Its 2.6.24 material though, and I very much hope they will clash
with Stephen's plans to introduce struct net_device_ops.
