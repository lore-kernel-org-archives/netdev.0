From: Shriram Rajagopalan <rshriram@cs.ubc.ca>
Subject: Re: [PATCH] net/sched: sch_plug - Queue traffic until an explicit
 release command
Date: Thu, 5 Jan 2012 10:15:47 -0800
Message-ID: <CAP8mzPPEThFQRs=7MzS-keu_JztkJ4QOVcTxsW+4bq3K4wWbDg@mail.gmail.com>
References: <1324329752-28459-1-git-send-email-rshriram@cs.ubc.ca>
 <1324391902.17751.227.camel@mojatatu> <CAP8mzPNmqPjmYZHT5d21D1yjz293wF+EF0BwoMAu+M=7VtHHSg@mail.gmail.com>
 <1324479261.18038.109.camel@mojatatu> <CAP8mzPNtei=6oVC8APf3Og_g+2YEUCnPCB+YOdBEKkcUYqXN1Q@mail.gmail.com>
Reply-To: rshriram@cs.ubc.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cs.ubc.ca ([142.103.6.52]:45243 "EHLO smtp.cs.ubc.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755407Ab2AESQb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:16:31 -0500
Received: from mail-ey0-f174.google.com (mail-ey0-f174.google.com [209.85.215.174])
	(authenticated bits=0)
	by smtp.cs.ubc.ca (8.14.3/8.13.6) with ESMTP id q05IGTsO002374
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 5 Jan 2012 10:16:30 -0800
Received: by eaad14 with SMTP id d14so521842eaa.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 10:16:28 -0800 (PST)
In-Reply-To: <CAP8mzPNtei=6oVC8APf3Og_g+2YEUCnPCB+YOdBEKkcUYqXN1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I apologize if this is a duplicate. Previous one got bumped due to
HTML formatting :(

On 2011-12-21, at 6:54 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On Tue, 2011-12-20 at 11:05 -0600, Shriram Rajagopalan wrote:
>
>> In dom0. Basically the setup is like this:
>> Guest (veth0)
>> dom0 (vif0.0 --> eth0)
>>
>> =A0 packets coming out of veth0 appear as incoming packets in vif0.0
>> Once Remus (or any other output commit style system is started)
>> the following commands could be executed in dom0, to activate this q=
disc
>> ip link set ifb0 up
>> tc qdisc add dev vif0.0 ingress
>> tc filter add dev vif0.0 parent ffff: proto ip pref 10 u32 match u32
>> 0 0 action mirred egress redirect dev eth0
>
> Ok. To fill in the blank there, I believe the qdisc will be attached =
to
> ifb0? Nobody cares about latency? You have > 20K packets being
> accumulated here ...
>

Yes, the qdisc is attached to ifb0.

There is a latency overhead (release packets only after checkpoint is c=
ommitted)
but that is an artifact of the checkpoint/output buffering principle it=
self.
Queuing delays at the qdisc, during buffer release are generally neglig=
ible.

The checkpoint intervals are very small (typically 30-50ms). Within
such a short execution
period, I don't expect the guest to generate 20K packets. It's an
extremely pathological case.

Also there is utmost one outstanding buffer to be released (not a
chain of buffers).
So there is no possibility of a large packet accumulation across
multiple output buffers.


> Also assuming that this is a setup thing that happens for every
> guest that needs checkpointing
>

Yep. Every guest has its own output buffer (and hence a dedicated ifb
and a qdisc).


>>
>> Oh yes. But throttle functionality doesnt seem to be implemented
>> in the qdisc code base. there is a throttle flag but looking at the
>> qdisc scheduler, I could see no references to this flag or related a=
ctions.
>> That is why in the dequeue function, I return NULL until the release=
 pointer
>> is set.
>
> Thats along the lines i was thinking of. If you could set the throttl=
e
> flag (more work involved than i am suggesting), then you solve the
> problem with any qdisc.
> Your qdisc is essentially a bfifo with throttling.

Not as simple as that. The throttle functionality you are talking
about is "throttle immediately".
The functionality I am talking about is "throttle at next incoming
packet" (i.e. continue dequeuing
existing packets in the queue.

There is a subtle difference between the two. I could implement the
(missing) throttle functionality
in the second version but that would be unintuitive to users, don't you=
 think ?


>
>> And we need a couple of netlink api calls (PLUG/UNPLUG) to manipulat=
e
>> the qdisc from userspace
>
> Right - needed to "set the throttle flag" part.
>
>> I have done better. When Remus is activated for a Guest VM, I pull t=
he
>> plug from the primary physical host and the ssh connection to the do=
mU,
>> with top command running (and/or xeyes) continues to run seamlessly.=
 ;)
>
> I dont think that kind of traffic will fill up your humongous queue.
> You need some bulk transfers going on filling the link bandwidth to s=
ee
> the futility of the queue.

Yes I know. I was just citing an example :).


>
>> When the guest VM recovers on another physical host, it is restored =
to the
>> most recent checkpoint. With a checkpoint frequency of 25ms, in the =
worst case
>> on failover, one checkpoint worth of execution could be lost.
>
> Out of curiosity: how much traffic do you end up generating for just
> checkpointing? Is this using a separate link?
>

