From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net-next 2/3] tipc: byte-based overload control on socket
 receive queue
Date: Thu, 21 Feb 2013 11:24:19 +0100
Message-ID: <5125F5D3.1000509@ericsson.com>
References: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com> <1360969067-29956-3-git-send-email-paul.gortmaker@windriver.com> <20130218144757.GA26199@hmsreliant.think-freely.org> <512332DA.5040508@ericsson.com> <20130219142629.GA31871@hmsreliant.think-freely.org> <5123BC46.40909@ericsson.com> <20130219191833.GB31871@hmsreliant.think-freely.org> <5123DDA8.5090202@ericsson.com> <20130219214439.GC31871@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Ying Xue <ying.xue@windriver.com>,
	Jon Maloy <maloy@donjonn.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:48550 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165Ab3BUKYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 05:24:24 -0500
In-Reply-To: <20130219214439.GC31871@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/19/2013 10:44 PM, Neil Horman wrote:
> On Tue, Feb 19, 2013 at 09:16:40PM +0100, Jon Maloy wrote:
>> On 02/19/2013 08:18 PM, Neil Horman wrote:
>>> On Tue, Feb 19, 2013 at 06:54:14PM +0100, Jon Maloy wrote:
>>>> On 02/19/2013 03:26 PM, Neil Horman wrote:
>>>>> On Tue, Feb 19, 2013 at 09:07:54AM +0100, Jon Maloy wrote:
>>>>>> On 02/18/2013 09:47 AM, Neil Horman wrote:
>>>>>>> On Fri, Feb 15, 2013 at 05:57:46PM -0500, Paul Gortmaker wrote:
>>>>>>>> From: Ying Xue <ying.xue@windriver.com>
>> <snip>
> 
>>>> 	
>>>> There are two reasons for this. 
>>>> The first one due to the message oriented nature of the flow control for 
>>>> connections. Max message size is 65k, and max number of unacked messages 
>>>> (at socket level, that is) before the sending process will take a break 
>>>> is 1024. 
>>>> So, simple maths gives that we must allow for 64MB + sk_overhead to guarantee 
>>>> that a connection never is broken because of receiver overload. Contrary to TCP,
>>> Note, this is false, due to the fact that, it presumes that the sender will
>>> honor the congestion window.  Granted, that would be a sender violation, but its
>>> still possible for packets to get lost due to receiver overrun.  
>>
>> The reason for this high limit is exactly to guard against crazy or malevolent 
>> senders. If they respect their send window they will never hit this limit on
>> connections.
>>
> Nope, You don't get to have it both ways - If a sender is malevolent or crazy,
> what makes you think it will respect its send window?

Nothing. That is why we need this extra security measure that this limit provides.
The normal senders will never hit it, the crazy ones will, and have their 
connections broken as a consequence. 
Sorry I didn't express this clearly enough.

> 
>> The fact that
>>> you ack packets before accepting them to the receive queue is the problem that
>>> needs fixing in this case, but that looks like it can be easily accomplished
>>> (see below).
>>>
[...]
> No, I get that, but the fact that TIPC has a shared retransmit queue between all
> sockets on the link isn't an excuse to violate the limits set on an individual
> socket.
> 
>> Granted, the retransmission will take care of the dropped packet, but in the 
>> meantime no other packets can be delivered through from that link, to any 
>> socket. Basically, all TIPC communication between the two involved
>> nodes in the given direction would grind to a halt until the slow or overwhelmed 
>> receiver process has decided to work off his receive queue, something that may 
>> never happen if it is faulty.
> Sounds like a bug.  That should be fixed.

This is not a bug, but an inherent  property of any protocol providing
sequential, guaranteed delivery of packets, TCP inclusive.
If you lose/drop a packet in the sequence, no subsequent packets in
the stream can be delivered until the missing one has been retransmitted and
delivered. To make this delivery dependent of the whims of each and any of the 
potentially hundreds of receiving processes is simply not a good idea.

I could even show that your proposal would cause almost immediate
deadlock, due to the order incoming and outgoing data paths are grabbing 
the locks. But I would rather drop this part of the discussion; we can 
achieve what we want anyway, with much simpler means. See below.

> 
>> You may see this as a flaw, but it is a consequence of that TIPC is a radically 
>> different design than IP based protocols, designed for completely different needs.
>> The shared link concept is a fundamental feature that has a lot of other advantages 
>> which I won't elaborate on here.
>>
> Very well.  While I'm thinking of it though, you also seem to be making a large
> leap in reasoning - you seem to be repeatedly equating my request to have you
> honor the limits of sk_rcvbuf, with a desire to have that limit be smaller than
> what you currently have it set to.  

Not at all. Just like you, I am trying to find a way to tune up the defaults 
and the the limits using existing mechanisms, so that we can honour the 
nominal value of sk_rcvbuf. 
I think what you suggested may be a way to achieve this, but I am a little 
worried about side effects. I'll explain further down.

> Thats absolutely untrue.  I don't care if
> you set your limit to UINT_MAX/2 on a socket, I just want what you set to be

[...]

>>
>> Ok, I wasn't aware of that. Now, if we could set these parameters from inside 
>> the module, when a socket is created, we I think we have what we need. We 
>> don't want to force every socket creator to set these limits explicitly, unless
>> he has some very particular needs and knows what he is doing.
>>
> I've tried to explain this several times now.  You don't have to have set this value to
> what you want programatically, nor do you need to force the value from within
> the module code itself, you can do it administratively.  

This is exactly what I want to avoid. To force the users to set special parameters
during boot up just to make TIPC work would become another obstacle for the its 
adoption. TIPC is extremely easy to install and use, and it should remain so.

A programmatic solution is much better, if we can solve it from inside the module,
and this is what I am convinced that we can.
The following is an approach we discussed (inside the team) earlier, but dropped
due to the perceived impossibility to set the sk_rcvbuf to the desired values.
Now this limitation is not there, as I understand, and we can revive our 
proposal.

1: When a TIPC socket is created, sk_rcvbuf is set to 64MB+ (as it was before the 
   latest patch). This is the limit used as last resort against connected peers
   not respecting the connection send window.

2: Datagram messages are checked against fractions of this value, according to
   their importance priority. E.g. LOW->sk_rcvbuf/16,  MEDIUM->sk_rcvbuf/8
   HIGH->sk_rcvbuf/4 and CRITICAL->sk_rcvbuf/2.

3: In the unlikely event that anybody wants to change these limits, he can change
   sk_rcvbuf via setsockopt(SOL_SOCK) either by first changing
   /proc/sys/net/core/rmem_max as you suggest, or via a dedicated setsockopt(SOL_TIPC).
   The latter option would have the advantage that it could enforce a lower limit of
   skr_rcvbuf of 64MB, something that would be unthinkable with SOL_SOCK, because it 
   would obviously affect other protocols.

What do you think?

///jon

If you set:
> 
> /proc/sys/net/core/rmem_default

But this will 
> 
> to the value that you want all your sockets to have, any socket that gets
> initalized with sock_init_data will inherit that value.  Note that, when doing
> so, you may also have to set:
> 
> 
> 
> As you can't adminstratively set your default socket rcvbuf value to something
> larger than the maximum allowed value without raising the maximum allowed value
> first.
> 
> Then all you have to do is make sure those values are set during boot up, and for
> users, it will appear as though nothing has changed.
> 
> Neil
> 
>>
