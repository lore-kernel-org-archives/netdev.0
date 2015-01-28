From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: A problem about ICMP packet-too-big message handler
Date: Wed, 28 Jan 2015 13:10:28 +0100
Message-ID: <20150128121026.GM13046@secunet.com>
References: <54C78B8D.1070104@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55847 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933857AbbA1UlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jan 2015 15:41:20 -0500
Content-Disposition: inline
In-Reply-To: <54C78B8D.1070104@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2015 at 08:58:53PM +0800, Yang Yingliang wrote:
> Hi,
> 
> My kernel is 3.10 LTS.
> 
> I got a problem here about handling ICMP packet-too-big message.
> 
> Before sending a packet-too-big packet :
> 
> # ip -6 route list table local
> local ::1 dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80::1 dev lo  metric 0 	//It  does not have expire value
> local fe80::200:ff:fe00:0 dev lo  metric 0 
> local fe80::200:ff:fe00:0 dev lo  metric 0 
> local fe80::200:ff:fe00:0 dev lo  metric 0 
> local fe80::200:ff:fe00:0 dev lo  metric 0 
> local fe80::200:ff:fe00:2 dev lo  metric 0 
> local fe80::5054:ff:fe12:3456 dev lo  metric 0
> 
> 
> After sending a packet-too-big packet
> 
> ip -6 route list table local
> local ::1 dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80::1 dev lo  metric 0  expires _597_  //It has expire value

Is this route still present after the expiration time is elapsed?

> local fe80::200:ff:fe00:0 dev lo  metric 0 
> local fe80::200:ff:fe00:0 dev lo  metric 0 
> local fe80::200:ff:fe00:0 dev lo  metric 0 
> local fe80::200:ff:fe00:0 dev lo  metric 0 
> local fe80::200:ff:fe00:2 dev lo  metric 0 
> local fe80::5054:ff:fe12:3456 dev lo  metric 0
> 
> When time is up, I can't ping fe80::1 .
> Is it ok or a bug ?

This looks pretty similar to a bug I discovered recently.
In my case, a ipv6 host route dissapeared 10 minutes after
a PMTU event. As a result, this host was not reachable
anymore.

This happens because we don't clone host routes before
we use them. If a PMTU event happens, the original route
is marked with an expire value. After the expiration time
is elapsed, the original route is deleted and we loose
conectivity to the host.

I'm currently testing patches to fix this. With these
patches the ipv6 host routes are cloned if they are
gateway routes, i.e. if PMTU events can happen.

I fear it will not fix your case because PMTU events are
not expected to happen at local fe80 routes. But you could
change patch 1 to unconditionally clone the routes, if
you want to check if this is your problem.

I'll sent the fixes marked as RFC in reply to this mail.
