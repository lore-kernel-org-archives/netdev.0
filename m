From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/7] net: network drivers should not depend on
 geneve/vxlan
Date: Wed, 20 Apr 2016 03:21:02 +0200
Message-ID: <5716D97E.6030000@stressinduktion.org>
References: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
 <20160419.202750.1844614056540086769.davem@davemloft.net>
 <1461114373.2649930.583890089.0C126826@webmail.messagingengine.com>
 <20160419.211134.2163748309501010595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:56083 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932298AbcDTBVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 21:21:05 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id BA3DB21138
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 21:21:04 -0400 (EDT)
In-Reply-To: <20160419.211134.2163748309501010595.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.04.2016 03:11, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 20 Apr 2016 03:06:13 +0200
> 
>> On Wed, Apr 20, 2016, at 02:27, David Miller wrote:
>>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>> Date: Mon, 18 Apr 2016 21:19:41 +0200
>>>
>>>> This patchset removes the dependency of network drivers on vxlan or
>>>> geneve, so those don't get autoloaded when the nic driver is loaded.
>>>>
>>>> Also audited the code such that vxlan_get_rx_port and geneve_get_rx_port
>>>> are not called without rtnl lock.
>>>
>>> In net-next, the 'qed' driver has tunneling offload support too.
>>> Don't you need to update this series to handle that driver as
>>> well?
>>
>> I audited qede as well:
>>
>> qede calls {vxlan,geneve}_get_rx_port only from ndo_open which isn't
>> reused anywhere else in the driver, only from ndo_open, which holds
>> rtnl_lock also. Thus the driver is safe and doesn't need a change.
> 
> I'm talking about your final patches which elide the dependencies.

The dependency will be removed with only the last two patches for all
drivers. The static inline functions {vxlan,geneve}_get_rx_port now
simply expand to a call to call_netdevice_notifiers, which is provided
by the core kernel and not by the vxlan or geneve module anymore.

During testing I saw that very often some drivers actually reused their
*_attach or *_open function from other callbacks, e.g. pci ones. While
they often didn't care about rtnl_lock, we now require that for the new
get_rx_port functions, thus I added them.

I hadn't had to modify all drivers with vxlan offloading support, e.g.
also mlx5 and the broadcom drivers, bnx2x and bnxt, were already fine.

Bye,
Hannes
