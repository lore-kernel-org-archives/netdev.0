From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] net/sched: sch_plug - Queue traffic until an explicit
 release command
Date: Wed, 21 Dec 2011 09:54:21 -0500
Message-ID: <1324479261.18038.109.camel@mojatatu>
References: <1324329752-28459-1-git-send-email-rshriram@cs.ubc.ca>
	 <1324391902.17751.227.camel@mojatatu>
	 <CAP8mzPNmqPjmYZHT5d21D1yjz293wF+EF0BwoMAu+M=7VtHHSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Brendan Cully <brendan@cs.ubc.ca>
To: rshriram@cs.ubc.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:38864 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225Ab1LUOy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 09:54:26 -0500
Received: by vcbfk14 with SMTP id fk14so5791485vcb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 06:54:26 -0800 (PST)
In-Reply-To: <CAP8mzPNmqPjmYZHT5d21D1yjz293wF+EF0BwoMAu+M=7VtHHSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-12-20 at 11:05 -0600, Shriram Rajagopalan wrote:

> In dom0. Basically the setup is like this:
>  Guest (veth0)
>  dom0 (vif0.0 --> eth0)
> 
>    packets coming out of veth0 appear as incoming packets in vif0.0
>  Once Remus (or any other output commit style system is started)
>  the following commands could be executed in dom0, to activate this qdisc
>  ip link set ifb0 up
>  tc qdisc add dev vif0.0 ingress
>  tc filter add dev vif0.0 parent ffff: proto ip pref 10 u32 match u32
> 0 0 action mirred egress redirect dev eth0

Ok. To fill in the blank there, I believe the qdisc will be attached to
ifb0? Nobody cares about latency? You have > 20K packets being
accumulated here ...

Also assuming that this is a setup thing that happens for every 
guest that needs checkpointing 

> 
> Oh yes. But throttle functionality doesnt seem to be implemented
> in the qdisc code base. there is a throttle flag but looking at the
> qdisc scheduler, I could see no references to this flag or related actions.
> That is why in the dequeue function, I return NULL until the release pointer
> is set.

Thats along the lines i was thinking of. If you could set the throttle
flag (more work involved than i am suggesting), then you solve the
problem with any qdisc.
Your qdisc is essentially a bfifo with throttling.
 
> And we need a couple of netlink api calls (PLUG/UNPLUG) to manipulate
> the qdisc from userspace

Right - needed to "set the throttle flag" part.

> I have done better. When Remus is activated for a Guest VM, I pull the
> plug from the primary physical host and the ssh connection to the domU,
> with top command running (and/or xeyes) continues to run seamlessly. ;)

I dont think that kind of traffic will fill up your humongous queue.
You need some bulk transfers going on filling the link bandwidth to see
the futility of the queue.

> When the guest VM recovers on another physical host, it is restored to the
> most recent checkpoint. With a checkpoint frequency of 25ms, in the worst case
> on failover, one checkpoint worth of execution could be lost.

Out of curiosity: how much traffic do you end up generating for just
checkpointing? Is this using a separate link?

I am also a little lost: Are you going to plug/unplug every time you
checkpoint? i.e we are going to have 2 netlink messages every 25ms
for above?

>  With the loss of
> the physical machine and its output buffer, the packets (tcp,udp, etc)
> are also lost.
> 
> But that does not affect the "consistency" of the state of Guest and
> client connections,
> as the client (say TCP clients) only think that there was some packet
> loss and "resend"
> the packets. The resuming Guest VM on the backup host would pickup the
> connection
> from where it left off.

Yes, this is what i was trying to get to. If you dont buffer,
the end hosts will recover anyways. The value being no code
changes needed. Not just that, I am pointing that buffering
in itself is not very useful when the link is being used to its
full capacity. 

[Sorry, I feel I am treading on questioning the utility of what
you are doing but i cant help myself, it is just my nature to 
question;-> In a past life i may have been a relative of some ancient
Greek philospher.]

> OTOH, if the packets were released before the checkpoint was done,
> then we have the
> classic orphaned messages problem. If the client and the Guest VM
> exchange a bunch of packets, the TCP window moves. 
> When the Guest VM resumes on the backup host,
> it is basically rolled back in time (by 25ms or so), i.e. it does not
> know about the shift
> in the tcp window. Hence, the client and Guest's tcp sequence numbers
> would be out of
> sync and the connection would hang. 

So this part is interesting - but i wonder if the issue is not so
much the window moved but some other bug or misfeature or i am missing
something. Shouldnt the sender just get an ACK with signifying the
correct sequence number? Also, if you have access to the receivers(new
guest) sequence number could you not "adjust it" based on the checkpoint
messages?

> Which we dont want. I want to buffer the packets and then release them
> once the checkpoint is committed at the backup host.

And whose value is still unclear to me.

> One could do this with any qdisc but the catch here is that the qdisc
> stops releasing packets only when it hits the stop pointer (ie start of
> the next checkpoint buffer). Simply putting a qdisc to sleep would
> prevent it from releasing packets from the current buffer (whose checkpoint
> has been acked).

I meant putting it to sleep when you plug and waking it when you
unplug. By sleep i meant blackholing for the checkpointing + 
recovery period. I understand that dropping is not what you want to
achieve because you see value in buffering.

> I agree. Its more sensible to configure it via the tc command. I would
> probably have to end up issuing patches for the tc code base too.

I think you MUST do this. We dont believe in hardcoding anything. You 
are playing in policy management territory. Let the control side worry
about policies. Ex: I think if you knew the bandwidth of the link and
the checkpointing frequency, you could come up with a reasonable buffer
size.

> > Look at the other feedback given to you (Stephen and Dave responded).
> >
> > If a qdisc is needed, should it not be a classful qdisc?
> >
> 
> I dont understand. why ?

I was coming from the same reasoning i used earlier, i.e
this sounds like a generic problem.
You are treading into policy management and deciding what is best
for the guest user. We have an infrastructure that allows the admin 
to setup policies based on traffic characteristics. You are limiting
this feature to be only used by folks who have no choice but to use
your qdisc. I cant isolate latency sensitive traffic like an slogin
sitting behind 20K scp packets etc. If you make it classful, that
isolation can be added etc. Not sure if i made sense.

Alternatively, this seems to me like a bfifo qdisc that needs to have
throttle support that can be controlled from user space.

cheers,
jamal
