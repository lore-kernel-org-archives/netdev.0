From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: on-link assumption in ipv4 routing cache
Date: Thu, 23 Oct 2008 13:47:44 -0400
Message-ID: <4900B8C0.5020205@hp.com>
References: <48FD2A34.7020702@hp.com> <20081020.221312.211946478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:27163 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbYJWRry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 13:47:54 -0400
In-Reply-To: <20081020.221312.211946478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Mon, 20 Oct 2008 21:02:44 -0400
> 
>> This was somewhat of a surprise since I expected a EHOSTUNRACH error since
>> there were no routes to the destination and SO_DONTROUTE was not set.
>>
>> I am really curious as to reason for this behavior?
> 
> In general the Linux ipv4 stack tries to do things that make it more
> likely for successful communication between two nodes.
> 
> This is one such example, another is the choice of using the host
> based addressing model rather than the interface based addressing
> model.
> 
> Alexey Kuznetsov is responsible for most of these decisions, he is
> a genius.
> 

Hi David

Ok, I've found the code and the explanation, but I think there is
a small bug here that's been around a very long time.  There is absolutely
no checking for the interface state.  This means that if the interface
is brought down, we are still going to attempt to route through it.
That seems broken, since the interface was administratively brought down.

I've actually tried to do this with my test app.  I've set it to connect
over a given interface, brought the interface down, and then issued the
connect().  The result is that the app hung until tcp_syn_retries SYNs have
been issued and then returned error.

I've got no issues against on-link assumption as long as there are some smarts
behind it.  The least we could do is use a running interface.

-vlad
