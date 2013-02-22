From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net-next 2/3] tipc: byte-based overload control on socket
 receive queue
Date: Fri, 22 Feb 2013 12:18:52 +0100
Message-ID: <5127541C.9070306@ericsson.com>
References: <20130219142629.GA31871@hmsreliant.think-freely.org> <5123BC46.40909@ericsson.com> <20130219191833.GB31871@hmsreliant.think-freely.org> <5123DDA8.5090202@ericsson.com> <20130219214439.GC31871@hmsreliant.think-freely.org> <5125F5D3.1000509@ericsson.com> <20130221150746.GA2730@shamino.rdu.redhat.com> <51265134.5080001@ericsson.com> <20130221181656.GC2730@shamino.rdu.redhat.com> <51268C21.8050602@donjonn.com> <20130221213528.GA32764@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <maloy@donjonn.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Ying Xue <ying.xue@windriver.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg20.ericsson.net ([198.24.6.45]:58116 "EHLO
	usevmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756289Ab3BVLTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 06:19:13 -0500
In-Reply-To: <20130221213528.GA32764@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/21/2013 10:35 PM, Neil Horman wrote:
> On Thu, Feb 21, 2013 at 10:05:37PM +0100, Jon Maloy wrote:
>> On 02/21/2013 07:16 PM, Neil Horman wrote:
>>> On Thu, Feb 21, 2013 at 05:54:12PM +0100, Jon Maloy wrote:
>>>> On 02/21/2013 04:07 PM, Neil Horman wrote:
>>>>> On Thu, Feb 21, 2013 at 11:24:19AM +0100, Jon Maloy wrote:
>>>>>> On 02/19/2013 10:44 PM, Neil Horman wrote:
>>>>>>> On Tue, Feb 19, 2013 at 09:16:40PM +0100, Jon Maloy wrote:
>>>>>>>> On 02/19/2013 08:18 PM, Neil Horman wrote:
>>>>>>>>> On Tue, Feb 19, 2013 at 06:54:14PM +0100, Jon Maloy wrote:
>>>>>>>>>> On 02/19/2013 03:26 PM, Neil Horman wrote:
>>>>>>>>>>> On Tue, Feb 19, 2013 at 09:07:54AM +0100, Jon Maloy wrote:
>>>>>>>>>>>> On 02/18/2013 09:47 AM, Neil Horman wrote:
>>>>>>>>>>>>> On Fri, Feb 15, 2013 at 05:57:46PM -0500, Paul Gortmaker wrote:
>>>>>>>>>>>>>> From: Ying Xue <ying.xue@windriver.com>
>>>>>>>> <snip>
>>>> I wouldn't call it a bug, because it doesn't cause deadlock in the current code,
>>>> but it is clearly a design that can be improved.
>>> I don't understand this - Above you said you could demonstrate how my proposal
>>> (which was to drop packets when they surpassed the sk_rcvbuf limit), would cause
>>> deadlock - if that happens, you have a locking bug.  If the only reason this
>>> does not happen currently is because you allow for a large overrun of your
>>> set sk_rcvbuf, then ostensibly a lockup can still be triggered if you have a
>>> misbehaving sender that is willing to send frames past its congestion window.
>>> So I think the root question here is: Does the code currently deadlock if you
>>> drop frames in the receive path? 
>> No. We can drop as as many as we want, the retransmission protocol will
>> take hand of that, and that part is pretty robust by now.
>> But it *would* deadlock if we tried to read fields in the sock structure, with
>> the necessary grabbing of locks that involves, from within the scope of
>> tipc_recv_msg, which is at a completely different level in the stack.
>>
>> Since we don't do that in the current code, there is no deadlock problem.
>>
> Theres tons of protocols that read socket structures that low in the receive
> path, in fact (with the exception of TIPC) they all do, specifically for the
> purpose of being able to check, among other things, the socket buffer recieve
> limit.  See sctp_rcv, tcp_v4_rcv, tcp_v6_rcv, _udp4_lib_rcv, etc for examples.

All those examples are trivial in this respect, because they either have
no retransmission layer at all, or the retransmission is bound to the socket 
name space itself. If you first have to lookup the socket even to perform the 
most basic protocol check it goes without saying that you can first take a 
quick look into sk_rcvbuf before going on. Besides, it doesn't cost any 
performance with this approach.

There are, or have  been, other protocols, TIPC, LINX, HDLC, LAPB, MTP2 etc. 
where reliability is ensured at a logical data link layer (L2.5), and where 
this kind of early endpoint access is less obvious, but not impossible.
TIPC is the only one of these present in the Linux kernel and sporting
a socket API, though; that's why we are having this discussion.

> Looking at tipc_recv_msg, it looks to me like you need to grab the
> tipc_port_lock for a short critical section to get the tipc_port struct, from
> which (as we previously discussed, you can get the socket).  Presuming you've
> done appropriate reference counting on your socket, thats it.  One lock, that
> you take and release in several other places in the same call path.

Ok. Currently it looks like this:

Outgoing data path:
------------------

grab socket lock
   grab net lock
     grab node_lock
       <send packet(s)>
     release node lock
   release net lock
release socket lock


Incoming data path:
-------------------

grab net lock (read mode)
    <do some packet sanity check>
    grab node lock
       <perform link level protocol check>
    release node lock'
release net lock
grab port lock
  grab socket lock
     <check sk_rcvbuf>
     <deliver or reject>
  release socket lock
release port lock

As I interpreted your suggestion, incoming data path
would become as follows:
-----------------------

grab net lock (read mode)
   <do some packet sanity check>
   grab node lock
-->   grab port lock
        grab socket lock
           <check sk_rcvbuf>
        release socket lock
-->   release port lock
      <perform link level protocol check>
    release node lock
release net lock
grab port lock
  grab socket lock
     <check sk_rcvbuf>
     <deliver or reject>
  release socket lock
release port lock
 
I.e., deadlock would occur almost immediately.


Now, having slept on it, I see we could also do:
-----------------------------------------------

grab port lock
   grab socket lock
       check sk_rcvbuf>
   release socket lock
release port lock
grab net lock (read mode)
     <do some packet sanity check>
     grab node lock
        <perform link level protocol check>
     release node lock'
release net lock'
grab port lock
  grab socket lock
     <check sk_rcvbuf>
     <deliver or reject>
  release socket lock
release port lock

If this is what you meant, then you are right.
It would work, although it would severely impact performance.

But the fact that it works technically doesn't mean it is the 
right thing to do, because of the way it would mess up the 
overall packet flow. 
This is not a good solution! 

And I think there are better ways...
If we really want to improve the solution we agreed on
yesterday we should rather go for a scheme adding back-pressure
to the sender socket, even for connectionless datagram messages, 
not only connections as we do now. We have some ideas there, and 
you are welcome to participate in the discussions. 
Maybe another thread at tipc-discussion?

Regards
///jon




> 
> Neil
> 
>> ///jon
>>
>> [...]
>>>
>>>>>>
>>>>
>>
>>
