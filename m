From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: any way to let host act as TCP server OR client on same IP/port?
Date: Thu, 14 Jul 2011 11:33:59 -0600
Message-ID: <4E1F2887.4040307@genband.com>
References: <4E1DC83C.3020506@genband.com>	<1310579520.2509.17.camel@edumazet-laptop>	<4E1DDE62.3080503@hp.com> <4E1DEEF9.7040901@genband.com> <4E1F0345.8020108@genband.com> <4E1F1D3A.1030204@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og110.obsmtp.com ([64.18.2.173]:60957 "EHLO
	exprod7og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932141Ab1GNReM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 13:34:12 -0400
In-Reply-To: <4E1F1D3A.1030204@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> In our case we don't need to actually be connected, just be listening
>>> and ready to either accept() a connection or connect() to someone else.
>>
>> It turns out that the application people really do want the server side
>> to be able to listen() at the same time as calling connect() from the
>> same address/port, so Rick's testcase was accurate.
>
> So, we are left asking "Why do the application people want that?" Does
> the server connect() to pseudo-random places, or does it only ever
> connect back to clients which have already connected to it?

I'm not an expert in the application domain, but here's what I know. 
You can think of the situation as having a server, a gateway, and many 
clients.  The goal is to map each client to a single unique port on the 
server-facing side of the gateway, such that all traffic for that client 
goes through that port.

The complicating factor is that traffic may be initiated by either the 
client or the server.  With UDP this isn't a problem, but for TCP it's 
tricky.

For IPv4 the app team originally set it up so that the gateway listens 
on a single port on the server side of the gateway, and when the server 
opens a connection to a client's unique port (with an ephemeral port as 
the source port) it gets NAT'd to that single port.  (The unique ports 
on the server side ensure that there are no 4-tuple collisions.)  For 
traffic originating from the client, the gateway binds a socket to the 
client's unique port and uses it to open a connection to the server.

IPv6 doesn't support NAT (at least not in the stock kernel), so they're 
looking for alternatives.

> If the desire is to have the same well-known port number involved in all
> connections to/from the server (perhaps for simplistic firewall rules
> involving serverip.magicport?)

I suspect it's something like that.

> then if the connections are back to the
> clients, the clients could simply open listen endpoints bound to the
> magic port number and the firewall rule become "server IP is source or
> destination) AND (magic port is source or destination)" - assuming the
> clients aren't bind()ing to the magic port number before connect()ing to
> the server.

We don't control the server, only the gateway.  Ephemeral source ports 
are used for connections opened by the server, so a known port is needed 
on the gateway side.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
