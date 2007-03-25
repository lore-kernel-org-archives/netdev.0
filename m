From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 1/5 2.6.21-rc4] l2tp: pppol2tp core
Date: Sun, 25 Mar 2007 17:00:43 +0100
Message-ID: <46069CAB.9050807@katalix.com>
References: <200703232307.l2NN7Rtg010808@quickie.katalix.com> <46052FC0.8080804@trash.net> <4605758F.90205@katalix.com> <4605908C.6050205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:60157 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751712AbXCYQAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2007 12:00:47 -0400
In-Reply-To: <4605908C.6050205@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

Thanks for your comments so far. More questions below.

Patrick McHardy wrote:
> James Chapman wrote:
>> Patrick McHardy wrote:
>>
>>> The interaction with UDP sockets looks pretty horrible IMO. On the
>>> send side I don't see why you can't simply build the UDP header
>>> yourself instead of doing these set_fs + sendmsgs hacks. 
>>
>> Wouldn't that effectively duplicate the code in udp_sendmsg()? If I
>> don't use a socket, I'd also have to build an IP header and feed the
>> frame into the IP stack for outbound routing. It doesn't feel like the
>> right thing to do.
> 
> Thats what other tunnel drivers do. Sending UDP is pretty simple, I'd
> expect that it comes down to less code than now.

I'm still not getting this. :( What other tunnel drivers do this?

I've looked at other socket code examples. I see sendmsg code like pppoe 
which builds a skb and does a dev_queue_xmit() or code like cifs that 
uses kernel_sendmsg() which does the set_fs hack internally.

ESP does build its own UDP header. But ESP is working at a different 
level (IP packet type) rather than L2TP which is really just UDP data. 
Most of the stuff done in udp_sendmsg() is relevant for L2TP, i.e. 
socket param checks, UDP checksum, flow classification, route lookup, IP 
output, MIB counter updates etc. If I do all of this in 
pppol2tp_sendmsg() and insert the IP and UDP header, should I also 
insert the netdevice's MAC address and then dev_queue_xmit()? I'd just 
like to be clear in my own mind what you are recommending before I code 
it up. :)

>> One reason for using the L2TP tunnel's UDP socket directly was to have
>> the data traffic carried by all sessions in that tunnel use the tunnel's
>> socket buffer, thereby ensuring that one tunnel's data can't starve
>> another tunnel.
> 
> If you use encapsulation sockets and process packets immediately
> that should still not be possible.

My understanding is that encapsulation is used where a header is 
inserted _before_ UDP/TCP headers, not after. In the L2TP case, the 
kernel has some data that it wants to send over UDP. The UDP socket 
doesn't need to be special.

>>> - pppol2tp_fget: why do you want to open sockets for other processes?
>>>   I hope this can go together with the sendmsg hacks
>>
>> There are two userspace daemons: l2tpd and pppd. L2ptd opens a UDP
>> tunnel socket and sets up one or more L2TP sessions in that tunnel. When
>> a new session is established, l2tpd spawns a pppd process (per session).
>> The pppd process creates a PPPoL2TP socket (this driver). The PPPoL2TP
>> socket is associated with the tunnel UDP socket that was created by
>> l2tpd. So on creating a new PPPoX socket, the connect() handling needs
>> to find the UDP socket of the tunnel. Since connect() runs in the
>> context of pppd, it needs a way of doing a sock lookup to find the UDP
>> socket that was created by l2tpd.
> 
> How about just passing the file descriptor from l2tpd to pppd?

I do already. :) The problem is that the UDP (tunnel) fd is created and 
owned by l2tpd and the PPPoX socket is created and owned by pppd. The 
PPPoX connect() is done by pppd on its PPPoX socket. The connect 
parameters include the fd of the UDP socket which is to be used to carry 
the PPPoX data. Hence pppol2tp_connect() needs to locate the UDP socket 
that was created by l2tpd, while in the context of pppd.

Thanks again for your comments!

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

