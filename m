From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: e1000e: reset of tx_queue_len
Date: Tue, 2 Mar 2010 10:27:01 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1003021020160.2888@jbrandeb-desk1.amr.corp.intel.com>
References: <4B8D4E7E.2000805@lastsummer.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netdev <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
To: Franco Fichtner <franco@lastsummer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:34184 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754178Ab0CBS1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 13:27:05 -0500
In-Reply-To: <4B8D4E7E.2000805@lastsummer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 2 Mar 2010, Franco Fichtner wrote:
> while working on a new server, I noticed that tx_queue_len is reset
> to the default of 1000 while ADDRCONF(NETDEV_CHANGE).
> This happens with 2.6.30.8, but I could not see any obvious
> differences to the current state of e1000e, while trying to find the
> problem in the code.

The driver tries to set the queuelen back to 1000 if the link changes 
speed, because the driver tries to shorten the txqueuelen to 100 to reduce 
latency when the link changes to 100/10 Mb/s

> The interface has been configured including a customized qlen
> via /etc/network/interfaces. The ports are not connected at startup
> so obviously the Kernel reports
> 
> ADDRCONF(NETDEV_UP): eth2: link is not ready

do your scripts try to configure the queuelen when link is not up?  Why 
are the ports not connected at startup?

> 
> while ifconfig properly displays the customized qlen.
> 
> When plugging the server tx_queue_len is reset to 1000.
> 
> Any help is appreciated. Thanks.

you can safely comment out the code in netdev.c on lines 3532 through 
3549, as well as any other lines of code in the driver that modify or use 
the variable netdev->tx_queue_len

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.30.y.git;a=blob;f=drivers/net/e1000e/netdev.c;h=42055a580f7ccd6cc2ac59ea5d7d864157b57107;hb=HEAD#l3532

Its possible we should just remove this code from the in-kernel 
driver, as I don't think many other drivers mess with the tx_queue_len 
either.  We did introduce the code to fix some users complaints about the 
amount of work that can get queued up in the hardware with tx_queue_len = 
1000 when at 10/100 speeds.

Hope this helps!
