From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net-next 2/3] tipc: byte-based overload control on socket
 receive queue
Date: Tue, 19 Feb 2013 21:16:40 +0100
Message-ID: <5123DDA8.5090202@ericsson.com>
References: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com> <1360969067-29956-3-git-send-email-paul.gortmaker@windriver.com> <20130218144757.GA26199@hmsreliant.think-freely.org> <512332DA.5040508@ericsson.com> <20130219142629.GA31871@hmsreliant.think-freely.org> <5123BC46.40909@ericsson.com> <20130219191833.GB31871@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Ying Xue <ying.xue@windriver.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:44330 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757787Ab3BSURF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 15:17:05 -0500
In-Reply-To: <20130219191833.GB31871@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/19/2013 08:18 PM, Neil Horman wrote:
> On Tue, Feb 19, 2013 at 06:54:14PM +0100, Jon Maloy wrote:
>> On 02/19/2013 03:26 PM, Neil Horman wrote:
>>> On Tue, Feb 19, 2013 at 09:07:54AM +0100, Jon Maloy wrote:
>>>> On 02/18/2013 09:47 AM, Neil Horman wrote:
>>>>> On Fri, Feb 15, 2013 at 05:57:46PM -0500, Paul Gortmaker wrote:
>>>>>> From: Ying Xue <ying.xue@windriver.com>
>>>>>>
>>>>>> Change overload control to be purely byte-based, using
>>>>>> sk->sk_rmem_alloc as byte counter, and compare it to a calculated
>>>>>> upper limit for the socket receive queue.
>>>>
>>>> [...]
>>>>
>>>>>> + *
>>>>>> + * For all connectionless messages, by default new queue limits are
>>>>>> + * as belows:
>>>>>> + *
>>>>>> + * TIPC_LOW_IMPORTANCE       (5MB)
>>>>>> + * TIPC_MEDIUM_IMPORTANCE    (10MB)
>>>>>> + * TIPC_HIGH_IMPORTANCE      (20MB)
>>>>>> + * TIPC_CRITICAL_IMPORTANCE  (40MB)
>>>>>> + *
>>>>>> + * Returns overload limit according to corresponding message importance
>>>>>> + */
>>>>>> +static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *buf)
>>>>>> +{
>>>>>> +	struct tipc_msg *msg = buf_msg(buf);
>>>>>> +	unsigned int limit;
>>>>>> +
>>>>>> +	if (msg_connected(msg))
>>>>>> +		limit = CONN_OVERLOAD_LIMIT;
>>>>> This still strikes me as a bit wierd.  If you really can't tolerate the default
>>>>> rmem settings in proc, have you considered separating the rmem and wmem values
>>>>> out into their own sysctls?  
>>>>
>>>> Initially we tried to set this value as default for sk_rcvbuf, and then use
>>>> fractions of it as limits, as you suggest below. The problem we found was that
>>>> if we want to change this via setsockopt(SOL_SOCKET, SO_RCVBUF) the value range
>>>> we can use is very limited, and doesn't fit our purposes.
>>>>
>>> Can you elaborate on this please?  The above doesn't really explain why you
>>> can't do what I suggested.  Not asserting that what you say is untrue, mind you,
>>> I'm just trying to understand what it is about TIPC that requires such a
>>> specific reception buffer envelope, 
>> 	
>> There are two reasons for this. 
>> The first one due to the message oriented nature of the flow control for 
>> connections. Max message size is 65k, and max number of unacked messages 
>> (at socket level, that is) before the sending process will take a break 
>> is 1024. 
>> So, simple maths gives that we must allow for 64MB + sk_overhead to guarantee 
>> that a connection never is broken because of receiver overload. Contrary to TCP,
> Note, this is false, due to the fact that, it presumes that the sender will
> honor the congestion window.  Granted, that would be a sender violation, but its
> still possible for packets to get lost due to receiver overrun.  

The reason for this high limit is exactly to guard against crazy or malevolent 
senders. If they respect their send window they will never hit this limit on
connections.

The fact that
> you ack packets before accepting them to the receive queue is the problem that
> needs fixing in this case, but that looks like it can be easily accomplished
> (see below).
> 
>> we don't have the luxury to just drop packets and expect them to be retransmitted,
>> because in TIPC they have already passed through the retransmission and 
>> defragmentation layers, and are committed for delivery when they reach the 
>> receiving socket.
> The problem isn't that you don't have the luxury of droping packets, the problem
> is that you've decided to ack an incomming packet before you've determined if
> you have the space to accept it (I sympathise with you here, I had to go through
> this same exercise with SCTP a few years ago).  Just trying to balance your
> rcvbuf space so that you don't have to worry about it causes more problems than
> it solves in the end.

I think you are missing an important point here. There is no one-to-one relation
between a link and a socket. The link serves *all* socket on a node, with one shared
send/retransmission queue and one shared packet number sequence.  So dropping 
packets on arrival as you suggest will not only hurt the process sending too many 
messages, but everybody else sending anything between the two nodes.
Granted, the retransmission will take care of the dropped packet, but in the 
meantime no other packets can be delivered through from that link, to any 
socket. Basically, all TIPC communication between the two involved
nodes in the given direction would grind to a halt until the slow or overwhelmed 
receiver process has decided to work off his receive queue, something that may 
never happen if it is faulty.
You may see this as a flaw, but it is a consequence of that TIPC is a radically 
different design than IP based protocols, designed for completely different needs.
The shared link concept is a fundamental feature that has a lot of other advantages 
which I won't elaborate on here.

> 
> The thing to do is just move your rcvbuf check lower in the stack, in this case
> to tipc_recv_msg.  You have a tipc_msg struct there, from which you can
> determine if the message is data, get the desination port, and convert that to a
> tipc_port pointer, which contains a usr_handle pointer.  From my read, the
> usr_handle pointer is only ever set to a socket structure, 

Unfortunately not. There are still remnants of the "native" interface present, 
which is not socket based at all. We are working on that.

so if you have a non
> NULL usr_handle, cast it to a struct sock, and read is sk_rcvbuf.  If its over
> capacity, drop the packet before you ack it.

In theory this is possible, but extremely awkward with the current locking
structure (We are working on that too). Anyway, I hope I have convinced
you with the above that dropping packets at the link level is not a viable
option.

> 
>> You may question the wisdom of having a message oriented flow control algorithm, 
>> but this the way it is now. We do actually have a working prototype where we 
>> introduce purely byte-based flow control, but it is not ready for delivery yet, 
>> and compatibility constraints will require that we still keep this high limit 
>> in some cases.
>>
> I do believe that a byte oriented algorithm is better, but for now a message
> based mechanism is fine by me.  My only concern is that you honor the limits
> placed on the socket.  I'm not sure what compatibilty requirement enjoin you
> from having a lower rcvbuf limit, but it would seem to me, just not acking a
> message until you are sure you can accept it would fix those problems.  Even if
> that isn't the case, honor the limits, tie them to the tunables in /proc (or
> create your own), and document what the required limits are.
> 
>> The second reason is that TIPC provides SOCK_RDM instead of SOCK_DGRAM as its
>> basic datagram service. (It is the only transport service doing this afaik.)
>> So, the risk of having datagram messages rejected (not dropped), for any reason, 
>> must be extremely low. ("Rejected" here means that we notify the sender when a
>> message cannot be delivered, we don't just silently drop it.)
> Thats fine, I'm not talking about rejecting messages, I'm specifically referring
> to dropping them - i.e. behaving as if they never arrived at the host at all
> (save for maybe increasing a stats counter, so the admin knows whats going on).
> One way or another the sender has to be prepared to handle an unacked frame.  If
> you can't, then the protocol is broken.
> 
>> Given that we also often have seen designs with many clients sending towards
>> one server we have empirical experience that we must have a high threshold here.
>> One can discuss whether 2MB or 5MB is the adequate limit for the lowest level, 
>> we don't really now since this a new design, but we have every reason to believe
>> that the upper limit permitted by setsockopt(SOL_SOCK) (425,984 bytes according
>> to a quick test I made) is not enough for us.
> I'm not trying to force you to a lower sk_rcvbuf value, I'm fine with whatever
> you want to set it to, my only request here is that you honor the limits set on
> your socket at least semi accurately.  If you need to set that limit higher by
> default, do so (theres sysctl values for that already:
> sysctl_rmem_[min|default|max], or you can build your own, though I would
> recommend you use the former).

Ok, I wasn't aware of that. Now, if we could set these parameters from inside 
the module, when a socket is created, we I think we have what we need. We 
don't want to force every socket creator to set these limits explicitly, unless
he has some very particular needs and knows what he is doing.

///jon

> 
> Note also, that the upper limit of sk_rcvbuf isn't 425,984 bytes.  That sounds
> more like what you have sysctl_rmem_max set to on your system at the moment.
> Bump that up if you need it higher (do the same with sysctl_rmem_default, for
> apps that need to expect your old buffer size value.
> 
>>
>>> and how enforcing queue limits here is so
>>> important when packets could just as easily be dropped at the ip layer (with
>>> ostensibly no fatal failure).
>>
>> There is no IP layer. TIPC and its retransmission layer sits directly on top of
>> L2/Ethernet. Nothing can be dropped below that layer, for obvious reasons,
>> and to drop anything above that layer *has* fatal consequences, because TIPC
>> guarantees delivery both for connection oriented and connectionless (as far as 
>> ever possible) services. 
> Sorry, I forgot TIPC sat directly on top of L2.  Regardless however, as noted
> above, you can certainly still do discards below your ack point in your stack.
> 
>> Anyway, only the receiving socket contains the info making it possible to
>> select which messages to reject, in the rare cases where that becomes
>> unavoidable.
>>
> Yup, and you can interrogate that from tipc_recv_msg
> 
>>>
>>>> We did consider to introduce a separate setsockopt at TIPC level for this,
>>>> but thought it had a value in itself to use the mechanism that is already there. 
>>>> Hence the "re-interpretation" of sk_rcvbuf as we do below.
>>>> Considering the weird doubling of this parameter that is done elsewhere in the
>>>> code we thought that having our own interpretation might be acceptable.
>>> Thats quite different IMHO.  The comments in sock_setsockopt make it pretty
>>> clear that the doubling of the rcvbuf value is done to account for the sk_buff
>>> overhead of packet reception, and thats documented in the socket(7) man page.
>>> What you have here is the ability to set sk_rcvbuf, and then have that setting
>>> be ignored, but only to within several different limits, depending on various
>>> conditions, all of which are not visible to user space.
>>>
>>>> We did of course see the potential issue with this, that is why we cc-ed
>>>> you for comments.
>>> I appreciate that.
>>>
>>>> Now I see that David already pulled the series, so I am a little uncertain 
>>>> about how to proceed. 
>>> I saw that too, and asked him about this.  A follow-on patch (if we wind up
>>> deciding one is warranted) is the way to go here.
>>
>> Good. The best solution I see now, if you think the times-32 scaling is 
>> unacceptable, would be to introduce a setsockopt() at SOL_TIPC level, and allow
>> for much wider limits than SOL_SOCK permits now. That we need these wider limits
>> is beyond doubt, as I see it.
>>
> No  See above, don't do a special socket option.  Just use the existing sysctl
> to define your default and upper limits, and if they're not big enough, set them
> higher,  you can use /etc/sysctl.conf to automate this.
> 
> Neil
> 
>> Regards
>> ///jon
>>
>>>
>>> Regards
>>> Neil
>>>
>>
>>