Yes, the checkpoint traffic is on a separate link. The amount of
traffic is purely application
workload dependent. I have seen traffic ranges from 3Mbits/s to 80+ Mbi=
ts/s


> I am also a little lost: Are you going to plug/unplug every time you
> checkpoint? i.e we are going to have 2 netlink messages every 25ms
> for above?
>

Yes. That's the idea.


>> With the loss of
>> the physical machine and its output buffer, the packets (tcp,udp, et=
c)
>> are also lost.
>>
>> But that does not affect the "consistency" of the state of Guest and
>> client connections,
>> as the client (say TCP clients) only think that there was some packe=
t
>> loss and "resend"
>> the packets. The resuming Guest VM on the backup host would pickup t=
he
>> connection
>> from where it left off.
>
> Yes, this is what i was trying to get to. If you dont buffer,
> the end hosts will recover anyways. The value being no code
> changes needed. Not just that, I am pointing that buffering
> in itself is not very useful when the link is being used to its
> full capacity.
>
> [Sorry, I feel I am treading on questioning the utility of what
> you are doing but i cant help myself, it is just my nature to
> question;-> In a past life i may have been a relative of some ancient
> Greek philospher.]
>
>> OTOH, if the packets were released before the checkpoint was done,
>> then we have the
>> classic orphaned messages problem. If the client and the Guest VM
>> exchange a bunch of packets, the TCP window moves.
>> When the Guest VM resumes on the backup host,
>> it is basically rolled back in time (by 25ms or so), i.e. it does no=
t
>> know about the shift
>> in the tcp window. Hence, the client and Guest's tcp sequence number=
s
>> would be out of
>> sync and the connection would hang.
>
> So this part is interesting - but i wonder if the issue is not so
> much the window moved but some other bug or misfeature or i am missin=
g
> something. Shouldnt the sender just get an ACK with signifying the
> correct sequence number?

It does. But that seq number points to a value greater than the
senders seq number.


> Also, if you have access to the receivers(new
> guest) sequence number could you not "adjust it" based on the checkpo=
int
> messages?

Think about a client connection with a database server. Without
buffering, the server
acknowledges a transaction commit and then client performs more
operations. Now the
server fails and when it recovers on "another" machine, it has no
knowledge of the first transaction.
We could play tricks with the seq numbers at the server side but
what's the use? The client has
=A0already seen a non-existent state.

The sequence number fixing might work for some stateless services but
when you do something
completely transparent like Remus that considers the entire Guest as
one big opaque state
machine, these techniques will fail.


>
>> Which we dont want. I want to buffer the packets and then release th=
em
>> once the checkpoint is committed at the backup host.
>
> And whose value is still unclear to me.

The backup host always knows about ever output the primary has sent or
intends to send.

Consider the database example above. With this qdisc, the server's
transaction commit
acknowledgment message will still be in the primary host's output
buffer. If the primary host crashes,
the backup host will resume VM execution from the last checkpoint
(consistent with respect to disk,
memory, network state).

If this last checkpoint does not even have a "commit txn" req from the
client, the client would resend
the req(tcp retransmit), server commits & acks. The disk state is "cons=
istent".

If the last checkpoint does indicate that server has sent commit txn
ack, then when the client resends
the "commit txn", the tcp stack recognizes the packet as a duplicate
packet, resends the packet
containing the "commit ack".

In both cases, server and client are in consistent state.


>
>> One could do this with any qdisc but the catch here is that the qdis=
c
>> stops releasing packets only when it hits the stop pointer (ie start=
 of
>> the next checkpoint buffer). Simply putting a qdisc to sleep would
>> prevent it from releasing packets from the current buffer (whose che=
ckpoint
>> has been acked).
>
> I meant putting it to sleep when you plug and waking it when you
> unplug. By sleep i meant blackholing for the checkpointing +
> recovery period. I understand that dropping is not what you want to
> achieve because you see value in buffering.
>
>> I agree. Its more sensible to configure it via the tc command. I wou=
ld
>> probably have to end up issuing patches for the tc code base too.
>
> I think you MUST do this. We dont believe in hardcoding anything. You
> are playing in policy management territory. Let the control side worr=
y
> about policies. Ex: I think if you knew the bandwidth of the link and
> the checkpointing frequency, you could come up with a reasonable buff=
er
> size.
>
>>> Look at the other feedback given to you (Stephen and Dave responded=
).
>>>
>>> If a qdisc is needed, should it not be a classful qdisc?
>>>
>>
>> I dont understand. why ?
>
> I was coming from the same reasoning i used earlier, i.e
> this sounds like a generic problem.
> You are treading into policy management and deciding what is best
> for the guest user. We have an infrastructure that allows the admin
> to setup policies based on traffic characteristics. You are limiting
> this feature to be only used by folks who have no choice but to use
> your qdisc. I cant isolate latency sensitive traffic like an slogin
> sitting behind 20K scp packets etc. If you make it classful, that
> isolation can be added etc. Not sure if i made sense.
>
> Alternatively, this seems to me like a bfifo qdisc that needs to have
> throttle support that can be controlled from user space.
>
> cheers,
> jamal
>
>
>

cheers
Shriram
