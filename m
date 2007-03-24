From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 1/5 2.6.21-rc4] l2tp: pppol2tp core
Date: Sat, 24 Mar 2007 19:01:35 +0000
Message-ID: <4605758F.90205@katalix.com>
References: <200703232307.l2NN7Rtg010808@quickie.katalix.com> <46052FC0.8080804@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:45603 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932702AbXCXTBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Mar 2007 15:01:37 -0400
In-Reply-To: <46052FC0.8080804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> James Chapman wrote:
>> [PPPOL2TP]: Add PPP-over-L2TP driver core.
>>
>> This driver handles only L2TP data frames; control frames are handled
>> by a userspace application. The dfriver implements L2TP using the
>> PPPoX socket family. Data is sent or received using regular socket
>> sendmsg() / recvmsg() calls. Kernel parameters of the socket can be
>> read or modified using ioctl() or [gs]etsockopt() calls.
> 
> 
> The interaction with UDP sockets looks pretty horrible IMO. On the
> send side I don't see why you can't simply build the UDP header
> yourself instead of doing these set_fs + sendmsgs hacks. 

Wouldn't that effectively duplicate the code in udp_sendmsg()? If I 
don't use a socket, I'd also have to build an IP header and feed the 
frame into the IP stack for outbound routing. It doesn't feel like the 
right thing to do.

One reason for using the L2TP tunnel's UDP socket directly was to have 
the data traffic carried by all sessions in that tunnel use the tunnel's 
socket buffer, thereby ensuring that one tunnel's data can't starve 
another tunnel.

> On the
> receive side I it would be nice if you could use the encapsulation
> socket stuff thats also used by IPsec.

Can you point me at some example code, please?

> A couple of random comments:
> 
> - your list locking is broken

Stupid me. Thanks.

> - list_for_each_entry_safe is only needed if you remove something
>   while iterating, its no replacement for locking

I've gotten into a bad habit of always using list_for_each_entry_safe. 
I'll fix these (with locking).

> - SOCK_2_SESSION/SOCK_2_TUNNEL are terribly ugly and should
>   probably be inline functions that use BUG_ON in case of an
>   invalid magic

ok

> - You should use skb_queue_walk for queue walking

ok

> - You should use endian-annotated types

I hadn't noticed them before. Will do.

> - pppol2tp_fget: why do you want to open sockets for other processes?
>   I hope this can go together with the sendmsg hacks

There are two userspace daemons: l2tpd and pppd. L2ptd opens a UDP 
tunnel socket and sets up one or more L2TP sessions in that tunnel. When 
a new session is established, l2tpd spawns a pppd process (per session). 
The pppd process creates a PPPoL2TP socket (this driver). The PPPoL2TP 
socket is associated with the tunnel UDP socket that was created by 
l2tpd. So on creating a new PPPoX socket, the connect() handling needs 
to find the UDP socket of the tunnel. Since connect() runs in the 
context of pppd, it needs a way of doing a sock lookup to find the UDP 
socket that was created by l2tpd.

Thanks for the comments. Please get back to me about the socket usage 
questions. Meanwhile I'll work on fixing the other things you noted.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

