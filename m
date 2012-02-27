From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Mon, 27 Feb 2012 15:00:06 +0100
Message-ID: <4F4B8C66.5060206@collabora.co.uk>
References: <1329753455-1106-1-git-send-email-javier@collabora.co.uk> <20120224.153616.117399887784547022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: javier@collabora.co.uk, eric.dumazet@gmail.com,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	rodrigo.moya@collabora.co.uk, sjoerd.simons@collabora.co.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120224.153616.117399887784547022.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 02/24/2012 09:36 PM, David Miller wrote:
> 
> My first impression is that I'm amazed at how much complicated new
> code you have to add to support groups of receivers of AF_UNIX
> messages.
> 
> I can't see how this is better than doing multicast over ipv4 using
> UDP or something like that, code which we have already and has been
> tested for decades.
> 

Primary for performance reasons. D-bus is an IPC system for processes in
the same machine so traversing the whole TCP/IP stack seems a little
overkill to me. We will try it though to have numbers on the actual
overhead of using UDP multicast over IP instead of multicast Unix domain
sockets.

We also thought of using Netlink sockets since it already supports
multicast and should be more lightweight than IP multicast. But even
Netlink doesn't meet our needs since our multicast on Unix sockets
implementation has different semantics needed for D-bus:

- total order is guaranteed: If sender A sends a message before B, then
receiver C and D should both get message A first and then B.

- slow readers: dropping packets vs blocking the sender. Although
  datagrams are not reliable on IP, datagrams on Unix sockets are never
  lost. So if one receiver has its buffer full the sender is blocked
instead of dropping packets. That way we guarantee a reliable
communication channel.

- multicast group acess control: controlling who can join the multicast
group.

- multicast on loopback is not supported: which means we have to use a
NIC (i.e: eth0).

> I really don't want to apply this stuff, it looks bloated,
> complicated, and there is another avenue for doing what you want to
> do.
> 

We can work to reduce the implementation complexity and make it less
bloated.

Or you don't like the idea in general?

> Applications have to change to support the new multicast facilities,
> so they can equally be changed to use a real transport that already
> supports multicasting.

Yes, this is not about minimizing user-space application change but to
improve the D-bus performance, or any other framework that relies on
multicast communication on a single machine.

Best regards,
Javier
