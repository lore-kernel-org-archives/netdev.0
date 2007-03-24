From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/5 2.6.21-rc4] l2tp: pppol2tp core
Date: Sat, 24 Mar 2007 21:56:44 +0100
Message-ID: <4605908C.6050205@trash.net>
References: <200703232307.l2NN7Rtg010808@quickie.katalix.com> <46052FC0.8080804@trash.net> <4605758F.90205@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60985 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbXCXU4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 16:56:49 -0400
In-Reply-To: <4605758F.90205@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> Patrick McHardy wrote:
> 
>> The interaction with UDP sockets looks pretty horrible IMO. On the
>> send side I don't see why you can't simply build the UDP header
>> yourself instead of doing these set_fs + sendmsgs hacks. 
> 
> 
> Wouldn't that effectively duplicate the code in udp_sendmsg()? If I
> don't use a socket, I'd also have to build an IP header and feed the
> frame into the IP stack for outbound routing. It doesn't feel like the
> right thing to do.


Thats what other tunnel drivers do. Sending UDP is pretty simple, I'd
expect that it comes down to less code than now.

> One reason for using the L2TP tunnel's UDP socket directly was to have
> the data traffic carried by all sessions in that tunnel use the tunnel's
> socket buffer, thereby ensuring that one tunnel's data can't starve
> another tunnel.


If you use encapsulation sockets and process packets immediately
that should still not be possible.

>> On the
>> receive side I it would be nice if you could use the encapsulation
>> socket stuff thats also used by IPsec.
> 
> 
> Can you point me at some example code, please?


net/ipv4/udp.c: udp_encap_rcv()

>> - pppol2tp_fget: why do you want to open sockets for other processes?
>>   I hope this can go together with the sendmsg hacks
> 
> 
> There are two userspace daemons: l2tpd and pppd. L2ptd opens a UDP
> tunnel socket and sets up one or more L2TP sessions in that tunnel. When
> a new session is established, l2tpd spawns a pppd process (per session).
> The pppd process creates a PPPoL2TP socket (this driver). The PPPoL2TP
> socket is associated with the tunnel UDP socket that was created by
> l2tpd. So on creating a new PPPoX socket, the connect() handling needs
> to find the UDP socket of the tunnel. Since connect() runs in the
> context of pppd, it needs a way of doing a sock lookup to find the UDP
> socket that was created by l2tpd.


How about just passing the file descriptor from l2tpd to pppd?
