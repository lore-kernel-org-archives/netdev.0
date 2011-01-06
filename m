From: Jesse Gross <jesse@nicira.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Thu, 6 Jan 2011 17:38:01 -0500
Message-ID: <AANLkTinJK-nbkP5_ee2cuS8RA7jTB4-bcWmAf4bjSouP@mail.gmail.com>
References: <20110106093312.GA1564@verge.net.au>
	<1294309362.3074.11.camel@edumazet-laptop>
	<20110106124439.GA17004@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:46562 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234Ab1AFWiE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 17:38:04 -0500
In-Reply-To: <20110106124439.GA17004@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 6, 2011 at 7:44 AM, Simon Horman <horms@verge.net.au> wrote=
:
> On Thu, Jan 06, 2011 at 11:22:42AM +0100, Eric Dumazet wrote:
>> Le jeudi 06 janvier 2011 =E0 18:33 +0900, Simon Horman a =E9crit :
>> > Hi,
>> >
>> > Back in October I reported that I noticed a problem whereby flow c=
ontrol
>> > breaks down when openvswitch is configured to mirror a port[1].
>> >
>> > I have (finally) looked into this further and the problem appears =
to relate
>> > to cloning of skbs, as Jesse Gross originally suspected.
>> >
>> > More specifically, in do_execute_actions[2] the first n-1 times th=
at an skb
>> > needs to be transmitted it is cloned first and the final time the =
original
>> > skb is used.
>> >
>> > In the case that there is only one action, which is the normal cas=
e, then
>> > the original skb will be used. But in the case of mirroring the cl=
oning
>> > comes into effect. And in my case the cloned skb seems to go to th=
e (slow)
>> > eth1 interface while the original skb goes to the (fast) dummy0 in=
terface
>> > that I set up to be a mirror. The result is that dummy0 "paces" th=
e flow,
>> > and its a cracking pace at that.
>> >
>> > As an experiment I hacked do_execute_actions() to use the original=
 skb
>> > for the first action instead of the last one. =A0In my case the re=
sult was
>> > that eth1 "paces" the flow, and things work reasonably nicely.
>> >
>> > Well, sort of. Things work well for non-GSO skbs but extremely poo=
rly for
>> > GSO skbs where only 3 (yes 3, not 3%) end up at the remote host ru=
nning
>> > netserv. I'm unsure why, but I digress.
>> >
>> > It seems to me that my hack illustrates the point that the flow en=
ds up
>> > being "paced" by one interface. However I think that what would be
>> > desirable is that the flow is "paced" by the slowest link. Unfortu=
nately
>> > I'm unsure how to achieve that.
>> >
>>
>> Hi Simon !
>>
>> "pacing" is done because skb is attached to a socket, and a socket h=
as a
>> limited (but configurable) sndbuf. sk->sk_wmem_alloc is the current =
sum
>> of all truesize skbs in flight.
>>
>> When you enter something that :
>>
>> 1) Get a clone of the skb, queue the clone to device X
>> 2) queue the original skb to device Y
>>
>> Then : =A0 =A0 =A0 =A0Socket sndbuf is not affected at all by device=
 X queue.
>> =A0 =A0 =A0 This is speed on device Y that matters.
>>
>> You want to get servo control on both X and Y
>>
>> You could try to
>>
>> 1) Get a clone of skb
>> =A0 =A0Attach it to socket too (so that socket get a feedback of fin=
al
>> orphaning for the clone) with skb_set_owner_w()
>> =A0 =A0queue the clone to device X
>>
>> Unfortunatly, stacked skb->destructor() makes this possible only for
>> known destructor (aka sock_wfree())
>
> Hi Eric !
>
> Thanks for the advice. I had thought about the socket buffer but at s=
ome
> point it slipped my mind.
>
> In any case the following patch seems to implement the change that I =
had in
> mind. However my discussions Michael Tsirkin elsewhere in this thread=
 are
> beginning to make me think that think that perhaps this change isn't =
the
> best solution.

I know that everyone likes a nice netperf result but I agree with
Michael that this probably isn't the right question to be asking.  I
don't think that socket buffers are a real solution to the flow
control problem: they happen to provide that functionality but it's
more of a side effect than anything.  It's just that the amount of
memory consumed by packets in the queue(s) doesn't really have any
implicit meaning for flow control (think multiple physical adapters,
all with the same speed instead of a virtual device and a physical
device with wildly different speeds).  The analog in the physical
world that you're looking for would be Ethernet flow control.
Obviously, if the question is limiting CPU or memory consumption then
that's a different story.

This patch also double counts memory, since the full size of the
packet will be accounted for by each clone, even though they share the
actual packet data.  Probably not too significant here but it might be
when flooding/mirroring to many interfaces.  This is at least fixable
(the Xen-style accounting through page tracking deals with it, though
it has its own problems).
