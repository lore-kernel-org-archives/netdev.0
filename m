From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: Re: [patch 2.6.24-git] net/enc28j60: low power mode
Date: Thu, 07 Feb 2008 11:49:01 +0100
Message-ID: <47AAE21D.30606@eptar.com>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <47A9EA42.3080800@eptar.com> <20080206181912.6E2E08E152@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe-relay03.albacom.net ([217.220.57.137]:31270 "EHLO
	fe-relay03.albacom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390AbYBGKsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 05:48:00 -0500
In-Reply-To: <20080206181912.6E2E08E152@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> The driver seemed to already have some goofage there:
>
>   # ifconfig eth1 up
>   net eth1: link down
>   net eth1: link down
>   net eth1: normal mode
>   net eth1: multicast mode
>   net eth1: multicast mode
>   #
>
>   
Without low power patch I have:

# ifconfig eth0 up
net eth0: link down
net eth0: normal mode
net eth0: multicast mode
net eth0: multicast mode
# net eth0: link up - Half duplex

> I'd normally expect it not to go down when told to go up, and
> then only to do the multicast thing once ...
>   
multicast is called by network stacks, no control by the driver. The driver
just print message.
I don't know why enc28j60_set_multicast_list() are called more than once.

When you do an ifconfig up the driver reset the chip, so you see link down
before link up message.

>
>   
>> In such cases If I dump the counters with ifconfig I got rx error 
>> counter > 0 and the RX and TX packets counters are freezed.
>> Actually I don't know what causes the freeze, it needs investigation. 
>> The cause can be the rx error condition or the power down/up commands.
>> May be receiving packets while it's going to wakeup causes problems.
>>     
>
> The enc28j60_setlink() was odd too.  It insists the link be down
> before changing duplex, then brings the link up ... so I had to
> put it down again to maintain the "lowpower if not up" invariant.
>
> But the way it brings the link up is to enc28j60_hw_init(), which
> it also does when bringing the link up.  So there's no need to
> bring the link up when changing duplex ...
>
>
>   
I don't follow you anymore.
To change duplex mode the link must be down.
enc28j60_setlink() reinitialize the chip with new duplex mode,
enc28j60_hw_init() never brings link up.

I propose you to add set_lowpower(true) in the enc28j60_probe() and in 
the enc28j60_net_close() after enc28j60_hw_disable().
Probably we don't need to set_lowpower(false) in enc28j60_net_open() since
it performs a soft reset with enc28j60_hw_init().
Do you agree?


>>
>> use
>> if(netif_msg_drv(priv)) ...
>> Doing so we can switch on/off messages runtime using ethtool.
>>     
>
> OK, although there's still a role for "-DDEBUG" compile-time
> mesage removal.
>
>   
It's ok to use

if(netif_msg_drv(priv)) dev_dbv(...


> This driver also abuses __FUNCTION__ (general policy:  don't use it)
>   
Why?
> Then there should be a single routine for all such busy-wait loops,
> so each such usage doesn't need to be open-coded.  Less space, and
> more obviously correct.  I'll add one and make phy_read() use it too.
>
>   
Ok

