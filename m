From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [net-2.6][DRIVER][VETH] fix dev refcount race
Date: Tue, 19 Feb 2008 19:30:44 +0300
Message-ID: <47BB0434.9080906@openvz.org>
References: <47BB0138.1000104@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58513 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753304AbYBSQbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 11:31:08 -0500
In-Reply-To: <47BB0138.1000104@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Subject: veth fix dev refcount race
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> When deleting the veth driver, veth_close calls netif_carrier_off
> for the two extremities of the network device. netif_carrier_off on
> the peer device will fire an event and hold a reference on the peer
> device. Just after, the peer is unregistered taking the rtnl_lock while
> the linkwatch_event is scheduled. If __linkwatch_run_queue does not
> occurs before the unregistering, unregister_netdevice will wait for
> the dev refcount to reach zero holding the rtnl_lock and linkwatch_event

Brr... AFAIS the unregister process waits for refcount without
the rtnl_lock. The run-todo was invented for this. No?

> will wait for the rtnl_lock and hold the dev refcount.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> ---
>  drivers/net/veth.c |   53 ++++++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 40 insertions(+), 13 deletions(-)
