From: Patrick McHardy <kaber@trash.net>
Subject: Re: Bisect'ed BUG in VLAN promisc mode (6c78dcbd47)
Date: Fri, 26 Sep 2008 22:10:55 +0200
Message-ID: <48DD41CF.20407@trash.net>
References: <1222437636.7598.14.camel@localhost.localdomain>	 <48DD0A4F.6020703@trash.net>	 <1222456933.2381.3.camel@localhost.localdomain> <48DD36D2.90103@trash.net>	 <48DD37E3.9090706@trash.net> <1222457670.2381.8.camel@localhost.localdomain> <48DD3AD5.80800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47190 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbYIZUK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 16:10:58 -0400
In-Reply-To: <48DD3AD5.80800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Jesper Dangaard Brouer wrote:
>> On Fri, 2008-09-26 at 21:28 +0200, Patrick McHardy wrote:
>>> Actually - one question: you're saying you're using different MAC
>>> addresses on the VLAN devices, so I guess thats why you're expecting
>>> the underlying device to still be in promiscous mode after you set
>>> eth1.1025 down. For devices that support multiple unicast addresses
>>> in hardware, we don't put the device in promiscous mode anymore.
>>> So the question is: is something actually not working, or did you
>>> just notice that the real device is no longer in promiscous mode?
>>
>> It stopped working!  In the test setup I do have a machine connected to
>> eth1.1013, where I have a ping running, that stop working...
> 
> Found it in the bugreport :) OK, I'll try to reproduce it now.

Found it without reproduing, but unfortunately I also have to leave
now, will look at it later again.

Anyways, the problem appears to be that the promiscous count is
decremented twice for the VLAN device, once in vlan_stop() because
the device is still in promiscous mode, once when af_packet takes
the VLAN device out of promisc in the NETDEV_UNREGISTER notifier
chain, which triggers the VLAN ->change_rx_mode callback and
removes another promiscous count from the real device.

I think the correct fix would be to not invoke ->change_rx_flags
while the device is down, similar to ->set_multicast_list and
->set_rx_mode, but I need to check the other drivers first.
