From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Tue, 12 Jun 2012 13:33:33 -0700 (PDT)
Message-ID: <20120612.133333.527780673034196147.davem@davemloft.net>
References: <20120611114256.GL27795@secunet.com>
	<20120611.160258.866525532025442350.davem@davemloft.net>
	<20120612114440.GM27795@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847Ab2FLUdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 16:33:37 -0400
In-Reply-To: <20120612114440.GM27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 12 Jun 2012 13:44:40 +0200

> On Mon, Jun 11, 2012 at 04:02:58PM -0700, David Miller wrote:
>> UDP works by notifying userspace of PMTU events.  And this is
>> mandatory, if we're setting DF we have to get the user to decrease the
>> size of it's datagram writes below the reported PMTU value.
>> 
>> As a consequence I believe RAW sockets should also work via
>> notifications.
>> 
>> And therefore it can be argued that in neither case should we update
>> the routing cache PMTU information.  
> 
> Should be ok as long as all userspace applications that use UDP or
> RAW sockets handle pmtu event notifications properly.

I am convinced that they absolutely must, if they use IP_PMTUDISC_DO.

Otherwise they will continue making larger-than-PMTU sendmsg()
requests.  As these are datagram sockets, we can't simply segment the
data.

> ping might be a special case, but now the behaviour of a big
> sized ping (say 1400 byte on a network that has a router with
> mtu 1300 along the path) with IP_PMTUDISC_WANT might depend on
> whether the cached pmtu informations are updated by a recent
> tcp connection.
> 
> If we had no tcp connection before, we see the behaviour that
> I described in my first mail. All packets have the DF bit set.
> 
> If a tcp connection updated the cached pmtu informations recently,
> the packets don't have the DF bit set. They are fragmented according
> the cached pmtu informations instead.
> 
> Other applications that do not care for pmtu event notifications
> might be in a similar situation. So perhaps we need the kind of
> patch you are suggested.

We can't do exactly as my patch did, because it allows remote entities
to easily poison PMTU information.  All they have to know is that
there is some UDP or RAW socket open with a certain ID and then send
forged ICMP to us.

What we possibly could do is adjust the socket's IP_PMTUDISC_* setting
from IP_PMTUDISC_WANT to IP_PMTUDISC_DONT in response to PMTU
messages.

This seems to solve all the problems.  Individual RAW and UDP sockets
get the behavior they did before, and route cache PMTU poisoning is
less of an issue.
