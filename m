From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net-next 2/3] tipc: byte-based overload control on socket
 receive queue
Date: Tue, 19 Feb 2013 18:54:14 +0100
Message-ID: <5123BC46.40909@ericsson.com>
References: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com> <1360969067-29956-3-git-send-email-paul.gortmaker@windriver.com> <20130218144757.GA26199@hmsreliant.think-freely.org> <512332DA.5040508@ericsson.com> <20130219142629.GA31871@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Ying Xue <ying.xue@windriver.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:43636 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757885Ab3BSRyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 12:54:19 -0500
In-Reply-To: <20130219142629.GA31871@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/19/2013 03:26 PM, Neil Horman wrote:
> On Tue, Feb 19, 2013 at 09:07:54AM +0100, Jon Maloy wrote:
>> On 02/18/2013 09:47 AM, Neil Horman wrote:
>>> On Fri, Feb 15, 2013 at 05:57:46PM -0500, Paul Gortmaker wrote:
>>>> From: Ying Xue <ying.xue@windriver.com>
>>>>
>>>> Change overload control to be purely byte-based, using
>>>> sk->sk_rmem_alloc as byte counter, and compare it to a calculated
>>>> upper limit for the socket receive queue.
>>
>> [...]
>>
>>>> + *
>>>> + * For all connectionless messages, by default new queue limits are
>>>> + * as belows:
>>>> + *
>>>> + * TIPC_LOW_IMPORTANCE       (5MB)
>>>> + * TIPC_MEDIUM_IMPORTANCE    (10MB)
>>>> + * TIPC_HIGH_IMPORTANCE      (20MB)
>>>> + * TIPC_CRITICAL_IMPORTANCE  (40MB)
>>>> + *
>>>> + * Returns overload limit according to corresponding message importance
>>>> + */
>>>> +static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *buf)
>>>> +{
>>>> +	struct tipc_msg *msg = buf_msg(buf);
>>>> +	unsigned int limit;
>>>> +
>>>> +	if (msg_connected(msg))
>>>> +		limit = CONN_OVERLOAD_LIMIT;
>>> This still strikes me as a bit wierd.  If you really can't tolerate the default
>>> rmem settings in proc, have you considered separating the rmem and wmem values
>>> out into their own sysctls?  
>>
>> Initially we tried to set this value as default for sk_rcvbuf, and then use
>> fractions of it as limits, as you suggest below. The problem we found was that
>> if we want to change this via setsockopt(SOL_SOCKET, SO_RCVBUF) the value range
>> we can use is very limited, and doesn't fit our purposes.
>>
> Can you elaborate on this please?  The above doesn't really explain why you
> can't do what I suggested.  Not asserting that what you say is untrue, mind you,
> I'm just trying to understand what it is about TIPC that requires such a
> specific reception buffer envelope, 
	
There are two reasons for this. 
The first one due to the message oriented nature of the flow control for 
connections. Max message size is 65k, and max number of unacked messages 
(at socket level, that is) before the sending process will take a break 
is 1024. 
So, simple maths gives that we must allow for 64MB + sk_overhead to guarantee 
that a connection never is broken because of receiver overload. Contrary to TCP,
we don't have the luxury to just drop packets and expect them to be retransmitted,
because in TIPC they have already passed through the retransmission and 
defragmentation layers, and are committed for delivery when they reach the 
receiving socket.
You may question the wisdom of having a message oriented flow control algorithm, 
but this the way it is now. We do actually have a working prototype where we 
introduce purely byte-based flow control, but it is not ready for delivery yet, 
and compatibility constraints will require that we still keep this high limit 
in some cases.

The second reason is that TIPC provides SOCK_RDM instead of SOCK_DGRAM as its
basic datagram service. (It is the only transport service doing this afaik.)
So, the risk of having datagram messages rejected (not dropped), for any reason, 
must be extremely low. ("Rejected" here means that we notify the sender when a
message cannot be delivered, we don't just silently drop it.)
Given that we also often have seen designs with many clients sending towards
one server we have empirical experience that we must have a high threshold here.
One can discuss whether 2MB or 5MB is the adequate limit for the lowest level, 
we don't really now since this a new design, but we have every reason to believe
that the upper limit permitted by setsockopt(SOL_SOCK) (425,984 bytes according
to a quick test I made) is not enough for us.

> and how enforcing queue limits here is so
> important when packets could just as easily be dropped at the ip layer (with
> ostensibly no fatal failure).

There is no IP layer. TIPC and its retransmission layer sits directly on top of
L2/Ethernet. Nothing can be dropped below that layer, for obvious reasons,
and to drop anything above that layer *has* fatal consequences, because TIPC
guarantees delivery both for connection oriented and connectionless (as far as 
ever possible) services. 
Anyway, only the receiving socket contains the info making it possible to
select which messages to reject, in the rare cases where that becomes
unavoidable.

> 
>> We did consider to introduce a separate setsockopt at TIPC level for this,
>> but thought it had a value in itself to use the mechanism that is already there. 
>> Hence the "re-interpretation" of sk_rcvbuf as we do below.
>> Considering the weird doubling of this parameter that is done elsewhere in the
>> code we thought that having our own interpretation might be acceptable.
> Thats quite different IMHO.  The comments in sock_setsockopt make it pretty
> clear that the doubling of the rcvbuf value is done to account for the sk_buff
> overhead of packet reception, and thats documented in the socket(7) man page.
> What you have here is the ability to set sk_rcvbuf, and then have that setting
> be ignored, but only to within several different limits, depending on various
> conditions, all of which are not visible to user space.
> 
>> We did of course see the potential issue with this, that is why we cc-ed
>> you for comments.
> I appreciate that.
> 
>> Now I see that David already pulled the series, so I am a little uncertain 
>> about how to proceed. 
> I saw that too, and asked him about this.  A follow-on patch (if we wind up
> deciding one is warranted) is the way to go here.

Good. The best solution I see now, if you think the times-32 scaling is 
unacceptable, would be to introduce a setsockopt() at SOL_TIPC level, and allow
for much wider limits than SOL_SOCK permits now. That we need these wider limits
is beyond doubt, as I see it.

Regards
///jon

> 
> Regards
> Neil
> 
